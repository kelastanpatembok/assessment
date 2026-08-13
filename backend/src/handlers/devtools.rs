use axum::{extract::Path, http::StatusCode};

use crate::{
    auth_extractor::AuthUser,
    error::{AppError, AppResult},
    state::AppState,
};

/// Dev-only endpoint (app.dev-tools-enabled) that clears a student's own
/// result so a test can be retaken while developing. SISWA only.
pub async fn clear_result(
    axum::extract::State(state): axum::extract::State<AppState>,
    auth: AuthUser,
    Path(test_key): Path<String>,
) -> AppResult<StatusCode> {
    auth.require_role(&["SISWA"])?;
    let table = match test_key.as_str() {
        "disc" => "disc_results",
        "holland" => "holland_results",
        "papi" => "papi_results",
        "cfit" => "cfit_results",
        "ist" => "ist_results",
        "epps" => "epps_results",
        _ => return Err(AppError::BadRequest("Unknown test key".to_string())),
    };
    let sql = format!("DELETE FROM {table} WHERE auth_user_id = $1");
    sqlx::query(&sql)
        .bind(&auth.user_id)
        .execute(&state.pool)
        .await
        .map_err(|e| AppError::from_sqlx("dev_clear_result", e))?;
    Ok(StatusCode::NO_CONTENT)
}
