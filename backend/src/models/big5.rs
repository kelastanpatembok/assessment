use serde::Serialize;

/// Big Five item bank entry (hardcoded, 30 items).
pub struct BigFiveItem {
    pub no: i32,
    pub trait_key: char,
    pub reversed: bool,
    pub statement: String,
}

#[derive(Debug, Clone, Serialize)]
pub struct BigFiveQuestion {
    pub no: i32,
    pub statement: String,
}

#[derive(Debug, Clone, Serialize)]
pub struct BigFiveTrait {
    pub key: String,
    pub label: String,
    pub value: f64,
    pub level: String,
    pub description: String,
}

/// Interpreted Big Five result (also the /big5/save persisted row shape).
#[derive(Debug, Clone, Serialize)]
pub struct BigFiveResultDto {
    pub headline: String,
    pub openness: f64,
    pub conscientiousness: f64,
    pub extraversion: f64,
    pub agreeableness: f64,
    pub neuroticism: f64,
    pub traits: Vec<BigFiveTrait>,
}
