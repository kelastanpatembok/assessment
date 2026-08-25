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
        })
    }
}

use crate::permissions;

impl AuthUser {
    /// 403 (not 401) when the role isn't permitted, mirroring Spring Security.
    pub fn require_role(&self, allowed: &[&str]) -> Result<(), AppError> {
        let role_upper = self.role.to_uppercase();
        if allowed.iter().any(|r| r.to_uppercase() == role_upper) {
            Ok(())
        } else {
            Err(AppError::Forbidden("Access denied".to_string()))
        }
    }

    /// Check if user has specific permission
    pub fn has_permission(&self, permission: permissions::Permission) -> bool {
        permissions::check_permission(&self.role, permission)
    }

    /// Require specific permission
    pub fn require_permission(&self, permission: permissions::Permission) -> Result<(), AppError> {
        if self.has_permission(permission) {
            Ok(())
        } else {
            Err(AppError::Forbidden(format!(
                "Permission denied: user role {} cannot access this resource",
                self.role
            )))
        }
    }

    /// Check if user can access specific endpoint
    pub fn can_access_endpoint(&self, endpoint: &str, method: &str) -> bool {
        if let Some(role) = permissions::Role::from_str(&self.role) {
            permissions::RolePermissions::can_access_endpoint(role, endpoint, method)
        } else {
            false
        }
    }

    pub fn is_role(&self, role: &str) -> bool {
        self.role.eq_ignore_ascii_case(role)
    }

    /// Check if user is superadmin
    pub fn is_superadmin(&self) -> bool {
        self.is_role("SUPERADMIN")
    }

    /// Check if user is psikolog
    pub fn is_psikolog(&self) -> bool {
        self.is_role("PSIKOLOG")
    }

    /// Check if user is guru BK
    pub fn is_gurubk(&self) -> bool {
        self.is_role("GURUBK")
    }

    /// Check if user is siswa
    pub fn is_siswa(&self) -> bool {
        self.is_role("SISWA")
    }

    /// Check if user is afiliator
    pub fn is_afiliator(&self) -> bool {
        self.is_role("AFILIATOR")
    }

    /// Check if user is admin sekolah
    pub fn is_admin_sekolah(&self) -> bool {
        self.is_role("ADMIN_SEKOLAH")
    }

    /// Check if user is orang tua siswa
    pub fn is_ortu_siswa(&self) -> bool {
        self.is_role("ORTU_SISWA")
    }
}
