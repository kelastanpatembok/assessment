use crate::{
    auth_extractor::AuthUser,
    error::{AppError, AppResult},
    models::epps::{EppsAnswerDto, EppsResult, EppsSubmitRequest},
    paging::{PageParams, PageResponse},
    scoring::epps,
    state::AppState,
};
use axum::{
    extract::{Path, Query, State},
    Json,
};
use std::collections::BTreeMap;

const SEL: &str = "id, auth_user_id, student_name, school_name, assignment_id, gender, trait_scores::text, consistency_raw, consistency_percentile, answers::text, completed_at";

pub async fn questions(
    State(state): State<AppState>,
    auth: AuthUser,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SISWA"])?;
    let rows: Vec<(i64, i32, String, String)> = sqlx::query_as(
        "SELECT id, item_no, statement_a, statement_b FROM epps_questions \
         WHERE is_active = true ORDER BY item_no",
    )
    .fetch_all(&state.pool)
    .await
    .map_err(|e| AppError::from_sqlx("epps_questions", e))?;

    Ok(Json(serde_json::json!(rows
        .into_iter()
        .map(|(id, no, statement_a, statement_b)| serde_json::json!({
            "id": id,
            "no": no,
            "statementA": statement_a,
            "statementB": statement_b,
        }))
        .collect::<Vec<_>>())))
}

pub async fn check(
    State(state): State<AppState>,
    auth: AuthUser,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SISWA"])?;
    Ok(Json(super::disc::check_for(&state, &auth, "epps").await?))
}

pub async fn submit(
    State(state): State<AppState>,
    auth: AuthUser,
    Json(req): Json<EppsSubmitRequest>,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SISWA"])?;
    let gender = req.gender.trim().to_uppercase();
    let female = match gender.as_str() {
        "PEREMPUAN" | "P" => true,
        "LAKI-LAKI" | "LAKI LAKI" | "L" => false,
        _ => {
            return Err(AppError::BadRequest(
                "Jenis kelamin harus Laki-Laki atau Perempuan.".to_string(),
            ))
        }
    };
    let mut answers = BTreeMap::new();
    for EppsAnswerDto { no, choice } in req.answers {
        if !(1..=225).contains(&no) || answers.insert(no, choice.trim().to_uppercase()).is_some() {
            return Err(AppError::BadRequest(
                "Jawaban EPPS tidak valid atau duplikat.".to_string(),
            ));
        }
    }
    let (scores, consistency_raw, consistency_percentile) =
        epps::score(&answers, female).map_err(AppError::BadRequest)?;
    let exists: i64 =
        sqlx::query_scalar("SELECT COUNT(*) FROM epps_results WHERE auth_user_id = $1")
            .bind(&auth.user_id)
            .fetch_one(&state.pool)
            .await
            .map_err(|e| AppError::from_sqlx("epps_exists", e))?;
    if exists > 0 {
        return Err(AppError::Conflict(
            "Anda sudah pernah mengerjakan tes ini. Hasil tidak dapat diulang.".to_string(),
        ));
    }
    let user = crate::db::load_user(&state.pool, &auth.user_id).await?;
    let student_name = user.as_ref().map(|u| u.name.clone());
    let school_name = match user.as_ref().and_then(|u| u.school_id) {
        Some(id) => crate::db::load_school(&state.pool, id)
            .await?
            .map(|s| s.name),
        None => None,
    };
    let score_json = serde_json::to_string(&scores.iter().map(|(code, score)| serde_json::json!({"code": code, "label": score.label, "raw": score.raw, "percentile": score.percentile})).collect::<Vec<_>>()).unwrap();
    let answer_json = serde_json::to_string(&answers).unwrap();
    let row = sqlx::query_as::<_, EppsResult>(&format!("INSERT INTO epps_results (auth_user_id, student_name, school_name, assignment_id, gender, trait_scores, consistency_raw, consistency_percentile, answers, completed_at) VALUES ($1,$2,$3,$4,$5,$6::jsonb,$7,$8,$9::jsonb,NOW()) RETURNING {SEL}"))
        .bind(&auth.user_id).bind(student_name).bind(school_name).bind(req.assignment_id).bind(gender).bind(score_json).bind(consistency_raw).bind(consistency_percentile).bind(answer_json).fetch_one(&state.pool).await.map_err(|e| AppError::from_sqlx("insert_epps_result", e))?;
    Ok(Json(row.as_json()))
}

pub async fn result_me(
    State(state): State<AppState>,
    auth: AuthUser,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SISWA"])?;
    let r = sqlx::query_as::<_, EppsResult>(&format!(
        "SELECT {SEL} FROM epps_results WHERE auth_user_id = $1"
    ))
    .bind(&auth.user_id)
    .fetch_optional(&state.pool)
    .await
    .map_err(|e| AppError::from_sqlx("epps_me", e))?
    .ok_or_else(|| AppError::NotFound("Epps result not found".to_string()))?;
    Ok(Json(r.as_json()))
}

pub async fn results(
    State(state): State<AppState>,
    auth: AuthUser,
    Query(params): Query<super::disc::CheckParams>,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SUPERADMIN", "GURUBK", "AFILIATOR", "PSIKOLOG"])?;
    let pp = PageParams {
        page: params.page, size: params.size, search: params.search, sort: params.sort, order: params.order,
    };
    Ok(Json(list_scoped(&state, &auth, &pp).await?))
}

async fn list_scoped(state: &AppState, auth: &AuthUser, params: &PageParams) -> AppResult<serde_json::Value> {
    let mut conds: Vec<String> = Vec::new();
    let mut binds: Vec<String> = Vec::new();
    let mut idx = 1usize;
    if params.has_search() {
        conds.push(format!("(LOWER(student_name) LIKE ${} OR LOWER(school_name) LIKE ${})", idx, idx));
        binds.push(params.search_like());
        idx += 1;
    }
    
    if auth.is_role("gurubk") {
        let school_id = crate::db::load_user(&state.pool, &auth.user_id).await?.and_then(|u| u.school_id);
        if let Some(sid) = school_id {
            conds.push(format!("EXISTS (SELECT 1 FROM schools s WHERE s.id = ${} AND s.name = epps_results.school_name)", idx));
            binds.push(sid.to_string());
            idx += 1;
        }
    } else if auth.is_role("afiliator") {
        conds.push(format!("auth_user_id IN (SELECT auth_user_id FROM assessment_users WHERE afiliator_id = ${})", idx));
        binds.push(auth.user_id.clone());
        idx += 1;
    }

    let where_sql = if conds.is_empty() { String::new() } else { format!(" WHERE {}", conds.join(" AND ")) };
    let sort = params.sort_key(&["studentName", "schoolName", "completedAt", "id"], "completedAt");
    let order = params.order_dir();
    let order_col = params.sort_col(sort);
    let size = params.size_clamped();
    let offset = params.offset();

    if params.is_paginated() {
        let count_sql = format!("SELECT COUNT(*) FROM epps_results{where_sql}");
        let mut cq = sqlx::query_scalar::<_, i64>(&count_sql);
        for b in &binds { cq = cq.bind(b); }
        let total: i64 = cq.fetch_one(&state.pool).await.map_err(|e| AppError::from_sqlx("count_epps", e))?;
        let sql = format!("SELECT {SEL} FROM epps_results{where_sql} ORDER BY {} {} LIMIT ${} OFFSET ${}", order_col, order, idx, idx + 1);
        let mut q = sqlx::query_as::<_, EppsResult>(&sql);
        for b in &binds { q = q.bind(b); }
        let rows: Vec<EppsResult> = q.bind(size).bind(offset).fetch_all(&state.pool).await.map_err(|e| AppError::from_sqlx("list_epps", e))?;
        let items: Vec<serde_json::Value> = rows.iter().map(|r| r.as_json()).collect();
        Ok(serde_json::to_value(PageResponse::new(items, params.page_or_zero(), size, total)).unwrap())
    } else {
        let sql = format!("SELECT {SEL} FROM epps_results{where_sql} ORDER BY {} {}", order_col, order);
        let mut q = sqlx::query_as::<_, EppsResult>(&sql);
        for b in &binds { q = q.bind(b); }
        let rows: Vec<EppsResult> = q.fetch_all(&state.pool).await.map_err(|e| AppError::from_sqlx("list_epps", e))?;
        Ok(serde_json::json!(rows.iter().map(|r| r.as_json()).collect::<Vec<_>>()))
    }
}

pub async fn result_by_user(
    State(state): State<AppState>,
    auth: AuthUser,
    Path(id): Path<String>,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SUPERADMIN", "GURUBK", "AFILIATOR", "PSIKOLOG"])?;
    let r = sqlx::query_as::<_, EppsResult>(&format!(
        "SELECT {SEL} FROM epps_results WHERE auth_user_id = $1"
    ))
    .bind(id)
    .fetch_optional(&state.pool)
    .await
    .map_err(|e| AppError::from_sqlx("epps_user", e))?
    .ok_or_else(|| AppError::NotFound("Epps result not found".to_string()))?;
    Ok(Json(r.as_json()))
}
