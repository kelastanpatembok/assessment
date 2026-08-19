use chrono::NaiveDateTime;
use serde::Serialize;

use crate::datetime::java_local_date_time;

#[derive(Debug, Clone, Serialize)]
pub struct School {
    pub id: i64,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub npsn: Option<String>,
    pub name: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub address: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub city: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub province: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub phone: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub email: Option<String>,
    pub created_at: NaiveDateTime,
    pub updated_at: NaiveDateTime,
}

impl School {
    pub fn as_json(&self) -> serde_json::Value {
        serde_json::json!({
            "id": self.id,
            "npsn": self.npsn,
            "name": self.name,
            "address": self.address,
            "city": self.city,
            "province": self.province,
            "phone": self.phone,
            "email": self.email,
            "createdAt": java_local_date_time(self.created_at),
            "updatedAt": java_local_date_time(self.updated_at),
        })
    }
}
