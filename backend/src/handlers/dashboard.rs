use axum::{extract::State, Json};

use crate::{
    auth_extractor::AuthUser,
    db,
    error::{AppError, AppResult},
    state::AppState,
};

/// SUPERADMIN always gets the zeroed DTO; GURUBK gets their school aggregate.
pub async fn summary(
    State(state): State<AppState>,
    auth: AuthUser,
) -> AppResult<Json<serde_json::Value>> {
    if auth.is_role("superadmin") {
        return Ok(Json(serde_json::json!({
            "totalStudents": 0,
            "completedTests": 0,
            "averageIq": 0.0,
            "discProfileDistribution": {},
            "hollandTypeDistribution": {},
        })));
    }

    let school_id = match db::load_user(&state.pool, &auth.user_id).await? {
        Some(u) => u.school_id,
        None => None,
    };
    let Some(school_id) = school_id else {
        return Ok(Json(serde_json::json!({
            "totalStudents": 0,
            "completedTests": 0,
            "averageIq": 0.0,
            "discProfileDistribution": {},
            "hollandTypeDistribution": {},
        })));
    };

    let students: i64 = sqlx::query_scalar(
        "SELECT COUNT(*) FROM assessment_users WHERE school_id = $1 AND role = 'siswa'",
    )
    .bind(school_id)
    .fetch_one(&state.pool)
    .await
    .map_err(|e| AppError::from_sqlx("dashboard_students", e))?;

    let assignments: Vec<i64> = sqlx::query_scalar("SELECT id FROM test_assignments WHERE school_id = $1")
        .bind(school_id)
        .fetch_all(&state.pool)
        .await
        .map_err(|e| AppError::from_sqlx("dashboard_assignments", e))?;

    let mut completed_tests: i64 = 0;
    let mut disc_dist: std::collections::BTreeMap<String, i64> = std::collections::BTreeMap::new();
    let mut holland_dist: std::collections::BTreeMap<String, i64> = std::collections::BTreeMap::new();

    for a in &assignments {
        let disc: i64 = sqlx::query_scalar("SELECT COUNT(*) FROM disc_results WHERE assignment_id = $1")
            .bind(a)
            .fetch_one(&state.pool)
            .await
            .map_err(|e| AppError::from_sqlx("dashboard_disc_count", e))?;
        completed_tests += disc;

        let profiles: Vec<String> = sqlx::query_scalar(
            "SELECT profile_title FROM disc_results WHERE assignment_id = $1 AND profile_title IS NOT NULL AND profile_title <> ''",
        )
        .bind(a)
        .fetch_all(&state.pool)
        .await
        .map_err(|e| AppError::from_sqlx("dashboard_disc_profiles", e))?;
        for p in profiles {
            *disc_dist.entry(p).or_insert(0) += 1;
        }

        let holland: Vec<crate::models::holland::HollandResult> = sqlx::query_as(
            "SELECT id, auth_user_id, student_name, school_name, assignment_id, r_score, i_score, a_score, s_score, e_score, c_score, \
             type1, type1_name, type1_description, type1_characteristics, type1_strengths, type1_weaknesses, type1_job_match, \
             type2, type2_name, type2_description, type2_characteristics, type2_strengths, type2_weaknesses, type2_job_match, \
             holland_code, answers::text, completed_at \
             FROM holland_results WHERE assignment_id = $1",
        )
        .bind(a)
        .fetch_all(&state.pool)
        .await
        .map_err(|e| AppError::from_sqlx("dashboard_holland", e))?;
        for h in &holland {
            let top = top_riasec(h);
            *holland_dist.entry(top).or_insert(0) += 1;
        }
    }

    Ok(Json(serde_json::json!({
        "totalStudents": students,
        "completedTests": completed_tests,
        "averageIq": 105.0,
        "discProfileDistribution": disc_dist,
        "hollandTypeDistribution": holland_dist,
    })))
}

fn top_riasec(h: &crate::models::holland::HollandResult) -> String {
    let mut vals: Vec<(char, i64)> = vec![
        ('R', h.r_score as i64),
        ('I', h.i_score as i64),
        ('A', h.a_score as i64),
        ('S', h.s_score as i64),
        ('E', h.e_score as i64),
        ('C', h.c_score as i64),
    ];
    vals.sort_by(|a, b| {
        let cmp = b.1.cmp(&a.1);
        if cmp != std::cmp::Ordering::Equal {
            cmp
        } else {
            a.0.cmp(&b.0)
        }
    });
    if vals.iter().all(|v| v.1 == 0) {
        "R".to_string()
    } else {
        vals[0].0.to_string()
    }
}
