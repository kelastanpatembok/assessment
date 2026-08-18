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
    let p = PageParams {
        page: params.page,
        size: params.size,
        search: params.search,
        sort: params.sort,
        order: params.order,
    };
    let rows: Vec<EppsResult> = sqlx::query_as(&format!(
        "SELECT {SEL} FROM epps_results ORDER BY completed_at DESC"
    ))
    .fetch_all(&state.pool)
    .await
    .map_err(|e| AppError::from_sqlx("epps_results", e))?;
    let items: Vec<_> = rows.iter().map(EppsResult::as_json).collect();
    Ok(Json(if p.is_paginated() {
        serde_json::to_value(PageResponse::new(
            items,
            p.page_or_zero(),
            p.size_clamped(),
            rows.len() as i64,
        ))
        .unwrap()
    } else {
        serde_json::json!(items)
    }))
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
