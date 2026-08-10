#![recursion_limit = "256"]

mod auth_client;
mod auth_extractor;
mod config;
mod datetime;
mod db;
mod decimal;
mod error;
mod handlers;
mod jwt;
mod models;
mod paging;
mod pdf;
mod routes;
mod scoring;
mod state;

use anyhow::Context;
use sqlx::postgres::{PgPool, PgPoolOptions};

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    // eco may have generated a Spring-style dotted key (cors.allowed-origins)
    // in this service's .env; dotenvy aborts the whole file at such a line,
    // silently dropping every variable after it. Parse the file manually and
    // skip unparseable lines so the remaining keys always load.
    load_env_tolerantly();

    tracing_subscriber::fmt()
        .with_env_filter(
            tracing_subscriber::EnvFilter::try_from_default_env()
                .unwrap_or_else(|_| "info".into()),
        )
        .json()
        .init();

    let config = config::AppConfig::from_env()?;
    tracing::info!(
        port = config.server_port,
        db_configured = true,
        auth_base_url = %config.auth_base_url,
        "starting assessment-backend"
    );

    let pool: PgPool = PgPoolOptions::new()
        .max_connections(10)
        .connect(&config.database_url)
        .await
        .context("failed to connect to PostgreSQL")?;

    let auth = auth_client::AuthClient::new(config.auth_base_url.clone());

    let state = state::AppState {
        pool,
        config: config.clone(),
        auth,
    };

    let app = routes::build_router(state);
    let listener = tokio::net::TcpListener::bind(("0.0.0.0", config.server_port))
        .await
        .context("failed to bind port")?;
    tracing::info!(port = config.server_port, "assessment-backend listening");
    axum::serve(listener, app).await.context("server error")
}

/// Loads the nearest .env (walking up from cwd), applying each KEY=VALUE
/// line only if the key is not already set, and silently skipping lines that
/// dotenvy would reject (e.g. keys containing dots). Keeps every variable
/// that follows a problem line instead of dropping the rest of the file.
fn load_env_tolerantly() {
    let mut dir = std::env::current_dir().ok();
    while let Some(d) = dir {
        let candidate = d.join(".env");
        if candidate.is_file() {
            if let Ok(contents) = std::fs::read_to_string(&candidate) {
                for line in contents.lines() {
                    let line = line.trim();
                    if line.is_empty() || line.starts_with('#') {
                        continue;
                    }
                    if let Some((key, value)) = line.split_once('=') {
                        let key = key.trim();
                        if key.is_empty() || key.contains('.') {
                            continue;
                        }
                        if std::env::var_os(key).is_none() {
                            let value = value.trim();
                            let value = value
                                .strip_prefix('"')
                                .and_then(|v| v.strip_suffix('"'))
                                .unwrap_or(value)
                                .to_string();
                            std::env::set_var(key, value);
                        }
                    }
                }
            }
            break;
        }
        dir = d.parent().map(|p| p.to_path_buf());
    }
}
