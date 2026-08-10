use axum::{
    extract::{Path, Query, State},
    Json,
};

use crate::{
    auth_extractor::AuthUser,
    error::{AppError, AppResult},
    models::cfit::{CfitQuestionView, CfitResult, CfitSubmitRequest},
    paging::{PageParams, PageResponse},
    scoring::cfit::cfit_item_is_correct,
    state::AppState,
};

const SORT_WHITELIST: [&str; 4] = ["studentName", "schoolName", "completedAt", "id"];

const SEL: &str = "id, auth_user_id, student_name, school_name, assignment_id, \
    sub1_score, sub2_score, sub3_score, sub4_score, total_score, iq_score, category, description, answers::text, completed_at";

pub async fn questions(
    State(state): State<AppState>,
    auth: AuthUser,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SISWA"])?;
    let rows: Vec<CfitQuestionView> = sqlx::query_as(
        "SELECT id, subtest_no, item_no, stem_image_url, option_images FROM cfit_questions \
         WHERE is_active = true ORDER BY subtest_no, item_no",
    )
    .fetch_all(&state.pool)
    .await
    .map_err(|e| AppError::from_sqlx("cfit_questions", e))?;
    Ok(Json(serde_json::json!(rows)))
}

pub async fn check(
    State(state): State<AppState>,
    auth: AuthUser,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SISWA"])?;
    Ok(Json(super::disc::check_for(&state, &auth, "cfit").await?))
}

pub async fn submit(
    State(state): State<AppState>,
    auth: AuthUser,
    Json(req): Json<CfitSubmitRequest>,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SISWA"])?;
    let exists: i64 = sqlx::query_scalar("SELECT COUNT(*) FROM cfit_results WHERE auth_user_id = $1")
        .bind(&auth.user_id)
        .fetch_one(&state.pool)
        .await
        .map_err(|e| AppError::from_sqlx("cfit_exists", e))?;
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

    // Score each subtest.
    let mut sub_scores = [0i32; 4];
    // Answers payload keyed by subtest for persistence.
    let mut answers_by_subtest: std::collections::BTreeMap<i32, Vec<serde_json::Value>> = std::collections::BTreeMap::new();

    let mut questions_by_subtest: std::collections::HashMap<i32, Vec<crate::models::cfit::CfitQuestionRow>> = std::collections::HashMap::new();

    for a in &req.answers {
        let qs = if !questions_by_subtest.contains_key(&a.subtest_no) {
            auth.require_role(&["SISWA"])?;
    let rows: Vec<crate::models::cfit::CfitQuestionRow> = sqlx::query_as(
                "SELECT id, subtest_no, item_no, stem_image_url, option_images, correct_answer, correct_answer2 \
                 FROM cfit_questions WHERE subtest_no = $1 AND is_active = true ORDER BY item_no",
            )
            .bind(a.subtest_no)
            .fetch_all(&state.pool)
            .await
            .map_err(|e| AppError::from_sqlx("cfit_questions_subtest", e))?;
            questions_by_subtest.insert(a.subtest_no, rows);
            questions_by_subtest.get(&a.subtest_no).unwrap()
        } else {
            questions_by_subtest.get(&a.subtest_no).unwrap()
        };
        let q = qs
            .iter()
            .find(|q| q.item_no == a.item_no)
            .ok_or_else(|| {
                AppError::NotFound(format!(
                    "CFIT question not found: subtest={} item={}",
                    a.subtest_no, a.item_no
                ))
            })?;
        if cfit_item_is_correct(&a.answers, &q.correct_answer, q.correct_answer2.as_deref()) {
            sub_scores[(a.subtest_no - 1) as usize] += 1;
        }
        let answers_by_subtest_entry = answers_by_subtest.entry(a.subtest_no).or_default();
        answers_by_subtest_entry.push(serde_json::json!({
            "itemNo": a.item_no,
            "answer": a.answers.join(", "),
        }));
    }

    let total = sub_scores.iter().sum::<i32>();

    // IQ band lookup.
    let band = sqlx::query_as::<_, (i32, Option<String>, Option<String>)>(
        "SELECT iq_min, category, description FROM cfit_descriptions WHERE score_min <= $1 AND score_max >= $1",
    )
    .bind(total)
    .fetch_optional(&state.pool)
    .await
    .map_err(|e| AppError::from_sqlx("cfit_band", e))?;

    let iq_score = band.as_ref().map(|b| b.0).unwrap_or(0);
    let category = band.as_ref().and_then(|b| b.1.clone());
    let description = band.as_ref().and_then(|b| b.2.clone());

    // Build answers JSON (map of subtestNo -> [{itemNo, answer}]).
    let answers_obj: serde_json::Map<String, serde_json::Value> = answers_by_subtest
        .iter()
        .map(|(k, v)| (k.to_string(), serde_json::json!(v)))
        .collect();
    let answers_json = serde_json::Value::Object(answers_obj).to_string();

    let row = sqlx::query_as::<_, CfitResult>(&format!(
        "INSERT INTO cfit_results (auth_user_id, student_name, school_name, assignment_id, \
         sub1_score, sub2_score, sub3_score, sub4_score, total_score, iq_score, category, description, answers, completed_at) \
         VALUES ($1,$2,$3,$4, $5,$6,$7,$8,$9,$10,$11,$12, $13::jsonb, NOW()) RETURNING {SEL}"
    ))
    .bind(&auth.user_id)
    .bind(&student_name)
    .bind(&school_name)
    .bind(req.assignment_id)
    .bind(sub_scores[0])
    .bind(sub_scores[1])
    .bind(sub_scores[2])
    .bind(sub_scores[3])
    .bind(total)
    .bind(iq_score)
    .bind(&category)
    .bind(&description)
    .bind(answers_json)
    .fetch_one(&state.pool)
    .await
    .map_err(|e| AppError::from_sqlx("insert_cfit_result", e))?;

    Ok(Json(row.as_json()))
}

pub async fn result_me(
    State(state): State<AppState>,
    auth: AuthUser,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SISWA"])?;
    let row = sqlx::query_as::<_, CfitResult>(&format!(
        "SELECT {SEL} FROM cfit_results WHERE auth_user_id = $1"
    ))
    .bind(&auth.user_id)
    .fetch_optional(&state.pool)
    .await
    .map_err(|e| AppError::from_sqlx("cfit_result_me", e))?
    .ok_or_else(|| AppError::NotFound("Cfit result not found".to_string()))?;
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
        let order_col = params.sort_col(sort);
    let size = params.size_clamped();
    let offset = params.offset();

    if params.is_paginated() {
        let count_sql = format!("SELECT COUNT(*) FROM cfit_results{where_sql}");
        let mut cq = sqlx::query_scalar::<_, i64>(&count_sql);
        for b in &binds { cq = cq.bind(b); }
        let total: i64 = cq.fetch_one(&state.pool).await.map_err(|e| AppError::from_sqlx("count_cfit", e))?;
        let sql = format!("SELECT {SEL} FROM cfit_results{where_sql} ORDER BY {} {} LIMIT ${} OFFSET ${}", order_col, order, idx, idx + 1);
        let mut q = sqlx::query_as::<_, CfitResult>(&sql);
        for b in &binds { q = q.bind(b); }
        let rows: Vec<CfitResult> = q.bind(size).bind(offset).fetch_all(&state.pool).await.map_err(|e| AppError::from_sqlx("list_cfit", e))?;
        let items: Vec<serde_json::Value> = rows.iter().map(|r| r.as_json()).collect();
        Ok(serde_json::to_value(PageResponse::new(items, params.page_or_zero(), size, total)).unwrap())
    } else {
        let sql = format!("SELECT {SEL} FROM cfit_results{where_sql} ORDER BY {} {}", order_col, order);
        let mut q = sqlx::query_as::<_, CfitResult>(&sql);
        for b in &binds { q = q.bind(b); }
        let rows: Vec<CfitResult> = q.fetch_all(&state.pool).await.map_err(|e| AppError::from_sqlx("list_cfit", e))?;
        Ok(serde_json::json!(rows.iter().map(|r| r.as_json()).collect::<Vec<_>>()))
    }
}

pub async fn result_by_user(
    State(state): State<AppState>,
    auth: AuthUser,
    Path(auth_user_id): Path<String>,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SUPERADMIN", "GURUBK", "AFILIATOR", "PSIKOLOG"])?;
    let row = sqlx::query_as::<_, CfitResult>(&format!(
        "SELECT {SEL} FROM cfit_results WHERE auth_user_id = $1"
    ))
    .bind(&auth_user_id)
    .fetch_optional(&state.pool)
    .await
    .map_err(|e| AppError::from_sqlx("cfit_by_user", e))?
    .ok_or_else(|| AppError::NotFound(format!("Cfit result not found for user: {auth_user_id}")))?;
    Ok(Json(row.as_json()))
}

pub async fn delete_own_result(
    State(state): State<AppState>,
    auth: AuthUser,
) -> AppResult<axum::http::StatusCode> {
    sqlx::query("DELETE FROM cfit_results WHERE auth_user_id = $1")
        .bind(&auth.user_id)
        .execute(&state.pool)
        .await
        .map_err(|e| AppError::from_sqlx("delete_cfit_result", e))?;
    Ok(axum::http::StatusCode::NO_CONTENT)
}
