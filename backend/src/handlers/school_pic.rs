use axum::{
    extract::{Path, State},
    http::StatusCode,
    Json,
};
use serde::Deserialize;

use crate::{
    auth_extractor::AuthUser,
    db,
    error::{AppError, AppResult},
    state::AppState,
};

#[derive(Debug, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct PicRequest {
    pub auth_user_id: String,
    #[serde(default)]
    pub is_primary: bool,
}

pub async fn list(
    State(state): State<AppState>,
    auth: AuthUser,
    Path(school_id): Path<i64>,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SUPERADMIN", "PSIKOLOG"])?;
    db::require_school(&state.pool, school_id).await?;
    let rows: Vec<(String, String, String, String, bool, chrono::NaiveDateTime)> = sqlx::query_as(
        "SELECT u.auth_user_id, u.name, u.email, u.role, sp.is_primary, sp.created_at \
         FROM school_pics sp JOIN assessment_users u ON u.auth_user_id = sp.auth_user_id \
         WHERE sp.school_id = $1 ORDER BY sp.is_primary DESC, LOWER(u.name)",
    )
    .bind(school_id)
    .fetch_all(&state.pool)
    .await
    .map_err(|e| AppError::from_sqlx("list_school_pics", e))?;

    Ok(Json(serde_json::json!(rows
        .into_iter()
        .map(|r| serde_json::json!({
            "authUserId": r.0,
            "name": r.1,
            "email": r.2,
            "role": r.3,
            "isPrimary": r.4,
            "createdAt": crate::datetime::java_local_date_time(r.5),
        }))
        .collect::<Vec<_>>())))
}

pub async fn add(
    State(state): State<AppState>,
    auth: AuthUser,
    Path(school_id): Path<i64>,
    Json(req): Json<PicRequest>,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SUPERADMIN"])?;
    db::require_school(&state.pool, school_id).await?;
    let user = db::load_user(&state.pool, &req.auth_user_id)
        .await?
        .ok_or_else(|| AppError::NotFound("Akun PIC tidak ditemukan".to_string()))?;
    if user.school_id != Some(school_id) {
        return Err(AppError::BadRequest(
            "Akun PIC harus terdaftar sebagai bagian dari sekolah ini".to_string(),
        ));
    }
    if user.role.eq_ignore_ascii_case("siswa") {
        return Err(AppError::BadRequest(
            "Akun siswa tidak dapat ditetapkan sebagai PIC sekolah".to_string(),
        ));
    }

    let existing_count: i64 =
        sqlx::query_scalar("SELECT COUNT(*) FROM school_pics WHERE school_id = $1")
            .bind(school_id)
            .fetch_one(&state.pool)
            .await
            .map_err(|e| AppError::from_sqlx("count_school_pics", e))?;
    let make_primary = req.is_primary || existing_count == 0;
    let mut tx = state.pool.begin().await?;
    if make_primary {
        sqlx::query("UPDATE school_pics SET is_primary = FALSE WHERE school_id = $1")
            .bind(school_id)
            .execute(&mut *tx)
            .await?;
    }
    sqlx::query(
        "INSERT INTO school_pics (school_id, auth_user_id, is_primary, created_by, created_at) \
         VALUES ($1, $2, $3, $4, NOW()) \
         ON CONFLICT (school_id, auth_user_id) DO UPDATE SET is_primary = EXCLUDED.is_primary",
    )
    .bind(school_id)
    .bind(&req.auth_user_id)
    .bind(make_primary)
    .bind(&auth.user_id)
    .execute(&mut *tx)
    .await?;
    tx.commit().await?;

    Ok(Json(
        serde_json::json!({ "success": true, "isPrimary": make_primary }),
    ))
}

pub async fn set_primary(
    State(state): State<AppState>,
    auth: AuthUser,
    Path((school_id, auth_user_id)): Path<(i64, String)>,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SUPERADMIN"])?;
    let mut tx = state.pool.begin().await?;
    sqlx::query("UPDATE school_pics SET is_primary = FALSE WHERE school_id = $1")
        .bind(school_id)
        .execute(&mut *tx)
        .await?;
    let changed = sqlx::query(
        "UPDATE school_pics SET is_primary = TRUE WHERE school_id = $1 AND auth_user_id = $2",
    )
    .bind(school_id)
    .bind(&auth_user_id)
    .execute(&mut *tx)
    .await?;
    if changed.rows_affected() == 0 {
        return Err(AppError::NotFound(
            "PIC sekolah tidak ditemukan".to_string(),
        ));
    }
    tx.commit().await?;
    Ok(Json(serde_json::json!({ "success": true })))
}

pub async fn remove(
    State(state): State<AppState>,
    auth: AuthUser,
    Path((school_id, auth_user_id)): Path<(i64, String)>,
) -> AppResult<StatusCode> {
    auth.require_role(&["SUPERADMIN"])?;
    let result = sqlx::query("DELETE FROM school_pics WHERE school_id = $1 AND auth_user_id = $2")
        .bind(school_id)
        .bind(auth_user_id)
        .execute(&state.pool)
        .await
        .map_err(|e| AppError::from_sqlx("remove_school_pic", e))?;
    if result.rows_affected() == 0 {
        return Err(AppError::NotFound(
            "PIC sekolah tidak ditemukan".to_string(),
        ));
    }
    Ok(StatusCode::NO_CONTENT)
}
