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
    pub npsn: Option<String>,
    pub address: Option<String>,
    pub city: Option<String>,
    pub province: Option<String>,
    pub phone: Option<String>,
    pub email: Option<String>,
}

const SORT_WHITELIST: [&str; 4] = ["name", "city", "province", "createdAt"];

#[derive(Deserialize)]
pub struct PublicSchoolSearch { pub search: Option<String> }
#[derive(Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct PublicSchoolMapQuery {
    pub min_lat: Option<f64>, pub max_lat: Option<f64>, pub min_lng: Option<f64>, pub max_lng: Option<f64>,
    pub search: Option<String>,
}

fn public_school_type(name: &str, configured: Option<String>) -> String {
    if let Some(value) = configured.filter(|value| !value.trim().is_empty()) { return value; }
    let normalized = name.to_ascii_uppercase();
    if normalized.contains("SMK") { "SMK".into() }
    else if normalized.contains("SMA") || normalized.contains("MA ") || normalized.starts_with("MA ") { "SMA/MA".into() }
    else if normalized.contains("SMP") || normalized.contains("MTS") { "SMP/MTs".into() }
    else if normalized.contains("SD ") || normalized.starts_with("SD") || normalized.contains("MI ") { "SD/MI".into() }
    else { "Lainnya".into() }
}

/// Safe, small selector used by onboarding and the public map search. Contact
/// details are deliberately excluded from this public projection.
pub async fn public_search(
    State(state): State<AppState>,
    Query(params): Query<PublicSchoolSearch>,
) -> AppResult<Json<serde_json::Value>> {
    let search = params.search.unwrap_or_default().trim().to_string();
    if search.len() < 2 { return Ok(Json(serde_json::json!({"items":[]}))); }
    let rows: Vec<(i64, Option<String>, String, Option<String>, Option<String>)> = sqlx::query_as(
        "SELECT id,npsn,name,city,province FROM schools WHERE LOWER(name) LIKE $1 OR npsn ILIKE $1 ORDER BY name ASC LIMIT 20",
    ).bind(format!("%{}%",search.to_lowercase())).fetch_all(&state.pool).await.map_err(|e| AppError::from_sqlx("public_school_search",e))?;
    Ok(Json(serde_json::json!({"items":rows.into_iter().map(|r|serde_json::json!({"id":r.0,"npsn":r.1,"name":r.2,"city":r.3,"province":r.4})).collect::<Vec<_>>() })))
}

/// Map points are deliberately bounded to the current viewport.  The browser
/// never receives the entire national directory in one request.
pub async fn public_map(
    State(state): State<AppState>, Query(params): Query<PublicSchoolMapQuery>,
) -> AppResult<Json<serde_json::Value>> {
    let (min_lat,max_lat,min_lng,max_lng)=(params.min_lat.unwrap_or(-11.1),params.max_lat.unwrap_or(6.3),params.min_lng.unwrap_or(94.6),params.max_lng.unwrap_or(141.1));
    if min_lat >= max_lat || min_lng >= max_lng || !(-90.0..=90.0).contains(&min_lat) || !(-90.0..=90.0).contains(&max_lat) || !(-180.0..=180.0).contains(&min_lng) || !(-180.0..=180.0).contains(&max_lng) { return Err(AppError::BadRequest("Batas peta tidak valid".into())); }
    let search=params.search.unwrap_or_default().trim().to_lowercase();
    let rows:Vec<(i64,Option<String>,String,Option<String>,Option<String>,Option<String>,f64,f64,Option<String>)>=sqlx::query_as(
        "SELECT id,npsn,name,address,city,province,latitude,longitude,school_type FROM schools WHERE latitude BETWEEN $1 AND $2 AND longitude BETWEEN $3 AND $4 AND ($5='' OR LOWER(name) LIKE '%' || $5 || '%' OR npsn ILIKE '%' || $5 || '%') ORDER BY name ASC LIMIT 1200"
    ).bind(min_lat).bind(max_lat).bind(min_lng).bind(max_lng).bind(search).fetch_all(&state.pool).await.map_err(|e|AppError::from_sqlx("public_school_map",e))?;
    let items=rows.into_iter().map(|r| {let kind=public_school_type(&r.2,r.8);serde_json::json!({"id":r.0,"npsn":r.1,"name":r.2,"address":r.3,"city":r.4,"province":r.5,"latitude":r.6,"longitude":r.7,"type":kind})}).collect::<Vec<_>>();
    Ok(Json(serde_json::json!({"items":items,"limit":1200})))
}

pub async fn public_detail(State(state):State<AppState>,Path(id):Path<i64>)->AppResult<Json<serde_json::Value>>{
 let row:Option<(i64,Option<String>,String,Option<String>,Option<String>,Option<String>,Option<f64>,Option<f64>,Option<String>)>=sqlx::query_as("SELECT id,npsn,name,address,city,province,latitude,longitude,school_type FROM schools WHERE id=$1").bind(id).fetch_optional(&state.pool).await.map_err(|e|AppError::from_sqlx("public_school_detail",e))?;
 let r=row.ok_or_else(||AppError::NotFound("Sekolah tidak ditemukan".into()))?;let kind=public_school_type(&r.2,r.8);
 Ok(Json(serde_json::json!({"id":r.0,"npsn":r.1,"name":r.2,"address":r.3,"city":r.4,"province":r.5,"latitude":r.6,"longitude":r.7,"type":kind})))
}

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
    if let Some(npsn) = &req.npsn {
        if db::find_school_by_npsn(&state.pool, npsn).await?.is_some() {
            return Err(AppError::Conflict(format!(
                "School with NPSN '{}' already exists",
                npsn
            )));
        }
    }
    let row = sqlx::query_as::<_, (i64, Option<String>, String, Option<String>, Option<String>, Option<String>, Option<String>, Option<String>, chrono::NaiveDateTime, chrono::NaiveDateTime)>(
        "INSERT INTO schools (name, npsn, address, city, province, phone, email, created_at, updated_at) \
         VALUES ($1, $2, $3, $4, $5, $6, $7, NOW(), NOW()) \
         RETURNING id, npsn, name, address, city, province, phone, email, created_at, updated_at",
    )
    .bind(&req.name)
    .bind(&req.npsn)
    .bind(&req.address)
    .bind(&req.city)
    .bind(&req.province)
    .bind(&req.phone)
    .bind(&req.email)
    .fetch_one(&state.pool)
    .await
    .map_err(|e| AppError::from_sqlx("create_school", e))?;

    Ok(Json(school_json(&row)))
}

pub async fn list(
    State(state): State<AppState>,
    auth: AuthUser,
    Query(params): Query<PageParams>,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SUPERADMIN", "GURUBK"])?;
    let mut where_sql = String::new();
    if params.has_search() {
        where_sql = " WHERE LOWER(name) LIKE $1 OR LOWER(npsn) LIKE $1 OR LOWER(address) LIKE $1 OR LOWER(city) LIKE $1 OR LOWER(province) LIKE $1"
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
            "SELECT id, npsn, name, address, city, province, phone, email, created_at, updated_at \
             FROM schools{where_sql} ORDER BY {} {} LIMIT ${} OFFSET ${}",
            sort,
            order,
            lim_idx,
            off_idx
        );
        let rows: Vec<(i64, Option<String>, String, Option<String>, Option<String>, Option<String>, Option<String>, Option<String>, chrono::NaiveDateTime, chrono::NaiveDateTime)> =
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
            "SELECT id, npsn, name, address, city, province, phone, email, created_at, updated_at \
             FROM schools{where_sql}"
        );
        let rows: Vec<(i64, Option<String>, String, Option<String>, Option<String>, Option<String>, Option<String>, Option<String>, chrono::NaiveDateTime, chrono::NaiveDateTime)> =
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
    if let Some(npsn) = &req.npsn {
        if let Some(existing) = db::find_school_by_npsn(&state.pool, npsn).await? {
            if existing.id != id {
                return Err(AppError::Conflict(format!(
                    "School with NPSN '{}' already exists",
                    npsn
                )));
            }
        }
    }
    let row = sqlx::query_as::<_, (i64, Option<String>, String, Option<String>, Option<String>, Option<String>, Option<String>, Option<String>, chrono::NaiveDateTime, chrono::NaiveDateTime)>(
        "UPDATE schools SET name = $2, npsn = $3, address = $4, city = $5, province = $6, phone = $7, email = $8, updated_at = NOW() \
         WHERE id = $1 RETURNING id, npsn, name, address, city, province, phone, email, created_at, updated_at",
    )
    .bind(id)
    .bind(&req.name)
    .bind(&req.npsn)
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
    r: &(i64, Option<String>, String, Option<String>, Option<String>, Option<String>, Option<String>, Option<String>, chrono::NaiveDateTime, chrono::NaiveDateTime),
) -> serde_json::Value {
    School {
        id: r.0,
        npsn: r.1.clone(),
        name: r.2.clone(),
        address: r.3.clone(),
        city: r.4.clone(),
        province: r.5.clone(),
        phone: r.6.clone(),
        email: r.7.clone(),
        created_at: r.8,
        updated_at: r.9,
    }
    .as_json()
}
