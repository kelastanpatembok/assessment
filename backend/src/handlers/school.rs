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
    models::school::School,
    paging::{PageParams, PageResponse},
    state::AppState,
};

#[derive(Deserialize)]
pub struct SchoolRequest {
    pub name: String,
    pub address: Option<String>,
    pub city: Option<String>,
    pub province: Option<String>,
    pub phone: Option<String>,
    pub email: Option<String>,
}

const SORT_WHITELIST: [&str; 4] = ["name", "city", "province", "createdAt"];

pub async fn create(
    State(state): State<AppState>,
    auth: AuthUser,
    Json(req): Json<SchoolRequest>,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SUPERADMIN"])?;
    if db::find_school_by_name(&state.pool, &req.name).await?.is_some() {
        return Err(AppError::Conflict(format!(
            "School with name '{}' already exists",
            req.name
        )));
    }
    let row = sqlx::query_as::<_, (i64, String, Option<String>, Option<String>, Option<String>, Option<String>, Option<String>, chrono::NaiveDateTime, chrono::NaiveDateTime)>(
        "INSERT INTO schools (name, address, city, province, phone, email, created_at, updated_at) \
         VALUES ($1, $2, $3, $4, $5, $6, NOW(), NOW()) \
         RETURNING id, name, address, city, province, phone, email, created_at, updated_at",
    )
    .bind(&req.name)
    .bind(&req.address)
    .bind(&req.city)
    .bind(&req.province)
    .bind(&req.phone)
    .bind(&req.email)
    .fetch_one(&state.pool)
    .await
    .map_err(|e| AppError::from_sqlx("create_school", e))?;

    let school = School {
        id: row.0,
        name: row.1,
        address: row.2,
        city: row.3,
        province: row.4,
        phone: row.5,
        email: row.6,
        created_at: row.7,
        updated_at: row.8,
    };
    Ok(Json(school.as_json()))
}

pub async fn list(
    State(state): State<AppState>,
    auth: AuthUser,
    Query(params): Query<PageParams>,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SUPERADMIN", "GURUBK"])?;
    let mut where_sql = String::new();
    if params.has_search() {
        where_sql = " WHERE LOWER(name) LIKE $1 OR LOWER(address) LIKE $1 OR LOWER(city) LIKE $1 OR LOWER(province) LIKE $1"
            .to_string();
    }
    let sort = params.sort_key(&SORT_WHITELIST, "name");
    let sort = params.sort_col(sort);
    let order = params.order_dir();

    if params.is_paginated() {
        let size = params.size_clamped();
        let offset = params.offset();
        let total: i64 = if params.has_search() {
            sqlx::query_scalar::<_, i64>(&format!(
                "SELECT COUNT(*) FROM schools{where_sql}"
            ))
            .bind(params.search_like())
            .fetch_one(&state.pool)
            .await
            .map_err(|e| AppError::from_sqlx("count_schools", e))?
        } else {
            sqlx::query_scalar::<_, i64>("SELECT COUNT(*) FROM schools")
                .fetch_one(&state.pool)
                .await
                .map_err(|e| AppError::from_sqlx("count_schools", e))?
        };
        // Bind indices: $1 is the search param when present, then size/offset.
        let (lim_idx, off_idx) = if params.has_search() { (2i32, 3i32) } else { (1i32, 2i32) };
        let sql = format!(
            "SELECT id, name, address, city, province, phone, email, created_at, updated_at \
             FROM schools{where_sql} ORDER BY {} {} LIMIT ${} OFFSET ${}",
            sort,
            order,
            lim_idx,
            off_idx
        );
        let rows: Vec<(i64, String, Option<String>, Option<String>, Option<String>, Option<String>, Option<String>, chrono::NaiveDateTime, chrono::NaiveDateTime)> =
            if params.has_search() {
                sqlx::query_as(&sql)
                    .bind(params.search_like())
                    .bind(size)
                    .bind(offset)
                    .fetch_all(&state.pool)
                    .await
                    .map_err(|e| AppError::from_sqlx("list_schools", e))?
            } else {
                sqlx::query_as(&sql)
                    .bind(size)
                    .bind(offset)
                    .fetch_all(&state.pool)
                    .await
                    .map_err(|e| AppError::from_sqlx("list_schools", e))?
            };
        let items: Vec<serde_json::Value> = rows.iter().map(|r| school_json(r)).collect();
        Ok(Json(serde_json::to_value(PageResponse::new(items, params.page_or_zero(), size, total)).unwrap()))
    } else {
        let sql = format!(
            "SELECT id, name, address, city, province, phone, email, created_at, updated_at \
             FROM schools{where_sql}"
        );
        let rows: Vec<(i64, String, Option<String>, Option<String>, Option<String>, Option<String>, Option<String>, chrono::NaiveDateTime, chrono::NaiveDateTime)> =
            if params.has_search() {
                sqlx::query_as(&sql)
                    .bind(params.search_like())
                    .fetch_all(&state.pool)
                    .await
                    .map_err(|e| AppError::from_sqlx("list_schools", e))?
            } else {
                sqlx::query_as(&sql)
                    .fetch_all(&state.pool)
                    .await
                    .map_err(|e| AppError::from_sqlx("list_schools", e))?
            };
        Ok(Json(serde_json::json!(rows.iter().map(|r| school_json(r)).collect::<Vec<_>>())))
    }
}

pub async fn get(
    State(state): State<AppState>,
    auth: AuthUser,
    Path(id): Path<i64>,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SUPERADMIN", "GURUBK"])?;
    let school = db::require_school(&state.pool, id).await?;
    Ok(Json(school.as_json()))
}

pub async fn update(
    State(state): State<AppState>,
    auth: AuthUser,
    Path(id): Path<i64>,
    Json(req): Json<SchoolRequest>,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SUPERADMIN"])?;
    db::require_school(&state.pool, id).await?;
    if let Some(existing) = db::find_school_by_name(&state.pool, &req.name).await? {
        if existing.id != id {
            return Err(AppError::Conflict(format!(
                "School with name '{}' already exists",
                req.name
            )));
        }
    }
    let row = sqlx::query_as::<_, (i64, String, Option<String>, Option<String>, Option<String>, Option<String>, Option<String>, chrono::NaiveDateTime, chrono::NaiveDateTime)>(
        "UPDATE schools SET name = $2, address = $3, city = $4, province = $5, phone = $6, email = $7, updated_at = NOW() \
         WHERE id = $1 RETURNING id, name, address, city, province, phone, email, created_at, updated_at",
    )
    .bind(id)
    .bind(&req.name)
    .bind(&req.address)
    .bind(&req.city)
    .bind(&req.province)
    .bind(&req.phone)
    .bind(&req.email)
    .fetch_one(&state.pool)
    .await
    .map_err(|e| AppError::from_sqlx("update_school", e))?;

    Ok(Json(school_json(&row)))
}

pub async fn delete(
    State(state): State<AppState>,
    auth: AuthUser,
    Path(id): Path<i64>,
) -> AppResult<StatusCode> {
    auth.require_role(&["SUPERADMIN"])?;
    let result = sqlx::query("DELETE FROM schools WHERE id = $1")
        .bind(id)
        .execute(&state.pool)
        .await
        .map_err(|e| AppError::from_sqlx("delete_school", e))?;
    if result.rows_affected() == 0 {
        return Err(AppError::NotFound(format!("School not found: {id}")));
    }
    Ok(StatusCode::NO_CONTENT)
}

fn school_json(
    r: &(i64, String, Option<String>, Option<String>, Option<String>, Option<String>, Option<String>, chrono::NaiveDateTime, chrono::NaiveDateTime),
) -> serde_json::Value {
    School {
        id: r.0,
        name: r.1.clone(),
        address: r.2.clone(),
        city: r.3.clone(),
        province: r.4.clone(),
        phone: r.5.clone(),
        email: r.6.clone(),
        created_at: r.7,
        updated_at: r.8,
    }
    .as_json()
}
