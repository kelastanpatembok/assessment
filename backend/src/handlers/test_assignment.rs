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
    models::test_assignment::{CreateAssignmentRequest, TestAssignment, TestAssignmentRow, UpdateAssignmentRequest},
    paging::{PageParams, PageResponse},
    state::AppState,
};

const SORT_WHITELIST: [&str; 6] = ["school.name", "category.name", "windowStart", "windowEnd", "id", "createdAt"];

#[derive(Deserialize)]
pub struct AssignmentListParams {
    #[serde(flatten)]
    pub page: PageParams,
    #[serde(default, deserialize_with = "crate::paging::de_bool_opt")]
    pub active: Option<bool>,
}

async fn load_category(state: &AppState, id: i64) -> AppResult<crate::models::test_category::TestCategory> {
    let row = sqlx::query_as::<_, crate::models::test_category::TestCategoryRow>(
        "SELECT id, name, slug, description, tests, price, is_active, created_at FROM test_categories WHERE id = $1",
    )
    .bind(id)
    .fetch_optional(&state.pool)
    .await
    .map_err(|e| AppError::from_sqlx("load_category", e))?
    .ok_or_else(|| AppError::NotFound(format!("TestCategory not found: {id}")))?;
    Ok(crate::models::test_category::TestCategory {
        id: row.id,
        name: row.name,
        slug: row.slug,
        description: row.description,
        tests: row.tests,
        price: row.price,
        active: row.active,
        created_at: row.created_at,
    })
}

async fn assemble(state: &AppState, row: TestAssignmentRow) -> AppResult<TestAssignment> {
    let category = load_category(state, row.category_id).await.ok();
    let school = match row.school_id {
        Some(id) => db::load_school(&state.pool, id).await?,
        None => None,
    };
    let student = match &row.student_id {
        Some(uid) => {
            let r = db::load_user(&state.pool, uid).await?;
            match r {
                Some(u) => Some(db::assemble_user(&state.pool, u).await?),
                None => None,
            }
        }
        None => None,
    };
    Ok(TestAssignment {
        id: row.id,
        category,
        school,
        student,
        assigned_by: row.assigned_by,
        window_start: row.window_start,
        window_end: row.window_end,
        active: row.active,
        created_at: row.created_at,
    })
}

fn parse_window_start(d: &str) -> AppResult<chrono::NaiveDateTime> {
    chrono::NaiveDate::parse_from_str(d, "%Y-%m-%d")
        .map(|date| date.and_hms_opt(0, 0, 0).unwrap())
        .map_err(|_| AppError::BadRequest(format!("Invalid startDate: {d}")))
}
fn parse_window_end(d: &str) -> AppResult<chrono::NaiveDateTime> {
    chrono::NaiveDate::parse_from_str(d, "%Y-%m-%d")
        .map(|date| date.and_hms_opt(23, 59, 59).unwrap())
        .map_err(|_| AppError::BadRequest(format!("Invalid endDate: {d}")))
}

pub async fn create(
    State(state): State<AppState>,
    auth: AuthUser,
    Json(req): Json<CreateAssignmentRequest>,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SUPERADMIN", "GURUBK"])?;
    load_category(&state, req.category_id).await?;
    if let Some(sid) = req.school_id {
        db::require_school(&state.pool, sid).await?;
    }
    if let Some(uid) = &req.student_id {
        db::require_user(&state.pool, uid).await?;
    }
    let window_start = parse_window_start(&req.start_date)?;
    let window_end = parse_window_end(&req.end_date)?;

    let row = sqlx::query_as::<_, TestAssignmentRow>(
        "INSERT INTO test_assignments (category_id, school_id, student_id, assigned_by, window_start, window_end, is_active, created_at) \
         VALUES ($1, $2, $3, $4, $5, $6, true, NOW()) \
         RETURNING id, category_id, school_id, student_id, assigned_by, window_start, window_end, is_active, created_at",
    )
    .bind(req.category_id)
    .bind(req.school_id)
    .bind(&req.student_id)
    .bind(&auth.user_id)
    .bind(window_start)
    .bind(window_end)
    .fetch_one(&state.pool)
    .await
    .map_err(|e| AppError::from_sqlx("create_assignment", e))?;

    let ta = assemble(&state, row).await?;
    Ok(Json(ta.as_json()))
}

pub async fn list(
    State(state): State<AppState>,
    auth: AuthUser,
    Query(params): Query<AssignmentListParams>,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SUPERADMIN", "GURUBK"])?;
    let mut conds: Vec<String> = Vec::new();
    let mut binds: Vec<String> = Vec::new();
    let mut idx = 1usize;

    let searchable = |col: &str, idx: usize| format!("(LOWER({col}) LIKE ${idx})");
    // Join-based search on school.name / category.name.
    if params.page.has_search() {
        let s = params.page.search_like();
        // Use subquery approach: exists on schools/name, categories/name.
        conds.push(format!(
            "(EXISTS (SELECT 1 FROM schools s WHERE s.id = test_assignments.school_id AND LOWER(s.name) LIKE ${}) \
              OR EXISTS (SELECT 1 FROM test_categories tc WHERE tc.id = test_assignments.category_id AND LOWER(tc.name) LIKE ${}))",
            idx, idx
        ));
        binds.push(s);
        idx += 1;
    }
    if let Some(active) = params.active {
        conds.push(format!("is_active = ${}", idx));
        binds.push(if active { "true".to_string() } else { "false".to_string() });
        idx += 1;
    }
    let _ = searchable("", 0);
    let where_sql = if conds.is_empty() { String::new() } else { format!(" WHERE {}", conds.join(" AND ")) };

    let sort = params.page.sort_key(&SORT_WHITELIST, "windowStart");
    let order = params.page.order_dir();
        let order_col = params.page.sort_col(sort);
    let size = params.page.size_clamped();
    let offset = params.page.offset();

    if params.page.is_paginated() {
        let count_sql = format!("SELECT COUNT(*) FROM test_assignments{where_sql}");
        let mut cq = sqlx::query_scalar::<_, i64>(&count_sql);
        for b in &binds {
            cq = cq.bind(b);
        }
        let total: i64 = cq.fetch_one(&state.pool).await.map_err(|e| AppError::from_sqlx("count_assignments", e))?;
        let sql = format!(
            "SELECT id, category_id, school_id, student_id, assigned_by, window_start, window_end, is_active, created_at \
             FROM test_assignments{where_sql} ORDER BY {} {} LIMIT ${} OFFSET ${}",
            order_col, order, idx, idx + 1
        );
        let mut q = sqlx::query_as::<_, TestAssignmentRow>(&sql);
        for b in &binds {
            q = q.bind(b);
        }
        let rows: Vec<TestAssignmentRow> = q.bind(size).bind(offset).fetch_all(&state.pool).await.map_err(|e| AppError::from_sqlx("list_assignments", e))?;
        let mut items = Vec::new();
        for r in rows {
            items.push(assemble(&state, r).await?.as_json());
        }
        Ok(Json(serde_json::to_value(PageResponse::new(items, params.page.page_or_zero(), size, total)).unwrap()))
    } else {
        let sql = format!(
            "SELECT id, category_id, school_id, student_id, assigned_by, window_start, window_end, is_active, created_at \
             FROM test_assignments{where_sql} ORDER BY {} {}",
            order_col, order
        );
        let mut q = sqlx::query_as::<_, TestAssignmentRow>(&sql);
        for b in &binds {
            q = q.bind(b);
        }
        let rows: Vec<TestAssignmentRow> = q.fetch_all(&state.pool).await.map_err(|e| AppError::from_sqlx("list_assignments", e))?;
        let mut out = Vec::new();
        for r in rows {
            out.push(assemble(&state, r).await?.as_json());
        }
        Ok(Json(serde_json::json!(out)))
    }
}

async fn by_school(
    State(state): State<AppState>,
    auth: AuthUser,
    Path(school_id): Path<i64>,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SUPERADMIN", "GURUBK"])?;
    let rows: Vec<TestAssignmentRow> = sqlx::query_as(
        "SELECT id, category_id, school_id, student_id, assigned_by, window_start, window_end, is_active, created_at \
         FROM test_assignments WHERE school_id = $1",
    )
    .bind(school_id)
    .fetch_all(&state.pool)
    .await
    .map_err(|e| AppError::from_sqlx("assignments_by_school", e))?;
    let mut out = Vec::new();
    for r in rows {
        out.push(assemble(&state, r).await?.as_json());
    }
    Ok(Json(serde_json::json!(out)))
}

async fn by_student(
    State(state): State<AppState>,
    auth: AuthUser,
    Path(student_id): Path<String>,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SUPERADMIN", "GURUBK"])?;
    let rows: Vec<TestAssignmentRow> = sqlx::query_as(
        "SELECT id, category_id, school_id, student_id, assigned_by, window_start, window_end, is_active, created_at \
         FROM test_assignments WHERE student_id = $1",
    )
    .bind(&student_id)
    .fetch_all(&state.pool)
    .await
    .map_err(|e| AppError::from_sqlx("assignments_by_student", e))?;
    let mut out = Vec::new();
    for r in rows {
        out.push(assemble(&state, r).await?.as_json());
    }
    Ok(Json(serde_json::json!(out)))
}

async fn my(
    State(state): State<AppState>,
    auth: AuthUser,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SISWA"])?;
    let rows: Vec<TestAssignmentRow> = sqlx::query_as(
        "SELECT id, category_id, school_id, student_id, assigned_by, window_start, window_end, is_active, created_at \
         FROM test_assignments WHERE student_id = $1",
    )
    .bind(&auth.user_id)
    .fetch_all(&state.pool)
    .await
    .map_err(|e| AppError::from_sqlx("assignments_my", e))?;
    let mut out = Vec::new();
    for r in rows {
        out.push(assemble(&state, r).await?.as_json());
    }
    Ok(Json(serde_json::json!(out)))
}

pub async fn update(
    State(state): State<AppState>,
    auth: AuthUser,
    Path(id): Path<i64>,
    Json(req): Json<UpdateAssignmentRequest>,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SUPERADMIN", "GURUBK"])?;
    let existing = sqlx::query_as::<_, TestAssignmentRow>(
        "SELECT id, category_id, school_id, student_id, assigned_by, window_start, window_end, is_active, created_at \
         FROM test_assignments WHERE id = $1",
    )
    .bind(id)
    .fetch_optional(&state.pool)
    .await
    .map_err(|e| AppError::from_sqlx("get_assignment", e))?
    .ok_or_else(|| AppError::NotFound(format!("TestAssignment not found: {id}")))?;

    let window_start = match &req.start_date {
        Some(d) => Some(parse_window_start(d)?),
        None => existing.window_start,
    };
    let window_end = match &req.end_date {
        Some(d) => Some(parse_window_end(d)?),
        None => existing.window_end,
    };
    let active = req.active.unwrap_or(existing.active);

    let row = sqlx::query_as::<_, TestAssignmentRow>(
        "UPDATE test_assignments SET window_start = $2, window_end = $3, is_active = $4 \
         WHERE id = $1 \
         RETURNING id, category_id, school_id, student_id, assigned_by, window_start, window_end, is_active, created_at",
    )
    .bind(id)
    .bind(window_start)
    .bind(window_end)
    .bind(active)
    .fetch_one(&state.pool)
    .await
    .map_err(|e| AppError::from_sqlx("update_assignment", e))?;

    let ta = assemble(&state, row).await?;
    Ok(Json(ta.as_json()))
}

pub async fn delete(
    State(state): State<AppState>,
    auth: AuthUser,
    Path(id): Path<i64>,
) -> AppResult<StatusCode> {
    auth.require_role(&["SUPERADMIN", "GURUBK"])?;
    // Deactivate (soft), not hard delete.
    let result = sqlx::query("UPDATE test_assignments SET is_active = false WHERE id = $1")
        .bind(id)
        .execute(&state.pool)
        .await
        .map_err(|e| AppError::from_sqlx("deactivate_assignment", e))?;
    if result.rows_affected() == 0 {
        return Err(AppError::NotFound(format!("TestAssignment not found: {id}")));
    }
    Ok(StatusCode::NO_CONTENT)
}

/// Shared router helper used by both /api/assignments and /api/test-assignments.
pub fn routes() -> axum::Router<AppState> {
    use axum::routing::get;
    axum::Router::new()
        .route("/", get(list).post(create))
        .route("/school/{schoolId}", get(by_school))
        .route("/student/{studentId}", get(by_student))
        .route("/my", get(my))
        .route("/{id}", axum::routing::put(update).delete(delete))
}
