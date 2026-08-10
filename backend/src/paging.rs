use serde::{Deserialize, Serialize};

pub fn de_i64_opt<'de, D>(d: D) -> Result<Option<i64>, D::Error>
where
    D: serde::Deserializer<'de>,
{
    let v = <Option<serde_json::Value>>::deserialize(d)?;
    match v {
        None => Ok(None),
        Some(serde_json::Value::Number(n)) => n.as_i64().map(Some).ok_or_else(|| serde::de::Error::custom("expected integer")),
        Some(serde_json::Value::String(s)) => s
            .parse::<i64>()
            .map(Some)
            .map_err(|_| serde::de::Error::custom("expected integer")),
        Some(_) => Err(serde::de::Error::custom("expected integer")),
    }
}

pub fn de_bool_opt<'de, D>(d: D) -> Result<Option<bool>, D::Error>
where
    D: serde::Deserializer<'de>,
{
    let v = <Option<serde_json::Value>>::deserialize(d)?;
    match v {
        None => Ok(None),
        Some(serde_json::Value::Bool(b)) => Ok(Some(b)),
        Some(serde_json::Value::String(s)) => match s.to_ascii_lowercase().as_str() {
            "true" | "1" => Ok(Some(true)),
            "false" | "0" => Ok(Some(false)),
            _ => Err(serde::de::Error::custom("expected boolean")),
        },
        Some(_) => Err(serde::de::Error::custom("expected boolean")),
    }
}

/// Mirrors Spring Data pagination query params: page (0-based), size,
/// search, sort, order. When neither page nor size is present the endpoint
/// returns a plain list instead of the paged envelope.
#[derive(Debug, Clone, Default, Deserialize)]
pub struct PageParams {
    #[serde(default, deserialize_with = "de_i64_opt")]
    pub page: Option<i64>,
    #[serde(default, deserialize_with = "de_i64_opt")]
    pub size: Option<i64>,
    pub search: Option<String>,
    pub sort: Option<String>,
    pub order: Option<String>,
}

impl PageParams {
    pub fn size_clamped(&self) -> i64 {
        match self.size {
            Some(s) => s.clamp(1, 100),
            None => 10,
        }
    }
    pub fn page_or_zero(&self) -> i64 {
        self.page.unwrap_or(0).max(0)
    }
    pub fn is_paginated(&self) -> bool {
        self.page.is_some() || self.size.is_some()
    }
    pub fn offset(&self) -> i64 {
        self.page_or_zero() * self.size_clamped()
    }
    pub fn order_dir(&self) -> &'static str {
        match self.order.as_deref() {
            Some("desc") => "DESC",
            _ => "ASC",
        }
    }
    /// Resolves the sort column against a whitelist; falls back to default.
    pub fn sort_key(&self, whitelist: &[&'static str], default: &'static str) -> &'static str {
        match self.sort.as_deref() {
            Some(s) => whitelist.iter().find(|w| **w == s).copied().unwrap_or(default),
            None => default,
        }
    }

    /// Maps a whitelisted camelCase sort key to the actual SQL column name.
    /// Keys are endpoint-specific but share these known shapes.
    pub fn sort_col(&self, key: &'static str) -> &'static str {
        match key {
            "createdAt" => "created_at",
            "updatedAt" => "updated_at",
            "windowStart" => "window_start",
            "windowEnd" => "window_end",
            "school.name" => "school_id",
            "category.name" => "category_id",
            "studentName" => "student_name",
            "schoolName" => "school_name",
            "completedAt" => "completed_at",
            "afiliatorShare" => "afiliator_share",
            "testAssignmentId" => "test_assignment_id",
            other => other,
        }
    }
    pub fn search_like(&self) -> String {
        format!("%{}%", self.search.as_deref().unwrap_or("").trim().to_lowercase())
    }
    pub fn has_search(&self) -> bool {
        self.search.as_deref().map(|s| !s.trim().is_empty()).unwrap_or(false)
    }
}

/// Pagination response envelope mirroring the Java PageResponse<T>.
#[derive(Debug, Serialize)]
pub struct PageResponse<T> {
    pub items: Vec<T>,
    pub page: i64,
    pub size: i64,
    pub total_elements: i64,
    pub total_pages: i64,
}

impl<T> PageResponse<T> {
    pub fn new(items: Vec<T>, page: i64, size: i64, total_elements: i64) -> Self {
        let total_pages = if size == 0 {
            0
        } else {
            (total_elements + size - 1) / size
        };
        Self {
            items,
            page,
            size,
            total_elements,
            total_pages,
        }
    }
}
