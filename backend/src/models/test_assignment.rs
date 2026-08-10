use chrono::NaiveDateTime;
use serde::{Deserialize, Serialize};

use crate::datetime::java_local_date_time;

use super::{school::School, test_category::TestCategory, user::AssessmentUser};

#[derive(Debug, Clone, sqlx::FromRow)]
pub struct TestAssignmentRow {
    pub id: i64,
    pub category_id: i64,
    pub school_id: Option<i64>,
    pub student_id: Option<String>,
    pub assigned_by: String,
    pub window_start: Option<NaiveDateTime>,
    pub window_end: Option<NaiveDateTime>,
    #[sqlx(rename = "is_active")]
    pub active: bool,
    pub created_at: NaiveDateTime,
}

#[derive(Debug, Clone, Serialize)]
pub struct TestAssignment {
    pub id: i64,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub category: Option<TestCategory>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub school: Option<School>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub student: Option<AssessmentUser>,
    pub assigned_by: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub window_start: Option<NaiveDateTime>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub window_end: Option<NaiveDateTime>,
    pub active: bool,
    pub created_at: NaiveDateTime,
}

impl TestAssignment {
    pub fn as_json(&self) -> serde_json::Value {
        crate::json_util::sorted(serde_json::json!({
            "id": self.id,
            "category": self.category.as_ref().map(|c| c.as_json()),
            "school": self.school.as_ref().map(|s| s.as_json()),
            "student": self.student.as_ref().map(|u| u.as_json()),
            "assignedBy": self.assigned_by,
            "windowStart": self.window_start.map(java_local_date_time),
            "windowEnd": self.window_end.map(java_local_date_time),
            "active": self.active,
            "createdAt": java_local_date_time(self.created_at),
        }))
    }
}

#[derive(Debug, Deserialize)]
pub struct CreateAssignmentRequest {
    pub category_id: i64,
    pub school_id: Option<i64>,
    pub student_id: Option<String>,
    pub start_date: String,
    pub end_date: String,
    #[serde(rename = "certificateEnabled")]
    pub certificate_enabled: Option<bool>,
}

#[derive(Debug, Deserialize)]
pub struct UpdateAssignmentRequest {
    pub start_date: Option<String>,
    pub end_date: Option<String>,
    pub active: Option<bool>,
    #[serde(rename = "certificateEnabled")]
    pub certificate_enabled: Option<bool>,
}
