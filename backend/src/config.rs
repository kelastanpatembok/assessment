use std::env;

const KNOWN_PLACEHOLDER_SECRETS: &[&str] = &[
    "your-secret-key-change-in-production",
    "change-this-secret",
    "secret",
];

const MIN_JWT_SECRET_BYTES: usize = 32;
const RECOMMENDED_JWT_SECRET_BYTES: usize = 64;

#[derive(Clone)]
pub struct AppConfig {
    /// postgresql:// connection string built from the JDBC-style env vars
    pub database_url: String,
    pub jwt_secret: String,
    pub server_port: u16,
    pub cors_allowed_origins: Vec<String>,
    pub auth_base_url: String,
    pub email_manager_url: String,
    pub credentials_storage_path: String,
    pub dev_tools_enabled: bool,
}

impl AppConfig {
    pub fn from_env() -> anyhow::Result<Self> {
        let server_port = env::var("SERVER_PORT")
            .ok()
            .and_then(|v| v.parse().ok())
            .unwrap_or(2002);

        let jwt_secret = env::var("JWT_SECRET").unwrap_or_default();
        if jwt_secret.is_empty() {
            anyhow::bail!(
                "JWT_SECRET is not set. Refusing to start with no way to validate tokens -- \
                 this must match the estate's shared secret (see auth's .env)."
            );
        }
        if KNOWN_PLACEHOLDER_SECRETS.contains(&jwt_secret.as_str()) {
            anyhow::bail!(
                "JWT_SECRET is set to a known placeholder value. Refusing to start -- \
                 use the estate's real shared secret."
            );
        }
        if jwt_secret.len() < MIN_JWT_SECRET_BYTES {
            anyhow::bail!(
                "JWT_SECRET is only {} bytes; refusing to start with fewer than {} for HS512.",
                jwt_secret.len(),
                MIN_JWT_SECRET_BYTES
            );
        }
        if jwt_secret.len() < RECOMMENDED_JWT_SECRET_BYTES {
            tracing::warn!(
                bytes = jwt_secret.len(),
                recommended = RECOMMENDED_JWT_SECRET_BYTES,
                "JWT_SECRET is shorter than recommended for HS512"
            );
        }

        Ok(Self {
            database_url: build_database_url()?,
            jwt_secret,
            server_port,
            cors_allowed_origins: env::var("CORS_ALLOWED_ORIGINS")
                .unwrap_or_else(|_| "http://localhost:2001".to_string())
                .split(',')
                .map(|s| s.trim().to_string())
                .filter(|s| !s.is_empty())
                .collect(),
            auth_base_url: env::var("AUTH_BASE_URL")
                .unwrap_or_else(|_| "http://localhost:2000/api".to_string()),
            email_manager_url: env::var("EMAIL_MANAGER_URL")
                .unwrap_or_else(|_| "http://localhost:3142/api/email".to_string())
                .trim_end_matches('/')
                .to_string(),
            credentials_storage_path: env::var("CREDENTIALS_STORAGE_PATH")
                .unwrap_or_else(|_| "./storage/credentials".to_string()),
            dev_tools_enabled: env::var("DEV_TOOLS_ENABLED")
                .map(|v| v != "false" && v != "0")
                .unwrap_or(true),
        })
    }
}

/// The Java backend configured PostgreSQL via JDBC-style env vars
/// (DATABASE_URL=jdbc:postgresql://host:port/db, DATABASE_USERNAME,
/// DATABASE_PASSWORD). Build a native postgresql:// URL from those so the
/// Rust service keeps reading the same eco-generated .env without changes.
fn build_database_url() -> anyhow::Result<String> {
    let raw = env::var("DATABASE_URL").unwrap_or_default();
    if raw.is_empty() {
        anyhow::bail!("DATABASE_URL is not set");
    }

    let (host, port, dbname) = parse_jdbc_url(&raw)
        .unwrap_or_else(|| ("localhost".to_string(), 5432, "assessment".to_string()));

    let username = env::var("DATABASE_USERNAME").unwrap_or_else(|_| "postgres".to_string());
    let password = env::var("DATABASE_PASSWORD").unwrap_or_default();

    let mut url = format!("postgresql://{username}:{password}@{host}:{port}/{dbname}");
    if let Some(rest) = raw.split('?').nth(1) {
        url.push('?');
        url.push_str(rest);
    }
    Ok(url)
}

/// jdbc:postgresql://localhost:5432/assessment      ->  (localhost, 5432, assessment)
/// postgresql://user:pass@host:5432/assessment     ->  (host, 5432, assessment)
///
/// Accepts both the legacy JDBC form (Spring Boot heritage) and the standard
/// postgresql:// form Eco's configgen writes. The earlier version only handled
/// `jdbc:postgresql://` and silently fell back to localhost for any other
/// format — after the database moved off the app CT to a data-plane CT, that
/// fallback pointed the whole estate at an empty localhost postgres (30s pool
/// timeouts → 500s → pages that "eventually landed").
fn parse_jdbc_url(raw: &str) -> Option<(String, u16, String)> {
    let body = raw
        .strip_prefix("jdbc:postgresql://")
        .or_else(|| raw.strip_prefix("postgresql://"))
        .or_else(|| raw.strip_prefix("postgres://"))?
        .split('?')
        .next()?;
    // Strip optional userinfo (user:pass@) when the URL carries credentials.
    let body = match body.rsplit_once('@') {
        Some((_, rest)) => rest,
        None => body,
    };
    let (host_port, db) = match body.rsplit_once('/') {
        Some((hp, d)) => (hp, d),
        None => (body, ""),
    };
    let (host, port) = match host_port.rsplit_once(':') {
        Some((h, p)) => (h.to_string(), p.parse().ok()?),
        None => (host_port.to_string(), 5432),
    };
    Some((host, port, db.to_string()))
}

#[cfg(test)]
mod tests {
    use super::parse_jdbc_url;

    #[test]
    fn parses_legacy_jdbc_url() {
        assert_eq!(
            parse_jdbc_url("jdbc:postgresql://localhost:5432/assessment"),
            Some(("localhost".to_string(), 5432, "assessment".to_string()))
        );
    }

    #[test]
    fn parses_standard_postgres_url_with_credentials() {
        assert_eq!(
            parse_jdbc_url("postgresql://assessment_user:secret@192.168.88.60:5432/assessment"),
            Some(("192.168.88.60".to_string(), 5432, "assessment".to_string()))
        );
        assert_eq!(
            parse_jdbc_url("postgres://user:pw@db:5432/x?sslmode=require"),
            Some(("db".to_string(), 5432, "x".to_string()))
        );
    }

    #[test]
    fn does_not_fall_back_when_scheme_is_missing() {
        // Anything that is not a postgres URL must not silently become localhost.
        assert_eq!(parse_jdbc_url("mysql://host/db"), None);
    }
}
