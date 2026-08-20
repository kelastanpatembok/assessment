use axum::{
    extract::{Path, Query, State},
    http::StatusCode,
    Json,
};
use bigdecimal::BigDecimal;
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
#[serde(rename_all = "camelCase")]
pub struct CreateStudentRequest {
    pub username: String,
    pub email: String,
    pub password: String,
    pub name: String,
    pub school_id: i64,
    pub afiliator_id: Option<String>,
    pub category_id: i64,
    pub date_of_birth: Option<chrono::NaiveDate>,
    pub gender: Option<String>,
}

#[derive(Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct CreateCounselorRequest {
    pub username: String,
    pub email: String,
    pub password: String,
    pub name: String,
    pub school_id: i64,
}

#[derive(Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct CreateAfiliatorRequest {
    pub username: String,
    pub email: String,
    pub password: String,
    pub name: String,
}

const SORT_WHITELIST: [&str; 5] = ["name", "username", "email", "school.name", "createdAt"];

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

    let row = sqlx::query_as::<_, AssessmentUserRow>(
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

/// First gurubk id for a school (or null).
async fn first_gurubk_for_school(state: &AppState, school_id: i64) -> AppResult<Option<String>> {
    let rows: Vec<AssessmentUserRow> = sqlx::query_as(
        "SELECT auth_user_id, name, email, username, role, school_id, afiliator_id, created_at, updated_at \
         FROM assessment_users WHERE school_id = $1",
    )
    .bind(school_id)
    .fetch_all(&state.pool)
    .await
    .map_err(|e| AppError::from_sqlx("findBySchoolId", e))?;
    Ok(rows.into_iter().find(|u| u.role == "gurubk").map(|u| u.auth_user_id))
}

fn round2(v: BigDecimal) -> BigDecimal {
    v.with_scale(2)
}

pub async fn create_student(
    State(state): State<AppState>,
    auth: AuthUser,
    Json(req): Json<CreateStudentRequest>,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SUPERADMIN", "GURUBK", "AFILIATOR"])?;
    // Scope overrides: gurubk forces own school; afiliator forces self.
    let school_id = if auth.is_role("gurubk") {
        db::load_user(&state.pool, &auth.user_id)
            .await?
            .and_then(|u| u.school_id)
            .unwrap_or(req.school_id)
    } else {
        req.school_id
    };
    let afiliator_id = if auth.is_role("afiliator") {
        Some(auth.user_id.clone())
    } else {
        req.afiliator_id.clone()
    };

    db::require_school(&state.pool, school_id).await?;

    let mut user = create_via_auth(
        &state,
        &req.username,
        &req.email,
        &req.password,
        &req.name,
        "siswa",
    )
    .await?;
    user.school = Some(db::require_school(&state.pool, school_id).await?);
    user.afiliator_id = afiliator_id.clone();

    sqlx::query("UPDATE assessment_users SET school_id = $2, afiliator_id = $3, updated_at = NOW() WHERE auth_user_id = $1")
        .bind(&user.auth_user_id)
        .bind(school_id)
        .bind(&afiliator_id)
        .execute(&state.pool)
        .await
        .map_err(|e| AppError::from_sqlx("update_student_school", e))?;

    if req.date_of_birth.is_some() || req.gender.as_deref().is_some_and(|value| !value.trim().is_empty()) {
        sqlx::query(
            "INSERT INTO student_profiles (auth_user_id,date_of_birth,gender,updated_at) VALUES ($1,$2,$3,NOW()) \
             ON CONFLICT (auth_user_id) DO UPDATE SET date_of_birth=EXCLUDED.date_of_birth,gender=EXCLUDED.gender,updated_at=NOW()",
        )
        .bind(&user.auth_user_id)
        .bind(req.date_of_birth)
        .bind(req.gender.as_deref().map(str::trim).filter(|value| !value.is_empty()))
        .execute(&state.pool)
        .await
        .map_err(|e| AppError::from_sqlx("save_student_profile", e))?;
    }

    // Fee config: category-specific or global.
    let config_row = sqlx::query_as::<_, crate::models::fee::FeeConfigRow>(
        "SELECT id, category_id, student_fee, afiliator_share_pct, gurubk_share_pct, platform_share_pct, updated_at \
         FROM fee_config WHERE category_id = $1",
    )
    .bind(req.category_id)
    .fetch_optional(&state.pool)
    .await
    .map_err(|e| AppError::from_sqlx("findFeeConfig", e))?;
    let config = match config_row {
        Some(c) => c,
        None => sqlx::query_as::<_, crate::models::fee::FeeConfigRow>(
            "SELECT id, category_id, student_fee, afiliator_share_pct, gurubk_share_pct, platform_share_pct, updated_at \
             FROM fee_config WHERE category_id IS NULL",
        )
        .fetch_optional(&state.pool)
        .await
        .map_err(|e| AppError::from_sqlx("findGlobalFeeConfig", e))?
        .ok_or_else(|| AppError::BadRequest("No fee config found for category or global".to_string()))?,
    };

    let category = sqlx::query_as::<_, crate::models::test_category::TestCategoryRow>(
        "SELECT id, name, slug, description, tests, price, is_active, created_at FROM test_categories WHERE id = $1",
    )
    .bind(req.category_id)
    .fetch_optional(&state.pool)
    .await
    .map_err(|e| AppError::from_sqlx("findCategory", e))?
    .ok_or_else(|| AppError::NotFound(format!("Category not found: {}", req.category_id)))?;

    let total = config.student_fee.0.clone();
    let afiliator_share = round2(
        total.clone() * config.afiliator_share_pct.0.clone() / BigDecimal::from(100),
    );
    let gurubk_share = round2(total.clone() * config.gurubk_share_pct.0.clone() / BigDecimal::from(100));
    let platform_share = round2(total.clone() * config.platform_share_pct.0.clone() / BigDecimal::from(100));

    let gurubk_id = first_gurubk_for_school(&state, school_id).await?;

    sqlx::query(
        "INSERT INTO fee_shares (student_id, category_id, afiliator_id, gurubk_id, total_fee, afiliator_share, gurubk_share, platform_share, created_at) \
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, NOW())",
    )
    .bind(&user.auth_user_id)
    .bind(category.id)
    .bind(&afiliator_id)
    .bind(&gurubk_id)
    .bind(&total)
    .bind(&afiliator_share)
    .bind(&gurubk_share)
    .bind(&platform_share)
    .execute(&state.pool)
    .await
    .map_err(|e| AppError::from_sqlx("save_fee_share", e))?;

    Ok(Json(user.as_json()))
}

pub async fn create_counselor(
    State(state): State<AppState>,
    auth: AuthUser,
    Json(req): Json<CreateCounselorRequest>,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SUPERADMIN"])?;
    db::require_school(&state.pool, req.school_id).await?;
    let mut user = create_via_auth(
        &state,
        &req.username,
        &req.email,
        &req.password,
        &req.name,
        "gurubk",
    )
    .await?;
    user.school = Some(db::require_school(&state.pool, req.school_id).await?);
    sqlx::query("UPDATE assessment_users SET school_id = $2, updated_at = NOW() WHERE auth_user_id = $1")
        .bind(&user.auth_user_id)
        .bind(req.school_id)
        .execute(&state.pool)
        .await
        .map_err(|e| AppError::from_sqlx("update_counselor_school", e))?;
    Ok(Json(user.as_json()))
}

pub async fn create_afiliator(
    State(state): State<AppState>,
    auth: AuthUser,
    Json(req): Json<CreateAfiliatorRequest>,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SUPERADMIN"])?;
    let user = create_via_auth(
        &state,
        &req.username,
        &req.email,
        &req.password,
        &req.name,
        "afiliator",
    )
    .await?;
    Ok(Json(user.as_json()))
}

pub async fn list(
    State(state): State<AppState>,
    auth: AuthUser,
    Query(params): Query<PageParams>,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SUPERADMIN", "GURUBK", "AFILIATOR", "PSIKOLOG"])?;
    // Build scoped WHERE.
    let mut conds: Vec<String> = Vec::new();
    let mut idx = 1usize;
    conds.push("role = 'siswa'".to_string());

    // Build a single bind vector in order; school_id is bigint so it must be
    // bound as i64, not a text string.
    enum Bind {
        Text(String),
        Int(i64),
    }
    let mut binds: Vec<Bind> = Vec::new();

    if auth.is_role("gurubk") {
        match db::load_user(&state.pool, &auth.user_id).await? {
            Some(u) if u.school_id.is_some() => {
                conds.push(format!("school_id = ${}", idx));
                binds.push(Bind::Int(u.school_id.unwrap()));
                idx += 1;
            }
            _ => {
                // no school -> empty page
                return Ok(Json(serde_json::json!({
                    "items": [], "page": params.page_or_zero(), "size": params.size_clamped(),
                    "totalElements": 0, "totalPages": 0
                })));
            }
        }
    } else if auth.is_role("afiliator") {
        conds.push(format!("afiliator_id = ${}", idx));
        binds.push(Bind::Text(auth.user_id.clone()));
        idx += 1;
    }

    if params.has_search() {
        conds.push(format!(
            "(LOWER(name) LIKE ${} OR LOWER(username) LIKE ${} OR LOWER(email) LIKE ${})",
            idx, idx, idx
        ));
        binds.push(Bind::Text(params.search_like()));
        idx += 1;
    }

    let where_sql = format!(" WHERE {}", conds.join(" AND "));
    let sort = params.sort_key(&SORT_WHITELIST, "createdAt");
    let order = params.order_dir();
        let order_col = params.sort_col(sort);
    let size = params.size_clamped();
    let offset = params.offset();

    if params.is_paginated() {
        let count_sql = format!("SELECT COUNT(*) FROM assessment_users{where_sql}");
        let mut cq = sqlx::query_scalar::<_, i64>(&count_sql);
        for b in &binds {
            match b {
                Bind::Text(s) => { cq = cq.bind(s); }
                Bind::Int(i) => { cq = cq.bind(i); }
            }
        }
        let total: i64 = cq
            .fetch_one(&state.pool)
            .await
            .map_err(|e| AppError::from_sqlx("count_students", e))?;

        let sql = format!(
            "SELECT auth_user_id, name, email, username, role, school_id, afiliator_id, created_at, updated_at \
             FROM assessment_users{where_sql} ORDER BY {} {} LIMIT ${} OFFSET ${}",
            order_col,
            order,
            idx,
            idx + 1
        );
        let mut q = sqlx::query_as::<_, AssessmentUserRow>(&sql);
        for b in &binds {
            match b {
                Bind::Text(s) => { q = q.bind(s); }
                Bind::Int(i) => { q = q.bind(i); }
            }
        }
        let rows: Vec<AssessmentUserRow> = q
            .bind(size)
            .bind(offset)
            .fetch_all(&state.pool)
            .await
            .map_err(|e| AppError::from_sqlx("list_students", e))?;
        let mut items = Vec::new();
        for r in rows {
            items.push(db::assemble_user(&state.pool, r).await?.as_json());
        }
        Ok(Json(serde_json::to_value(PageResponse::new(items, params.page_or_zero(), size, total)).unwrap()))
    } else {
        let sql = format!(
            "SELECT auth_user_id, name, email, username, role, school_id, afiliator_id, created_at, updated_at \
             FROM assessment_users{where_sql}"
        );
        let mut q = sqlx::query_as::<_, AssessmentUserRow>(&sql);
        for b in &binds {
            match b {
                Bind::Text(s) => { q = q.bind(s); }
                Bind::Int(i) => { q = q.bind(i); }
            }
        }
        let rows: Vec<AssessmentUserRow> = q
            .fetch_all(&state.pool)
            .await
            .map_err(|e| AppError::from_sqlx("list_students", e))?;
        let mut out = Vec::new();
        for r in rows {
            out.push(db::assemble_user(&state.pool, r).await?.as_json());
        }
        Ok(Json(serde_json::json!(out)))
    }
}

pub async fn get(
    State(state): State<AppState>,
    auth: AuthUser,
    Path(auth_user_id): Path<String>,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SUPERADMIN", "GURUBK", "AFILIATOR", "PSIKOLOG"])?;
    let user = db::require_user(&state.pool, &auth_user_id).await?;
    Ok(Json(user.as_json()))
}

pub async fn delete(
    State(state): State<AppState>,
    auth: AuthUser,
    Path(auth_user_id): Path<String>,
) -> AppResult<StatusCode> {
    auth.require_role(&["SUPERADMIN", "GURUBK", "AFILIATOR"])?;
    sqlx::query("DELETE FROM fee_shares WHERE student_id = $1")
        .bind(&auth_user_id)
        .execute(&state.pool)
        .await
        .map_err(|e| AppError::from_sqlx("delete_fee_share", e))?;
    let result = sqlx::query("DELETE FROM assessment_users WHERE auth_user_id = $1")
        .bind(&auth_user_id)
        .execute(&state.pool)
        .await
        .map_err(|e| AppError::from_sqlx("delete_student", e))?;
    if result.rows_affected() == 0 {
        return Err(AppError::NotFound(format!("Student not found: {auth_user_id}")));
    }
    Ok(StatusCode::NO_CONTENT)
}
