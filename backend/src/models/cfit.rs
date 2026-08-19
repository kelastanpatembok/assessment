use chrono::NaiveDateTime;
use serde::{Deserialize, Serialize};
use sqlx::types::Json;

use crate::datetime::java_local_date_time;

/// cfit_questions masked student view (answer key stripped).
#[derive(Debug, Clone, Serialize, sqlx::FromRow)]
pub struct CfitQuestionView {
    pub id: i64,
    #[serde(rename = "subtestNo")]
    pub subtest_no: i32,
    #[serde(rename = "itemNo")]
    pub item_no: i32,
    #[serde(rename = "stemImageUrl")]
    pub stem_image_url: Option<String>,
    #[serde(rename = "optionImages")]
    pub option_images: Json<Vec<String>>,
}

/// cfit_questions full row (for scoring).
#[derive(Debug, Clone, sqlx::FromRow)]
pub struct CfitQuestionRow {
    pub id: i64,
    pub subtest_no: i32,
    pub item_no: i32,
    pub stem_image_url: Option<String>,
    pub option_images: Json<Vec<String>>,
    pub correct_answer: String,
    pub correct_answer2: Option<String>,
}

#[derive(Debug, Clone, Deserialize)]
pub struct CfitAnswerDto {
    #[serde(rename = "subtestNo")]
    pub subtest_no: i32,
    #[serde(rename = "itemNo")]
    pub item_no: i32,
    pub answers: Vec<String>,
}

#[derive(Debug, Clone, Deserialize)]
pub struct CfitSubmitRequest {
    #[serde(rename = "assignmentId")]
    pub assignment_id: i64,
    pub answers: Vec<CfitAnswerDto>,
}

/// cfit_results entity.
#[derive(Debug, Clone, Serialize, sqlx::FromRow)]
pub struct CfitResult {
    pub id: i64,
    pub auth_user_id: String,
    pub student_name: Option<String>,
    pub school_name: Option<String>,
    pub assignment_id: Option<i64>,
    pub sub1_score: i32,
    pub sub2_score: i32,
    pub sub3_score: i32,
    pub sub4_score: i32,
    pub total_score: i32,
    pub iq_score: i32,
    pub category: Option<String>,
    pub description: Option<String>,
    pub answers: Option<String>,
    pub completed_at: NaiveDateTime,
}

impl CfitResult {
    pub fn as_json(&self) -> serde_json::Value {
        serde_json::json!({
            "id": self.id,
            "authUserId": self.auth_user_id,
            "studentName": self.student_name,
            "schoolName": self.school_name,
            "assignmentId": self.assignment_id,
            "sub1Score": self.sub1_score,
            "sub2Score": self.sub2_score,
            "sub3Score": self.sub3_score,
            "sub4Score": self.sub4_score,
            "totalScore": self.total_score,
            "iqScore": self.iq_score,
            "category": self.category,
            "description": self.description,
            "answers": self.answers,
            "completedAt": java_local_date_time(self.completed_at),
        })
    }
}

#[cfg(test)]
mod tests {
    use super::CfitQuestionView;
    use sqlx::types::Json;

    #[test]
    fn question_view_serializes_jsonb_options_as_an_array() {
        let question = CfitQuestionView {
            id: 1,
            subtest_no: 1,
            item_no: 1,
            stem_image_url: Some("/cfit/question.png".to_string()),
            option_images: Json(vec!["/cfit/a.png".to_string(), "/cfit/b.png".to_string()]),
        };

        let value = serde_json::to_value(question).expect("question should serialize");
        assert_eq!(
            value["optionImages"],
            serde_json::json!(["/cfit/a.png", "/cfit/b.png"])
        );
    }
}
