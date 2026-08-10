use axum::{
    extract::{Query, State},
    Json,
};
use serde::Deserialize;

use crate::{
    auth_extractor::AuthUser,
    error::{AppError, AppResult},
    models::test_assignment::TestAssignmentRow,
    paging::{PageParams, PageResponse},
    state::AppState,
};

#[derive(Deserialize)]
pub struct SummaryParams {
    #[serde(flatten)]
    pub page: PageParams,
    #[serde(default, deserialize_with = "crate::paging::de_bool_opt")]
    pub active: Option<bool>,
}

const SORT_WHITELIST: [&str; 5] = ["id", "school.name", "category.name", "windowStart", "windowEnd"];

fn school_name(row: &TestAssignmentRow) -> String {
    row.school_id.map(|_| "-".to_string()).unwrap_or("-".to_string())
}

pub async fn list(
    State(state): State<AppState>,
    auth: AuthUser,
    Query(params): Query<SummaryParams>,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SUPERADMIN", "GURUBK"])?;
    let mut conds: Vec<String> = Vec::new();
    let mut binds: Vec<String> = Vec::new();
    let mut idx = 1usize;
    if params.page.has_search() {
        let s = params.page.search_like();
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
    let where_sql = if conds.is_empty() { String::new() } else { format!(" WHERE {}", conds.join(" AND ")) };

    let sort = params.page.sort_key(&SORT_WHITELIST, "windowStart");
    let order = params.page.order_dir();
        let order_col = params.page.sort_col(sort);
    let size = params.page.size_clamped();
    let offset = params.page.offset();

    let count_sql = format!("SELECT COUNT(*) FROM test_assignments{where_sql}");
    let mut cq = sqlx::query_scalar::<_, i64>(&count_sql);
    for b in &binds {
        cq = cq.bind(b);
    }
    let total: i64 = cq.fetch_one(&state.pool).await.map_err(|e| AppError::from_sqlx("count_summaries", e))?;

    let sql = format!(
        "SELECT id, category_id, school_id, student_id, assigned_by, window_start, window_end, is_active, created_at \
         FROM test_assignments{where_sql} ORDER BY {} {} LIMIT ${} OFFSET ${}",
        order_col, order, idx, idx + 1
    );
    let mut q = sqlx::query_as::<_, TestAssignmentRow>(&sql);
    for b in &binds {
        q = q.bind(b);
    }
    let rows: Vec<TestAssignmentRow> = q.bind(size).bind(offset).fetch_all(&state.pool).await.map_err(|e| AppError::from_sqlx("list_summaries", e))?;

    let ids: Vec<i64> = rows.iter().map(|r| r.id).collect();
    let counts = count_results_per_assignment(&state, &ids).await?;
    let latest_batches = latest_batch_per_assignment(&state, &ids).await?;

    let mut items = Vec::new();
    for r in &rows {
        let cat = load_category_name(&state, r.category_id).await;
        let school_nm = load_school_name(&state, r.school_id).await;
        let tests = load_category_tests(&state, r.category_id).await;
        let latest = latest_batches.get(&r.id);
        items.push(serde_json::json!({
            "id": r.id,
            "schoolName": school_nm,
            "categoryName": cat,
            "tests": tests,
            "active": r.active,
            "windowStart": r.window_start.map(|d| crate::datetime::java_local_date_time(d)),
            "windowEnd": r.window_end.map(|d| crate::datetime::java_local_date_time(d)),
            "resultCount": counts.get(&r.id).copied().unwrap_or(0),
            "latestBatchId": latest.map(|b| b.id),
            "latestBatchFilename": latest.map(|b| b.pdf_filename.clone()),
        }));
    }
    let _ = school_name(&TestAssignmentRow {
        id: 0, category_id: 0, school_id: None, student_id: None, assigned_by: String::new(),
        window_start: None, window_end: None, active: false, created_at: chrono::NaiveDateTime::MIN,
    });
    Ok(Json(serde_json::to_value(PageResponse::new(items, params.page.page_or_zero(), size, total)).unwrap()))
}

pub async fn summary(
    State(state): State<AppState>,
    auth: AuthUser,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SUPERADMIN", "GURUBK"])?;
    let rows: Vec<TestAssignmentRow> = sqlx::query_as(
        "SELECT id, category_id, school_id, student_id, assigned_by, window_start, window_end, is_active, created_at FROM test_assignments",
    )
    .fetch_all(&state.pool)
    .await
    .map_err(|e| AppError::from_sqlx("all_assignments", e))?;
    let ids: Vec<i64> = rows.iter().map(|r| r.id).collect();
    let counts = count_results_per_assignment(&state, &ids).await?;
    let total_results: i64 = counts.values().sum();
    let active = rows.iter().filter(|r| r.active).count();
    Ok(Json(serde_json::json!({
        "totalAssignments": rows.len(),
        "activeAssignments": active,
        "totalResults": total_results,
    })))
}

async fn load_category_name(state: &AppState, id: i64) -> String {
    sqlx::query_scalar::<_, String>("SELECT name FROM test_categories WHERE id = $1")
        .bind(id)
        .fetch_optional(&state.pool)
        .await
        .ok()
        .flatten()
        .unwrap_or_else(|| "-".to_string())
}

async fn load_category_tests(state: &AppState, id: i64) -> Vec<String> {
    sqlx::query_scalar::<_, Vec<String>>("SELECT tests FROM test_categories WHERE id = $1")
        .bind(id)
        .fetch_optional(&state.pool)
        .await
        .ok()
        .flatten()
        .unwrap_or_default()
}

async fn load_school_name(state: &AppState, id: Option<i64>) -> String {
    match id {
        Some(id) => sqlx::query_scalar::<_, String>("SELECT name FROM schools WHERE id = $1")
            .bind(id)
            .fetch_optional(&state.pool)
            .await
            .ok()
            .flatten()
            .unwrap_or_else(|| "-".to_string()),
        None => "-".to_string(),
    }
}

async fn count_results_per_assignment(
    state: &AppState,
    ids: &[i64],
) -> AppResult<std::collections::HashMap<i64, i64>> {
    let mut counts: std::collections::HashMap<i64, i64> = ids.iter().map(|&id| (id, 0)).collect();
    if ids.is_empty() {
        return Ok(counts);
    }
    for table in ["disc_results", "holland_results", "papi_results", "cfit_results", "ist_results"] {
        let sql = format!(
            "SELECT assignment_id, COUNT(*) FROM {table} WHERE assignment_id = ANY($1) GROUP BY assignment_id"
        );
        let rows: Vec<(i64, i64)> = sqlx::query_as(&sql)
            .bind(ids)
            .fetch_all(&state.pool)
            .await
            .map_err(|e| AppError::from_sqlx(&format!("count_{table}"), e))?;
        for (assignment_id, n) in rows {
            *counts.entry(assignment_id).or_insert(0) += n;
        }
    }
    Ok(counts)
}

async fn latest_batch_per_assignment(
    state: &AppState,
    ids: &[i64],
) -> AppResult<std::collections::HashMap<i64, crate::models::credential::CredentialBatchRow>> {
    let mut out = std::collections::HashMap::new();
    if ids.is_empty() {
        return Ok(out);
    }
    let rows: Vec<crate::models::credential::CredentialBatchRow> = sqlx::query_as(
        "SELECT id, test_assignment_id, school_id, school_name, category_name, credential_count, pdf_filename, generated_by, created_at \
         FROM credential_batches WHERE test_assignment_id = ANY($1) ORDER BY created_at DESC",
    )
    .bind(ids)
    .fetch_all(&state.pool)
    .await
    .map_err(|e| AppError::from_sqlx("latest_batches", e))?;
    for r in rows {
        out.entry(r.test_assignment_id).or_insert(r);
    }
    Ok(out)
}
