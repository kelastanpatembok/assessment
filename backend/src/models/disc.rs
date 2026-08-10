use chrono::NaiveDateTime;
use serde::{Deserialize, Serialize};

use crate::datetime::java_local_date_time;
use crate::decimal::Decimal;

/// disc_questions row.
#[derive(Debug, Clone, Serialize)]
pub struct DiscQuestion {
    pub id: i64,
    #[serde(rename = "blockNo")]
    pub block_no: i32,
    #[serde(rename = "itemNo")]
    pub item_no: i32,
    pub category: String,
    pub statement: String,
    pub active: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DiscAnswerDto {
    #[serde(rename = "blockNo")]
    pub block_no: i32,
    #[serde(rename = "mostItemNo")]
    pub most_item_no: i32,
    #[serde(rename = "leastItemNo")]
    pub least_item_no: i32,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DiscSubmitRequest {
    #[serde(rename = "assignmentId")]
    pub assignment_id: i64,
    pub answers: Vec<DiscAnswerDto>,
}

/// disc_results entity — mirrors the Java entity's JSON, including the
/// JSONB-backed fields that serialize as JSON strings (`::text` in SQL).
#[derive(Debug, Clone, Serialize, sqlx::FromRow)]
pub struct DiscResult {
    pub id: i64,
    pub auth_user_id: String,
    pub student_name: Option<String>,
    pub school_name: Option<String>,
    pub assignment_id: Option<i64>,
    pub d_most: i32,
    pub i_most: i32,
    pub s_most: i32,
    pub c_most: i32,
    pub d_least: i32,
    pub i_least: i32,
    pub s_least: i32,
    pub c_least: i32,
    pub d_dif: i32,
    pub i_dif: i32,
    pub s_dif: i32,
    pub c_dif: i32,
    pub most_d_conv: Option<Decimal>,
    pub most_i_conv: Option<Decimal>,
    pub most_s_conv: Option<Decimal>,
    pub most_c_conv: Option<Decimal>,
    pub least_d_conv: Option<Decimal>,
    pub least_i_conv: Option<Decimal>,
    pub least_s_conv: Option<Decimal>,
    pub least_c_conv: Option<Decimal>,
    pub dif_d_conv: Option<Decimal>,
    pub dif_i_conv: Option<Decimal>,
    pub dif_s_conv: Option<Decimal>,
    pub dif_c_conv: Option<Decimal>,
    pub most_key: Option<String>,
    pub least_key: Option<String>,
    pub dif_key: Option<String>,
    pub profile_title: Option<String>,
    pub profile_desc: Option<String>,
    pub dif_profile_traits: Option<String>,
    pub job_recommendations: Option<String>,
    pub most_profile_title: Option<String>,
    pub most_profile_traits: Option<String>,
    pub least_profile_title: Option<String>,
    pub least_profile_traits: Option<String>,
    pub answers: Option<String>,
    pub completed_at: NaiveDateTime,
}

impl DiscResult {
    pub fn as_json(&self) -> serde_json::Value {
        let opt_str = |v: &Option<String>| v.as_ref().map(|s| s.clone());
        serde_json::json!({
            "id": self.id,
            "authUserId": self.auth_user_id,
            "studentName": self.student_name,
            "schoolName": self.school_name,
            "assignmentId": self.assignment_id,
            "mostDConv": self.most_d_conv,
            "mostIConv": self.most_i_conv,
            "mostSConv": self.most_s_conv,
            "mostCConv": self.most_c_conv,
            "leastDConv": self.least_d_conv,
            "leastIConv": self.least_i_conv,
            "leastSConv": self.least_s_conv,
            "leastCConv": self.least_c_conv,
            "difDConv": self.dif_d_conv,
            "difIConv": self.dif_i_conv,
            "difSConv": self.dif_s_conv,
            "difCConv": self.dif_c_conv,
            "mostKey": self.most_key,
            "leastKey": self.least_key,
            "difKey": self.dif_key,
            "profileTitle": self.profile_title,
            "profileDesc": self.profile_desc,
            "difProfileTraits": opt_str(&self.dif_profile_traits),
            "jobRecommendations": self.job_recommendations,
            "mostProfileTitle": self.most_profile_title,
            "mostProfileTraits": opt_str(&self.most_profile_traits),
            "leastProfileTitle": self.least_profile_title,
            "leastProfileTraits": opt_str(&self.least_profile_traits),
            "answers": opt_str(&self.answers),
            "completedAt": java_local_date_time(self.completed_at),
            "dmost": self.d_most,
            "imost": self.i_most,
            "smost": self.s_most,
            "cmost": self.c_most,
            "dleast": self.d_least,
            "ileast": self.i_least,
            "sleast": self.s_least,
            "cleast": self.c_least,
            "ddif": self.d_dif,
            "idif": self.i_dif,
            "sdif": self.s_dif,
            "cdif": self.c_dif,
        })
    }
}
