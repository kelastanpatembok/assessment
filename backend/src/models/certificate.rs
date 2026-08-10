use chrono::NaiveDateTime;
use serde::{Deserialize, Serialize};

use crate::datetime::java_local_date_time;

use super::{disc::DiscResult, holland::HollandResult, ist::IstResult, papi::PapiResult};

/// certificates table row.
#[derive(Debug, Clone, sqlx::FromRow)]
pub struct CertificateRow {
    pub id: i64,
    pub auth_user_id: String,
    pub test_type: String,
    pub storage_key: String,
    pub created_at: NaiveDateTime,
}

#[derive(Debug, Clone, Serialize)]
pub struct CertificateView {
    pub test_type: String,
    pub storage_key: String,
    pub url: String,
    pub created_at: Option<String>,
}

impl CertificateView {
    pub fn new(row: &CertificateRow) -> Self {
        Self {
            test_type: row.test_type.clone(),
            storage_key: row.storage_key.clone(),
            url: format!("/api/storage/content/{}", row.storage_key),
            created_at: Some(java_local_date_time(row.created_at)),
        }
    }
}

#[derive(Debug, Deserialize)]
pub struct CreateCertificateRequest {
    pub test_type: String,
    pub storage_key: String,
}

/// /certificates/{testType}/{authUserId} response union.
#[derive(Debug, Clone)]
pub enum CertificateResultPayload {
    Disc(DiscResult),
    Holland(HollandResult),
    Papi(PapiResult),
    Cfit(crate::models::cfit::CfitResult),
    Ist(IstResult),
}

#[derive(Debug, Clone)]
pub struct CertificateDetail {
    pub result: serde_json::Value,
    pub profile: Option<serde_json::Value>,
}
