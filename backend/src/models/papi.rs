use chrono::NaiveDateTime;
use serde::{Deserialize, Serialize};

use crate::datetime::java_local_date_time;

/// papi_questions row (returned as-is by GET /papi/questions).
#[derive(Debug, Clone, Serialize)]
pub struct PapiQuestion {
    pub id: i64,
    #[serde(rename = "pairNo")]
    pub pair_no: i32,
    #[serde(rename = "itemLetter")]
    pub item_letter: String,
    #[serde(rename = "traitCode")]
    pub trait_code: String,
    pub statement: String,
    pub active: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PapiAnswerDto {
    #[serde(rename = "pairNo")]
    pub pair_no: i32,
    #[serde(rename = "chosenLetter")]
    pub chosen_letter: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PapiSubmitRequest {
    #[serde(rename = "assignmentId")]
    pub assignment_id: i64,
    pub answers: Vec<PapiAnswerDto>,
}

/// papi_results entity (submit response).
#[derive(Debug, Clone, Serialize, sqlx::FromRow)]
pub struct PapiResult {
    pub id: i64,
    pub auth_user_id: String,
    pub student_name: Option<String>,
    pub school_name: Option<String>,
    pub assignment_id: Option<i64>,
    pub trait_scores: Option<String>,
    pub answers: Option<String>,
    pub completed_at: NaiveDateTime,
}

impl PapiResult {
    pub fn as_json(&self) -> serde_json::Value {
        crate::json_util::sorted(serde_json::json!({
            "id": self.id,
            "authUserId": self.auth_user_id,
            "studentName": self.student_name,
            "schoolName": self.school_name,
            "assignmentId": self.assignment_id,
            "traitScores": self.trait_scores,
            "answers": self.answers,
            "completedAt": java_local_date_time(self.completed_at),
        }))
    }
}

/// papi_descriptions lookup row (read-only at runtime).
#[derive(Debug, Clone, sqlx::FromRow)]
pub struct PapiDescription {
    pub trait_code: String,
    pub trait_name: String,
    pub description: Option<String>,
    pub high_desc: Option<String>,
    pub low_desc: Option<String>,
}

/// Trait detail returned in the interpreted PapiResultView.
#[derive(Debug, Clone, Serialize)]
pub struct TraitDetail {
    #[serde(rename = "traitCode")]
    pub trait_code: String,
    #[serde(rename = "traitName")]
    pub trait_name: String,
    pub score: i32,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub description: Option<String>,
    pub band: String,
    #[serde(rename = "bandText")]
    pub band_text: Option<String>,
}

/// Interpreted papi result (result/me and results/{id} responses).
#[derive(Debug, Clone, Serialize)]
pub struct PapiResultView {
    pub id: i64,
    pub auth_user_id: String,
    pub student_name: Option<String>,
    pub school_name: Option<String>,
    pub assignment_id: Option<i64>,
    pub trait_scores: Option<String>,
    pub trait_details: Vec<TraitDetail>,
    pub completed_at: NaiveDateTime,
}

impl PapiResultView {
    pub fn as_json(&self) -> serde_json::Value {
        crate::json_util::sorted(serde_json::json!({
            "id": self.id,
            "authUserId": self.auth_user_id,
            "studentName": self.student_name,
            "schoolName": self.school_name,
            "assignmentId": self.assignment_id,
            "traitScores": self.trait_scores,
            "traitDetails": self.trait_details,
            "completedAt": java_local_date_time(self.completed_at),
        }))
    }
}
