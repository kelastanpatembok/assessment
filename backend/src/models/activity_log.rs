use chrono::NaiveDateTime;

/// activity_logs table row.
#[derive(Debug, Clone, sqlx::FromRow)]
pub struct ActivityLogRow {
    pub id: i64,
    pub auth_user_id: String,
    pub test_type: String,
    pub event_type: String,
    pub metadata: Option<serde_json::Value>,
    pub created_at: NaiveDateTime,
}
