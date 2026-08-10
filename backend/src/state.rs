use sqlx::PgPool;

use crate::{auth_client::AuthClient, config::AppConfig};

#[derive(Clone)]
pub struct AppState {
    pub pool: PgPool,
    pub config: AppConfig,
    pub auth: AuthClient,
}
