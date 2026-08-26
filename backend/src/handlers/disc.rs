use axum::{
    extract::{Path, Query, State},
    Json,
};
use serde::Deserialize;
use sqlx::PgPool;

use crate::{
    auth_extractor::AuthUser,
    error::{AppError, AppResult},
    models::disc::{DiscQuestion, DiscResult, DiscSubmitRequest},
    paging::{PageParams, PageResponse},
    scoring::disc::classify,
    state::AppState,
};

const SORT_WHITELIST: [&str; 4] = ["studentName", "schoolName", "completedAt", "id"];

#[derive(Deserialize)]
pub struct CheckParams {
    #[serde(default, deserialize_with = "crate::paging::de_i64_opt")]
    pub page: Option<i64>,
    #[serde(default, deserialize_with = "crate::paging::de_i64_opt")]
    pub size: Option<i64>,
    pub search: Option<String>,
    pub sort: Option<String>,
    pub order: Option<String>,
}

fn disc_question_row(r: (i64, i32, i32, String, String, bool)) -> DiscQuestion {
    DiscQuestion {
        id: r.0,
        block_no: r.1,
        item_no: r.2,
        category: r.3,
        statement: r.4,
        active: r.5,
    }
}

pub async fn questions(
    State(state): State<AppState>,
    auth: AuthUser,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SISWA"])?;
    let rows: Vec<(i64, i32, i32, String, String, bool)> = sqlx::query_as(
        "SELECT id, block_no, item_no, category, statement, is_active FROM disc_questions \
         WHERE is_active = true ORDER BY block_no, item_no",
    )
    .fetch_all(&state.pool)
    .await
    .map_err(|e| AppError::from_sqlx("disc_questions", e))?;
    Ok(Json(serde_json::json!(rows.into_iter().map(disc_question_row).collect::<Vec<_>>())))
}

/// Shared check logic: {canTake, completed, assignmentId, windowStart, windowEnd}.
pub async fn check_for(
    state: &AppState,
    auth: &AuthUser,
    test_type: &str,
) -> AppResult<serde_json::Value> {
    let user = crate::db::load_user(&state.pool, &auth.user_id).await?;
    let school_id = user.as_ref().and_then(|u| u.school_id);

    // Completed = an existing result row for this student.
    let table = match test_type {
        "disc" => "disc_results",
        "holland" => "holland_results",
        "papi" => "papi_results",
        "cfit" => "cfit_results",
        "ist" => "ist_results",
        "epps" => "epps_results",
        _ => return Err(AppError::BadRequest(format!("Unknown test type: {test_type}"))),
    };
    let sql = format!("SELECT COUNT(*) FROM {table} WHERE auth_user_id = $1");
    let completed: i64 = sqlx::query_scalar(&sql)
        .bind(&auth.user_id)
        .fetch_one(&state.pool)
        .await
        .map_err(|e| AppError::from_sqlx("check_completed", e))?;

    let assignment_id = get_active_assignment_id(state, school_id, &auth.user_id, test_type).await?;

    Ok(serde_json::json!({
        "canTake": assignment_id.is_some() && completed == 0,
        "completed": completed > 0,
        "assignmentId": assignment_id.unwrap_or(0),
        "windowStart": serde_json::Value::Null,
        "windowEnd": serde_json::Value::Null,
    }))
}

/// Active assignment whose category tests include test_type.
async fn get_active_assignment_id(
    state: &AppState,
    school_id: Option<i64>,
    student_id: &str,
    test_type: &str,
) -> AppResult<Option<i64>> {
    let mut sql = String::from(
        "SELECT ta.id FROM test_assignments ta \
         JOIN test_categories tc ON tc.id = ta.category_id \
         WHERE ta.is_active = true AND tc.tests @> ARRAY[$1]::text[] AND \
         (ta.window_start IS NULL OR ta.window_start <= NOW()) AND \
         (ta.window_end IS NULL OR ta.window_end >= NOW()) AND \
         (ta.student_id = $2",
    );
    if let Some(_sid) = school_id {
        sql.push_str(" OR ta.school_id = $3");
    }
    sql.push(')');
    sql.push_str(" LIMIT 1");

    let mut q = sqlx::query_scalar::<_, i64>(&sql);
    q = q.bind(test_type).bind(student_id);
    if school_id.is_some() {
        q = q.bind(school_id.unwrap());
    }
    Ok(q.fetch_optional(&state.pool).await.map_err(|e| AppError::from_sqlx("active_assignment", e))?)
}

pub async fn check(
    State(state): State<AppState>,
    auth: AuthUser,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SISWA"])?;
    Ok(Json(check_for(&state, &auth, "disc").await?))
}

pub async fn submit(
    State(state): State<AppState>,
    auth: AuthUser,
    Json(req): Json<DiscSubmitRequest>,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SISWA"])?;
    // Completeness guard: expected distinct blocks in the active question set.
    let expected: i64 = sqlx::query_scalar("SELECT COUNT(DISTINCT block_no) FROM disc_questions WHERE is_active = true")
        .fetch_one(&state.pool)
        .await
        .map_err(|e| AppError::from_sqlx("count_blocks", e))?;
    if req.answers.len() as i64 != expected {
        return Err(AppError::BadRequest(format!(
            "Jawaban tidak lengkap: diterima {} dari {} kelompok soal",
            req.answers.len(),
            expected
        )));
    }

    // Duplicate result guard.
    let exists: i64 = sqlx::query_scalar("SELECT COUNT(*) FROM disc_results WHERE auth_user_id = $1")
        .bind(&auth.user_id)
        .fetch_one(&state.pool)
        .await
        .map_err(|e| AppError::from_sqlx("disc_exists", e))?;
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

    // Tally MOST/LEAST.
    let mut d_most = 0; let mut i_most = 0; let mut s_most = 0; let mut c_most = 0;
    let mut d_least = 0; let mut i_least = 0; let mut s_least = 0; let mut c_least = 0;

    for a in &req.answers {
        let cat_most = resolve_block_item(&state.pool, a.block_no, a.most_item_no).await?;
        let cat_least = resolve_block_item(&state.pool, a.block_no, a.least_item_no).await?;
        match cat_most.to_uppercase().as_str() {
            "D" => d_most += 1, "I" => i_most += 1, "S" => s_most += 1, "C" => c_most += 1, _ => {}
        }
        match cat_least.to_uppercase().as_str() {
            "D" => d_least += 1, "I" => i_least += 1, "S" => s_least += 1, "C" => c_least += 1, _ => {}
        }
    }

    let d_dif = d_most - d_least;
    let i_dif = i_most - i_least;
    let s_dif = s_most - s_least;
    let c_dif = c_most - c_least;

    // Conversion lookups.
    let most = convert_dimensions(&state.pool, "disc_most_conversion", d_most, i_most, s_most, c_most, 0, 20).await?;
    let least = convert_dimensions(&state.pool, "disc_least_conversion", d_least, i_least, s_least, c_least, 0, 20).await?;
    let dif = convert_dimensions(&state.pool, "disc_dif_conversion", d_dif, i_dif, s_dif, c_dif, -22, 22).await?;

    // Pattern classification + profile lookups.
    let most_pat = classify(most.0.to_f64(), most.1.to_f64(), most.2.to_f64(), most.3.to_f64());
    let least_pat = classify(least.0.to_f64(), least.1.to_f64(), least.2.to_f64(), least.3.to_f64());
    let dif_pat = classify(dif.0.to_f64(), dif.1.to_f64(), dif.2.to_f64(), dif.3.to_f64());

    let most_prof = load_pattern_profile(&state.pool, most_pat).await?;
    let least_prof = load_pattern_profile(&state.pool, least_pat).await?;
    let dif_prof = load_pattern_profile(&state.pool, dif_pat).await?;

    let answers_json = serde_json::to_string(&req.answers).unwrap_or_else(|_| "[]".to_string());

    let row = sqlx::query_as::<_, DiscResult>(
        "INSERT INTO disc_results \
         (auth_user_id, student_name, school_name, assignment_id, \
          d_most, i_most, s_most, c_most, d_least, i_least, s_least, c_least, d_dif, i_dif, s_dif, c_dif, \
          most_d_conv, most_i_conv, most_s_conv, most_c_conv, \
          least_d_conv, least_i_conv, least_s_conv, least_c_conv, \
          dif_d_conv, dif_i_conv, dif_s_conv, dif_c_conv, \
          most_key, least_key, dif_key, \
          profile_title, profile_desc, dif_profile_traits, job_recommendations, \
          most_profile_title, most_profile_traits, least_profile_title, least_profile_traits, \
          answers, completed_at) \
         VALUES ($1,$2,$3,$4, $5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16, \
                 $17,$18,$19,$20, $21,$22,$23,$24, $25,$26,$27,$28, \
                 $29,$30,$31, $32,$33,$34::jsonb,$35, $36,$37::jsonb,$38,$39::jsonb, \
                 $40::jsonb, NOW()) \
         RETURNING id, auth_user_id, student_name, school_name, assignment_id, \
                 d_most, i_most, s_most, c_most, d_least, i_least, s_least, c_least, d_dif, i_dif, s_dif, c_dif, \
                 most_d_conv, most_i_conv, most_s_conv, most_c_conv, \
                 least_d_conv, least_i_conv, least_s_conv, least_c_conv, \
                 dif_d_conv, dif_i_conv, dif_s_conv, dif_c_conv, \
                 most_key, least_key, dif_key, \
                 profile_title, profile_desc, dif_profile_traits::text, job_recommendations, \
                 most_profile_title, most_profile_traits::text, least_profile_title, least_profile_traits::text, \
                 answers::text, completed_at",
    )
    .bind(&auth.user_id)
    .bind(&student_name)
    .bind(&school_name)
    .bind(req.assignment_id)
    .bind(d_most).bind(i_most).bind(s_most).bind(c_most)
    .bind(d_least).bind(i_least).bind(s_least).bind(c_least)
    .bind(d_dif).bind(i_dif).bind(s_dif).bind(c_dif)
    .bind(&most.0).bind(&most.1).bind(&most.2).bind(&most.3)
    .bind(&least.0).bind(&least.1).bind(&least.2).bind(&least.3)
    .bind(&dif.0).bind(&dif.1).bind(&dif.2).bind(&dif.3)
    .bind(&most_prof.type_key).bind(&least_prof.type_key).bind(&dif_prof.type_key)
    .bind(&dif_prof.title).bind(&dif_prof.description)
    .bind(&dif_prof.traits_text).bind(&dif_prof.job_recommendations)
    .bind(&most_prof.title).bind(&most_prof.traits_text)
    .bind(&least_prof.title).bind(&least_prof.traits_text)
    .bind(answers_json)
    .fetch_one(&state.pool)
    .await
    .map_err(|e| AppError::from_sqlx("insert_disc_result", e))?;

    log_activity(&state, "disc", "FINISH").await;
    Ok(Json(row.as_json()))
}

async fn resolve_block_item(pool: &PgPool, block: i32, item: i32) -> AppResult<String> {
    let cat: Option<String> = sqlx::query_scalar(
        "SELECT category FROM disc_questions WHERE block_no = $1 AND item_no = $2",
    )
    .bind(block)
    .bind(item)
    .fetch_optional(pool)
    .await
    .map_err(|e| AppError::from_sqlx("resolve_disc_item", e))?;
    cat.ok_or_else(|| {
        AppError::NotFound(format!(
            "DISC question not found: block={} item={}",
            block, item
        ))
    })
}

type Conv = (crate::decimal::Decimal, crate::decimal::Decimal, crate::decimal::Decimal, crate::decimal::Decimal);

async fn convert_dimensions(
    pool: &PgPool,
    table: &str,
    d: i32,
    i: i32,
    s: i32,
    c: i32,
    min: i32,
    max: i32,
) -> AppResult<Conv> {
    let d_c = lookup_conv(pool, table, d.clamp(min, max), "d_conv", table).await?;
    let i_c = lookup_conv(pool, table, i.clamp(min, max), "i_conv", table).await?;
    let s_c = lookup_conv(pool, table, s.clamp(min, max), "s_conv", table).await?;
    let c_c = lookup_conv(pool, table, c.clamp(min, max), "c_conv", table).await?;
    Ok((d_c, i_c, s_c, c_c))
}

async fn lookup_conv(pool: &PgPool, table: &str, raw: i32, col: &str, label: &str) -> AppResult<crate::decimal::Decimal> {
    let sql = format!("SELECT {col} FROM {table} WHERE raw_value = $1");
    let v: Option<bigdecimal::BigDecimal> = sqlx::query_scalar(&sql)
        .bind(raw)
        .fetch_optional(pool)
        .await
        .map_err(|e| AppError::from_sqlx(&format!("conv_{label}"), e))?;
    v.map(crate::decimal::Decimal::from)
        .ok_or_else(|| AppError::NotFound(format!("Missing {label} row for raw={raw}")))
}

struct PatternProfile {
    type_key: String,
    title: String,
    description: Option<String>,
    traits_text: Option<String>,
    job_recommendations: Option<String>,
}

async fn load_pattern_profile(pool: &PgPool, index: i32) -> AppResult<PatternProfile> {
    let row = sqlx::query_as::<_, (String, String, Option<String>, Option<String>, Option<String>)>(
        "SELECT type_key, title, description, traits::text, job_recommendations \
         FROM disc_pattern_profiles WHERE pattern_index = $1",
    )
    .bind(index)
    .fetch_optional(pool)
    .await
    .map_err(|e| AppError::from_sqlx("load_pattern_profile", e))?
    .ok_or_else(|| AppError::NotFound(format!("Unknown DISC pattern index: {index}")))?;
    Ok(PatternProfile {
        type_key: row.0,
        title: row.1,
        description: row.2,
        traits_text: row.3,
        job_recommendations: row.4,
    })
}

async fn log_activity(state: &AppState, test_type: &str, event: &str) {
    let _ = sqlx::query(
        "INSERT INTO activity_logs (auth_user_id, test_type, event_type, metadata, created_at) VALUES ('system', $1, $2, '{}'::jsonb, NOW())",
    )
    .bind(test_type)
    .bind(event)
    .execute(&state.pool)
    .await;
}

pub async fn result_me(
    State(state): State<AppState>,
    auth: AuthUser,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SISWA"])?;
    let row = fetch_own_result(&state.pool, &auth.user_id).await?
        .ok_or_else(|| AppError::NotFound("Disc result not found".to_string()))?;
    Ok(Json(row.as_json()))
}

async fn fetch_own_result(pool: &PgPool, user_id: &str) -> AppResult<Option<DiscResult>> {
    Ok(sqlx::query_as::<_, DiscResult>(
        "SELECT id, auth_user_id, student_name, school_name, assignment_id, \
         d_most, i_most, s_most, c_most, d_least, i_least, s_least, c_least, d_dif, i_dif, s_dif, c_dif, \
         most_d_conv, most_i_conv, most_s_conv, most_c_conv, \
         least_d_conv, least_i_conv, least_s_conv, least_c_conv, \
         dif_d_conv, dif_i_conv, dif_s_conv, dif_c_conv, \
         most_key, least_key, dif_key, profile_title, profile_desc, dif_profile_traits::text, job_recommendations, \
         most_profile_title, most_profile_traits::text, least_profile_title, least_profile_traits::text, \
         answers::text, completed_at FROM disc_results WHERE auth_user_id = $1",
    )
    .bind(user_id)
    .fetch_optional(pool)
    .await
    .map_err(|e| AppError::from_sqlx("fetch_disc_result", e))?)
}

async fn list_results_scoped(
    state: &AppState,
    auth: &AuthUser,
    params: &PageParams,
    table: &str,
) -> AppResult<serde_json::Value> {
    let _ = table;
    let mut conds: Vec<String> = Vec::new();
    let mut binds: Vec<String> = Vec::new();
    let mut idx = 1usize;

    if auth.is_role("gurubk") {
        let school_id = crate::db::load_user(&state.pool, &auth.user_id).await?.and_then(|u| u.school_id);
        if let Some(sid) = school_id {
            conds.push(format!("EXISTS (SELECT 1 FROM schools s WHERE s.id = ${} AND s.name = disc_results.school_name)", idx));
            binds.push(sid.to_string());
            idx += 1;
        }
    } else if auth.is_role("afiliator") {
        conds.push(format!("auth_user_id IN (SELECT auth_user_id FROM assessment_users WHERE afiliator_id = ${})", idx));
        binds.push(auth.user_id.clone());
        idx += 1;
    }

    if params.has_search() {
        conds.push(format!(
            "(LOWER(student_name) LIKE ${} OR LOWER(school_name) LIKE ${})",
            idx, idx
        ));
        binds.push(params.search_like());
        idx += 1;
    }
    let where_sql = if conds.is_empty() { String::new() } else { format!(" WHERE {}", conds.join(" AND ")) };
    let sort = params.sort_key(&SORT_WHITELIST, "completedAt");
    let order = params.order_dir();
        let order_col = params.sort_col(sort);
    let size = params.size_clamped();
    let offset = params.offset();
    let sel = "id, auth_user_id, student_name, school_name, assignment_id, \
         d_most, i_most, s_most, c_most, d_least, i_least, s_least, c_least, d_dif, i_dif, s_dif, c_dif, \
         most_d_conv, most_i_conv, most_s_conv, most_c_conv, \
         least_d_conv, least_i_conv, least_s_conv, least_c_conv, \
         dif_d_conv, dif_i_conv, dif_s_conv, dif_c_conv, \
         most_key, least_key, dif_key, profile_title, profile_desc, dif_profile_traits::text, job_recommendations, \
         most_profile_title, most_profile_traits::text, least_profile_title, least_profile_traits::text, \
         answers::text, completed_at";

    if params.is_paginated() {
        let count_sql = format!("SELECT COUNT(*) FROM disc_results{where_sql}");
        let mut cq = sqlx::query_scalar::<_, i64>(&count_sql);
        for b in &binds { cq = cq.bind(b); }
        let total: i64 = cq.fetch_one(&state.pool).await.map_err(|e| AppError::from_sqlx("count_disc", e))?;
        let sql = format!("SELECT {sel} FROM disc_results{where_sql} ORDER BY {} {} LIMIT ${} OFFSET ${}", order_col, order, idx, idx + 1);
        let mut q = sqlx::query_as::<_, DiscResult>(&sql);
        for b in &binds { q = q.bind(b); }
        let rows: Vec<DiscResult> = q.bind(size).bind(offset).fetch_all(&state.pool).await.map_err(|e| AppError::from_sqlx("list_disc", e))?;
        let items: Vec<serde_json::Value> = rows.iter().map(|r| r.as_json()).collect();
        Ok(serde_json::to_value(PageResponse::new(items, params.page_or_zero(), size, total)).unwrap())
    } else {
        let sql = format!("SELECT {sel} FROM disc_results{where_sql} ORDER BY {} {}", order_col, order);
        let mut q = sqlx::query_as::<_, DiscResult>(&sql);
        for b in &binds { q = q.bind(b); }
        let rows: Vec<DiscResult> = q.fetch_all(&state.pool).await.map_err(|e| AppError::from_sqlx("list_disc", e))?;
        Ok(serde_json::json!(rows.iter().map(|r| r.as_json()).collect::<Vec<_>>()))
    }
}

pub async fn results(
    State(state): State<AppState>,
    auth: AuthUser,
    Query(params): Query<CheckParams>,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SUPERADMIN", "GURUBK", "AFILIATOR", "PSIKOLOG"])?;
    let pp = PageParams {
        page: params.page,
        size: params.size,
        search: params.search,
        sort: params.sort,
        order: params.order,
    };
    Ok(Json(list_results_scoped(&state, &auth, &pp, "disc").await?))
}

pub async fn result_by_user(
    State(state): State<AppState>,
    auth: AuthUser,
    Path(auth_user_id): Path<String>,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SUPERADMIN", "GURUBK", "AFILIATOR", "PSIKOLOG"])?;
    let row = sqlx::query_as::<_, DiscResult>(
        "SELECT id, auth_user_id, student_name, school_name, assignment_id, \
         d_most, i_most, s_most, c_most, d_least, i_least, s_least, c_least, d_dif, i_dif, s_dif, c_dif, \
         most_d_conv, most_i_conv, most_s_conv, most_c_conv, \
         least_d_conv, least_i_conv, least_s_conv, least_c_conv, \
         dif_d_conv, dif_i_conv, dif_s_conv, dif_c_conv, \
         most_key, least_key, dif_key, profile_title, profile_desc, dif_profile_traits::text, job_recommendations, \
         most_profile_title, most_profile_traits::text, least_profile_title, least_profile_traits::text, \
         answers::text, completed_at FROM disc_results WHERE auth_user_id = $1",
    )
    .bind(&auth_user_id)
    .fetch_optional(&state.pool)
    .await
    .map_err(|e| AppError::from_sqlx("disc_result_by_user", e))?
    .ok_or_else(|| AppError::NotFound(format!("Disc result not found for user: {auth_user_id}")))?;
    Ok(Json(row.as_json()))
}

pub async fn delete_own_result(
    State(state): State<AppState>,
    auth: AuthUser,
) -> AppResult<axum::http::StatusCode> {
    sqlx::query("DELETE FROM disc_results WHERE auth_user_id = $1")
        .bind(&auth.user_id)
        .execute(&state.pool)
        .await
        .map_err(|e| AppError::from_sqlx("delete_disc_result", e))?;
    Ok(axum::http::StatusCode::NO_CONTENT)
}
