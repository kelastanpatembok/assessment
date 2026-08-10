use axum::{
    extract::{Query, State},
    Json,
};
use serde::Deserialize;

use crate::{
    auth_extractor::AuthUser,
    db,
    error::{AppError, AppResult},
    models::user::AssessmentUserRow,
    paging::{PageParams, PageResponse},
    state::AppState,
};

#[derive(Deserialize)]
pub struct SearchParams {
    #[serde(flatten)]
    pub page: PageParams,
    pub query: String,
}

const SORT_WHITELIST: [&str; 3] = ["name", "username", "createdAt"];

pub async fn search(
    State(state): State<AppState>,
    auth: AuthUser,
    Query(params): Query<SearchParams>,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SUPERADMIN", "PSIKOLOG"])?;
    let query = params.query.trim();
    if query.chars().count() < 2 {
        if params.page.is_paginated() {
            return Ok(Json(serde_json::to_value(PageResponse::new(Vec::<serde_json::Value>::new(), params.page.page_or_zero(), params.page.size_clamped(), 0)).unwrap()));
        }
        return Ok(Json(serde_json::json!([])));
    }

    let like = format!("%{}%", query.to_lowercase());

    if params.page.is_paginated() {
        let role_cond = " AND role = 'siswa'";
        let total: i64 = sqlx::query_scalar::<_, i64>(
            "SELECT COUNT(*) FROM assessment_users WHERE (LOWER(username) LIKE $1 OR LOWER(name) LIKE $1)",
        )
        .bind(&like)
        .fetch_one(&state.pool)
        .await
        .map_err(|e| AppError::from_sqlx("psikolog_count", e))?;
        let _ = role_cond;
        let sort = params.page.sort_key(&SORT_WHITELIST, "name");
        let sort = params.page.sort_col(sort);
        let order = params.page.order_dir();
        let size = params.page.size_clamped();
        let offset = params.page.offset();
        let rows: Vec<AssessmentUserRow> = sqlx::query_as(&format!(
            "SELECT auth_user_id, name, email, username, role, school_id, afiliator_id, created_at, updated_at \
             FROM assessment_users WHERE (LOWER(username) LIKE $1 OR LOWER(name) LIKE $1) \
             ORDER BY {} {} LIMIT $2 OFFSET $3",
            sort, order
        ))
        .bind(&like)
        .bind(size)
        .bind(offset)
        .fetch_all(&state.pool)
        .await
        .map_err(|e| AppError::from_sqlx("psikolog_search", e))?;
        let mut items = Vec::new();
        for r in rows {
            items.push(db::assemble_user(&state.pool, r).await?.as_json());
        }
        return Ok(Json(serde_json::to_value(PageResponse::new(items, params.page.page_or_zero(), size, total)).unwrap()));
    }

    // Non-paginated: top 50 users whose username or name contains the query.
    let rows: Vec<AssessmentUserRow> = sqlx::query_as(
        "SELECT auth_user_id, name, email, username, role, school_id, afiliator_id, created_at, updated_at \
         FROM assessment_users WHERE (LOWER(username) LIKE $1 OR LOWER(name) LIKE $1) ORDER BY name ASC LIMIT 50",
    )
    .bind(&like)
    .fetch_all(&state.pool)
    .await
    .map_err(|e| AppError::from_sqlx("psikolog_search", e))?;
    let mut out = Vec::new();
    for r in rows {
        out.push(db::assemble_user(&state.pool, r).await?.as_json());
    }
    Ok(Json(serde_json::json!(out)))
}
