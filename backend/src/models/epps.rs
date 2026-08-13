use chrono::NaiveDateTime;
use serde::{Deserialize, Serialize};

use crate::datetime::java_local_date_time;

#[derive(Debug, Deserialize, Serialize, Clone)]
pub struct EppsAnswerDto {
    pub no: i32,
    pub choice: String,
}

#[derive(Debug, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct EppsSubmitRequest {
    pub assignment_id: i64,
    pub gender: String,
    pub answers: Vec<EppsAnswerDto>,
}

#[derive(Debug, sqlx::FromRow)]
pub struct EppsResult {
    pub id: i64,
    pub auth_user_id: String,
    pub student_name: Option<String>,
    pub school_name: Option<String>,
    pub assignment_id: Option<i64>,
    pub gender: String,
    pub trait_scores: String,
    pub consistency_raw: i32,
    pub consistency_percentile: i32,
    pub answers: String,
    pub completed_at: NaiveDateTime,
}

impl EppsResult {
    pub fn as_json(&self) -> serde_json::Value {
        serde_json::json!({
            "id": self.id, "authUserId": self.auth_user_id, "studentName": self.student_name,
            "schoolName": self.school_name, "assignmentId": self.assignment_id, "gender": self.gender,
            "traitScores": serde_json::from_str::<serde_json::Value>(&self.trait_scores).unwrap_or_else(|_| serde_json::json!({})),
            "consistencyRaw": self.consistency_raw, "consistencyPercentile": self.consistency_percentile,
            "completedAt": java_local_date_time(self.completed_at),
        })
    }
}
