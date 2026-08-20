use std::collections::HashMap;

use axum::{
    body::Body,
    extract::{Path, Query, State},
    http::{header, Response},
    Json,
};
use base64::{engine::general_purpose::STANDARD as BASE64, Engine as _};
use chrono::{Datelike, NaiveDate, NaiveDateTime};
use rand::Rng;
use serde::Deserialize;

use crate::{
    auth_extractor::AuthUser,
    error::{AppError, AppResult},
    paging::{PageParams, PageResponse},
    report_pdf::{MethodInfo, MethodResult, ReportData, StudentReport},
    state::AppState,
};

#[derive(Debug, Clone)]
struct AssignmentContext {
    assignment_id: i64,
    school_id: i64,
    school_name: String,
    official_email: String,
    package_name: String,
    method_keys: Vec<String>,
    pic_emails: Vec<(String, String)>,
}

#[derive(Debug, Clone)]
struct StudentRow {
    auth_user_id: String,
    name: String,
    date_of_birth: Option<NaiveDate>,
    gender: Option<String>,
}

#[derive(Debug, Deserialize)]
pub struct HistoryParams {
    #[serde(flatten)]
    pub page: PageParams,
}

pub async fn preview(
    State(state): State<AppState>,
    auth: AuthUser,
    Path(assignment_id): Path<i64>,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["PSIKOLOG", "SUPERADMIN"])?;
    let (context, students) = load_report_data(&state, assignment_id).await?;
    let incomplete = students
        .iter()
        .filter(|student| student.results.iter().any(|result| !result.completed))
        .count();
    Ok(Json(serde_json::json!({
        "assignmentId": context.assignment_id,
        "schoolId": context.school_id,
        "schoolName": context.school_name,
        "officialEmail": context.official_email,
        "picRecipients": context.pic_emails.iter().map(|(name, email)| serde_json::json!({"name": name, "email": email})).collect::<Vec<_>>(),
        "packageName": context.package_name,
        "methods": method_infos(&context.method_keys).iter().map(|method| serde_json::json!({"key": method.key, "label": method.label})).collect::<Vec<_>>(),
        "studentCount": students.len(),
        "incompleteStudentCount": incomplete,
        "students": students.iter().map(|student| serde_json::json!({
            "name": student.name,
            "complete": student.results.iter().all(|result| result.completed),
            "results": student.results.iter().map(|result| serde_json::json!({
                "key": result.key, "label": result.label, "summary": result.summary, "completed": result.completed
            })).collect::<Vec<_>>()
        })).collect::<Vec<_>>()
    })))
}

pub async fn send(
    State(state): State<AppState>,
    auth: AuthUser,
    Path(assignment_id): Path<i64>,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["PSIKOLOG", "SUPERADMIN"])?;
    let (context, students) = load_report_data(&state, assignment_id).await?;
    if students.is_empty() {
        return Err(AppError::BadRequest(
            "Belum ada siswa pada sekolah ini".to_string(),
        ));
    }

    let now = chrono::Local::now().naive_local();
    let report_no = format!(
        "LAP-PSI-{}-{:04}{:02}{:02}-{}",
        assignment_id,
        now.year(),
        now.month(),
        now.day(),
        &uuid::Uuid::new_v4().simple().to_string()[..6].to_uppercase()
    );
    let password = random_password(12);
    let methods = method_infos(&context.method_keys);
    let incomplete_count = students
        .iter()
        .filter(|student| student.results.iter().any(|result| !result.completed))
        .count();
    let report = ReportData {
        report_no: report_no.clone(),
        school_name: context.school_name.clone(),
        official_email: context.official_email.clone(),
        package_name: context.package_name.clone(),
        generated_date: indonesian_date(now),
        methods,
        students,
    };
    let pdf = crate::report_pdf::build_assessment_report(&report, &password)
        .map_err(AppError::Internal)?;
    let filename = format!("{}-{}.pdf", report_no, safe_filename(&context.school_name));
    let subject = format!("Laporan Hasil Asesmen Psikologi - {}", context.school_name);
    let pic_email_values: Vec<String> = context
        .pic_emails
        .iter()
        .map(|(_, email)| email.clone())
        .collect();

    let delivery_id: i64 = sqlx::query_scalar(
        "INSERT INTO assessment_report_deliveries \
         (report_no, assignment_id, school_id, created_by, official_email, pic_emails, subject, pdf_filename, pdf_data, method_keys, student_count, incomplete_student_count, status, created_at) \
         VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,'preparing',NOW()) RETURNING id",
    )
    .bind(&report_no)
    .bind(assignment_id)
    .bind(context.school_id)
    .bind(&auth.user_id)
    .bind(&context.official_email)
    .bind(&pic_email_values)
    .bind(&subject)
    .bind(&filename)
    .bind(&pdf)
    .bind(&context.method_keys)
    .bind(report.students.len() as i32)
    .bind(incomplete_count as i32)
    .fetch_one(&state.pool)
    .await
    .map_err(|e| AppError::from_sqlx("insert_report_delivery", e))?;

    let html = email_html(
        &context,
        &report_no,
        report.students.len(),
        incomplete_count,
        &password,
    );
    let payload = serde_json::json!({
        "to": context.official_email,
        "name": context.school_name,
        "cc": context.pic_emails.iter().map(|(name, email)| serde_json::json!({"name": name, "email": email})).collect::<Vec<_>>(),
        "subject": subject,
        "html": html,
        "campaign": "assessment-school-report",
        "attachments": [{ "name": filename, "content": BASE64.encode(&pdf) }]
    });
    let response = state
        .http
        .post(format!("{}/send", state.config.email_manager_url))
        .json(&payload)
        .send()
        .await;
    let response = match response {
        Ok(response) => response,
        Err(error) => {
            mark_failed(&state, delivery_id, &error.to_string()).await;
            return Err(AppError::Internal(error.into()));
        }
    };
    if !response.status().is_success() {
        let status = response.status();
        let body = response.text().await.unwrap_or_default();
        let message = format!("email-manager rejected report: {status} {body}");
        mark_failed(&state, delivery_id, &message).await;
        return Err(AppError::Internal(anyhow::anyhow!(message)));
    }
    let email_response: serde_json::Value = response.json().await?;
    let message_id = email_response
        .get("id")
        .and_then(|value| value.as_str())
        .ok_or_else(|| AppError::Internal(anyhow::anyhow!("email-manager response omitted id")))?;
    sqlx::query(
        "UPDATE assessment_report_deliveries SET email_message_id = $2, status = 'queued' WHERE id = $1",
    )
    .bind(delivery_id)
    .bind(message_id)
    .execute(&state.pool)
    .await
    .map_err(|e| AppError::from_sqlx("queue_report_delivery", e))?;

    Ok(Json(serde_json::json!({
        "id": delivery_id,
        "reportNo": report_no,
        "status": "queued",
        "filename": filename,
        "studentCount": report.students.len(),
        "incompleteStudentCount": incomplete_count,
        "officialEmail": context.official_email,
        "picEmails": pic_email_values,
    })))
}

pub async fn history(
    State(state): State<AppState>,
    auth: AuthUser,
    Query(params): Query<HistoryParams>,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["PSIKOLOG", "SUPERADMIN"])?;
    refresh_pending_statuses(&state).await;
    let size = params.page.size_clamped();
    let offset = params.page.offset();
    let search = params.page.search_like();
    let has_search = params.page.has_search();
    let where_sql = if has_search {
        " WHERE LOWER(d.report_no) LIKE $1 OR LOWER(s.name) LIKE $1 OR LOWER(d.official_email) LIKE $1 OR LOWER(d.subject) LIKE $1 OR EXISTS (SELECT 1 FROM unnest(d.pic_emails) p WHERE LOWER(p) LIKE $1)"
    } else {
        ""
    };
    let count_sql = format!(
        "SELECT COUNT(*) FROM assessment_report_deliveries d JOIN schools s ON s.id=d.school_id{where_sql}"
    );
    let total: i64 = if has_search {
        sqlx::query_scalar(&count_sql)
            .bind(&search)
            .fetch_one(&state.pool)
            .await?
    } else {
        sqlx::query_scalar(&count_sql)
            .fetch_one(&state.pool)
            .await?
    };
    let (limit_idx, offset_idx) = if has_search { (2, 3) } else { (1, 2) };
    let query = format!(
        "SELECT d.id,d.report_no,d.assignment_id,s.name,d.created_by,d.official_email,d.pic_emails,d.subject,d.pdf_filename,d.method_keys,d.student_count,d.incomplete_student_count,d.status,d.error,d.created_at,d.sent_at \
         FROM assessment_report_deliveries d JOIN schools s ON s.id=d.school_id{where_sql} \
         ORDER BY d.created_at DESC LIMIT ${limit_idx} OFFSET ${offset_idx}"
    );
    type Row = (
        i64,
        String,
        i64,
        String,
        String,
        String,
        Vec<String>,
        String,
        String,
        Vec<String>,
        i32,
        i32,
        String,
        Option<String>,
        NaiveDateTime,
        Option<NaiveDateTime>,
    );
    let rows: Vec<Row> = if has_search {
        sqlx::query_as(&query)
            .bind(&search)
            .bind(size)
            .bind(offset)
            .fetch_all(&state.pool)
            .await?
    } else {
        sqlx::query_as(&query)
            .bind(size)
            .bind(offset)
            .fetch_all(&state.pool)
            .await?
    };
    let items = rows
        .into_iter()
        .map(|row| {
            serde_json::json!({
                "id": row.0, "reportNo": row.1, "assignmentId": row.2, "schoolName": row.3,
                "createdBy": row.4, "officialEmail": row.5, "picEmails": row.6, "subject": row.7,
                "pdfFilename": row.8, "methodKeys": row.9, "studentCount": row.10,
                "incompleteStudentCount": row.11, "status": row.12, "error": row.13,
                "createdAt": crate::datetime::java_local_date_time(row.14),
                "sentAt": row.15.map(crate::datetime::java_local_date_time),
            })
        })
        .collect::<Vec<_>>();
    Ok(Json(
        serde_json::to_value(PageResponse::new(
            items,
            params.page.page_or_zero(),
            size,
            total,
        ))
        .unwrap(),
    ))
}

pub async fn download(
    State(state): State<AppState>,
    auth: AuthUser,
    Path(id): Path<i64>,
) -> AppResult<Response<Body>> {
    auth.require_role(&["PSIKOLOG", "SUPERADMIN"])?;
    let row: Option<(String, Vec<u8>)> = sqlx::query_as(
        "SELECT pdf_filename,pdf_data FROM assessment_report_deliveries WHERE id=$1",
    )
    .bind(id)
    .fetch_optional(&state.pool)
    .await?;
    let (filename, bytes) =
        row.ok_or_else(|| AppError::NotFound("Riwayat laporan tidak ditemukan".to_string()))?;
    Response::builder()
        .header(header::CONTENT_TYPE, "application/pdf")
        .header(
            header::CONTENT_DISPOSITION,
            format!("attachment; filename=\"{}\"", safe_filename(&filename)),
        )
        .header(header::CACHE_CONTROL, "private, no-store")
        .body(Body::from(bytes))
        .map_err(|error| AppError::Internal(error.into()))
}

async fn load_report_data(
    state: &AppState,
    assignment_id: i64,
) -> AppResult<(AssignmentContext, Vec<StudentReport>)> {
    let assignment: Option<(i64, String, Option<String>, String, Vec<String>)> = sqlx::query_as(
        "SELECT s.id,s.name,s.email,tc.name,tc.tests FROM test_assignments ta \
         JOIN schools s ON s.id=ta.school_id JOIN test_categories tc ON tc.id=ta.category_id WHERE ta.id=$1",
    )
    .bind(assignment_id)
    .fetch_optional(&state.pool)
    .await?;
    let (school_id, school_name, official_email, package_name, method_keys) = assignment
        .ok_or_else(|| AppError::NotFound("Penugasan sekolah tidak ditemukan".to_string()))?;
    let official_email = official_email
        .filter(|email| !email.trim().is_empty())
        .ok_or_else(|| AppError::BadRequest("Email resmi sekolah belum diisi".to_string()))?;
    let pic_emails: Vec<(String, String)> = sqlx::query_as(
        "SELECT u.name,u.email FROM school_pics sp JOIN assessment_users u ON u.auth_user_id=sp.auth_user_id \
         WHERE sp.school_id=$1 ORDER BY sp.is_primary DESC,LOWER(u.name)",
    )
    .bind(school_id)
    .fetch_all(&state.pool)
    .await?;
    if pic_emails.is_empty() {
        return Err(AppError::BadRequest(
            "Sekolah belum memiliki PIC yang mempunyai akun".to_string(),
        ));
    }
    let student_rows: Vec<StudentRow> =
        sqlx::query_as::<_, (String, String, Option<NaiveDate>, Option<String>)>(
            "SELECT u.auth_user_id,u.name,sp.date_of_birth,sp.gender FROM assessment_users u \
         LEFT JOIN student_profiles sp ON sp.auth_user_id=u.auth_user_id \
         WHERE u.school_id=$1 AND u.role='siswa' ORDER BY LOWER(u.name)",
        )
        .bind(school_id)
        .fetch_all(&state.pool)
        .await?
        .into_iter()
        .map(|row| StudentRow {
            auth_user_id: row.0,
            name: row.1,
            date_of_birth: row.2,
            gender: row.3,
        })
        .collect();
    let result_maps = load_method_results(state, assignment_id, &method_keys).await?;
    let labels: HashMap<String, String> = method_infos(&method_keys)
        .into_iter()
        .map(|method| (method.key, method.label))
        .collect();
    let students = student_rows
        .into_iter()
        .map(|student| {
            let results = method_keys
                .iter()
                .map(|key| {
                    result_maps
                        .get(key)
                        .and_then(|map| map.get(&student.auth_user_id))
                        .cloned()
                        .unwrap_or_else(|| MethodResult {
                            key: key.clone(),
                            label: labels
                                .get(key)
                                .cloned()
                                .unwrap_or_else(|| key.to_uppercase()),
                            summary: "Belum dikerjakan".to_string(),
                            detail: "Hasil belum tersedia.".to_string(),
                            rating: None,
                            completed: false,
                        })
                })
                .collect();
            StudentReport {
                name: student.name,
                date_of_birth: student
                    .date_of_birth
                    .map(|date| date.format("%d-%m-%Y").to_string()),
                gender: student.gender.map(|gender| display_gender(&gender)),
                results,
            }
        })
        .collect();
    Ok((
        AssignmentContext {
            assignment_id,
            school_id,
            school_name,
            official_email,
            package_name,
            method_keys,
            pic_emails,
        },
        students,
    ))
}

async fn load_method_results(
    state: &AppState,
    assignment_id: i64,
    method_keys: &[String],
) -> AppResult<HashMap<String, HashMap<String, MethodResult>>> {
    let mut all = HashMap::new();
    for key in method_keys {
        let label = method_label(key);
        let map = match key.as_str() {
            "disc" => {
                let rows: Vec<(String,Option<String>,Option<String>,Option<String>)> = sqlx::query_as(
                    "SELECT auth_user_id,profile_title,dif_key,COALESCE(profile_desc,dif_profile_traits) FROM disc_results WHERE assignment_id=$1",
                ).bind(assignment_id).fetch_all(&state.pool).await?;
                rows.into_iter()
                    .map(|row| {
                        let summary = row
                            .1
                            .or(row.2)
                            .unwrap_or_else(|| "Profil DISC tersedia".to_string());
                        (
                            row.0,
                            completed_result(
                                key,
                                label,
                                summary.clone(),
                                row.3.unwrap_or(summary),
                                None,
                            ),
                        )
                    })
                    .collect()
            }
            "holland" => {
                let rows: Vec<(String,Option<String>,Option<String>,Option<String>,Option<String>,Option<String>)> = sqlx::query_as(
                    "SELECT auth_user_id,holland_code,type1_name,type2_name,type1_strengths,type1_weaknesses FROM holland_results WHERE assignment_id=$1",
                ).bind(assignment_id).fetch_all(&state.pool).await?;
                rows.into_iter()
                    .map(|row| {
                        let code = row.1.unwrap_or_else(|| "-".to_string());
                        let types = [row.2, row.3]
                            .into_iter()
                            .flatten()
                            .collect::<Vec<_>>()
                            .join(" dan ");
                        let summary = format!(
                            "Kode {}{}",
                            code,
                            if types.is_empty() {
                                String::new()
                            } else {
                                format!(" - {types}")
                            }
                        );
                        let detail = format!(
                            "{}. Area kekuatan: {}. Area pengembangan: {}.",
                            summary,
                            row.4.unwrap_or_else(|| "perlu dibahas".into()),
                            row.5.unwrap_or_else(|| "perlu dibahas".into())
                        );
                        (row.0, completed_result(key, label, summary, detail, None))
                    })
                    .collect()
            }
            "papi" => {
                let rows: Vec<(String,Option<String>)> = sqlx::query_as(
                    "SELECT auth_user_id,trait_scores::text FROM papi_results WHERE assignment_id=$1",
                ).bind(assignment_id).fetch_all(&state.pool).await?;
                rows.into_iter()
                    .map(|row| {
                        let scores = top_json_scores(row.1.as_deref().unwrap_or("{}"), 3);
                        let summary = if scores.is_empty() {
                            "Profil kerja tersedia".into()
                        } else {
                            format!("Aspek menonjol: {}", scores.join(", "))
                        };
                        (
                            row.0,
                            completed_result(key, label, summary.clone(), summary, None),
                        )
                    })
                    .collect()
            }
            "cfit" => {
                let rows: Vec<(String,i32,Option<String>,Option<String>)> = sqlx::query_as(
                    "SELECT auth_user_id,iq_score,category,description FROM cfit_results WHERE assignment_id=$1",
                ).bind(assignment_id).fetch_all(&state.pool).await?;
                rows.into_iter()
                    .map(|row| {
                        let summary = format!(
                            "IQ {} - {}",
                            row.1,
                            row.2
                                .clone()
                                .unwrap_or_else(|| "kategori belum tersedia".into())
                        );
                        (
                            row.0,
                            completed_result(
                                key,
                                label,
                                summary.clone(),
                                row.3.unwrap_or(summary),
                                Some(iq_rating(row.1)),
                            ),
                        )
                    })
                    .collect()
            }
            "ist" => {
                let rows: Vec<(String,i32,Option<String>,Option<String>)> = sqlx::query_as(
                    "SELECT auth_user_id,iq_score,iq_category,subtest_scores::text FROM ist_results WHERE assignment_id=$1",
                ).bind(assignment_id).fetch_all(&state.pool).await?;
                rows.into_iter()
                    .map(|row| {
                        let summary = format!(
                            "IQ {} - {}",
                            row.1,
                            row.2
                                .clone()
                                .unwrap_or_else(|| "kategori belum tersedia".into())
                        );
                        let subtests = top_json_scores(row.3.as_deref().unwrap_or("{}"), 3);
                        let detail = if subtests.is_empty() {
                            summary.clone()
                        } else {
                            format!("{}. Subtes menonjol: {}.", summary, subtests.join(", "))
                        };
                        (
                            row.0,
                            completed_result(key, label, summary, detail, Some(iq_rating(row.1))),
                        )
                    })
                    .collect()
            }
            "epps" => {
                let rows: Vec<(String,String,i32)> = sqlx::query_as(
                    "SELECT auth_user_id,trait_scores::text,consistency_raw FROM epps_results WHERE assignment_id=$1",
                ).bind(assignment_id).fetch_all(&state.pool).await?;
                rows.into_iter()
                    .map(|row| {
                        let scores = top_json_scores(&row.1, 3);
                        let summary = format!(
                            "Kebutuhan menonjol: {}",
                            if scores.is_empty() {
                                "profil tersedia".into()
                            } else {
                                scores.join(", ")
                            }
                        );
                        let detail = format!("{}. Konsistensi jawaban {}/15.", summary, row.2);
                        (row.0, completed_result(key, label, summary, detail, None))
                    })
                    .collect()
            }
            _ => HashMap::new(),
        };
        all.insert(key.clone(), map);
    }
    Ok(all)
}

fn completed_result(
    key: &str,
    label: &str,
    summary: String,
    detail: String,
    rating: Option<u8>,
) -> MethodResult {
    MethodResult {
        key: key.to_string(),
        label: label.to_string(),
        summary,
        detail,
        rating,
        completed: true,
    }
}

fn method_infos(keys: &[String]) -> Vec<MethodInfo> {
    keys.iter().map(|key| {
        let (label, academic, benefit, reference) = match key.as_str() {
            "disc" => ("DISC", "DISC memetakan kecenderungan perilaku yang biasa diringkas sebagai Dominance, Influence, Steadiness, dan Conscientiousness. Instrumen ini menggambarkan gaya respons dan komunikasi, bukan diagnosis klinis atau ukuran kemampuan.", "Membantu siswa dan pendamping mengenali cara berkomunikasi, merespons tuntutan, bekerja sama, dan menyesuaikan pendekatan pengembangan.", "Wiley, Everything DiSC Research Report: Scales, Reliability, and Validation."),
            "holland" => ("Holland RIASEC", "Model RIASEC John L. Holland mengelompokkan minat vokasional dalam enam lingkungan: Realistic, Investigative, Artistic, Social, Enterprising, dan Conventional. Kode teratas menunjukkan pola minat, bukan tingkat kecerdasan atau kepastian karier.", "Mendukung eksplorasi jurusan, aktivitas belajar, dan lingkungan kerja yang lebih selaras dengan minat siswa, untuk kemudian dibahas bersama data akademik dan pengalaman nyata.", "Holland (1997); Rounds, Hoff & Lewis, O*NET Interest Profiler Manual (2021)."),
            "papi" => ("PAPI Kostick", "PAPI adalah inventori kepribadian terkait pekerjaan yang memotret kebutuhan dan kecenderungan peran dalam konteks organisasi. Profilnya bersifat kontekstual dan perlu dibaca sebagai pola, bukan label baik atau buruk.", "Membantu memahami preferensi kerja, kepemimpinan, relasi, ritme aktivitas, pengambilan keputusan, dan area pengembangan dalam situasi belajar maupun organisasi.", "Talogy, Personality and Preference Inventory (PAPI), product documentation."),
            "cfit" => ("CFIT", "Culture Fair Intelligence Test dirancang untuk mengurangi ketergantungan pada bahasa dan pengetahuan sekolah saat memperkirakan kemampuan penalaran umum atau fluid reasoning. Istilah culture-fair tidak berarti sepenuhnya bebas pengaruh budaya.", "Memberikan salah satu indikator potensi penalaran nonverbal untuk perencanaan belajar. Interpretasi tetap perlu mempertimbangkan kondisi pengerjaan, pendidikan, bahasa, dan data lain.", "Cattell & Cattell, Culture Fair Intelligence Test manual; Pearson Assessments."),
            "ist" => ("IST", "Intelligenz-Struktur-Test menilai struktur kemampuan kognitif melalui beberapa subtes verbal, numerik, figural, dan memori. Skor total perlu dibaca bersama pola antarsubtes dan norma yang sesuai.", "Membantu mengenali kekuatan relatif dan kebutuhan dukungan pada cara mengolah informasi, sehingga strategi belajar dapat disusun lebih spesifik.", "Beauducel, Liepmann, Horn & Brocke, Intelligence Structure Test; Hogrefe."),
            "epps" => ("EPPS", "Edwards Personal Preference Schedule berangkat dari teori kebutuhan Murray dan menggunakan format pilihan paksa untuk menggambarkan kebutuhan psikologis relatif di dalam diri individu. Skor bersifat ipsatif sehingga tidak tepat dipakai sebagai peringkat antarsiswa.", "Mendukung percakapan mengenai motif, kebutuhan relasional, dorongan berprestasi, kemandirian, ketekunan, dan pola pribadi lain yang relevan bagi pengembangan.", "Edwards, A. L. (1959), Manual for the Edwards Personal Preference Schedule."),
            _ => ("Metode asesmen", "Metode ini merupakan bagian dari paket asesmen yang dipilih sekolah.", "Hasil digunakan sebagai bahan diskusi pengembangan bersama tenaga profesional.", "Manual teknis metode yang digunakan."),
        };
        MethodInfo { key: key.clone(), label: label.into(), academic_description: academic.into(), benefit: benefit.into(), reference: reference.into() }
    }).collect()
}

fn method_label(key: &str) -> &'static str {
    match key {
        "disc" => "DISC",
        "holland" => "Holland RIASEC",
        "papi" => "PAPI Kostick",
        "cfit" => "CFIT",
        "ist" => "IST",
        "epps" => "EPPS",
        _ => "Asesmen",
    }
}

fn top_json_scores(raw: &str, limit: usize) -> Vec<String> {
    let value = serde_json::from_str::<serde_json::Value>(raw).unwrap_or_default();
    if let Some(items) = value.as_array() {
        let mut scores = items
            .iter()
            .filter_map(|item| {
                let object = item.as_object()?;
                let code = object
                    .get("code")
                    .and_then(serde_json::Value::as_str)
                    .or_else(|| object.get("label").and_then(serde_json::Value::as_str))?;
                let score = object
                    .get("percentile")
                    .and_then(serde_json::Value::as_i64)
                    .or_else(|| object.get("raw").and_then(serde_json::Value::as_i64))?;
                Some((code.to_string(), score))
            })
            .collect::<Vec<_>>();
        scores.sort_by(|left, right| right.1.cmp(&left.1).then_with(|| left.0.cmp(&right.0)));
        return scores
            .into_iter()
            .take(limit)
            .map(|(key, score)| format!("{} {}", key.to_uppercase(), score))
            .collect();
    }
    let mut scores = value
        .as_object()
        .map(|object| {
            object
                .iter()
                .filter_map(|(key, value)| {
                    value
                        .as_i64()
                        .or_else(|| value.as_f64().map(|number| number.round() as i64))
                        .map(|score| (key.clone(), score))
                })
                .collect::<Vec<_>>()
        })
        .unwrap_or_default();
    scores.sort_by(|left, right| right.1.cmp(&left.1).then_with(|| left.0.cmp(&right.0)));
    scores
        .into_iter()
        .take(limit)
        .map(|(key, score)| format!("{} {}", key.to_uppercase(), score))
        .collect()
}

fn iq_rating(iq: i32) -> u8 {
    match iq {
        ..=79 => 1,
        80..=89 => 2,
        90..=109 => 3,
        110..=119 => 4,
        _ => 5,
    }
}

fn random_password(length: usize) -> String {
    const CHARS: &[u8] = b"ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789";
    let mut rng = rand::thread_rng();
    (0..length)
        .map(|_| CHARS[rng.gen_range(0..CHARS.len())] as char)
        .collect()
}

fn safe_filename(value: &str) -> String {
    let cleaned: String = value
        .chars()
        .map(|character| {
            if character.is_ascii_alphanumeric() || matches!(character, '-' | '_' | '.') {
                character
            } else {
                '-'
            }
        })
        .collect();
    cleaned.trim_matches('-').to_string()
}

fn indonesian_date(value: NaiveDateTime) -> String {
    const MONTHS: [&str; 12] = [
        "Januari",
        "Februari",
        "Maret",
        "April",
        "Mei",
        "Juni",
        "Juli",
        "Agustus",
        "September",
        "Oktober",
        "November",
        "Desember",
    ];
    format!(
        "{} {} {}",
        value.day(),
        MONTHS[(value.month() - 1) as usize],
        value.year()
    )
}

fn display_gender(value: &str) -> String {
    match value.trim().to_ascii_uppercase().as_str() {
        "L" | "LAKI-LAKI" | "MALE" => "Laki-laki".into(),
        "P" | "PEREMPUAN" | "FEMALE" => "Perempuan".into(),
        _ => value.to_string(),
    }
}

fn email_html(
    context: &AssignmentContext,
    report_no: &str,
    students: usize,
    incomplete: usize,
    password: &str,
) -> String {
    format!(
        "<div style=\"font-family:Arial,sans-serif;color:#202027;line-height:1.6;max-width:680px\"><h2 style=\"color:#3d156b\">Laporan Hasil Asesmen Psikologi</h2><p>Yth. Pimpinan dan PIC {},</p><p>Terlampir laporan hasil asesmen psikologi untuk <strong>{}</strong> dengan nomor <strong>{}</strong>.</p><table style=\"border-collapse:collapse;width:100%;margin:20px 0\"><tr><td style=\"padding:8px;border:1px solid #ddd\">Jumlah siswa</td><td style=\"padding:8px;border:1px solid #ddd\"><strong>{}</strong></td></tr><tr><td style=\"padding:8px;border:1px solid #ddd\">Siswa dengan hasil belum lengkap</td><td style=\"padding:8px;border:1px solid #ddd\"><strong>{}</strong></td></tr></table><div style=\"background:#f3eef8;border-left:4px solid #6530a0;padding:14px 16px;margin:20px 0\"><strong>Password PDF:</strong> <span style=\"font-family:monospace;font-size:16px\">{}</span></div><p>Laporan parsial tetap dapat digunakan untuk peninjauan awal. Setiap hasil yang belum tersedia ditandai <strong>BELUM</strong> dan tidak boleh dianggap sebagai nilai nol.</p><p>Hormat kami,<br><strong>a.n. Dewi Handayani H, M.Psi, Psikolog</strong><br>SIPP: 20120111 - 2024 - 02 - 3622</p><p style=\"font-size:12px;color:#666;border-top:1px solid #ddd;padding-top:12px\">Dokumen ini bersifat rahasia dan hanya ditujukan bagi sekolah terkait.</p></div>",
        html_escape(&context.school_name),
        html_escape(&context.package_name),
        html_escape(report_no),
        students,
        incomplete,
        html_escape(password),
    )
}

fn html_escape(value: &str) -> String {
    value
        .replace('&', "&amp;")
        .replace('<', "&lt;")
        .replace('>', "&gt;")
        .replace('"', "&quot;")
        .replace('\'', "&#39;")
}

async fn mark_failed(state: &AppState, id: i64, error: &str) {
    let _ =
        sqlx::query("UPDATE assessment_report_deliveries SET status='failed',error=$2 WHERE id=$1")
            .bind(id)
            .bind(error.chars().take(1000).collect::<String>())
            .execute(&state.pool)
            .await;
}

async fn refresh_pending_statuses(state: &AppState) {
    let rows: Vec<(i64, String)> = sqlx::query_as(
        "SELECT id,email_message_id FROM assessment_report_deliveries WHERE status IN ('queued','sending') AND email_message_id IS NOT NULL ORDER BY created_at DESC LIMIT 25",
    ).fetch_all(&state.pool).await.unwrap_or_default();
    for (id, message_id) in rows {
        let response = state
            .http
            .get(format!(
                "{}/status/{}",
                state.config.email_manager_url, message_id
            ))
            .send()
            .await;
        let Ok(response) = response else { continue };
        if !response.status().is_success() {
            continue;
        }
        let Ok(value) = response.json::<serde_json::Value>().await else {
            continue;
        };
        let Some(status) = value.get("status").and_then(|status| status.as_str()) else {
            continue;
        };
        let error = value.get("error").and_then(|error| error.as_str());
        let sent = matches!(status, "sent" | "delivered");
        let _ = sqlx::query(
            "UPDATE assessment_report_deliveries SET status=$2,error=$3,sent_at=CASE WHEN $4 THEN COALESCE(sent_at,NOW()) ELSE sent_at END WHERE id=$1",
        ).bind(id).bind(status).bind(error).bind(sent).execute(&state.pool).await;
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn password_uses_unambiguous_characters() {
        let password = random_password(12);
        assert_eq!(password.len(), 12);
        assert!(!password.contains('0'));
        assert!(!password.contains('O'));
        assert!(!password.contains('l'));
    }

    #[test]
    fn only_selected_methods_get_explanations() {
        let methods = method_infos(&["holland".to_string(), "cfit".to_string()]);
        assert_eq!(methods.len(), 2);
        assert_eq!(methods[0].key, "holland");
        assert_eq!(methods[1].key, "cfit");
    }

    #[test]
    fn reads_top_epps_scores_from_array_payload() {
        let scores = top_json_scores(
            r#"[{"code":"ach","raw":12,"percentile":40},{"code":"ord","raw":18,"percentile":85}]"#,
            2,
        );
        assert_eq!(scores, vec!["ORD 85", "ACH 40"]);
    }
}
