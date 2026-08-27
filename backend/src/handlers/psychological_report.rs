use axum::{body::Body, extract::{Path, State}, http::{header, Response}, Json};
use chrono::Datelike;
use serde::Deserialize;
use sqlx::Row;

use crate::{auth_extractor::AuthUser, error::{AppError, AppResult}, report_pdf::{PsychologicalAspect, PsychologicalReport}, state::AppState};

const DEFAULT_RULES: &str = r#"{
  "note":"Konfigurasi ini menentukan narasi/rubrik resmi. Ubah dan simpan sebelum menerbitkan laporan.",
  "aspects":[
    {"key":"intellectual","label":"Kemampuan intelektual dan logika berpikir","definition":"Berdasarkan hasil IQ (CFIT atau IST).","sources":["CFIT/IST"]},
    {"key":"achievement","label":"Motivasi berprestasi","definition":"Berdasarkan PAPI Kostick N, G, A dan EPPS Achievement.","sources":["PAPI N/G/A","EPPS Achievement"]},
    {"key":"confidence","label":"Kepercayaan diri","definition":"Berdasarkan pola DISC, khususnya dominasi D dan kecenderungan C.","sources":["DISC D/C"]},
    {"key":"emotion","label":"Stabilitas emosi","definition":"Berdasarkan PAPI Kostick Z, E, K dan EPPS Endurance.","sources":["PAPI Z/E/K","EPPS Endurance"]},
    {"key":"adjustment","label":"Penyesuaian diri","definition":"Berdasarkan PAPI Kostick O, B, S, X dan EPPS Affiliation.","sources":["PAPI O/B/S/X","EPPS Affiliation"]}
  ],
  "holland":{"label":"Minat karier","definition":"Menggunakan dua tipe Holland RIASEC tertinggi."}
}"#;

#[derive(Deserialize)]
pub struct RuleInput { pub rules: serde_json::Value }

pub async fn rules(State(state): State<AppState>, auth: AuthUser) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SUPERADMIN"])?;
    let row = sqlx::query("SELECT version,rules,updated_at FROM psychological_report_rule_sets WHERE is_active=true ORDER BY version DESC LIMIT 1")
        .fetch_optional(&state.pool).await.map_err(|e| AppError::from_sqlx("report_rules", e))?;
    Ok(Json(if let Some(row) = row { serde_json::json!({"version":row.get::<i32,_>("version"),"rules":row.get::<serde_json::Value,_>("rules"),"updatedAt":row.get::<chrono::NaiveDateTime,_>("updated_at")}) } else { serde_json::json!({"version":0,"rules":serde_json::from_str::<serde_json::Value>(DEFAULT_RULES).unwrap(),"draft":true}) }))
}

pub async fn update_rules(State(state): State<AppState>, auth: AuthUser, Json(input): Json<RuleInput>) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SUPERADMIN"])?;
    if !input.rules.get("aspects").map(|x| x.is_array()).unwrap_or(false) { return Err(AppError::BadRequest("Rubrik harus memiliki daftar aspek".into())); }
    let mut tx = state.pool.begin().await.map_err(|e| AppError::from_sqlx("report_rules_tx", e))?;
    sqlx::query("UPDATE psychological_report_rule_sets SET is_active=false,updated_at=NOW() WHERE is_active=true").execute(&mut *tx).await.map_err(|e| AppError::from_sqlx("deactivate_report_rules", e))?;
    let version: i32 = sqlx::query_scalar("SELECT COALESCE(MAX(version),0)+1 FROM psychological_report_rule_sets").fetch_one(&mut *tx).await.map_err(|e| AppError::from_sqlx("next_report_rule_version", e))?;
    sqlx::query("INSERT INTO psychological_report_rule_sets(version,rules,is_active,created_by) VALUES($1,$2,true,$3)").bind(version).bind(&input.rules).bind(&auth.user_id).execute(&mut *tx).await.map_err(|e| AppError::from_sqlx("create_report_rules", e))?;
    tx.commit().await.map_err(|e| AppError::from_sqlx("commit_report_rules", e))?;
    Ok(Json(serde_json::json!({"version":version,"rules":input.rules})))
}

pub async fn mine(State(state): State<AppState>, auth: AuthUser) -> AppResult<Json<serde_json::Value>> {
    // A credential may be assigned directly to a student or to every student
    // in a school. Show a combined report only after the student has at least
    // one completed instrument in that particular assignment.
    let assignments = sqlx::query("SELECT ta.id, s.name FROM test_assignments ta JOIN schools s ON s.id=ta.school_id JOIN assessment_users u ON u.auth_user_id=$1 WHERE ta.is_active=true AND (ta.student_id=$1 OR ta.school_id=u.school_id) AND EXISTS (SELECT 1 FROM disc_results r WHERE r.auth_user_id=$1 AND r.assignment_id=ta.id UNION SELECT 1 FROM holland_results r WHERE r.auth_user_id=$1 AND r.assignment_id=ta.id UNION SELECT 1 FROM papi_results r WHERE r.auth_user_id=$1 AND r.assignment_id=ta.id UNION SELECT 1 FROM cfit_results r WHERE r.auth_user_id=$1 AND r.assignment_id=ta.id UNION SELECT 1 FROM ist_results r WHERE r.auth_user_id=$1 AND r.assignment_id=ta.id UNION SELECT 1 FROM epps_results r WHERE r.auth_user_id=$1 AND r.assignment_id=ta.id) ORDER BY ta.created_at DESC")
      .bind(&auth.user_id).fetch_all(&state.pool).await.map_err(|e| AppError::from_sqlx("my_report_assignments", e))?;
    let items = assignments.into_iter().map(|r| serde_json::json!({"assignmentId":r.get::<i64,_>("id"),"schoolName":r.get::<String,_>("name")})).collect::<Vec<_>>();
    Ok(Json(serde_json::json!({"items":items})))
}

pub async fn list(State(state): State<AppState>, auth: AuthUser) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SUPERADMIN", "PSIKOLOG", "GURUBK"])?;
    let participants = "WITH report_participants AS (SELECT assignment_id,auth_user_id FROM disc_results UNION SELECT assignment_id,auth_user_id FROM holland_results UNION SELECT assignment_id,auth_user_id FROM papi_results UNION SELECT assignment_id,auth_user_id FROM cfit_results UNION SELECT assignment_id,auth_user_id FROM ist_results UNION SELECT assignment_id,auth_user_id FROM epps_results) ";
    let rows = if auth.is_role("GURUBK") {
        sqlx::query(&(participants.to_owned()+"SELECT ta.id assignment_id,p.auth_user_id student_id,u.name student_name,s.name school_name FROM report_participants p JOIN test_assignments ta ON ta.id=p.assignment_id JOIN assessment_users u ON u.auth_user_id=p.auth_user_id JOIN schools s ON s.id=ta.school_id WHERE ta.is_active=true AND ta.school_id=(SELECT school_id FROM assessment_users WHERE auth_user_id=$1) ORDER BY ta.created_at DESC")).bind(&auth.user_id).fetch_all(&state.pool).await
    } else { sqlx::query(&(participants.to_owned()+"SELECT ta.id assignment_id,p.auth_user_id student_id,u.name student_name,s.name school_name FROM report_participants p JOIN test_assignments ta ON ta.id=p.assignment_id JOIN assessment_users u ON u.auth_user_id=p.auth_user_id JOIN schools s ON s.id=ta.school_id WHERE ta.is_active=true ORDER BY ta.created_at DESC")).fetch_all(&state.pool).await }.map_err(|e| AppError::from_sqlx("list_psychological_reports", e))?;
    Ok(Json(serde_json::json!({"items":rows.into_iter().map(|r|serde_json::json!({"assignmentId":r.get::<i64,_>("assignment_id"),"studentId":r.get::<String,_>("student_id"),"studentName":r.get::<String,_>("student_name"),"schoolName":r.get::<String,_>("school_name")})).collect::<Vec<_>>() })))
}

pub async fn view(State(state): State<AppState>, auth: AuthUser, Path((assignment_id, student_id)): Path<(i64,String)>) -> AppResult<Json<serde_json::Value>> {
    let report = load(&state, &auth, assignment_id, &student_id).await?;
    Ok(Json(report_json(&report)))
}

pub async fn download(State(state): State<AppState>, auth: AuthUser, Path((assignment_id, student_id)): Path<(i64,String)>) -> AppResult<Response<Body>> {
    let mut report = load(&state, &auth, assignment_id, &student_id).await?;
    let rule_version: i32 = sqlx::query_scalar("SELECT version FROM psychological_report_rule_sets WHERE is_active=true LIMIT 1").fetch_optional(&state.pool).await.map_err(|e| AppError::from_sqlx("active_report_rules", e))?.ok_or_else(|| AppError::BadRequest("Superadmin perlu menyimpan rubrik laporan sebelum PDF resmi diterbitkan".into()))?;
    let issue = sqlx::query("SELECT id,report_no,issued_at FROM psychological_report_issues WHERE assignment_id=$1 AND student_id=$2 AND rule_version=$3")
        .bind(assignment_id).bind(&student_id).bind(rule_version).fetch_optional(&state.pool).await.map_err(|e| AppError::from_sqlx("report_issue", e))?;
    let (issue_id, report_no, issued_at) = if let Some(row)=issue {(row.get::<i64,_>("id"),row.get::<String,_>("report_no"),row.get::<chrono::NaiveDateTime,_>("issued_at"))} else {
      let today=chrono::Local::now(); let no=format!("LAP-PSI/{:04}/{:02}/{:02}/{}",today.year(),today.month(),today.day(),uuid::Uuid::new_v4().simple().to_string()[..6].to_uppercase());
      let row=sqlx::query("INSERT INTO psychological_report_issues(report_no,assignment_id,student_id,school_id,rule_version,issued_by) VALUES($1,$2,$3,$4,$5,$6) RETURNING id,issued_at").bind(&no).bind(assignment_id).bind(&student_id).bind(report.school_id).bind(rule_version).bind(&auth.user_id).fetch_one(&state.pool).await.map_err(|e| AppError::from_sqlx("issue_report",e))?; (row.get("id"),no,row.get("issued_at")) };
    sqlx::query("INSERT INTO psychological_report_downloads(issue_id,downloaded_by) VALUES($1,$2)").bind(issue_id).bind(&auth.user_id).execute(&state.pool).await.map_err(|e| AppError::from_sqlx("audit_report_download",e))?;
    report.pdf.report_no=report_no.clone(); report.pdf.issued_date=indonesian(issued_at); report.pdf.printed_date=indonesian(chrono::Local::now().naive_local());
    let bytes=crate::report_pdf::build_psychological_report(&report.pdf).map_err(AppError::Internal)?;
    Ok(Response::builder().header(header::CONTENT_TYPE,"application/pdf").header(header::CONTENT_DISPOSITION,format!("attachment; filename=\"{}.pdf\"",report_no)).body(Body::from(bytes)).unwrap())
}

struct Loaded { school_id:i64, pdf: PsychologicalReport }
async fn load(state:&AppState, auth:&AuthUser, assignment_id:i64, student_id:&str)->AppResult<Loaded>{
  let r=sqlx::query("SELECT ta.school_id,s.name school_name,u.name student_name,u.username,u.school_id student_school FROM test_assignments ta JOIN schools s ON s.id=ta.school_id JOIN assessment_users u ON u.auth_user_id=$2 WHERE ta.id=$1 AND (ta.student_id=$2 OR ta.school_id=u.school_id)").bind(assignment_id).bind(student_id).fetch_optional(&state.pool).await.map_err(|e|AppError::from_sqlx("report_scope",e))?.ok_or_else(||AppError::NotFound("Penugasan peserta tidak ditemukan".into()))?;
  let school_id:i64=r.get("school_id");
  if auth.user_id != student_id && !auth.is_role("SUPERADMIN") && !auth.is_role("PSIKOLOG") { let caller_school:Option<i64>=sqlx::query_scalar("SELECT school_id FROM assessment_users WHERE auth_user_id=$1").bind(&auth.user_id).fetch_optional(&state.pool).await.map_err(|e|AppError::from_sqlx("caller_school",e))?.flatten(); if !auth.is_role("GURUBK") || caller_school != Some(school_id) { return Err(AppError::Forbidden("Laporan hanya dapat diakses sesuai kewenangan sekolah".into())); } }
  let cfit:Option<i32>=sqlx::query_scalar("SELECT iq_score FROM cfit_results WHERE auth_user_id=$1 AND assignment_id=$2").bind(student_id).bind(assignment_id).fetch_optional(&state.pool).await.map_err(|e|AppError::from_sqlx("report_cfit",e))?;
  let ist:Option<i32>=sqlx::query_scalar("SELECT iq_score FROM ist_results WHERE auth_user_id=$1 AND assignment_id=$2").bind(student_id).bind(assignment_id).fetch_optional(&state.pool).await.map_err(|e|AppError::from_sqlx("report_ist",e))?;
  let disc:Option<(String,String)>=sqlx::query_as("SELECT dif_key,profile_title FROM disc_results WHERE auth_user_id=$1 AND assignment_id=$2").bind(student_id).bind(assignment_id).fetch_optional(&state.pool).await.map_err(|e|AppError::from_sqlx("report_disc",e))?;
  let holland:Option<(String,String)>=sqlx::query_as("SELECT type1_name,type2_name FROM holland_results WHERE auth_user_id=$1 AND assignment_id=$2").bind(student_id).bind(assignment_id).fetch_optional(&state.pool).await.map_err(|e|AppError::from_sqlx("report_holland",e))?;
  let papi:Option<serde_json::Value>=sqlx::query_scalar("SELECT trait_scores FROM papi_results WHERE auth_user_id=$1 AND assignment_id=$2").bind(student_id).bind(assignment_id).fetch_optional(&state.pool).await.map_err(|e|AppError::from_sqlx("report_papi",e))?;
  let epps:Option<serde_json::Value>=sqlx::query_scalar("SELECT trait_scores FROM epps_results WHERE auth_user_id=$1 AND assignment_id=$2").bind(student_id).bind(assignment_id).fetch_optional(&state.pool).await.map_err(|e|AppError::from_sqlx("report_epps",e))?;
  let rules=active_rules(state).await?;
  let aspect_rule=|key| configured_aspect(&rules,key);
  let score_for=|key:&str| papi.as_ref().and_then(|v|v.get(key)).map(|v|v.to_string()).unwrap_or_else(||"belum tersedia".into());
  let epps_score_for=|key:&str| epps.as_ref().and_then(|v|v.as_array()).and_then(|items|items.iter().find(|item|item.get("code").and_then(|code|code.as_str())==Some(key))).and_then(|item|item.get("percentile")).map(|value|value.to_string()).unwrap_or_else(||"belum tersedia".into());
  let (intellectual_label,intellectual_definition)=aspect_rule("intellectual");
  let (achievement_label,achievement_definition)=aspect_rule("achievement");
  let (confidence_label,confidence_definition)=aspect_rule("confidence");
  let (emotion_label,emotion_definition)=aspect_rule("emotion");
  let (adjustment_label,adjustment_definition)=aspect_rule("adjustment");
  let aspects=vec![
    PsychologicalAspect{label:intellectual_label,definition:intellectual_definition,result: match (cfit,ist){(Some(a),Some(b))=>format!("CFIT {} dan IST {}.",a,b),(Some(a),_)=>format!("CFIT {}.",a),(_,Some(b))=>format!("IST {}.",b),_=>"Belum tersedia.".into()}},
    PsychologicalAspect{label:achievement_label,definition:achievement_definition,result:format!("PAPI N/G/A: {}/{}/{}; EPPS Prestasi: persentil {}.",score_for("N"),score_for("G"),score_for("A"),epps_score_for("ACH"))},
    PsychologicalAspect{label:confidence_label,definition:confidence_definition,result:disc.as_ref().map(|(k,t)|format!("Profil DISC {} — {}.",k,t)).unwrap_or_else(||"Belum tersedia.".into())},
    PsychologicalAspect{label:emotion_label,definition:emotion_definition,result:format!("PAPI Z/E/K: {}/{}/{}; EPPS Ketekunan: persentil {}.",score_for("Z"),score_for("E"),score_for("K"),epps_score_for("END"))},
    PsychologicalAspect{label:adjustment_label,definition:adjustment_definition,result:format!("PAPI O/B/S/X: {}/{}/{}/{}; EPPS Afiliasi: persentil {}.",score_for("O"),score_for("B"),score_for("S"),score_for("X"),epps_score_for("AFF"))},
  ];
  let holland=holland.map(|(a,b)|format!("Dua tipe tertinggi: {} dan {}.",a,b)).unwrap_or_else(||"Belum tersedia.".into());
  Ok(Loaded{school_id,pdf:PsychologicalReport{report_no:"Pratinjau".into(),issued_date:"-".into(),printed_date:"-".into(),school_name:r.get("school_name"),student_name:r.get("student_name"),student_identity:r.get("username"),aspects,holland}})
}
async fn active_rules(state:&AppState)->AppResult<serde_json::Value>{
  let saved:Option<serde_json::Value>=sqlx::query_scalar("SELECT rules FROM psychological_report_rule_sets WHERE is_active=true ORDER BY version DESC LIMIT 1").fetch_optional(&state.pool).await.map_err(|e|AppError::from_sqlx("load_report_rules",e))?;
  Ok(saved.unwrap_or_else(||serde_json::from_str(DEFAULT_RULES).expect("valid default report rules")))
}
fn configured_aspect(rules:&serde_json::Value,key:&str)->(String,String){
  let default:serde_json::Value=serde_json::from_str(DEFAULT_RULES).expect("valid default report rules");
  let fallback=default.get("aspects").and_then(|a|a.as_array()).and_then(|items|items.iter().find(|item|item.get("key").and_then(|k|k.as_str())==Some(key)));
  let configured=rules.get("aspects").and_then(|a|a.as_array()).and_then(|items|items.iter().find(|item|item.get("key").and_then(|k|k.as_str())==Some(key)));
  let label=configured.and_then(|item|item.get("label")).and_then(|v|v.as_str()).or_else(||fallback.and_then(|item|item.get("label")).and_then(|v|v.as_str())).unwrap_or(key).to_string();
  let definition=configured.and_then(|item|item.get("definition")).and_then(|v|v.as_str()).or_else(||fallback.and_then(|item|item.get("definition")).and_then(|v|v.as_str())).unwrap_or("Definisi belum dikonfigurasi.").to_string();
  (label,definition)
}
fn report_json(r:&Loaded)->serde_json::Value {serde_json::json!({"schoolName":r.pdf.school_name,"studentName":r.pdf.student_name,"aspects":r.pdf.aspects.iter().map(|a|serde_json::json!({"label":a.label,"definition":a.definition,"result":a.result})).collect::<Vec<_>>(),"holland":r.pdf.holland})}
fn indonesian(d:chrono::NaiveDateTime)->String {const M:[&str;12]=["Januari","Februari","Maret","April","Mei","Juni","Juli","Agustus","September","Oktober","November","Desember"];format!("{} {} {}",d.day(),M[d.month0() as usize],d.year())}
