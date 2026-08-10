use chrono::NaiveDateTime;
use serde::{Deserialize, Serialize};

use crate::datetime::java_local_date_time;
use crate::decimal::Decimal;

use super::test_category::TestCategory;

/// fee_config table row.
#[derive(Debug, Clone, sqlx::FromRow)]
pub struct FeeConfigRow {
    pub id: i64,
    pub category_id: Option<i64>,
    pub student_fee: Decimal,
    pub afiliator_share_pct: Decimal,
    pub gurubk_share_pct: Decimal,
    pub platform_share_pct: Decimal,
    pub updated_at: NaiveDateTime,
}

#[derive(Debug, Clone, Serialize)]
pub struct FeeConfig {
    pub id: i64,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub category: Option<TestCategory>,
    pub student_fee: Decimal,
    pub afiliator_share_pct: Decimal,
    pub gurubk_share_pct: Decimal,
    pub platform_share_pct: Decimal,
    pub updated_at: NaiveDateTime,
}

impl FeeConfig {
    pub fn from_row(r: &FeeConfigRow, category: Option<TestCategory>) -> Self {
        Self {
            id: r.id,
            category,
            student_fee: r.student_fee.clone(),
            afiliator_share_pct: r.afiliator_share_pct.clone(),
            gurubk_share_pct: r.gurubk_share_pct.clone(),
            platform_share_pct: r.platform_share_pct.clone(),
            updated_at: r.updated_at,
        }
    }
    pub fn as_json(&self) -> serde_json::Value {
        serde_json::json!({
            "id": self.id,
            "category": self.category.as_ref().map(|c| c.as_json()),
            "studentFee": self.student_fee,
            "afiliatorSharePct": self.afiliator_share_pct,
            "gurubkSharePct": self.gurubk_share_pct,
            "platformSharePct": self.platform_share_pct,
            "updatedAt": java_local_date_time(self.updated_at),
        })
    }
}

#[derive(Debug, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct FeeConfigRequest {
    pub category_id: Option<i64>,
    pub student_fee: Decimal,
    pub afiliator_share_pct: Decimal,
    pub gurubk_share_pct: Decimal,
    pub platform_share_pct: Decimal,
}

/// fee_shares table row.
#[derive(Debug, Clone, sqlx::FromRow)]
pub struct FeeShareRow {
    pub id: i64,
    pub student_id: String,
    pub category_id: i64,
    pub afiliator_id: Option<String>,
    pub gurubk_id: Option<String>,
    pub total_fee: Decimal,
    pub afiliator_share: Decimal,
    pub gurubk_share: Decimal,
    pub platform_share: Decimal,
    pub created_at: NaiveDateTime,
}

/// Enriched fee share response (fees/my).
#[derive(Debug, Clone, Serialize)]
pub struct FeeShareView {
    pub id: i64,
    pub student_name: Option<String>,
    pub school_name: Option<String>,
    pub category_name: Option<String>,
    pub total_fee: Decimal,
    pub afiliator_share: Decimal,
    pub gurubk_share: Decimal,
    pub platform_share: Decimal,
    pub created_at: NaiveDateTime,
}

impl FeeShareView {
    pub fn as_json(&self) -> serde_json::Value {
        serde_json::json!({
            "id": self.id,
            "studentName": self.student_name,
            "schoolName": self.school_name,
            "categoryName": self.category_name,
            "totalFee": self.total_fee,
            "afiliatorShare": self.afiliator_share,
            "gurubkShare": self.gurubk_share,
            "platformShare": self.platform_share,
            "createdAt": java_local_date_time(self.created_at),
        })
    }
}
