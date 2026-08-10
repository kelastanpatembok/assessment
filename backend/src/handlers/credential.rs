use axum::{
    extract::{Path, Query, State},
    http::{header, StatusCode},
    response::Response,
    Json,
};
use rand::seq::SliceRandom;
use rand::Rng;
use serde::Deserialize;

use crate::{
    auth_extractor::AuthUser,
    error::{AppError, AppResult},
    models::credential::{BulkCredentialRequest, BulkCredentialResponse, CredentialBatch, CredentialBatchRow, CredentialDto},
    paging::{PageParams, PageResponse},
    state::AppState,
};

const UPPERCASE: &[u8] = b"ABCDEFGHJKLMNPQRSTUVWXYZ";
const LOWERCASE: &[u8] = b"abcdefghijkmnopqrstuvwxyz";
const DIGITS: &[u8] = b"23456789";
const ALL_CHARS: &[u8] = b"ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789";
const PASSWORD_LENGTH: usize = 8;
const MAX_SEQUENCE_ATTEMPTS: i32 = 1000;
const CONFLICT_CHECK_BATCH_SIZE: usize = 50;
const MAX_CODE_LENGTH: usize = 10;

fn valid_pattern(s: &str) -> bool {
    !s.is_empty() && s.len() <= MAX_CODE_LENGTH && s.chars().all(|c| c.is_ascii_alphanumeric() || c == '_')
}

fn generate_password(rng: &mut impl Rng) -> String {
    let mut chars: Vec<u8> = Vec::with_capacity(PASSWORD_LENGTH);
    chars.push(UPPERCASE[rng.gen_range(0..UPPERCASE.len())]);
    chars.push(LOWERCASE[rng.gen_range(0..LOWERCASE.len())]);
    chars.push(DIGITS[rng.gen_range(0..DIGITS.len())]);
    for _ in 3..PASSWORD_LENGTH {
        chars.push(ALL_CHARS[rng.gen_range(0..ALL_CHARS.len())]);
    }
    chars.shuffle(rng);
    String::from_utf8(chars).unwrap()
}

fn generate_passwords(count: usize) -> Vec<String> {
    let mut rng = rand::thread_rng();
    let mut set: std::collections::HashSet<String> = std::collections::HashSet::new();
    while set.len() < count {
        set.insert(generate_password(&mut rng));
    }
    set.into_iter().collect()
}

/// Unique usernames with conflict resolution (mirrors UsernameGenerationService).
async fn generate_unique_usernames(
    state: &AppState,
    school_code: &str,
    test_code: &str,
    count: i32,
) -> AppResult<Vec<String>> {
    if !valid_pattern(school_code) {
        return Err(AppError::CredentialGenerationFailed(format!(
            "schoolCode contains invalid characters or exceeds maximum length"
        )));
    }
    if !valid_pattern(test_code) {
        return Err(AppError::CredentialGenerationFailed(format!(
            "testCode contains invalid characters or exceeds maximum length"
        )));
    }

    let prefix = format!("{school_code}_{test_code}_");
    let mut candidates = Vec::new();
    for i in 1..=count {
        candidates.push(format!("{prefix}{:03}", i));
    }

    let existing = state.auth.check_usernames_exist(&candidates).await.map_err(|e| AppError::Internal(e))?;
    let mut reserved: std::collections::HashSet<String> = std::collections::HashSet::new();
    let mut unique = Vec::new();
    let mut sequence_offset = count + 1;

    for candidate in candidates {
        if !existing.contains(&candidate) {
            unique.push(candidate.clone());
            reserved.insert(candidate);
        } else {
            let resolved = resolve_conflict(state, &prefix, sequence_offset, &mut reserved).await;
            match resolved {
                Some(r) => {
                    unique.push(r.clone());
                    reserved.insert(r);
                    sequence_offset += 1;
                }
                None => {
                    return Err(AppError::CredentialGenerationFailed(format!(
                        "Could not generate unique username after {MAX_SEQUENCE_ATTEMPTS} attempts. Pattern: {prefix}, offset: {sequence_offset}"
                    )));
                }
            }
        }
    }
    Ok(unique)
}

async fn resolve_conflict(
    state: &AppState,
    prefix: &str,
    start_seq: i32,
    reserved: &mut std::collections::HashSet<String>,
) -> Option<String> {
    let mut base = start_seq;
    while base < start_seq + MAX_SEQUENCE_ATTEMPTS {
        let window_end = std::cmp::min(base + CONFLICT_CHECK_BATCH_SIZE as i32, start_seq + MAX_SEQUENCE_ATTEMPTS);
        let mut window: Vec<String> = Vec::new();
        for seq in base..window_end {
            let candidate = format!("{prefix}{:03}", seq);
            if !reserved.contains(&candidate) {
                window.push(candidate);
            }
        }
        if !window.is_empty() {
            let existing = state.auth.check_usernames_exist(&window).await.ok()?;
            for candidate in &window {
                if !existing.contains(candidate) {
                    return Some(candidate.clone());
                }
            }
        }
        base += CONFLICT_CHECK_BATCH_SIZE as i32;
    }
    None
}

#[derive(Deserialize)]
pub struct BatchParams {
    pub test_assignment_id: Option<i64>,
    #[serde(flatten)]
    pub page: PageParams,
}

pub async fn bulk_generate(
    State(state): State<AppState>,
    auth: AuthUser,
    Json(req): Json<BulkCredentialRequest>,
) -> AppResult<(StatusCode, Json<serde_json::Value>)> {
    auth.require_role(&["SUPERADMIN"])?;
    // Validate assignment.
    let assignment = sqlx::query_as::<_, crate::models::test_assignment::TestAssignmentRow>(
        "SELECT id, category_id, school_id, student_id, assigned_by, window_start, window_end, is_active, created_at FROM test_assignments WHERE id = $1",
    )
    .bind(req.test_assignment_id)
    .fetch_optional(&state.pool)
    .await
    .map_err(|e| AppError::from_sqlx("find_assignment", e))?
    .ok_or_else(|| AppError::CredentialGenerationFailed(format!("Test assignment not found: id={}", req.test_assignment_id)))?;

    if !assignment.active {
        return Err(AppError::CredentialGenerationFailed("Test assignment is not active".to_string()));
    }
    if let Some(end) = assignment.window_end {
        if end < chrono::Utc::now().naive_utc() {
            return Err(AppError::CredentialGenerationFailed("Test assignment has ended".to_string()));
        }
    }
    let school_id = assignment.school_id.ok_or_else(|| AppError::CredentialGenerationFailed("Assignment has no school".to_string()))?;
    let school = crate::db::load_school(&state.pool, school_id).await?
        .ok_or_else(|| AppError::CredentialGenerationFailed("Assignment school missing".to_string()))?;
    let category = sqlx::query_as::<_, crate::models::test_category::TestCategoryRow>(
        "SELECT id, name, slug, description, tests, price, is_active, created_at FROM test_categories WHERE id = $1",
    )
    .bind(assignment.category_id)
    .fetch_optional(&state.pool)
    .await
    .map_err(|e| AppError::from_sqlx("find_category", e))?
    .ok_or_else(|| AppError::CredentialGenerationFailed("Assignment category missing".to_string()))?;

    let usernames = generate_unique_usernames(&state, &req.school_code, &req.test_code, req.count).await?;
    let passwords = generate_passwords(req.count as usize);

    // Create credentials atomically in batches of 50.
    let mut credentials = Vec::new();
    let created_auth_ids: Vec<String> = Vec::new();
    let mut _created_auth_ids = created_auth_ids;

    for (i, (username, password)) in usernames.iter().zip(passwords.iter()).enumerate() {
        let email = format!("{username}@generated.local");
        let name = format!("Student {username}");
        match state.auth.register(username, &email, password, &name, "siswa").await {
            Ok(resp) => {
                let auth_user_id = resp.user.id;
                sqlx::query(
                    "INSERT INTO assessment_users (auth_user_id, name, email, username, role, school_id, created_at, updated_at) \
                     VALUES ($1, $2, $3, $4, 'siswa', $5, NOW(), NOW())",
                )
                .bind(&auth_user_id)
                .bind(&name)
                .bind(&email)
                .bind(username)
                .bind(school_id)
                .execute(&state.pool)
                .await
                .map_err(|e| AppError::from_sqlx("insert_credential_user", e))?;

                let _ = i;
                credentials.push(CredentialDto {
                    username: username.clone(),
                    password: password.clone(),
                    auth_user_id: auth_user_id.clone(),
                    created_at: chrono::Utc::now().naive_utc(),
                });
                _created_auth_ids.push(auth_user_id);
            }
            Err(e) => {
                // Compensating rollback: delete already-created auth users.
                for uid in &_created_auth_ids {
                    state.auth.delete_user(uid).await;
                }
                return Err(AppError::CredentialCreationFailed(format!(
                    "Failed to create credential for {username}: {e}"
                )));
            }
        }
    }

    // Best-effort PDF batch.
    let batch_id = save_pdf_batch(&state, &req, school_id, &school.name, &category.name, &auth.username, &credentials).await.ok();

    let now = chrono::Utc::now().naive_utc();
    Ok((
        StatusCode::CREATED,
        Json(BulkCredentialResponse {
            credentials,
            school_name: school.name,
            test_category: category.name,
            count: req.count,
            created_by: auth.username,
            created_at: now,
            credential_batch_id: batch_id,
        }
        .as_json()),
    ))
}

/// Generates a minimal A4 PDF with the credential table and persists the
/// batch row + file. Mirrors CredentialService.saveCredentialPdfBatch.
async fn save_pdf_batch(
    state: &AppState,
    req: &BulkCredentialRequest,
    school_id: i64,
    school_name: &str,
    category_name: &str,
    generated_by: &str,
    credentials: &[CredentialDto],
) -> AppResult<i64> {
    let pdf_bytes = crate::pdf::build_credentials_pdf(school_name, category_name, credentials)?;

    let now = chrono::Utc::now().naive_utc();
    let filename = crate::pdf::display_filename(school_name, category_name, now);

    let batch = sqlx::query_as::<_, CredentialBatchRow>(
        "INSERT INTO credential_batches (test_assignment_id, school_id, school_name, category_name, credential_count, pdf_filename, generated_by, created_at) \
         VALUES ($1, $2, $3, $4, $5, $6, $7, NOW()) \
         RETURNING id, test_assignment_id, school_id, school_name, category_name, credential_count, pdf_filename, generated_by, created_at",
    )
    .bind(req.test_assignment_id)
    .bind(school_id)
    .bind(school_name)
    .bind(category_name)
    .bind(credentials.len() as i32)
    .bind(&filename)
    .bind(generated_by)
    .fetch_one(&state.pool)
    .await
    .map_err(|e| AppError::from_sqlx("insert_batch", e))?;

    let dir = std::path::Path::new(&state.config.credentials_storage_path);
    std::fs::create_dir_all(dir).map_err(|e| AppError::Internal(anyhow::anyhow!("mkdir credentials: {e}")))?;
    let file_path = dir.join(format!("{}.pdf", batch.id));
    std::fs::write(&file_path, pdf_bytes).map_err(|e| AppError::Internal(anyhow::anyhow!("write pdf: {e}")))?;
    Ok(batch.id)
}

pub async fn batches(
    State(state): State<AppState>,
    auth: AuthUser,
    Query(params): Query<BatchParams>,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SUPERADMIN"])?;
    let conds: Vec<String> = match params.test_assignment_id {
        Some(tid) => vec![format!("test_assignment_id = {}", tid)],
        None => vec![],
    };
    let where_sql = if conds.is_empty() { String::new() } else { format!(" WHERE {}", conds.join(" AND ")) };

    let sel = "id, test_assignment_id, school_id, school_name, category_name, credential_count, pdf_filename, generated_by, created_at";

    if params.page.is_paginated() {
        let count_sql = format!("SELECT COUNT(*) FROM credential_batches{where_sql}");
        let total: i64 = sqlx::query_scalar(&count_sql)
            .fetch_one(&state.pool)
            .await
            .map_err(|e| AppError::from_sqlx("count_batches", e))?;
        let size = params.page.size_clamped();
        let offset = params.page.offset();
        let sql = format!("SELECT {sel} FROM credential_batches{where_sql} ORDER BY created_at DESC LIMIT $1 OFFSET $2");
        let rows: Vec<CredentialBatchRow> = sqlx::query_as(&sql).bind(size).bind(offset).fetch_all(&state.pool).await.map_err(|e| AppError::from_sqlx("list_batches", e))?;
        let items: Vec<serde_json::Value> = rows.iter().map(|r| CredentialBatch::from_row(r).as_json()).collect();
        Ok(Json(serde_json::to_value(PageResponse::new(items, params.page.page_or_zero(), size, total)).unwrap()))
    } else {
        let order = if params.test_assignment_id.is_some() {
            "ORDER BY created_at DESC"
        } else {
            "ORDER BY created_at DESC"
        };
        let sql = format!("SELECT {sel} FROM credential_batches{where_sql} {order}");
        let rows: Vec<CredentialBatchRow> = sqlx::query_as(&sql).fetch_all(&state.pool).await.map_err(|e| AppError::from_sqlx("list_batches", e))?;
        Ok(Json(serde_json::json!(rows.iter().map(|r| CredentialBatch::from_row(r).as_json()).collect::<Vec<_>>())))
    }
}

pub async fn download(
    State(state): State<AppState>,
    auth: AuthUser,
    Path(id): Path<i64>,
) -> AppResult<Response> {
    auth.require_role(&["SUPERADMIN"])?;
    let row = sqlx::query_as::<_, CredentialBatchRow>(
        "SELECT id, test_assignment_id, school_id, school_name, category_name, credential_count, pdf_filename, generated_by, created_at FROM credential_batches WHERE id = $1",
    )
    .bind(id)
    .fetch_optional(&state.pool)
    .await
    .map_err(|e| AppError::from_sqlx("get_batch", e))?
    .ok_or_else(|| AppError::NotFound(format!("Credential batch not found: {id}")))?;

    let path = std::path::Path::new(&state.config.credentials_storage_path).join(format!("{id}.pdf"));
    let bytes = std::fs::read(&path).map_err(|_| AppError::NotFound(format!("PDF file missing for batch: {id}")))?;

    let disposition = format!("attachment; filename*=UTF-8''{}", urlencode(&row.pdf_filename));
    Response::builder()
        .status(StatusCode::OK)
        .header(header::CONTENT_TYPE, "application/pdf")
        .header(header::CONTENT_DISPOSITION, disposition)
        .body(axum::body::Body::from(bytes))
        .map_err(|e| AppError::Internal(anyhow::anyhow!("response: {e}")))
}

fn urlencode(s: &str) -> String {
    s.chars()
        .flat_map(|c| {
            if c.is_ascii_alphanumeric() || matches!(c, '-' | '_' | '.' | '~') {
                vec![c]
            } else {
                let mut out = Vec::new();
                for b in c.to_string().as_bytes() {
                    out.push('%');
                    out.push(char::from_digit((b >> 4) as u32, 16).unwrap().to_ascii_uppercase());
                    out.push(char::from_digit((b & 0xF) as u32, 16).unwrap().to_ascii_uppercase());
                }
                out
            }
        })
        .collect()
}

pub async fn delete(
    State(state): State<AppState>,
    auth: AuthUser,
    Path(id): Path<i64>,
) -> AppResult<StatusCode> {
    auth.require_role(&["SUPERADMIN"])?;
    let path = std::path::Path::new(&state.config.credentials_storage_path).join(format!("{id}.pdf"));
    let _ = std::fs::remove_file(&path);
    let result = sqlx::query("DELETE FROM credential_batches WHERE id = $1")
        .bind(id)
        .execute(&state.pool)
        .await
        .map_err(|e| AppError::from_sqlx("delete_batch", e))?;
    if result.rows_affected() == 0 {
        return Err(AppError::NotFound(format!("Credential batch not found: {id}")));
    }
    Ok(StatusCode::NO_CONTENT)
}
