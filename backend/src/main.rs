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
    dotenvy::dotenv().ok();

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
