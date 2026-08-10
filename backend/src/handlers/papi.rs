use axum::{
    extract::{Path, Query, State},
    Json,
};

use crate::{
    auth_extractor::AuthUser,
    error::{AppError, AppResult},
    models::papi::{
        PapiDescription, PapiQuestion, PapiResult, PapiResultView, PapiSubmitRequest,
        TraitDetail,
    },
    paging::{PageParams, PageResponse},
    scoring::papi::{PAPI_TRAIT_ORDER, HIGH_BAND_THRESHOLD},
    state::AppState,
};

const SORT_WHITELIST: [&str; 4] = ["studentName", "schoolName", "completedAt", "id"];

const SEL: &str = "id, auth_user_id, student_name, school_name, assignment_id, trait_scores::text, answers::text, completed_at";

fn question_row(r: (i64, i32, String, String, String, bool)) -> PapiQuestion {
    PapiQuestion {
        id: r.0, pair_no: r.1, item_letter: r.2, trait_code: r.3, statement: r.4, active: r.5,
    }
}

pub async fn questions(
    State(state): State<AppState>,
    auth: AuthUser,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SISWA"])?;
    let rows: Vec<(i64, i32, String, String, String, bool)> = sqlx::query_as(
        "SELECT id, pair_no, item_letter, trait_code, statement, is_active FROM papi_questions \
         WHERE is_active = true ORDER BY pair_no, item_letter",
    )
    .fetch_all(&state.pool)
    .await
    .map_err(|e| AppError::from_sqlx("papi_questions", e))?;
    Ok(Json(serde_json::json!(rows.into_iter().map(question_row).collect::<Vec<_>>())))
}

pub async fn check(
    State(state): State<AppState>,
    auth: AuthUser,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SISWA"])?;
    Ok(Json(super::disc::check_for(&state, &auth, "papi").await?))
}

pub async fn submit(
    State(state): State<AppState>,
    auth: AuthUser,
    Json(req): Json<PapiSubmitRequest>,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SISWA"])?;
    let exists: i64 = sqlx::query_scalar("SELECT COUNT(*) FROM papi_results WHERE auth_user_id = $1")
        .bind(&auth.user_id)
        .fetch_one(&state.pool)
        .await
        .map_err(|e| AppError::from_sqlx("papi_exists", e))?;
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

    // Tally trait counts.
    let mut counts: std::collections::HashMap<String, i32> = std::collections::HashMap::new();
    for a in &req.answers {
        let pair: Vec<(String, String)> = sqlx::query_as(
            "SELECT item_letter, trait_code FROM papi_questions WHERE pair_no = $1 ORDER BY item_letter",
        )
        .bind(a.pair_no)
        .fetch_all(&state.pool)
        .await
        .map_err(|e| AppError::from_sqlx("papi_pair", e))?;
        let trait_code = pair
            .iter()
            .find(|(letter, _)| letter.eq_ignore_ascii_case(&a.chosen_letter))
            .map(|(_, tc)| tc.clone())
            .ok_or_else(|| {
                AppError::NotFound(format!(
                    "PAPI question not found: pair={} letter={}",
                    a.pair_no, a.chosen_letter
                ))
            })?;
        *counts.entry(trait_code).or_insert(0) += 1;
    }

    // Build trait_scores JSON as a sorted map (matching PostgreSQL jsonb text).
    let mut sorted: Vec<(String, i32)> = counts.into_iter().collect();
    sorted.sort();
    let trait_scores_obj: serde_json::Map<String, serde_json::Value> = sorted
        .iter()
        .map(|(k, v)| (k.clone(), serde_json::json!(v)))
        .collect();
    let trait_scores_text = serde_json::Value::Object(trait_scores_obj).to_string();

    let answers_json = serde_json::to_string(&req.answers).unwrap_or_else(|_| "[]".to_string());

    let row = sqlx::query_as::<_, PapiResult>(&format!(
        "INSERT INTO papi_results (auth_user_id, student_name, school_name, assignment_id, trait_scores, answers, completed_at) \
         VALUES ($1,$2,$3,$4, $5::jsonb, $6::jsonb, NOW()) RETURNING {SEL}"
    ))
    .bind(&auth.user_id)
    .bind(&student_name)
    .bind(&school_name)
    .bind(req.assignment_id)
    .bind(trait_scores_text)
    .bind(answers_json)
    .fetch_one(&state.pool)
    .await
    .map_err(|e| AppError::from_sqlx("insert_papi_result", e))?;

    Ok(Json(row.as_json()))
}

/// Parse the trait_scores JSON string into a map.
fn parse_trait_scores(text: Option<&str>) -> std::collections::HashMap<String, i32> {
    let mut out = std::collections::HashMap::new();
    if let Some(t) = text {
        if let Ok(v) = serde_json::from_str::<serde_json::Value>(t) {
            if let Some(obj) = v.as_object() {
                for (k, v) in obj {
                    out.insert(k.clone(), v.as_i64().unwrap_or(0) as i32);
                }
            }
        }
    }
    out
}

async fn build_view(state: &AppState, r: &PapiResult) -> AppResult<PapiResultView> {
    let scores = parse_trait_scores(r.trait_scores.as_deref());
    let mut trait_details = Vec::new();
    for &code in PAPI_TRAIT_ORDER.iter() {
        let score = scores.get(&code.to_string()).copied().unwrap_or(0);
        let desc = load_desc(&state.pool, code).await?;
        let band = if score >= HIGH_BAND_THRESHOLD { "TINGGI" } else { "RENDAH" };
        let band_text = if score >= HIGH_BAND_THRESHOLD {
            desc.as_ref().and_then(|d| d.high_desc.clone())
        } else {
            desc.as_ref().and_then(|d| d.low_desc.clone())
        };
        trait_details.push(TraitDetail {
            trait_code: code.to_string(),
            trait_name: desc.as_ref().map(|d| d.trait_name.clone()).unwrap_or_else(|| code.to_string()),
            score,
            description: desc.as_ref().and_then(|d| d.description.clone()),
            band: band.to_string(),
            band_text,
        });
    }
    Ok(PapiResultView {
        id: r.id,
        auth_user_id: r.auth_user_id.clone(),
        student_name: r.student_name.clone(),
        school_name: r.school_name.clone(),
        assignment_id: r.assignment_id,
        trait_scores: r.trait_scores.clone(),
        trait_details,
        completed_at: r.completed_at,
    })
}

async fn load_desc(pool: &sqlx::PgPool, code: char) -> AppResult<Option<PapiDescription>> {
    Ok(sqlx::query_as::<_, PapiDescription>(
        "SELECT trait_code, trait_name, description, high_desc, low_desc FROM papi_descriptions WHERE trait_code = $1",
    )
    .bind(code.to_string())
    .fetch_optional(pool)
    .await
    .map_err(|e| AppError::from_sqlx("papi_desc", e))?)
}

pub async fn result_me(
    State(state): State<AppState>,
    auth: AuthUser,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SISWA"])?;
    let row = sqlx::query_as::<_, PapiResult>(&format!(
        "SELECT {SEL} FROM papi_results WHERE auth_user_id = $1"
    ))
    .bind(&auth.user_id)
    .fetch_optional(&state.pool)
    .await
    .map_err(|e| AppError::from_sqlx("papi_result_me", e))?
    .ok_or_else(|| AppError::NotFound("Papi result not found".to_string()))?;
    let view = build_view(&state, &row).await?;
    Ok(Json(view.as_json()))
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
        let count_sql = format!("SELECT COUNT(*) FROM papi_results{where_sql}");
        let mut cq = sqlx::query_scalar::<_, i64>(&count_sql);
        for b in &binds { cq = cq.bind(b); }
        let total: i64 = cq.fetch_one(&state.pool).await.map_err(|e| AppError::from_sqlx("count_papi", e))?;
        let sql = format!("SELECT {SEL} FROM papi_results{where_sql} ORDER BY {} {} LIMIT ${} OFFSET ${}", order_col, order, idx, idx + 1);
        let mut q = sqlx::query_as::<_, PapiResult>(&sql);
        for b in &binds { q = q.bind(b); }
        let rows: Vec<PapiResult> = q.bind(size).bind(offset).fetch_all(&state.pool).await.map_err(|e| AppError::from_sqlx("list_papi", e))?;
        let items: Vec<serde_json::Value> = rows.iter().map(|r| r.as_json()).collect();
        Ok(serde_json::to_value(PageResponse::new(items, params.page_or_zero(), size, total)).unwrap())
    } else {
        let sql = format!("SELECT {SEL} FROM papi_results{where_sql} ORDER BY {} {}", order_col, order);
        let mut q = sqlx::query_as::<_, PapiResult>(&sql);
        for b in &binds { q = q.bind(b); }
        let rows: Vec<PapiResult> = q.fetch_all(&state.pool).await.map_err(|e| AppError::from_sqlx("list_papi", e))?;
        Ok(serde_json::json!(rows.iter().map(|r| r.as_json()).collect::<Vec<_>>()))
    }
}

pub async fn result_by_user(
    State(state): State<AppState>,
    auth: AuthUser,
    Path(auth_user_id): Path<String>,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SUPERADMIN", "GURUBK", "AFILIATOR", "PSIKOLOG"])?;
    let row = sqlx::query_as::<_, PapiResult>(&format!(
        "SELECT {SEL} FROM papi_results WHERE auth_user_id = $1"
    ))
    .bind(&auth_user_id)
    .fetch_optional(&state.pool)
    .await
    .map_err(|e| AppError::from_sqlx("papi_by_user", e))?
    .ok_or_else(|| AppError::NotFound(format!("Papi result not found for user: {auth_user_id}")))?;
    let view = build_view(&state, &row).await?;
    Ok(Json(view.as_json()))
}

pub async fn delete_own_result(
    State(state): State<AppState>,
    auth: AuthUser,
) -> AppResult<axum::http::StatusCode> {
    sqlx::query("DELETE FROM papi_results WHERE auth_user_id = $1")
        .bind(&auth.user_id)
        .execute(&state.pool)
        .await
        .map_err(|e| AppError::from_sqlx("delete_papi_result", e))?;
    Ok(axum::http::StatusCode::NO_CONTENT)
}
