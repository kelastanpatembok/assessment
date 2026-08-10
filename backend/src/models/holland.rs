use chrono::NaiveDateTime;
use serde::{Deserialize, Serialize};

use crate::datetime::java_local_date_time;

/// holland_questions row (returned as-is by GET /holland/questions).
#[derive(Debug, Clone, Serialize)]
pub struct HollandQuestion {
    pub id: i64,
    pub round: i32,
    #[serde(rename = "riasecType")]
    pub riasec_type: String,
    #[serde(rename = "itemNo")]
    pub item_no: i32,
    pub statement: String,
    pub active: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct HollandAnswerDto {
    #[serde(rename = "questionId")]
    pub question_id: i64,
    pub score: i32,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct HollandSubmitRequest {
    #[serde(rename = "assignmentId")]
    pub assignment_id: i64,
    pub answers: Vec<HollandAnswerDto>,
}

/// holland_results entity.
#[derive(Debug, Clone, Serialize, sqlx::FromRow)]
pub struct HollandResult {
    pub id: i64,
    pub auth_user_id: String,
    pub student_name: Option<String>,
    pub school_name: Option<String>,
    pub assignment_id: Option<i64>,
    pub r_score: i32,
    pub i_score: i32,
    pub a_score: i32,
    pub s_score: i32,
    pub e_score: i32,
    pub c_score: i32,
    pub type1: Option<String>,
    pub type1_name: Option<String>,
    pub type1_description: Option<String>,
    pub type1_characteristics: Option<String>,
    pub type1_strengths: Option<String>,
    pub type1_weaknesses: Option<String>,
    pub type1_job_match: Option<String>,
    pub type2: Option<String>,
    pub type2_name: Option<String>,
    pub type2_description: Option<String>,
    pub type2_characteristics: Option<String>,
    pub type2_strengths: Option<String>,
    pub type2_weaknesses: Option<String>,
    pub type2_job_match: Option<String>,
    pub holland_code: Option<String>,
    pub answers: Option<String>,
    pub completed_at: NaiveDateTime,
}

impl HollandResult {
    pub fn as_json(&self) -> serde_json::Value {
        let s = |v: &Option<String>| v.as_ref().map(|x| x.clone());
        serde_json::json!({
            "id": self.id,
            "authUserId": self.auth_user_id,
            "studentName": self.student_name,
            "schoolName": self.school_name,
            "assignmentId": self.assignment_id,
            "type1": self.type1,
            "type1Name": self.type1_name,
            "type1Description": self.type1_description,
            "type1Characteristics": self.type1_characteristics,
            "type1Strengths": self.type1_strengths,
            "type1Weaknesses": self.type1_weaknesses,
            "type1JobMatch": self.type1_job_match,
            "type2": self.type2,
            "type2Name": self.type2_name,
            "type2Description": self.type2_description,
            "type2Characteristics": self.type2_characteristics,
            "type2Strengths": self.type2_strengths,
            "type2Weaknesses": self.type2_weaknesses,
            "type2JobMatch": self.type2_job_match,
            "hollandCode": self.holland_code,
            "answers": s(&self.answers),
            "completedAt": java_local_date_time(self.completed_at),
            "rscore": self.r_score,
            "iscore": self.i_score,
            "ascore": self.a_score,
            "sscore": self.s_score,
            "escore": self.e_score,
            "cscore": self.c_score,
        })
    }
}
