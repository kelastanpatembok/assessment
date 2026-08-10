use axum::{extract::State, Json};
use serde::Deserialize;

use crate::{
    db,
    error::{AppError, AppResult},
    models::user::AssessmentUserRow,
    state::AppState,
};

#[derive(Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ProvisionRequest {
    pub name: String,
    pub email: String,
    pub username: String,
    pub role: String,
}

pub async fn provision(
    State(state): State<AppState>,
    auth: crate::auth_extractor::AuthUser,
    Json(req): Json<ProvisionRequest>,
) -> AppResult<Json<serde_json::Value>> {
    let existing = db::load_user(&state.pool, &auth.user_id).await?;
    let user = if let Some(row) = existing {
        db::assemble_user(&state.pool, row).await?
    } else {
        let row = sqlx::query_as::<_, AssessmentUserRow>(
            "INSERT INTO assessment_users (auth_user_id, name, email, username, role, created_at, updated_at) \
             VALUES ($1, $2, $3, $4, $5, NOW(), NOW()) RETURNING auth_user_id, name, email, username, role, school_id, afiliator_id, created_at, updated_at",
        )
        .bind(&auth.user_id)
        .bind(&req.name)
        .bind(&req.email)
        .bind(&req.username)
        .bind(&req.role)
        .fetch_one(&state.pool)
        .await
        .map_err(|e| AppError::from_sqlx("provision_profile", e))?;
        db::assemble_user(&state.pool, row).await?
    };
    Ok(Json(user.as_json()))
}

pub async fn me(
    State(state): State<AppState>,
    auth: crate::auth_extractor::AuthUser,
) -> AppResult<Json<serde_json::Value>> {
    let user = db::require_user(&state.pool, &auth.user_id).await?;
    Ok(Json(user.as_json()))
}
