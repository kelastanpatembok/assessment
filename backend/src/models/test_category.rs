use chrono::NaiveDateTime;
use serde::{Deserialize, Serialize};

use crate::datetime::java_local_date_time;
use crate::decimal::Decimal;

#[derive(Debug, Clone, sqlx::FromRow)]
pub struct TestCategoryRow {
    pub id: i64,
    pub name: String,
    pub slug: String,
    pub description: Option<String>,
    pub tests: Vec<String>,
    pub price: Decimal,
    #[sqlx(rename = "is_active")]
    pub active: bool,
    pub created_at: NaiveDateTime,
}

#[derive(Debug, Clone, Serialize)]
pub struct TestCategory {
    pub id: i64,
    pub name: String,
    pub slug: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub description: Option<String>,
    pub tests: Vec<String>,
    pub price: Decimal,
    pub active: bool,
    pub created_at: NaiveDateTime,
}

impl TestCategory {
    pub fn as_json(&self) -> serde_json::Value {
        crate::json_util::sorted(serde_json::json!({
            "id": self.id,
            "name": self.name,
            "slug": self.slug,
            "description": self.description,
            "tests": self.tests,
            "price": serde_json::to_value(&self.price).unwrap_or(serde_json::json!(0)),
            "active": self.active,
            "createdAt": java_local_date_time(self.created_at),
        }))
    }
}

#[derive(Debug, Deserialize)]
pub struct TestCategoryRequest {
    pub name: String,
    pub slug: String,
    pub description: Option<String>,
    pub tests: Vec<String>,
    pub price: Decimal,
    pub active: bool,
}
