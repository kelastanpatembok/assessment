use chrono::NaiveDateTime;
use serde::{Deserialize, Serialize};

use crate::datetime::java_local_date_time;

/// ist_questions masked student view (answer key and time limit stripped).
#[derive(Debug, Clone, Serialize, sqlx::FromRow)]
pub struct IstQuestionView {
    pub id: i64,
    #[serde(rename = "subtestCode")]
    pub subtest_code: String,
    #[serde(rename = "itemNo")]
    pub item_no: i32,
    #[serde(rename = "questionText")]
    pub question_text: Option<String>,
    #[serde(rename = "imageUrl")]
    pub image_url: Option<String>,
    pub options: Option<serde_json::Value>,
    #[serde(rename = "optionImages")]
    pub option_images: Option<Vec<String>>,
}

/// ist_questions full row (for scoring).
#[derive(Debug, Clone, sqlx::FromRow)]
pub struct IstQuestionRow {
    pub id: i64,
    pub subtest_code: String,
    pub item_no: i32,
    pub question_text: Option<String>,
    pub image_url: Option<String>,
    pub options: Option<serde_json::Value>,
    pub option_images: Option<Vec<String>>,
    pub correct_answer: Option<String>,
}

/// ist_zr_questions row.
#[derive(Debug, Clone, sqlx::FromRow)]
pub struct IstZrQuestionRow {
    pub id: i64,
    pub item_no: i32,
    pub sequence_text: String,
    pub correct_answer: i32,
}

/// ist_zr_questions masked student view.
#[derive(Debug, Clone, Serialize, sqlx::FromRow)]
pub struct IstZrQuestionView {
    pub id: i64,
    #[serde(rename = "itemNo")]
    pub item_no: i32,
    #[serde(rename = "sequenceText")]
    pub sequence_text: String,
}

#[derive(Debug, Clone, Deserialize)]
pub struct IstItemAnswer {
    #[serde(rename = "itemNo")]
    pub item_no: i32,
    pub answer: String,
}

#[derive(Debug, Clone, Deserialize)]
pub struct IstSubtestAnswers {
    #[serde(rename = "subtestCode")]
    pub subtest_code: String,
    pub items: Vec<IstItemAnswer>,
}

#[derive(Debug, Clone, Deserialize)]
pub struct IstSubmitRequest {
    #[serde(rename = "assignmentId")]
    pub assignment_id: i64,
    pub subtests: Vec<IstSubtestAnswers>,
}

/// ist_results entity.
#[derive(Debug, Clone, Serialize, sqlx::FromRow)]
pub struct IstResult {
    pub id: i64,
    pub auth_user_id: String,
    pub student_name: Option<String>,
    pub school_name: Option<String>,
    pub assignment_id: Option<i64>,
    pub subtest_scores: Option<String>,
    pub total_wert: i32,
    pub iq_score: i32,
    pub iq_category: Option<String>,
    pub answers: Option<String>,
    pub completed_at: NaiveDateTime,
}

impl IstResult {
    pub fn as_json(&self) -> serde_json::Value {
        crate::json_util::sorted(serde_json::json!({
            "id": self.id,
            "authUserId": self.auth_user_id,
            "studentName": self.student_name,
            "schoolName": self.school_name,
            "assignmentId": self.assignment_id,
            "subtestScores": self.subtest_scores,
            "totalWert": self.total_wert,
            "iqScore": self.iq_score,
            "iqCategory": self.iq_category,
            "answers": self.answers,
            "completedAt": java_local_date_time(self.completed_at),
        }))
    }
}
