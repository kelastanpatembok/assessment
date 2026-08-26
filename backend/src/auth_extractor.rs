use axum::{
    extract::FromRequestParts,
    http::{request::Parts, StatusCode},
    response::{IntoResponse, Response},
    Json,
};
use serde_json::json;

use crate::{error::AppError, jwt, state::AppState};

pub struct AuthUser {
    pub user_id: String,
    pub username: String,
    pub role: String,
    pub roles: Vec<String>,
    /// Forwarded only to Auth's superadmin-only provisioning endpoint.
    /// It never reaches a client response or application log.
    pub token: String,
}

pub struct AuthRejection(String);

impl IntoResponse for AuthRejection {
    fn into_response(self) -> Response {
        (
            StatusCode::UNAUTHORIZED,
            Json(json!({
                "code": "UNAUTHORIZED",
                "message": format!("Unauthorized: {}", self.0),
                "timestamp": crate::datetime::java_now_utc(),
            })),
        )
            .into_response()
    }
}

#[axum::async_trait]
impl FromRequestParts<AppState> for AuthUser {
    type Rejection = AuthRejection;

    async fn from_request_parts(
        parts: &mut Parts,
        state: &AppState,
    ) -> Result<Self, Self::Rejection> {
        let header = parts
            .headers
            .get("Authorization")
            .and_then(|v| v.to_str().ok())
            .ok_or_else(|| AuthRejection("missing bearer token".to_string()))?;
        let token = header
            .strip_prefix("Bearer ")
            .ok_or_else(|| AuthRejection("missing bearer token".to_string()))?;
        let claims = jwt::validate_token(&state.config.jwt_secret, token)
            .ok_or_else(|| AuthRejection("invalid or expired token".to_string()))?;
        Ok(AuthUser {
            user_id: claims.sub,
            username: claims.username,
            role: claims.role,
            roles: claims.roles,
            token: token.to_string(),
        })
    }
}

impl AuthUser {
    /// 403 (not 401) when the role isn't permitted, mirroring Spring Security.
    pub fn require_role(&self, allowed: &[&str]) -> Result<(), AppError> {
        if allowed.iter().any(|allowed_role| self.is_role(allowed_role)) {
            Ok(())
        } else {
            Err(AppError::Forbidden("Access denied".to_string()))
        }
    }

    pub fn is_role(&self, role: &str) -> bool {
        self.role.eq_ignore_ascii_case(role)
          || self.roles.iter().any(|value| value.eq_ignore_ascii_case(role))
    }
}
