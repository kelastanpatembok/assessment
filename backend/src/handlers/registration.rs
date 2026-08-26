use axum::{
    extract::{Path, Query, State},
    http::StatusCode,
    Json,
};
use serde::{Deserialize, Serialize};
use sqlx::FromRow;

use crate::{
    auth_extractor::AuthUser,
    error::{AppError, AppResult},
    paging::{PageParams, PageResponse},
    state::AppState,
};

// ─── Models ────────────────────────────────────────────────────────────────

#[derive(Debug, Clone, FromRow, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct Registration {
    pub id: i64,
    pub name: String,
    pub email: String,
    pub phone: Option<String>,
    pub school_name: Option<String>,
    pub school_address: Option<String>,
    pub role: String,
    pub status: String,
    pub notes: Option<String>,
    pub auth_user_id: Option<String>,
    pub created_at: chrono::NaiveDateTime,
    pub updated_at: chrono::NaiveDateTime,
}

// ─── Requests ──────────────────────────────────────────────────────────────

#[derive(Debug, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct CreateRegistrationRequest {
    pub name: String,
    pub email: String,
    pub phone: Option<String>,
    pub school_name: Option<String>,
    pub school_address: Option<String>,
    pub role: Option<String>,
}

#[derive(Debug, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct UpdateRegistrationRequest {
    pub status: Option<String>,
    pub notes: Option<String>,
}

#[derive(Debug, Deserialize)]
pub struct ListParams {
    #[serde(flatten)]
    pub page: PageParams,
    pub status: Option<String>,
}

// ─── Public endpoint – anyone can submit ──────────────────────────────────

pub async fn submit(
    State(state): State<AppState>,
    Json(req): Json<CreateRegistrationRequest>,
) -> AppResult<Json<serde_json::Value>> {
    let name = req.name.trim().to_string();
    let email = req.email.trim().to_lowercase();
    if name.is_empty() || email.is_empty() {
        return Err(AppError::BadRequest("Nama dan email wajib diisi.".to_string()));
    }
    let role = req.role.as_deref().unwrap_or("SISWA").to_uppercase();

    let row = sqlx::query_as::<_, Registration>(
        "INSERT INTO registrations (name, email, phone, school_name, school_address, role, status, created_at, updated_at) \
         VALUES ($1, $2, $3, $4, $5, $6, 'pending', NOW(), NOW()) \
         RETURNING id, name, email, phone, school_name, school_address, role, status, notes, auth_user_id, created_at, updated_at",
    )
    .bind(&name)
    .bind(&email)
    .bind(req.phone.as_deref())
    .bind(req.school_name.as_deref())
    .bind(req.school_address.as_deref())
    .bind(&role)
    .fetch_one(&state.pool)
    .await
    .map_err(|e| AppError::from_sqlx("insert_registration", e))?;

    Ok(Json(serde_json::json!({
        "id": row.id,
        "message": "Pendaftaran berhasil! Tim kami akan segera menghubungi Anda.",
    })))
}

// ─── Admin – list all registrations ───────────────────────────────────────

pub async fn list(
    State(state): State<AppState>,
    auth: AuthUser,
    Query(params): Query<ListParams>,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SUPERADMIN"])?;

    let mut conds: Vec<String> = Vec::new();
    let mut binds: Vec<String> = Vec::new();
    let mut idx = 1usize;

    if let Some(search) = params.page.search.as_deref() {
        if !search.trim().is_empty() {
            conds.push(format!(
                "(LOWER(name) LIKE ${} OR LOWER(email) LIKE ${} OR LOWER(school_name) LIKE ${})",
                idx, idx, idx
            ));
            binds.push(format!("%{}%", search.trim().to_lowercase()));
            idx += 1;
        }
    }
    if let Some(status) = params.status.as_deref() {
        if !status.trim().is_empty() {
            conds.push(format!("status = ${}", idx));
            binds.push(status.trim().to_string());
            idx += 1;
        }
    }

    let where_sql = if conds.is_empty() {
        String::new()
    } else {
        format!(" WHERE {}", conds.join(" AND "))
    };

    let order_col = "created_at";
    let size = params.page.size_clamped();
    let offset = params.page.offset();

    let count_sql = format!("SELECT COUNT(*) FROM registrations{where_sql}");
    let mut cq = sqlx::query_scalar::<_, i64>(&count_sql);
    for b in &binds { cq = cq.bind(b); }
    let total: i64 = cq.fetch_one(&state.pool).await.map_err(|e| AppError::from_sqlx("count_registrations", e))?;

    let sql = format!(
        "SELECT id, name, email, phone, school_name, school_address, role, status, notes, auth_user_id, created_at, updated_at \
         FROM registrations{where_sql} ORDER BY {} DESC LIMIT ${} OFFSET ${}",
        order_col, idx, idx + 1
    );
    let mut q = sqlx::query_as::<_, Registration>(&sql);
    for b in &binds { q = q.bind(b); }
    let rows: Vec<Registration> = q.bind(size).bind(offset).fetch_all(&state.pool).await
        .map_err(|e| AppError::from_sqlx("list_registrations", e))?;

    Ok(Json(serde_json::to_value(PageResponse::new(
        rows,
        params.page.page_or_zero(),
        size,
        total,
    )).unwrap()))
}

// ─── Admin – update status / notes ────────────────────────────────────────

pub async fn update(
    State(state): State<AppState>,
    auth: AuthUser,
    Path(id): Path<i64>,
    Json(req): Json<UpdateRegistrationRequest>,
) -> AppResult<Json<Registration>> {
    auth.require_role(&["SUPERADMIN"])?;

    let allowed_status = ["pending", "approved", "rejected"];
    if let Some(ref s) = req.status {
        if !allowed_status.contains(&s.as_str()) {
            return Err(AppError::BadRequest(format!("Status tidak valid: {s}")));
        }
    }

    let row = sqlx::query_as::<_, Registration>(
        "UPDATE registrations SET \
            status = COALESCE($2, status), \
            notes  = COALESCE($3, notes), \
            updated_at = NOW() \
         WHERE id = $1 \
         RETURNING id, name, email, phone, school_name, school_address, role, status, notes, auth_user_id, created_at, updated_at",
    )
    .bind(id)
    .bind(req.status.as_deref())
    .bind(req.notes.as_deref())
    .fetch_optional(&state.pool)
    .await
    .map_err(|e| AppError::from_sqlx("update_registration", e))?
    .ok_or_else(|| AppError::NotFound(format!("Registration not found: {id}")))?;

    Ok(Json(row))
}

// ─── Admin – delete ────────────────────────────────────────────────────────

pub async fn delete(
    State(state): State<AppState>,
    auth: AuthUser,
    Path(id): Path<i64>,
) -> AppResult<StatusCode> {
    auth.require_role(&["SUPERADMIN"])?;

    let result = sqlx::query("DELETE FROM registrations WHERE id = $1")
        .bind(id)
        .execute(&state.pool)
        .await
        .map_err(|e| AppError::from_sqlx("delete_registration", e))?;

    if result.rows_affected() == 0 {
        return Err(AppError::NotFound(format!("Registration not found: {id}")));
    }
    Ok(StatusCode::NO_CONTENT)
}

// ─── Admin – provision account from registration ───────────────────────────

#[derive(Debug, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ProvisionRequest {
    pub username: String,
    pub password: String,
    pub role: String,          // SISWA | GURUBK | PSIKOLOG | SUPERADMIN | AFILIATOR
    pub school_id: Option<i64>,
}

pub async fn provision(
    State(state): State<AppState>,
    auth: AuthUser,
    Path(id): Path<i64>,
    Json(req): Json<ProvisionRequest>,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SUPERADMIN"])?;

    // Load the registration
    let reg = sqlx::query_as::<_, Registration>(
        "SELECT id, name, email, phone, school_name, school_address, role, status, notes, auth_user_id, created_at, updated_at \
         FROM registrations WHERE id = $1",
    )
    .bind(id)
    .fetch_optional(&state.pool)
    .await
    .map_err(|e| AppError::from_sqlx("load_registration", e))?
    .ok_or_else(|| AppError::NotFound(format!("Registration not found: {id}")))?;

    // Prevent double-provisioning
    if reg.auth_user_id.is_some() {
        return Err(AppError::Conflict(
            "Akun sudah pernah dibuat untuk pendaftaran ini.".to_string(),
        ));
    }

    let username = req.username.trim().to_string();
    let role = req.role.trim().to_lowercase();
    let allowed_roles = ["siswa", "gurubk", "psikolog", "superadmin", "afiliator"];
    if !allowed_roles.contains(&role.as_str()) {
        return Err(AppError::BadRequest(format!("Role tidak valid: {role}")));
    }

    // Validate school_id if provided
    if let Some(sid) = req.school_id {
        crate::db::require_school(&state.pool, sid).await?;
    }

    // Register in auth service
    let resp = state
        .auth
        .register(&username, &reg.email, &req.password, &reg.name, &role)
        .await
        .map_err(|e| AppError::Internal(e))?;
    let auth_user_id = resp.user.id;

    // Provision assessment_users row
    sqlx::query(
        "INSERT INTO assessment_users (auth_user_id, name, email, username, role, phone, school_id, created_at, updated_at) \
         VALUES ($1, $2, $3, $4, $5, $6, $7, NOW(), NOW())",
    )
    .bind(&auth_user_id)
    .bind(&reg.name)
    .bind(&reg.email)
    .bind(&username)
    .bind(&role)
    .bind(reg.phone.as_deref())
    .bind(req.school_id)
    .execute(&state.pool)
    .await
    .map_err(|e| AppError::from_sqlx("provision_user", e))?;

    // Mark registration as approved and link auth_user_id
    sqlx::query(
        "UPDATE registrations SET status = 'approved', auth_user_id = $2, updated_at = NOW() WHERE id = $1",
    )
    .bind(id)
    .bind(&auth_user_id)
    .execute(&state.pool)
    .await
    .map_err(|e| AppError::from_sqlx("link_registration", e))?;

    Ok(Json(serde_json::json!({
        "message": "Akun berhasil dibuat.",
        "authUserId": auth_user_id,
        "username": username,
        "role": role,
    })))
}
