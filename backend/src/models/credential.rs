use chrono::NaiveDateTime;
use serde::{Deserialize, Serialize};

use crate::datetime::java_local_date_time;

#[derive(Debug, Clone, Deserialize)]
pub struct BulkCredentialRequest {
    pub test_assignment_id: i64,
    pub school_code: String,
    pub test_code: String,
    pub count: i32,
}

#[derive(Debug, Clone, Serialize)]
pub struct CredentialDto {
    pub username: String,
    pub password: String,
    pub auth_user_id: String,
    pub created_at: NaiveDateTime,
}

impl CredentialDto {
    pub fn as_json(&self) -> serde_json::Value {
        serde_json::json!({
            "username": self.username,
            "password": self.password,
            "authUserId": self.auth_user_id,
            "createdAt": java_local_date_time(self.created_at),
        })
    }
}

#[derive(Debug, Clone, Serialize)]
pub struct BulkCredentialResponse {
    pub credentials: Vec<CredentialDto>,
    pub school_name: String,
    pub test_category: String,
    pub count: i32,
    pub created_by: String,
    pub created_at: NaiveDateTime,
    pub credential_batch_id: Option<i64>,
}

impl BulkCredentialResponse {
    pub fn as_json(&self) -> serde_json::Value {
        serde_json::json!({
            "credentials": self.credentials.iter().map(|c| c.as_json()).collect::<Vec<_>>(),
            "schoolName": self.school_name,
            "testCategory": self.test_category,
            "count": self.count,
            "createdBy": self.created_by,
            "createdAt": java_local_date_time(self.created_at),
            "credentialBatchId": self.credential_batch_id,
        })
    }
}

/// credential_batches table row.
#[derive(Debug, Clone, sqlx::FromRow)]
pub struct CredentialBatchRow {
    pub id: i64,
    pub test_assignment_id: i64,
    pub school_id: Option<i64>,
    pub school_name: String,
    pub category_name: String,
    pub credential_count: i32,
    pub pdf_filename: String,
    pub generated_by: String,
    pub created_at: NaiveDateTime,
}

#[derive(Debug, Clone, Serialize)]
pub struct CredentialBatch {
    pub id: i64,
    pub test_assignment_id: i64,
    pub school_id: Option<i64>,
    pub school_name: String,
    pub category_name: String,
    pub credential_count: i32,
    pub pdf_filename: String,
    pub generated_by: String,
    pub created_at: NaiveDateTime,
}

impl CredentialBatch {
    pub fn from_row(r: &CredentialBatchRow) -> Self {
        Self {
            id: r.id,
            test_assignment_id: r.test_assignment_id,
            school_id: r.school_id,
            school_name: r.school_name.clone(),
            category_name: r.category_name.clone(),
            credential_count: r.credential_count,
            pdf_filename: r.pdf_filename.clone(),
            generated_by: r.generated_by.clone(),
            created_at: r.created_at,
        }
    }
    pub fn as_json(&self) -> serde_json::Value {
        serde_json::json!({
            "id": self.id,
            "testAssignmentId": self.test_assignment_id,
            "schoolId": self.school_id,
            "schoolName": self.school_name,
            "categoryName": self.category_name,
            "credentialCount": self.credential_count,
            "pdfFilename": self.pdf_filename,
            "generatedBy": self.generated_by,
            "createdAt": java_local_date_time(self.created_at),
        })
    }
}
