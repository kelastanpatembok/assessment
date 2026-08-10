use chrono::NaiveDateTime;
use serde::Serialize;

use crate::datetime::java_local_date_time;

use super::school::School;

#[derive(Debug, Clone, sqlx::FromRow)]
pub struct AssessmentUserRow {
    pub auth_user_id: String,
    pub name: String,
    pub email: String,
    pub username: String,
    pub role: String,
    pub school_id: Option<i64>,
    pub afiliator_id: Option<String>,
    pub created_at: NaiveDateTime,
    pub updated_at: NaiveDateTime,
}

/// Serialized shape of an assessment user (the assessment_users table joined
/// with its school). Matches the Java AssessmentUser entity JSON exactly.
#[derive(Debug, Clone, Serialize)]
pub struct AssessmentUser {
    pub auth_user_id: String,
    pub name: String,
    pub email: String,
    pub username: String,
    pub role: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub school: Option<School>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub afiliator_id: Option<String>,
    pub created_at: NaiveDateTime,
    pub updated_at: NaiveDateTime,
}

impl AssessmentUser {
    pub fn with_school(mut self, school: Option<School>) -> Self {
        self.school = school;
        self
    }

    pub fn as_json(&self) -> serde_json::Value {
        crate::json_util::sorted(serde_json::json!({
            "authUserId": self.auth_user_id,
            "name": self.name,
            "email": self.email,
            "username": self.username,
            "role": self.role,
            "school": self.school.as_ref().map(|s| s.as_json()),
            "afiliatorId": self.afiliator_id,
            "createdAt": java_local_date_time(self.created_at),
            "updatedAt": java_local_date_time(self.updated_at),
        }))
    }
}
