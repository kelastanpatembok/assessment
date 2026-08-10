use axum::{
    extract::{Path, Query, State},
    http::StatusCode,
    Json,
};

use crate::{
    auth_extractor::AuthUser,
    error::{AppError, AppResult},
    models::test_category::{TestCategory, TestCategoryRequest, TestCategoryRow},
    paging::{PageParams, PageResponse},
    state::AppState,
};

const SORT_WHITELIST: [&str; 4] = ["name", "slug", "price", "createdAt"];

fn category_json(r: &TestCategoryRow) -> serde_json::Value {
    TestCategory {
        id: r.id,
        name: r.name.clone(),
        slug: r.slug.clone(),
        description: r.description.clone(),
        tests: r.tests.clone(),
        price: r.price.clone(),
        active: r.active,
        created_at: r.created_at,
    }
    .as_json()
}

pub async fn list(
    State(state): State<AppState>,
    _auth: AuthUser,
    Query(params): Query<PageParams>,
) -> AppResult<Json<serde_json::Value>> {
    let mut conds: Vec<String> = vec!["is_active = true".to_string()];
    let mut binds: Vec<String> = Vec::new();
    let mut idx = 2usize;
    if params.has_search() {
        conds.push(format!("(LOWER(name) LIKE ${} OR LOWER(slug) LIKE ${})", idx, idx));
        binds.push(params.search_like());
        idx += 1;
    }
    let where_sql = format!(" WHERE {}", conds.join(" AND "));
    let sort = params.sort_key(&SORT_WHITELIST, "name");
    let sort = params.sort_col(sort);
    let order = params.order_dir();
    let size = params.size_clamped();
    let offset = params.offset();

    if params.is_paginated() {
        let count_sql = format!("SELECT COUNT(*) FROM test_categories{where_sql}");
        let mut cq = sqlx::query_scalar::<_, i64>(&count_sql);
        for b in &binds {
            cq = cq.bind(b);
        }
        let total: i64 = cq
            .fetch_one(&state.pool)
            .await
            .map_err(|e| AppError::from_sqlx("count_categories", e))?;
        let sql = format!(
            "SELECT id, name, slug, description, tests, price, is_active, created_at \
             FROM test_categories{where_sql} ORDER BY {} {} LIMIT ${} OFFSET ${}",
            sort, order, idx, idx + 1
        );
        let mut q = sqlx::query_as::<_, TestCategoryRow>(&sql);
        for b in &binds {
            q = q.bind(b);
        }
        let rows: Vec<TestCategoryRow> = q
            .bind(size)
            .bind(offset)
            .fetch_all(&state.pool)
            .await
            .map_err(|e| AppError::from_sqlx("list_categories", e))?;
        let items: Vec<serde_json::Value> = rows.iter().map(category_json).collect();
        Ok(Json(serde_json::to_value(PageResponse::new(items, params.page_or_zero(), size, total)).unwrap()))
    } else {
        let sql = format!(
            "SELECT id, name, slug, description, tests, price, is_active, created_at \
             FROM test_categories{where_sql}"
        );
        let mut q = sqlx::query_as::<_, TestCategoryRow>(&sql);
        for b in &binds {
            q = q.bind(b);
        }
        let rows: Vec<TestCategoryRow> = q
            .fetch_all(&state.pool)
            .await
            .map_err(|e| AppError::from_sqlx("list_categories", e))?;
        Ok(Json(serde_json::json!(rows.iter().map(category_json).collect::<Vec<_>>())))
    }
}

pub async fn get(
    State(state): State<AppState>,
    _auth: AuthUser,
    Path(id): Path<i64>,
) -> AppResult<Json<serde_json::Value>> {
    let row = sqlx::query_as::<_, TestCategoryRow>(
        "SELECT id, name, slug, description, tests, price, is_active, created_at FROM test_categories WHERE id = $1",
    )
    .bind(id)
    .fetch_optional(&state.pool)
    .await
    .map_err(|e| AppError::from_sqlx("get_category", e))?
    .ok_or_else(|| AppError::NotFound(format!("TestCategory not found: {id}")))?;
    Ok(Json(category_json(&row)))
}

async fn find_by_slug(state: &AppState, slug: &str) -> AppResult<Option<i64>> {
    Ok(sqlx::query_scalar::<_, i64>("SELECT id FROM test_categories WHERE slug = $1")
        .bind(slug)
        .fetch_optional(&state.pool)
        .await
        .map_err(|e| AppError::from_sqlx("findBySlug", e))?)
}

pub async fn create(
    State(state): State<AppState>,
    auth: AuthUser,
    Json(req): Json<TestCategoryRequest>,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SUPERADMIN"])?;
    if let Some(existing) = find_by_slug(&state, &req.slug).await? {
        if existing != 0 {
            return Err(AppError::Conflict(format!(
                "TestCategory with slug '{}' already exists",
                req.slug
            )));
        }
    }
    let row = sqlx::query_as::<_, TestCategoryRow>(
        "INSERT INTO test_categories (name, slug, description, tests, price, is_active, created_at) \
         VALUES ($1, $2, $3, $4, $5, $6, NOW()) \
         RETURNING id, name, slug, description, tests, price, is_active, created_at",
    )
    .bind(&req.name)
    .bind(&req.slug)
    .bind(&req.description)
    .bind(&req.tests)
    .bind(&req.price.0)
    .bind(req.active)
    .fetch_one(&state.pool)
    .await
    .map_err(|e| AppError::from_sqlx("create_category", e))?;
    Ok(Json(category_json(&row)))
}

pub async fn update(
    State(state): State<AppState>,
    auth: AuthUser,
    Path(id): Path<i64>,
    Json(req): Json<TestCategoryRequest>,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SUPERADMIN"])?;
    auth.require_role(&["SUPERADMIN"])?;
    if let Some(existing) = find_by_slug(&state, &req.slug).await? {
        if existing != id {
            return Err(AppError::Conflict(format!(
                "TestCategory with slug '{}' already exists",
                req.slug
            )));
        }
    }
    let row = sqlx::query_as::<_, TestCategoryRow>(
        "UPDATE test_categories SET name = $2, slug = $3, description = $4, tests = $5, price = $6, is_active = $7 \
         WHERE id = $1 \
         RETURNING id, name, slug, description, tests, price, is_active, created_at",
    )
    .bind(id)
    .bind(&req.name)
    .bind(&req.slug)
    .bind(&req.description)
    .bind(&req.tests)
    .bind(&req.price.0)
    .bind(req.active)
    .fetch_one(&state.pool)
    .await
    .map_err(|e| AppError::from_sqlx("update_category", e))?;
    Ok(Json(category_json(&row)))
}

pub async fn delete(
    State(state): State<AppState>,
    auth: AuthUser,
    Path(id): Path<i64>,
) -> AppResult<StatusCode> {
    auth.require_role(&["SUPERADMIN"])?;
    let result = sqlx::query("DELETE FROM test_categories WHERE id = $1")
        .bind(id)
        .execute(&state.pool)
        .await
        .map_err(|e| AppError::from_sqlx("delete_category", e))?;
    if result.rows_affected() == 0 {
        return Err(AppError::NotFound(format!("TestCategory not found: {id}")));
    }
    Ok(StatusCode::NO_CONTENT)
}
