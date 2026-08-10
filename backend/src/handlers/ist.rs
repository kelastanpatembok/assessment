use axum::{
    extract::{Path, Query, State},
    Json,
};
use serde::Deserialize;

use crate::{
    auth_extractor::AuthUser,
    error::{AppError, AppResult},
    models::ist::{
        IstItemAnswer, IstQuestionRow, IstQuestionView, IstResult, IstSubmitRequest,
        IstZrQuestionRow, IstZrQuestionView,
    },
    paging::{PageParams, PageResponse},
    scoring::ist::{ist_standard_correct, ist_zr_correct},
    state::AppState,
};

const SORT_WHITELIST: [&str; 4] = ["studentName", "schoolName", "completedAt", "id"];

const SEL: &str = "id, auth_user_id, student_name, school_name, assignment_id, subtest_scores::text, total_wert, iq_score, iq_category, answers::text, completed_at";

#[derive(Deserialize)]
pub struct QuestionsParams {
    pub subtest: Option<String>,
}

fn to_view(r: &IstQuestionRow) -> IstQuestionView {
    IstQuestionView {
        id: r.id,
        subtest_code: r.subtest_code.clone(),
        item_no: r.item_no,
        question_text: r.question_text.clone(),
        image_url: r.image_url.clone(),
        options: r.options.clone(),
        option_images: r.option_images.clone(),
    }
}

fn to_zr_view(r: &IstZrQuestionRow) -> IstZrQuestionView {
    IstZrQuestionView {
        id: r.id,
        item_no: r.item_no,
        sequence_text: r.sequence_text.clone(),
    }
}

pub async fn questions(
    State(state): State<AppState>,
    auth: AuthUser,
    Query(params): Query<QuestionsParams>,
) -> AppResult<Json<serde_json::Value>> {
    match params.subtest.as_deref().map(|s| s.to_uppercase()) {
        Some(code) if code == "ZR" => {
            auth.require_role(&["SISWA"])?;
    let rows: Vec<IstZrQuestionRow> = sqlx::query_as(
                "SELECT id, item_no, sequence_text, correct_answer FROM ist_zr_questions ORDER BY item_no",
            )
            .fetch_all(&state.pool)
            .await
            .map_err(|e| AppError::from_sqlx("ist_zr_questions", e))?;
            Ok(Json(serde_json::json!(rows.iter().map(to_zr_view).collect::<Vec<_>>())))
        }
        Some(code) => {
            auth.require_role(&["SISWA"])?;
    let rows: Vec<IstQuestionRow> = sqlx::query_as(
                "SELECT id, subtest_code, item_no, question_text, image_url, options, option_images, correct_answer \
                 FROM ist_questions WHERE subtest_code = $1 AND is_active = true ORDER BY item_no",
            )
            .bind(&code)
            .fetch_all(&state.pool)
            .await
            .map_err(|e| AppError::from_sqlx("ist_questions", e))?;
            Ok(Json(serde_json::json!(rows.iter().map(to_view).collect::<Vec<_>>())))
        }
        None => {
            auth.require_role(&["SISWA"])?;
    let rows: Vec<IstQuestionRow> = sqlx::query_as(
                "SELECT id, subtest_code, item_no, question_text, image_url, options, option_images, correct_answer \
                 FROM ist_questions WHERE subtest_code <> 'ZR' AND is_active = true ORDER BY subtest_code, item_no",
            )
            .fetch_all(&state.pool)
            .await
            .map_err(|e| AppError::from_sqlx("ist_questions", e))?;
            Ok(Json(serde_json::json!(rows.iter().map(to_view).collect::<Vec<_>>())))
        }
    }
}

pub async fn check(
    State(state): State<AppState>,
    auth: AuthUser,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SISWA"])?;
    Ok(Json(super::disc::check_for(&state, &auth, "ist").await?))
}

pub async fn submit(
    State(state): State<AppState>,
    auth: AuthUser,
    Json(req): Json<IstSubmitRequest>,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SISWA"])?;
    let exists: i64 = sqlx::query_scalar("SELECT COUNT(*) FROM ist_results WHERE auth_user_id = $1")
        .bind(&auth.user_id)
        .fetch_one(&state.pool)
        .await
        .map_err(|e| AppError::from_sqlx("ist_exists", e))?;
    if exists > 0 {
        return Err(AppError::Conflict(
            "Anda sudah pernah mengerjakan tes ini. Hasil tidak dapat diulang.".to_string(),
        ));
    }

    let user = crate::db::load_user(&state.pool, &auth.user_id).await?;
    let student_name = user.as_ref().map(|u| u.name.clone());
    let school_name = match user.as_ref().and_then(|u| u.school_id) {
        Some(sid) => crate::db::load_school(&state.pool, sid).await?.map(|s| s.name),
        None => None,
    };

    // Score per subtest.
    let mut raw_scores: std::collections::BTreeMap<String, i32> = std::collections::BTreeMap::new();
    let mut answers_payload: Vec<serde_json::Value> = Vec::new();

    for st in &req.subtests {
        let code = st.subtest_code.to_uppercase();
        let raw = if code == "ZR" {
            let questions: Vec<IstZrQuestionRow> = sqlx::query_as(
                "SELECT id, item_no, sequence_text, correct_answer FROM ist_zr_questions ORDER BY item_no",
            )
            .fetch_all(&state.pool)
            .await
            .map_err(|e| AppError::from_sqlx("ist_zr_questions", e))?;
            score_zr(&questions, &st.items)
        } else {
            let questions: Vec<IstQuestionRow> = sqlx::query_as(
                "SELECT id, subtest_code, item_no, question_text, image_url, options, option_images, correct_answer \
                 FROM ist_questions WHERE subtest_code = $1 AND is_active = true ORDER BY item_no",
            )
            .bind(&code)
            .fetch_all(&state.pool)
            .await
            .map_err(|e| AppError::from_sqlx("ist_questions", e))?;
            score_standard(&questions, &st.items)
        };
        raw_scores.insert(code.clone(), raw);
        answers_payload.push(serde_json::json!({
            "subtestCode": st.subtest_code,
            "items": st.items.iter().map(|i| serde_json::json!({"itemNo": i.item_no, "answer": i.answer})).collect::<Vec<_>>(),
        }));
    }

    // Norming (Wert).
    let mut werts: std::collections::BTreeMap<String, (i32, i32)> = std::collections::BTreeMap::new();
    let mut total_wert = 0;
    for (code, raw) in &raw_scores {
        let wert: Option<i32> = sqlx::query_scalar(
            "SELECT wert FROM ist_norma WHERE subtest_code = $1 AND raw_score = $2",
        )
        .bind(code)
        .bind(raw)
        .fetch_optional(&state.pool)
        .await
        .map_err(|e| AppError::from_sqlx("ist_norma", e))?;
        let wert = wert.unwrap_or_else(|| (*raw).min(10));
        total_wert += wert;
        werts.insert(code.clone(), (*raw, wert));
    }

    // IQ band lookup.
    let band = sqlx::query_as::<_, (i32, Option<String>)>(
        "SELECT iq_min, category FROM ist_iq_bands WHERE wert_min <= $1 AND wert_max >= $1",
    )
    .bind(total_wert)
    .fetch_optional(&state.pool)
    .await
    .map_err(|e| AppError::from_sqlx("ist_iq_bands", e))?;
    let iq_score = band.as_ref().map(|b| b.0).unwrap_or(0);
    let iq_category = band.as_ref().and_then(|b| b.1.clone());

    // subtest_scores JSON: {"SE":{"raw":X,"wert":Y}, ...}
    let mut scores_obj = serde_json::Map::new();
    for (code, (raw, wert)) in &werts {
        scores_obj.insert(code.clone(), serde_json::json!({"raw": raw, "wert": wert}));
    }
    let scores_text = serde_json::Value::Object(scores_obj).to_string();
    let answers_json = serde_json::to_string(&answers_payload).unwrap_or_else(|_| "[]".to_string());

    let row = sqlx::query_as::<_, IstResult>(&format!(
        "INSERT INTO ist_results (auth_user_id, student_name, school_name, assignment_id, subtest_scores, total_wert, iq_score, iq_category, answers, completed_at) \
         VALUES ($1,$2,$3,$4, $5::jsonb, $6, $7, $8, $9::jsonb, NOW()) RETURNING {SEL}"
    ))
    .bind(&auth.user_id)
    .bind(&student_name)
    .bind(&school_name)
    .bind(req.assignment_id)
    .bind(scores_text)
    .bind(total_wert)
    .bind(iq_score)
    .bind(&iq_category)
    .bind(answers_json)
    .fetch_one(&state.pool)
    .await
    .map_err(|e| AppError::from_sqlx("insert_ist_result", e))?;

    Ok(Json(row.as_json()))
}

fn score_standard(questions: &[IstQuestionRow], items: &[IstItemAnswer]) -> i32 {
    let mut correct = 0;
    for item in items {
        if let Some(q) = questions.iter().find(|q| q.item_no == item.item_no) {
            if ist_standard_correct(&item.answer, q.correct_answer.as_deref()) {
                correct += 1;
            }
        }
    }
    correct
}

fn score_zr(questions: &[IstZrQuestionRow], items: &[IstItemAnswer]) -> i32 {
    let mut correct = 0;
    for item in items {
        if let Some(q) = questions.iter().find(|q| q.item_no == item.item_no) {
            if ist_zr_correct(&item.answer, q.correct_answer) {
                correct += 1;
            }
        }
    }
    correct
}

pub async fn result_me(
    State(state): State<AppState>,
    auth: AuthUser,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SISWA"])?;
    let row = sqlx::query_as::<_, IstResult>(&format!(
        "SELECT {SEL} FROM ist_results WHERE auth_user_id = $1"
    ))
    .bind(&auth.user_id)
    .fetch_optional(&state.pool)
    .await
    .map_err(|e| AppError::from_sqlx("ist_result_me", e))?
    .ok_or_else(|| AppError::NotFound("Ist result not found".to_string()))?;
    Ok(Json(row.as_json()))
}

pub async fn results(
    State(state): State<AppState>,
    auth: AuthUser,
    Query(params): Query<super::disc::CheckParams>,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SUPERADMIN", "GURUBK", "AFILIATOR", "PSIKOLOG"])?;
    let pp = PageParams {
        page: params.page, size: params.size, search: params.search, sort: params.sort, order: params.order,
    };
    let _ = auth;
    Ok(Json(list_scoped(&state, &pp).await?))
}

async fn list_scoped(state: &AppState, params: &PageParams) -> AppResult<serde_json::Value> {
    let mut conds: Vec<String> = Vec::new();
    let mut binds: Vec<String> = Vec::new();
    let mut idx = 1usize;
    if params.has_search() {
        conds.push(format!("(LOWER(student_name) LIKE ${} OR LOWER(school_name) LIKE ${})", idx, idx));
        binds.push(params.search_like());
        idx += 1;
    }
    let where_sql = if conds.is_empty() { String::new() } else { format!(" WHERE {}", conds.join(" AND ")) };
    let sort = params.sort_key(&SORT_WHITELIST, "completedAt");
    let order = params.order_dir();
    let order_col = match sort {
        "studentName" => "student_name",
        "schoolName" => "school_name",
        "id" => "id",
        _ => "completed_at",
    };
    let size = params.size_clamped();
    let offset = params.offset();

    if params.is_paginated() {
        let count_sql = format!("SELECT COUNT(*) FROM ist_results{where_sql}");
        let mut cq = sqlx::query_scalar::<_, i64>(&count_sql);
        for b in &binds { cq = cq.bind(b); }
        let total: i64 = cq.fetch_one(&state.pool).await.map_err(|e| AppError::from_sqlx("count_ist", e))?;
        let sql = format!("SELECT {SEL} FROM ist_results{where_sql} ORDER BY {} {} LIMIT ${} OFFSET ${}", order_col, order, idx, idx + 1);
        let mut q = sqlx::query_as::<_, IstResult>(&sql);
        for b in &binds { q = q.bind(b); }
        let rows: Vec<IstResult> = q.bind(size).bind(offset).fetch_all(&state.pool).await.map_err(|e| AppError::from_sqlx("list_ist", e))?;
        let items: Vec<serde_json::Value> = rows.iter().map(|r| r.as_json()).collect();
        Ok(serde_json::to_value(PageResponse::new(items, params.page_or_zero(), size, total)).unwrap())
    } else {
        let sql = format!("SELECT {SEL} FROM ist_results{where_sql} ORDER BY {} {}", order_col, order);
        let mut q = sqlx::query_as::<_, IstResult>(&sql);
        for b in &binds { q = q.bind(b); }
        let rows: Vec<IstResult> = q.fetch_all(&state.pool).await.map_err(|e| AppError::from_sqlx("list_ist", e))?;
        Ok(serde_json::json!(rows.iter().map(|r| r.as_json()).collect::<Vec<_>>()))
    }
}

pub async fn result_by_user(
    State(state): State<AppState>,
    auth: AuthUser,
    Path(auth_user_id): Path<String>,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SUPERADMIN", "GURUBK", "AFILIATOR", "PSIKOLOG"])?;
    let row = sqlx::query_as::<_, IstResult>(&format!(
        "SELECT {SEL} FROM ist_results WHERE auth_user_id = $1"
    ))
    .bind(&auth_user_id)
    .fetch_optional(&state.pool)
    .await
    .map_err(|e| AppError::from_sqlx("ist_by_user", e))?
    .ok_or_else(|| AppError::NotFound(format!("Ist result not found for user: {auth_user_id}")))?;
    Ok(Json(row.as_json()))
}

pub async fn delete_own_result(
    State(state): State<AppState>,
    auth: AuthUser,
) -> AppResult<axum::http::StatusCode> {
    sqlx::query("DELETE FROM ist_results WHERE auth_user_id = $1")
        .bind(&auth.user_id)
        .execute(&state.pool)
        .await
        .map_err(|e| AppError::from_sqlx("delete_ist_result", e))?;
    Ok(axum::http::StatusCode::NO_CONTENT)
}
