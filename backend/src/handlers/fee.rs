use axum::{
    extract::{Query, State},
    Json,
};

use crate::{
    auth_extractor::AuthUser,
    db,
    error::{AppError, AppResult},
    models::fee::{FeeConfig, FeeConfigRequest, FeeConfigRow, FeeShareRow, FeeShareView},
    models::test_category::TestCategory,
    paging::{PageParams, PageResponse},
    state::AppState,
};

pub async fn config(
    State(state): State<AppState>,
    auth: AuthUser,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SUPERADMIN"])?;
    let rows: Vec<FeeConfigRow> = sqlx::query_as(
        "SELECT id, category_id, student_fee, afiliator_share_pct, gurubk_share_pct, platform_share_pct, updated_at FROM fee_config ORDER BY id",
    )
    .fetch_all(&state.pool)
    .await
    .map_err(|e| AppError::from_sqlx("fee_config", e))?;
    let mut out = Vec::new();
    for r in rows {
        let category = match r.category_id {
            Some(cid) => load_category(&state, cid).await?,
            None => None,
        };
        out.push(FeeConfig::from_row(&r, category).as_json());
    }
    Ok(Json(serde_json::json!(out)))
}

async fn load_category(state: &AppState, id: i64) -> AppResult<Option<TestCategory>> {
    let row = sqlx::query_as::<_, crate::models::test_category::TestCategoryRow>(
        "SELECT id, name, slug, description, tests, price, is_active, created_at FROM test_categories WHERE id = $1",
    )
    .bind(id)
    .fetch_optional(&state.pool)
    .await
    .map_err(|e| AppError::from_sqlx("load_fee_category", e))?;
    Ok(row.map(|r| TestCategory {
        id: r.id, name: r.name, slug: r.slug, description: r.description, tests: r.tests, price: r.price, active: r.active, created_at: r.created_at,
    }))
}

pub async fn update_config(
    State(state): State<AppState>,
    auth: AuthUser,
    Json(req): Json<FeeConfigRequest>,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SUPERADMIN"])?;
    let pct_sum = req.afiliator_share_pct.to_f64() + req.gurubk_share_pct.to_f64() + req.platform_share_pct.to_f64();
    if pct_sum > 100.0 {
        return Err(AppError::BadRequest("Share percentages exceed 100%".to_string()));
    }

    let existing = match req.category_id {
        Some(cid) => sqlx::query_as::<_, FeeConfigRow>(
            "SELECT id, category_id, student_fee, afiliator_share_pct, gurubk_share_pct, platform_share_pct, updated_at FROM fee_config WHERE category_id = $1",
        )
        .bind(cid)
        .fetch_optional(&state.pool)
        .await
        .map_err(|e| AppError::from_sqlx("fee_config_by_cat", e))?,
        None => None,
    };

    let row = match existing {
        Some(r) => sqlx::query_as::<_, FeeConfigRow>(
            "UPDATE fee_config SET student_fee=$2, afiliator_share_pct=$3, gurubk_share_pct=$4, platform_share_pct=$5, updated_at=NOW() \
             WHERE id=$1 RETURNING id, category_id, student_fee, afiliator_share_pct, gurubk_share_pct, platform_share_pct, updated_at",
        )
        .bind(r.id)
        .bind(&req.student_fee.0)
        .bind(&req.afiliator_share_pct.0)
        .bind(&req.gurubk_share_pct.0)
        .bind(&req.platform_share_pct.0)
        .fetch_one(&state.pool)
        .await
        .map_err(|e| AppError::from_sqlx("update_fee_config", e))?,
        None => sqlx::query_as::<_, FeeConfigRow>(
            "INSERT INTO fee_config (category_id, student_fee, afiliator_share_pct, gurubk_share_pct, platform_share_pct, updated_at) \
             VALUES ($1,$2,$3,$4,$5, NOW()) RETURNING id, category_id, student_fee, afiliator_share_pct, gurubk_share_pct, platform_share_pct, updated_at",
        )
        .bind(req.category_id)
        .bind(&req.student_fee.0)
        .bind(&req.afiliator_share_pct.0)
        .bind(&req.gurubk_share_pct.0)
        .bind(&req.platform_share_pct.0)
        .fetch_one(&state.pool)
        .await
        .map_err(|e| AppError::from_sqlx("insert_fee_config", e))?,
    };

    let category = match row.category_id {
        Some(cid) => load_category(&state, cid).await?,
        None => None,
    };
    Ok(Json(FeeConfig::from_row(&row, category).as_json()))
}

pub async fn my(
    State(state): State<AppState>,
    auth: AuthUser,
    Query(params): Query<PageParams>,
) -> AppResult<Json<serde_json::Value>> {
    let rows: Vec<FeeShareRow> = if auth.is_role("afiliator") {
        sqlx::query_as(
            "SELECT id, student_id, category_id, afiliator_id, gurubk_id, total_fee, afiliator_share, gurubk_share, platform_share, created_at \
             FROM fee_shares WHERE afiliator_id = $1",
        )
        .bind(&auth.user_id)
        .fetch_all(&state.pool)
        .await
        .map_err(|e| AppError::from_sqlx("fee_my_afiliator", e))?
    } else {
        sqlx::query_as(
            "SELECT id, student_id, category_id, afiliator_id, gurubk_id, total_fee, afiliator_share, gurubk_share, platform_share, created_at \
             FROM fee_shares WHERE student_id = $1",
        )
        .bind(&auth.user_id)
        .fetch_all(&state.pool)
        .await
        .map_err(|e| AppError::from_sqlx("fee_my_student", e))?
    };

    let mut views = Vec::new();
    for r in &rows {
        let student = db::load_user(&state.pool, &r.student_id).await?;
        let student_name = student.as_ref().map(|u| u.name.clone());
        let school_name = match student.as_ref().and_then(|u| u.school_id) {
            Some(sid) => db::load_school(&state.pool, sid).await?.map(|s| s.name),
            None => None,
        };
        let category_name = load_category_name(&state, r.category_id).await;
        views.push(FeeShareView {
            id: r.id,
            student_name,
            school_name,
            category_name,
            total_fee: r.total_fee.clone(),
            afiliator_share: r.afiliator_share.clone(),
            gurubk_share: r.gurubk_share.clone(),
            platform_share: r.platform_share.clone(),
            created_at: r.created_at,
        });
    }

    // In-memory search.
    if let Some(search) = params.search.as_deref() {
        if !search.trim().is_empty() {
            let s = search.trim().to_lowercase();
            views.retain(|v| {
                v.student_name.as_deref().map(|x| x.to_lowercase().contains(&s)).unwrap_or(false)
                    || v.school_name.as_deref().map(|x| x.to_lowercase().contains(&s)).unwrap_or(false)
                    || v.category_name.as_deref().map(|x| x.to_lowercase().contains(&s)).unwrap_or(false)
            });
        }
    }

    // Sort (whitelist: studentName, categoryName, afiliatorShare, createdAt; default createdAt; desc unless order=asc).
    let sort = params.sort_key(&["studentName", "categoryName", "afiliatorShare", "createdAt"], "createdAt");
    let asc = params.order.as_deref() == Some("asc");
    let cmp = |a: &FeeShareView, b: &FeeShareView| -> std::cmp::Ordering {
        let ord = match sort {
            "studentName" => a.student_name.cmp(&b.student_name),
            "categoryName" => a.category_name.cmp(&b.category_name),
            "afiliatorShare" => a.afiliator_share.to_f64().partial_cmp(&b.afiliator_share.to_f64()).unwrap_or(std::cmp::Ordering::Equal),
            _ => a.created_at.cmp(&b.created_at),
        };
        if asc { ord } else { ord.reverse() }
    };
    views.sort_by(cmp);

    if params.is_paginated() {
        let size = params.size_clamped();
        let offset = params.offset();
        let total = views.len() as i64;
        let page_items: Vec<FeeShareView> = views.into_iter().skip(offset as usize).take(size as usize).collect();
        let items: Vec<serde_json::Value> = page_items.iter().map(|v| v.as_json()).collect();
        return Ok(Json(serde_json::to_value(PageResponse::new(items, params.page_or_zero(), size, total)).unwrap()));
    }
    Ok(Json(serde_json::json!(views.iter().map(|v| v.as_json()).collect::<Vec<_>>())))
}

async fn load_category_name(state: &AppState, id: i64) -> Option<String> {
    sqlx::query_scalar::<_, String>("SELECT name FROM test_categories WHERE id = $1")
        .bind(id)
        .fetch_optional(&state.pool)
        .await
        .ok()
        .flatten()
}

pub async fn summary_afiliator(
    State(state): State<AppState>,
    auth: AuthUser,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["AFILIATOR"])?;
    let total: Option<bigdecimal::BigDecimal> = sqlx::query_scalar(
        "SELECT SUM(afiliator_share) FROM fee_shares WHERE afiliator_id = $1",
    )
    .bind(&auth.user_id)
    .fetch_one(&state.pool)
    .await
    .map_err(|e| AppError::from_sqlx("fee_summary_afiliator", e))?;
    let total = total.unwrap_or_else(|| bigdecimal::BigDecimal::from(0));
    Ok(Json(serde_json::json!({ "totalShare": crate::decimal::Decimal(total) })))
}
