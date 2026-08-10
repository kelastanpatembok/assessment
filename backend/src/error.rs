use axum::{
    http::StatusCode,
    response::{IntoResponse, Response},
    Json,
};
use serde::Serialize;
use std::collections::HashMap;

use crate::datetime::java_now_utc;

/// Mirrors the Spring GlobalExceptionHandler error envelope exactly:
/// `{"code": "...", "message": "...", "details": {...}|null, "timestamp": "..."}`
#[derive(Serialize)]
pub struct ErrorEnvelope {
    code: String,
    message: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    details: Option<HashMap<String, String>>,
    timestamp: String,
}

pub enum AppError {
    BadRequest(String),
    Validation(HashMap<String, String>),
    Forbidden(String),
    NotFound(String),
    Conflict(String),
    CredentialGenerationFailed(String),
    CredentialCreationFailed(String),
    Internal(anyhow::Error),
}

impl AppError {
    fn status_and_code(&self) -> (StatusCode, &'static str) {
        match self {
            AppError::BadRequest(_) => (StatusCode::BAD_REQUEST, "BAD_REQUEST"),
            AppError::Validation(_) => (StatusCode::BAD_REQUEST, "VALIDATION_ERROR"),
            AppError::Forbidden(_) => (StatusCode::FORBIDDEN, "FORBIDDEN"),
            AppError::NotFound(_) => (StatusCode::NOT_FOUND, "NOT_FOUND"),
            AppError::Conflict(_) => (StatusCode::CONFLICT, "CONFLICT"),
            AppError::CredentialGenerationFailed(_) => (
                StatusCode::UNPROCESSABLE_ENTITY,
                "CREDENTIAL_GENERATION_FAILED",
            ),
            AppError::CredentialCreationFailed(_) => {
                (StatusCode::INTERNAL_SERVER_ERROR, "CREDENTIAL_CREATION_FAILED")
            }
            AppError::Internal(_) => {
                (StatusCode::INTERNAL_SERVER_ERROR, "INTERNAL_SERVER_ERROR")
            }
        }
    }

    pub fn from_sqlx(label: &str, err: sqlx::Error) -> Self {
        AppError::Internal(anyhow::anyhow!("{label}: {err}"))
    }
}

impl IntoResponse for AppError {
    fn into_response(self) -> Response {
        let (status, code) = self.status_and_code();
        let (message, details) = match self {
            AppError::BadRequest(msg) => (msg, None),
            AppError::Validation(details) => ("Validation failed".to_string(), Some(details)),
            AppError::Forbidden(msg) => (msg, None),
            AppError::NotFound(msg) => (msg, None),
            AppError::Conflict(msg) => (msg, None),
            AppError::CredentialGenerationFailed(msg) => (msg, None),
            AppError::CredentialCreationFailed(msg) => (msg, None),
            AppError::Internal(err) => {
                tracing::error!("Unexpected error occurred: {err:?}");
                ("An unexpected error occurred".to_string(), None)
            }
        };

        let body = ErrorEnvelope {
            code: code.to_string(),
            message,
            details,
            timestamp: java_now_utc(),
        };
        (status, Json(body)).into_response()
    }
}

impl From<anyhow::Error> for AppError {
    fn from(err: anyhow::Error) -> Self {
        AppError::Internal(err)
    }
}

impl From<sqlx::Error> for AppError {
    fn from(err: sqlx::Error) -> Self {
        AppError::Internal(err.into())
    }
}

impl From<reqwest::Error> for AppError {
    fn from(err: reqwest::Error) -> Self {
        AppError::Internal(err.into())
    }
}

pub type AppResult<T> = Result<T, AppError>;

/// Mirrors `@NotBlank`-style validation producing `{field: message}`.
pub fn require_non_blank(fields: &[(&str, &str)]) -> AppResult<()> {
    let details: HashMap<String, String> = fields
        .iter()
        .filter(|(_, value)| value.trim().is_empty())
        .map(|(name, _)| (name.to_string(), format!("{name} is required")))
        .collect();
    if details.is_empty() {
        Ok(())
    } else {
        Err(AppError::Validation(details))
    }
}
