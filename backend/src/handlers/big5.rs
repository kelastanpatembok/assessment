use axum::{extract::State, Json};
use serde_json::{json, Value};

use crate::{
    auth_extractor::AuthUser,
    error::{AppError, AppResult},
    scoring::big5,
    state::AppState,
};

pub async fn questions() -> Json<serde_json::Value> {
    Json(serde_json::to_value(big5::questions()).unwrap_or(json!([])))
}

fn parse_answers(v: Value) -> AppResult<std::collections::HashMap<String, i32>> {
    let obj = v.as_object().ok_or_else(|| AppError::BadRequest("Invalid answers".to_string()))?;
    let mut out = std::collections::HashMap::new();
    for (k, v) in obj {
        if let Some(n) = v.as_i64() {
            out.insert(k.clone(), n as i32);
        }
    }
    Ok(out)
}

pub async fn submit(Json(body): Json<Value>) -> AppResult<Json<Value>> {
    let answers = parse_answers(body).map_err(|e| e)?;
    let raw = big5::score(&answers).map_err(AppError::BadRequest)?;
    let dto = big5::interpret(&raw);
    Ok(Json(serde_json::to_value(dto).unwrap()))
}

pub async fn save(
    State(state): State<AppState>,
    auth: AuthUser,
    Json(body): Json<Value>,
) -> AppResult<Json<Value>> {
    let answers = parse_answers(body.clone())?;
    let raw = big5::score(&answers).map_err(AppError::BadRequest)?;
    let dto = big5::interpret(&raw);

    // Persist raw percents (not the inverted neuroticism).
    let mut map = std::collections::HashMap::new();
    for (k, v) in &raw {
        map.insert(k.to_string().to_lowercase(), *v);
    }
    let answers_json = serde_json::to_string(&body).unwrap_or_else(|_| "{}".to_string());
    let exists: i64 = sqlx::query_scalar("SELECT COUNT(*) FROM big5_results WHERE auth_user_id = $1")
        .bind(&auth.user_id)
        .fetch_one(&state.pool)
        .await
        .map_err(|e| AppError::from_sqlx("big5_exists", e))?;

    if exists > 0 {
        sqlx::query(
            "UPDATE big5_results SET openness=$2, conscientiousness=$3, extraversion=$4, agreeableness=$5, neuroticism=$6, answers=$7::jsonb WHERE auth_user_id=$1",
        )
        .bind(&auth.user_id)
        .bind(map.get("o").copied().unwrap_or(0.0))
        .bind(map.get("c").copied().unwrap_or(0.0))
        .bind(map.get("e").copied().unwrap_or(0.0))
        .bind(map.get("a").copied().unwrap_or(0.0))
        .bind(map.get("n").copied().unwrap_or(0.0))
        .bind(answers_json)
        .execute(&state.pool)
        .await
        .map_err(|e| AppError::from_sqlx("update_big5", e))?;
    } else {
        sqlx::query(
            "INSERT INTO big5_results (auth_user_id, openness, conscientiousness, extraversion, agreeableness, neuroticism, answers, completed_at) \
             VALUES ($1,$2,$3,$4,$5,$6, $7::jsonb, NOW())",
        )
        .bind(&auth.user_id)
        .bind(map.get("o").copied().unwrap_or(0.0))
        .bind(map.get("c").copied().unwrap_or(0.0))
        .bind(map.get("e").copied().unwrap_or(0.0))
        .bind(map.get("a").copied().unwrap_or(0.0))
        .bind(map.get("n").copied().unwrap_or(0.0))
        .bind(answers_json)
        .execute(&state.pool)
        .await
        .map_err(|e| AppError::from_sqlx("insert_big5", e))?;
    }

    Ok(Json(serde_json::to_value(dto).unwrap()))
}

pub async fn result_me(
    State(state): State<AppState>,
    auth: AuthUser,
) -> AppResult<Json<Value>> {
    let row = sqlx::query_as::<_, (f64, f64, f64, f64, f64)>(
        "SELECT openness, conscientiousness, extraversion, agreeableness, neuroticism FROM big5_results WHERE auth_user_id = $1",
    )
    .bind(&auth.user_id)
    .fetch_optional(&state.pool)
    .await
    .map_err(|e| AppError::from_sqlx("big5_result_me", e))?
    .ok_or_else(|| AppError::NotFound("Big5 result not found".to_string()))?;

    let raw: Vec<(char, f64)> = vec![
        ('o', row.0), ('c', row.1), ('e', row.2), ('a', row.3), ('n', row.4),
    ];
    let dto = big5::interpret(&raw);
    Ok(Json(serde_json::to_value(dto).unwrap()))
}
