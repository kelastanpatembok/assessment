use sqlx::PgPool;

use crate::{
    error::AppResult,
    models::{
        school::School,
        user::{AssessmentUser, AssessmentUserRow},
    },
};

/// Load a school by id.
pub async fn load_school(pool: &PgPool, id: i64) -> AppResult<Option<School>> {
    let row = sqlx::query_as::<_, (i64, String, Option<String>, Option<String>, Option<String>, Option<String>, Option<String>, chrono::NaiveDateTime, chrono::NaiveDateTime)>(
        "SELECT id, name, address, city, province, phone, email, created_at, updated_at FROM schools WHERE id = $1",
    )
    .bind(id)
    .fetch_optional(pool)
    .await
    .map_err(|e| crate::error::AppError::from_sqlx("load_school", e))?;

    Ok(row.map(|r| School {
        id: r.0,
        name: r.1,
        address: r.2,
        city: r.3,
        province: r.4,
        phone: r.5,
        email: r.6,
        created_at: r.7,
        updated_at: r.8,
    }))
}

/// Load a school by name (for uniqueness checks).
pub async fn find_school_by_name(pool: &PgPool, name: &str) -> AppResult<Option<School>> {
    let row = sqlx::query_as::<_, (i64, String, Option<String>, Option<String>, Option<String>, Option<String>, Option<String>, chrono::NaiveDateTime, chrono::NaiveDateTime)>(
        "SELECT id, name, address, city, province, phone, email, created_at, updated_at FROM schools WHERE name = $1",
    )
    .bind(name)
    .fetch_optional(pool)
    .await
    .map_err(|e| crate::error::AppError::from_sqlx("find_school_by_name", e))?;

    Ok(row.map(|r| School {
        id: r.0,
        name: r.1,
        address: r.2,
        city: r.3,
        province: r.4,
        phone: r.5,
        email: r.6,
        created_at: r.7,
        updated_at: r.8,
    }))
}

/// Load an assessment user row by auth user id.
pub async fn load_user(pool: &PgPool, auth_user_id: &str) -> AppResult<Option<AssessmentUserRow>> {
    let row = sqlx::query_as::<_, AssessmentUserRow>(
        "SELECT auth_user_id, name, email, username, role, school_id, afiliator_id, created_at, updated_at \
         FROM assessment_users WHERE auth_user_id = $1",
    )
    .bind(auth_user_id)
    .fetch_optional(pool)
    .await
    .map_err(|e| crate::error::AppError::from_sqlx("load_user", e))?;
    Ok(row)
}

/// Assemble a full AssessmentUser (row + school object).
pub async fn assemble_user(pool: &PgPool, row: AssessmentUserRow) -> AppResult<AssessmentUser> {
    let school = match row.school_id {
        Some(id) => load_school(pool, id).await?,
        None => None,
    };
    Ok(AssessmentUser {
        auth_user_id: row.auth_user_id,
        name: row.name,
        email: row.email,
        username: row.username,
        role: row.role,
        school,
        afiliator_id: row.afiliator_id,
        created_at: row.created_at,
        updated_at: row.updated_at,
    })
}

/// Assemble a full AssessmentUser, erroring with 404 if missing.
pub async fn require_user(pool: &PgPool, auth_user_id: &str) -> AppResult<AssessmentUser> {
    let row = load_user(pool, auth_user_id)
        .await?
        .ok_or_else(|| crate::error::AppError::NotFound(format!("User not found: {auth_user_id}")))?;
    assemble_user(pool, row).await
}

pub async fn require_school(pool: &PgPool, id: i64) -> AppResult<School> {
    load_school(pool, id)
        .await?
        .ok_or_else(|| crate::error::AppError::NotFound(format!("School not found: {id}")))
}
