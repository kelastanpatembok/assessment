use chrono::NaiveDateTime;
use serde::Serialize;

use crate::datetime::java_local_date_time;

#[derive(Debug, Clone, Serialize)]
pub struct School {
    pub id: i64,
    pub name: String,
    pub address: Option<String>,
    pub city: Option<String>,
    pub province: Option<String>,
    pub phone: Option<String>,
    pub email: Option<String>,
    pub created_at: NaiveDateTime,
    pub updated_at: NaiveDateTime,
}

impl School {
    pub fn as_json(&self) -> serde_json::Value {
        crate::json_util::sorted(serde_json::json!({
            "id": self.id,
            "name": self.name,
            "address": self.address,
            "city": self.city,
            "province": self.province,
            "phone": self.phone,
            "email": self.email,
            "createdAt": java_local_date_time(self.created_at),
            "updatedAt": java_local_date_time(self.updated_at),
        }))
    }
}
