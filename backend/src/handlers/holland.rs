use axum::{
    extract::{Path, Query, State},
    Json,
};

use crate::{
    auth_extractor::AuthUser,
    error::{AppError, AppResult},
    models::holland::{HollandQuestion, HollandResult, HollandSubmitRequest},
    paging::{PageParams, PageResponse},
    scoring::holland::rank_types,
    state::AppState,
};

const SORT_WHITELIST: [&str; 4] = ["studentName", "schoolName", "completedAt", "id"];

const SEL: &str = "id, auth_user_id, student_name, school_name, assignment_id, \
    r_score, i_score, a_score, s_score, e_score, c_score, \
    type1, type1_name, type1_description, type1_characteristics, type1_strengths, type1_weaknesses, type1_job_match, \
    type2, type2_name, type2_description, type2_characteristics, type2_strengths, type2_weaknesses, type2_job_match, \
    holland_code, answers::text, completed_at";

fn question_row(r: (i64, i32, String, i32, String, bool)) -> HollandQuestion {
    HollandQuestion {
        id: r.0, round: r.1, riasec_type: r.2, item_no: r.3, statement: r.4, active: r.5,
    }
}

pub async fn questions(
    State(state): State<AppState>,
    auth: AuthUser,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SISWA"])?;
    super::disc::require_active_assignment(&state, &auth, "holland").await?;
    let rows: Vec<(i64, i32, String, i32, String, bool)> = sqlx::query_as(
        "SELECT id, round, riasec_type, item_no, statement, is_active FROM holland_questions \
         WHERE is_active = true ORDER BY round, riasec_type, item_no",
    )
    .fetch_all(&state.pool)
    .await
    .map_err(|e| AppError::from_sqlx("holland_questions", e))?;
    Ok(Json(serde_json::json!(rows.into_iter().map(question_row).collect::<Vec<_>>())))
}

pub async fn check(
    State(state): State<AppState>,
    auth: AuthUser,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SISWA"])?;
    let assignment_id = super::disc::require_active_assignment(&state, &auth, "holland").await?;
    Ok(Json(super::disc::check_for(&state, &auth, "holland").await?))
}

pub async fn submit(
    State(state): State<AppState>,
    auth: AuthUser,
    Json(req): Json<HollandSubmitRequest>,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SISWA"])?;
    let assignment_id = super::disc::require_active_assignment(&state, &auth, "holland").await?;
    let exists: i64 = sqlx::query_scalar("SELECT COUNT(*) FROM holland_results WHERE auth_user_id = $1")
        .bind(&auth.user_id)
        .fetch_one(&state.pool)
        .await
        .map_err(|e| AppError::from_sqlx("holland_exists", e))?;
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

    let mut totals: std::collections::HashMap<char, i64> = std::collections::HashMap::new();
    for a in &req.answers {
        let riasec: Option<String> = sqlx::query_scalar(
            "SELECT riasec_type FROM holland_questions WHERE id = $1",
        )
        .bind(a.question_id)
        .fetch_optional(&state.pool)
        .await
        .map_err(|e| AppError::from_sqlx("load_holland_question", e))?;
        let riasec = riasec.ok_or_else(|| {
            AppError::NotFound(format!("Holland question not found: {}", a.question_id))
        })?;
        let ch = riasec.to_uppercase().chars().next().unwrap_or('R');
        *totals.entry(ch).or_insert(0) += a.score as i64;
    }

    let ranked = rank_types(&totals);
    let type1 = ranked[0];
    let type2 = ranked[1];
    let holland_code = format!("{}{}", type1, type2);

    let d1 = load_description(&state.pool, type1).await?;
    let d2 = load_description(&state.pool, type2).await?;

    let answers_json = serde_json::to_string(&req.answers).unwrap_or_else(|_| "[]".to_string());

    let row = sqlx::query_as::<_, HollandResult>(
        &format!(
            "INSERT INTO holland_results \
             (auth_user_id, student_name, school_name, assignment_id, r_score, i_score, a_score, s_score, e_score, c_score, \
              type1, type1_name, type1_description, type1_characteristics, type1_strengths, type1_weaknesses, type1_job_match, \
              type2, type2_name, type2_description, type2_characteristics, type2_strengths, type2_weaknesses, type2_job_match, \
              holland_code, answers, completed_at) \
             VALUES ($1,$2,$3,$4, $5,$6,$7,$8,$9,$10, \
                     $11,$12,$13,$14,$15,$16,$17, \
                     $18,$19,$20,$21,$22,$23,$24, \
                     $25,$26::jsonb, NOW()) \
             RETURNING {SEL}"
        )
        .replace("{SEL}", SEL),
    )
    .bind(&auth.user_id)
    .bind(&student_name)
    .bind(&school_name)
    .bind(assignment_id)
    .bind(totals.get(&'R').copied().unwrap_or(0) as i32)
    .bind(totals.get(&'I').copied().unwrap_or(0) as i32)
    .bind(totals.get(&'A').copied().unwrap_or(0) as i32)
    .bind(totals.get(&'S').copied().unwrap_or(0) as i32)
    .bind(totals.get(&'E').copied().unwrap_or(0) as i32)
    .bind(totals.get(&'C').copied().unwrap_or(0) as i32)
    .bind(type1.to_string())
    .bind(&d1.0)
    .bind(&d1.1)
    .bind(&d1.2)
    .bind(&d1.3)
    .bind(&d1.4)
    .bind(&d1.5)
    .bind(type2.to_string())
    .bind(&d2.0)
    .bind(&d2.1)
    .bind(&d2.2)
    .bind(&d2.3)
    .bind(&d2.4)
    .bind(&d2.5)
    .bind(holland_code)
    .bind(answers_json)
    .fetch_one(&state.pool)
    .await
    .map_err(|e| AppError::from_sqlx("insert_holland_result", e))?;

    Ok(Json(row.as_json()))
}

/// (name, description, characteristics, strengths, weaknesses, job_match) — nulls when missing.
async fn load_description(
    pool: &sqlx::PgPool,
    t: char,
) -> AppResult<(Option<String>, Option<String>, Option<String>, Option<String>, Option<String>, Option<String>)> {
    let row = sqlx::query_as::<_, (Option<String>, Option<String>, Option<String>, Option<String>, Option<String>, Option<String>)>(
        "SELECT name, description, characteristics, strengths, weaknesses, job_match FROM holland_descriptions WHERE riasec_type = $1",
    )
    .bind(t.to_string())
    .fetch_optional(pool)
    .await
    .map_err(|e| AppError::from_sqlx("load_holland_desc", e))?;
    Ok(row.unwrap_or((None, None, None, None, None, None)))
}

pub async fn result_me(
    State(state): State<AppState>,
    auth: AuthUser,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SISWA"])?;
    let row = sqlx::query_as::<_, HollandResult>(&format!(
        "SELECT {SEL} FROM holland_results WHERE auth_user_id = $1"
    ))
    .bind(&auth.user_id)
    .fetch_optional(&state.pool)
    .await
    .map_err(|e| AppError::from_sqlx("holland_result_me", e))?
    .ok_or_else(|| AppError::NotFound("Holland result not found".to_string()))?;
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
    Ok(Json(list_scoped(&state, &auth, &pp).await?))
}

async fn list_scoped(state: &AppState, auth: &AuthUser, params: &PageParams) -> AppResult<serde_json::Value> {
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
    let _ = auth;
    let size = params.size_clamped();
    let offset = params.offset();

    if params.is_paginated() {
        let count_sql = format!("SELECT COUNT(*) FROM holland_results{where_sql}");
        let mut cq = sqlx::query_scalar::<_, i64>(&count_sql);
        for b in &binds { cq = cq.bind(b); }
        let total: i64 = cq.fetch_one(&state.pool).await.map_err(|e| AppError::from_sqlx("count_holland", e))?;
        let sql = format!("SELECT {SEL} FROM holland_results{where_sql} ORDER BY {} {} LIMIT ${} OFFSET ${}", order_col, order, idx, idx + 1);
        let mut q = sqlx::query_as::<_, HollandResult>(&sql);
        for b in &binds { q = q.bind(b); }
        let rows: Vec<HollandResult> = q.bind(size).bind(offset).fetch_all(&state.pool).await.map_err(|e| AppError::from_sqlx("list_holland", e))?;
        let items: Vec<serde_json::Value> = rows.iter().map(|r| r.as_json()).collect();
        Ok(serde_json::to_value(PageResponse::new(items, params.page_or_zero(), size, total)).unwrap())
    } else {
        let sql = format!("SELECT {SEL} FROM holland_results{where_sql} ORDER BY {} {}", order_col, order);
        let mut q = sqlx::query_as::<_, HollandResult>(&sql);
        for b in &binds { q = q.bind(b); }
        let rows: Vec<HollandResult> = q.fetch_all(&state.pool).await.map_err(|e| AppError::from_sqlx("list_holland", e))?;
        Ok(serde_json::json!(rows.iter().map(|r| r.as_json()).collect::<Vec<_>>()))
    }
}

pub async fn result_by_user(
    State(state): State<AppState>,
    auth: AuthUser,
    Path(auth_user_id): Path<String>,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SUPERADMIN", "GURUBK", "AFILIATOR", "PSIKOLOG"])?;
    let row = sqlx::query_as::<_, HollandResult>(&format!(
        "SELECT {SEL} FROM holland_results WHERE auth_user_id = $1"
    ))
    .bind(&auth_user_id)
    .fetch_optional(&state.pool)
    .await
    .map_err(|e| AppError::from_sqlx("holland_by_user", e))?
    .ok_or_else(|| AppError::NotFound(format!("Holland result not found for user: {auth_user_id}")))?;
    Ok(Json(row.as_json()))
}

pub async fn delete_own_result(
    State(state): State<AppState>,
    auth: AuthUser,
) -> AppResult<axum::http::StatusCode> {
    sqlx::query("DELETE FROM holland_results WHERE auth_user_id = $1")
        .bind(&auth.user_id)
        .execute(&state.pool)
        .await
        .map_err(|e| AppError::from_sqlx("delete_holland_result", e))?;
    Ok(axum::http::StatusCode::NO_CONTENT)
}
