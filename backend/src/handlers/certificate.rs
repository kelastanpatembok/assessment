use axum::{
    extract::{Path, State},
    Json,
};
use serde::Deserialize;

use crate::{
    auth_extractor::AuthUser,
    db,
    error::{AppError, AppResult},
    models::certificate::CertificateRow,
    state::AppState,
};

const KNOWN_TESTS: [&str; 5] = ["disc", "holland", "papi", "cfit", "ist"];

#[derive(Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct CreateCertificateRequest {
    pub test_type: String,
    pub storage_key: String,
}

fn valid_storage_key(key: &str) -> bool {
    if key.is_empty() || key.len() > 255 {
        return false;
    }
    key.split('/').all(|seg| {
        !seg.is_empty()
            && seg.len() <= 120
            && seg.chars().all(|ch| ch.is_alphanumeric() || ch == '-' || ch == '_' || ch == '.')
    })
}

fn cert_view(r: &CertificateRow) -> serde_json::Value {
    serde_json::json!({
        "testType": r.test_type,
        "storageKey": r.storage_key,
        "url": format!("/api/storage/content/{}", r.storage_key),
        "createdAt": crate::datetime::java_local_date_time(r.created_at),
    })
}

pub async fn create(
    State(state): State<AppState>,
    auth: AuthUser,
    Json(req): Json<CreateCertificateRequest>,
) -> AppResult<Json<serde_json::Value>> {
    let test_type = req.test_type.trim().to_lowercase();
    let storage_key = req.storage_key.trim().to_string();
    if !KNOWN_TESTS.contains(&test_type.as_str()) {
        return Err(AppError::Internal(anyhow::anyhow!("Test type tidak dikenal: {}", req.test_type)));
    }
    if !valid_storage_key(&storage_key) {
        return Err(AppError::Internal(anyhow::anyhow!("Storage key tidak valid")));
    }

    let existing = sqlx::query_as::<_, CertificateRow>(
        "SELECT id, auth_user_id, test_type, storage_key, created_at FROM certificates WHERE auth_user_id = $1 AND test_type = $2",
    )
    .bind(&auth.user_id)
    .bind(&test_type)
    .fetch_optional(&state.pool)
    .await
    .map_err(|e| AppError::from_sqlx("find_certificate", e))?;

    let row = match existing {
        Some(r) => sqlx::query_as::<_, CertificateRow>(
            "UPDATE certificates SET storage_key = $3 WHERE id = $1 RETURNING id, auth_user_id, test_type, storage_key, created_at",
        )
        .bind(r.id)
        .bind(&test_type)
        .bind(&storage_key)
        .fetch_one(&state.pool)
        .await
        .map_err(|e| AppError::from_sqlx("update_certificate", e))?,
        None => sqlx::query_as::<_, CertificateRow>(
            "INSERT INTO certificates (auth_user_id, test_type, storage_key, created_at) VALUES ($1, $2, $3, NOW()) \
             RETURNING id, auth_user_id, test_type, storage_key, created_at",
        )
        .bind(&auth.user_id)
        .bind(&test_type)
        .bind(&storage_key)
        .fetch_one(&state.pool)
        .await
        .map_err(|e| AppError::from_sqlx("insert_certificate", e))?,
    };

    Ok(Json(cert_view(&row)))
}

async fn list_for(state: &AppState, auth_user_id: &str) -> AppResult<serde_json::Value> {
    let rows: Vec<CertificateRow> = sqlx::query_as(
        "SELECT id, auth_user_id, test_type, storage_key, created_at FROM certificates WHERE auth_user_id = $1 ORDER BY created_at DESC",
    )
    .bind(auth_user_id)
    .fetch_all(&state.pool)
    .await
    .map_err(|e| AppError::from_sqlx("list_certificates", e))?;
    Ok(serde_json::json!(rows.iter().map(cert_view).collect::<Vec<_>>()))
}

pub async fn mine(
    State(state): State<AppState>,
    auth: AuthUser,
) -> AppResult<Json<serde_json::Value>> {
    Ok(Json(list_for(&state, &auth.user_id).await?))
}

pub async fn for_student(
    State(state): State<AppState>,
    auth: AuthUser,
    Path(auth_user_id): Path<String>,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SUPERADMIN", "GURUBK", "AFILIATOR", "PSIKOLOG"])?;
    Ok(Json(list_for(&state, &auth_user_id).await?))
}

/// Ownership check: siswa may only access their own certificate.
fn assert_ownership_or_admin(auth: &AuthUser, auth_user_id: &str) -> AppResult<()> {
    if auth.is_role("siswa") && auth.user_id != auth_user_id {
        return Err(AppError::Forbidden(
            "Students may only access their own certificates".to_string(),
        ));
    }
    Ok(())
}

pub async fn test_certificate(
    State(state): State<AppState>,
    auth: AuthUser,
    Path((test_type, auth_user_id)): Path<(String, String)>,
) -> AppResult<Json<serde_json::Value>> {
    assert_ownership_or_admin(&auth, &auth_user_id)?;
    let result = load_result(&state, &test_type, &auth_user_id).await?;
    let profile = match db::load_user(&state.pool, &auth_user_id).await? {
        Some(r) => db::assemble_user(&state.pool, r).await?.as_json(),
        None => serde_json::json!({}),
    };
    Ok(Json(serde_json::json!({ "result": result, "profile": profile })))
}

async fn load_result(state: &AppState, test_type: &str, auth_user_id: &str) -> AppResult<serde_json::Value> {
    match test_type {
        "disc" => {
            let row = sqlx::query_as::<_, crate::models::disc::DiscResult>(
                "SELECT id, auth_user_id, student_name, school_name, assignment_id, \
                 d_most, i_most, s_most, c_most, d_least, i_least, s_least, c_least, d_dif, i_dif, s_dif, c_dif, \
                 most_d_conv, most_i_conv, most_s_conv, most_c_conv, \
                 least_d_conv, least_i_conv, least_s_conv, least_c_conv, \
                 dif_d_conv, dif_i_conv, dif_s_conv, dif_c_conv, \
                 most_key, least_key, dif_key, profile_title, profile_desc, dif_profile_traits::text, job_recommendations, \
                 most_profile_title, most_profile_traits::text, least_profile_title, least_profile_traits::text, \
                 answers::text, completed_at FROM disc_results WHERE auth_user_id = $1",
            )
            .bind(auth_user_id)
            .fetch_optional(&state.pool)
            .await
            .map_err(|e| AppError::from_sqlx("cert_disc", e))?
            .ok_or_else(|| AppError::NotFound(format!("No DISC result for: {auth_user_id}")))?;
            Ok(row.as_json())
        }
        "holland" => {
            let row = sqlx::query_as::<_, crate::models::holland::HollandResult>(
                "SELECT id, auth_user_id, student_name, school_name, assignment_id, \
                 r_score, i_score, a_score, s_score, e_score, c_score, \
                 type1, type1_name, type1_description, type1_characteristics, type1_strengths, type1_weaknesses, type1_job_match, \
                 type2, type2_name, type2_description, type2_characteristics, type2_strengths, type2_weaknesses, type2_job_match, \
                 holland_code, answers::text, completed_at FROM holland_results WHERE auth_user_id = $1",
            )
            .bind(auth_user_id)
            .fetch_optional(&state.pool)
            .await
            .map_err(|e| AppError::from_sqlx("cert_holland", e))?
            .ok_or_else(|| AppError::NotFound(format!("No Holland result for: {auth_user_id}")))?;
            Ok(row.as_json())
        }
        "papi" => {
            let row = sqlx::query_as::<_, crate::models::papi::PapiResult>(
                "SELECT id, auth_user_id, student_name, school_name, assignment_id, trait_scores::text, answers::text, completed_at \
                 FROM papi_results WHERE auth_user_id = $1",
            )
            .bind(auth_user_id)
            .fetch_optional(&state.pool)
            .await
            .map_err(|e| AppError::from_sqlx("cert_papi", e))?
            .ok_or_else(|| AppError::NotFound(format!("No PAPI result for: {auth_user_id}")))?;
            Ok(row.as_json())
        }
        "cfit" => {
            let row = sqlx::query_as::<_, crate::models::cfit::CfitResult>(
                "SELECT id, auth_user_id, student_name, school_name, assignment_id, \
                 sub1_score, sub2_score, sub3_score, sub4_score, total_score, iq_score, category, description, answers::text, completed_at \
                 FROM cfit_results WHERE auth_user_id = $1",
            )
            .bind(auth_user_id)
            .fetch_optional(&state.pool)
            .await
            .map_err(|e| AppError::from_sqlx("cert_cfit", e))?
            .ok_or_else(|| AppError::NotFound(format!("No CFIT result for: {auth_user_id}")))?;
            Ok(row.as_json())
        }
        "ist" => {
            let row = sqlx::query_as::<_, crate::models::ist::IstResult>(
                "SELECT id, auth_user_id, student_name, school_name, assignment_id, subtest_scores::text, total_wert, iq_score, iq_category, answers::text, completed_at \
                 FROM ist_results WHERE auth_user_id = $1",
            )
            .bind(auth_user_id)
            .fetch_optional(&state.pool)
            .await
            .map_err(|e| AppError::from_sqlx("cert_ist", e))?
            .ok_or_else(|| AppError::NotFound(format!("No IST result for: {auth_user_id}")))?;
            Ok(row.as_json())
        }
        _ => Err(AppError::NotFound(format!("Unknown test type: {test_type}"))),
    }
}
