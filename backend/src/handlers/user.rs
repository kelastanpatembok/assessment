use axum::{
    extract::{Path, Query, State},
    http::StatusCode,
    Json,
};
use serde::Deserialize;

use crate::{
    auth_extractor::AuthUser,
    db,
    error::{AppError, AppResult},
    paging::{PageParams, PageResponse},
    state::AppState,
};

#[derive(Deserialize)]
pub struct CreateUserRequest {
    pub username: String,
    pub email: String,
    pub password: String,
    pub name: String,
    pub role: String,
    pub school_id: Option<i64>,
}

#[derive(Deserialize)]
pub struct UpdateUserRequest {
    pub name: Option<String>,
    pub email: Option<String>,
    pub school_id: Option<i64>,
    pub password: Option<String>,
}

const SORT_WHITELIST: [&str; 6] = ["name", "username", "email", "role", "school.name", "createdAt"];

/// Register a user in auth, then provision the assessment_users row.
async fn create_via_auth(
    state: &AppState,
    username: &str,
    email: &str,
    password: &str,
    name: &str,
    role: &str,
) -> AppResult<crate::models::user::AssessmentUser> {
    let resp = state
        .auth
        .register(username, email, password, name, role)
        .await
        .map_err(|e| AppError::Internal(e))?;
    let auth_user_id = resp.user.id;

    let row = sqlx::query_as::<_, crate::models::user::AssessmentUserRow>(
        "INSERT INTO assessment_users (auth_user_id, name, email, username, role, created_at, updated_at) \
         VALUES ($1, $2, $3, $4, $5, NOW(), NOW()) RETURNING auth_user_id, name, email, username, role, school_id, afiliator_id, created_at, updated_at",
    )
    .bind(&auth_user_id)
    .bind(name)
    .bind(email)
    .bind(username)
    .bind(role)
    .fetch_one(&state.pool)
    .await
    .map_err(|e| AppError::from_sqlx("provision_profile", e))?;

    db::assemble_user(&state.pool, row).await
}

#[derive(Deserialize)]
pub struct UserListParams {
    #[serde(flatten)]
    pub page: PageParams,
    pub role: Option<String>,
}

pub async fn list(
    State(state): State<AppState>,
    auth: AuthUser,
    Query(params): Query<UserListParams>,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SUPERADMIN"])?;
    // Non-paginated branch in the Java code ignores all filters and returns findAll().
    if !params.page.is_paginated() {
        let rows: Vec<crate::models::user::AssessmentUserRow> = sqlx::query_as(
            "SELECT auth_user_id, name, email, username, role, school_id, afiliator_id, created_at, updated_at \
             FROM assessment_users",
        )
        .fetch_all(&state.pool)
        .await
        .map_err(|e| AppError::from_sqlx("list_users", e))?;
        let mut out = Vec::new();
        for r in rows {
            out.push(db::assemble_user(&state.pool, r).await?.as_json());
        }
        return Ok(Json(serde_json::json!(out)));
    }

    let mut conds: Vec<String> = Vec::new();
    let mut binds: Vec<String> = Vec::new();
    let mut idx = 1usize;
    if let Some(search) = params.page.search.as_deref() {
        if !search.trim().is_empty() {
            conds.push(format!(
                "(LOWER(name) LIKE ${} OR LOWER(username) LIKE ${} OR LOWER(email) LIKE ${})",
                idx, idx, idx
            ));
            binds.push(format!("%{}%", search.trim().to_lowercase()));
            idx += 1;
        }
    }
    if let Some(role) = params.role.as_deref() {
        if !role.trim().is_empty() {
            conds.push(format!("role = ${}", idx));
            binds.push(role.trim().to_string());
            idx += 1;
        }
    }
    let where_sql = if conds.is_empty() {
        String::new()
    } else {
        format!(" WHERE {}", conds.join(" AND "))
    };

    let sort = params.page.sort_key(&SORT_WHITELIST, "createdAt");
    let order = params.page.order_dir();
    let size = params.page.size_clamped();
    let offset = params.page.offset();

        let order_col = params.page.sort_col(sort);

    let count_sql = format!("SELECT COUNT(*) FROM assessment_users{where_sql}");
    let mut cq = sqlx::query_scalar::<_, i64>(&count_sql);
    for b in &binds {
        cq = cq.bind(b);
    }
    let total: i64 = cq
        .fetch_one(&state.pool)
        .await
        .map_err(|e| AppError::from_sqlx("count_users", e))?;

    let sql = format!(
        "SELECT auth_user_id, name, email, username, role, school_id, afiliator_id, created_at, updated_at \
         FROM assessment_users{where_sql} ORDER BY {} {} LIMIT ${} OFFSET ${}",
        order_col,
        order,
        idx,
        idx + 1
    );
    let mut q = sqlx::query_as::<_, crate::models::user::AssessmentUserRow>(&sql);
    for b in &binds {
        q = q.bind(b);
    }
    let rows: Vec<crate::models::user::AssessmentUserRow> = q
        .bind(size)
        .bind(offset)
        .fetch_all(&state.pool)
        .await
        .map_err(|e| AppError::from_sqlx("list_users", e))?;

    let mut items = Vec::new();
    for r in rows {
        items.push(db::assemble_user(&state.pool, r).await?.as_json());
    }
    Ok(Json(serde_json::to_value(PageResponse::new(items, params.page.page_or_zero(), size, total)).unwrap()))
}

pub async fn me(
    State(state): State<AppState>,
    auth: AuthUser,
) -> AppResult<Json<serde_json::Value>> {
    let user = db::require_user(&state.pool, &auth.user_id).await?;
    Ok(Json(user.as_json()))
}

pub async fn create(
    State(state): State<AppState>,
    auth: AuthUser,
    Json(req): Json<CreateUserRequest>,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SUPERADMIN"])?;
    let user = match req.role.as_str() {
        "gurubk" => {
            let school_id = req.school_id.ok_or_else(|| {
                AppError::Internal(anyhow::anyhow!("schoolId required for gurubk"))
            })?;
            db::require_school(&state.pool, school_id).await?;
            let mut u = create_via_auth(
                &state,
                &req.username,
                &req.email,
                &req.password,
                &req.name,
                "gurubk",
            )
            .await?;
            u.school = Some(db::require_school(&state.pool, school_id).await?);
            u
        }
        "afiliator" => {
            create_via_auth(&state, &req.username, &req.email, &req.password, &req.name, "afiliator").await?
        }
        "psikolog" => {
            create_via_auth(&state, &req.username, &req.email, &req.password, &req.name, "psikolog").await?
        }
        _ => {
            return Err(AppError::Internal(anyhow::anyhow!(
                "Use /students for siswa role"
            )));
        }
    };
    Ok(Json(user.as_json()))
}

pub async fn update(
    State(state): State<AppState>,
    auth: AuthUser,
    Path(auth_user_id): Path<String>,
    Json(req): Json<UpdateUserRequest>,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SUPERADMIN"])?;
    let row = db::load_user(&state.pool, &auth_user_id)
        .await?
        .ok_or_else(|| AppError::NotFound(format!("User not found: {auth_user_id}")))?;

    let name = req.name.clone().filter(|s| !s.trim().is_empty());
    let email = req.email.clone().filter(|s| !s.trim().is_empty());
    let school_id = req.school_id; // null clears school

    if let Some(password) = req.password.as_deref().filter(|s| !s.trim().is_empty()) {
        let username = row.username.clone();
        if state.auth.change_password(&auth_user_id, &username, password).await.is_err() {
            // Match the Java backend: the Rust auth service rejects admin-driven
            // resets (needs currentPassword + bearer), which surfaced as a 500.
            return Err(AppError::Internal(anyhow::anyhow!(
                "Failed to change password in auth service"
            )));
        }
    }

    let updated = sqlx::query_as::<_, crate::models::user::AssessmentUserRow>(
        "UPDATE assessment_users SET \
            name = COALESCE($2, name), \
            email = COALESCE($3, email), \
            school_id = $4, \
            updated_at = NOW() \
         WHERE auth_user_id = $1 \
         RETURNING auth_user_id, name, email, username, role, school_id, afiliator_id, created_at, updated_at",
    )
    .bind(&auth_user_id)
    .bind(name.as_deref().unwrap_or(&row.name))
    .bind(email.as_deref().unwrap_or(&row.email))
    .bind(school_id)
    .fetch_one(&state.pool)
    .await
    .map_err(|e| AppError::from_sqlx("update_user", e))?;

    let user = db::assemble_user(&state.pool, updated).await?;
    Ok(Json(user.as_json()))
}

pub async fn delete(
    State(state): State<AppState>,
    auth: AuthUser,
    Path(auth_user_id): Path<String>,
) -> AppResult<StatusCode> {
    auth.require_role(&["SUPERADMIN"])?;
    let result = sqlx::query("DELETE FROM assessment_users WHERE auth_user_id = $1")
        .bind(&auth_user_id)
        .execute(&state.pool)
        .await
        .map_err(|e| AppError::from_sqlx("delete_user", e))?;
    if result.rows_affected() == 0 {
        return Err(AppError::NotFound(format!("User not found: {auth_user_id}")));
    }
    Ok(StatusCode::NO_CONTENT)
}

pub async fn by_role(
    State(state): State<AppState>,
    auth: AuthUser,
    Path(role): Path<String>,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SUPERADMIN", "GURUBK"])?;
    let rows: Vec<crate::models::user::AssessmentUserRow> = sqlx::query_as(
        "SELECT auth_user_id, name, email, username, role, school_id, afiliator_id, created_at, updated_at \
         FROM assessment_users WHERE role = $1",
    )
    .bind(&role)
    .fetch_all(&state.pool)
    .await
    .map_err(|e| AppError::from_sqlx("by_role", e))?;
    let mut out = Vec::new();
    for r in rows {
        out.push(db::assemble_user(&state.pool, r).await?.as_json());
    }
    Ok(Json(serde_json::json!(out)))
}

pub async fn by_school(
    State(state): State<AppState>,
    auth: AuthUser,
    Path(school_id): Path<i64>,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SUPERADMIN", "GURUBK"])?;
    let rows: Vec<crate::models::user::AssessmentUserRow> = sqlx::query_as(
        "SELECT auth_user_id, name, email, username, role, school_id, afiliator_id, created_at, updated_at \
         FROM assessment_users WHERE school_id = $1",
    )
    .bind(school_id)
    .fetch_all(&state.pool)
    .await
    .map_err(|e| AppError::from_sqlx("by_school", e))?;
    let mut out = Vec::new();
    for r in rows {
        out.push(db::assemble_user(&state.pool, r).await?.as_json());
    }
    Ok(Json(serde_json::json!(out)))
}
