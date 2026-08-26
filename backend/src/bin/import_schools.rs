//! One-shot importer: pull nationwide school data (SMP/SMA/SMK/SLB, optionally
//! SD) from the public api-sekolah-indonesia mirror of Dapodik and upsert it
//! into the assessment `schools` table, keyed by NPSN (migration 28).
//!
//! Usage (run from the dev machine, never on the server):
//!   cargo run --bin import_schools                 # SMP,SMA,SMK,SLB
//!   cargo run --bin import_schools -- --all        # + SD
//!   cargo run --bin import_schools -- --jenjang SMP,SMA
//!   cargo run --bin import_schools -- --dry-run
//!
//! Reads DATABASE_URL (jdbc:postgresql:// or postgresql://) plus
//! DATABASE_USERNAME / DATABASE_PASSWORD from the nearest .env, same as main.

use std::time::Duration;

use anyhow::Context;
use serde_json::{json, Value};

const BASE_URL: &str = "https://api-sekolah-indonesia.vercel.app";
const PER_PAGE: usize = 1000;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    load_env_tolerantly();

    let mut args = std::env::args().skip(1);
    let mut all = false;
    let mut jenjang: Option<Vec<String>> = None;
    let mut dry_run = false;
    while let Some(arg) = args.next() {
        match arg.as_str() {
            "--all" => all = true,
            "--dry-run" => dry_run = true,
            "--jenjang" => {
                let v = args.next().context("--jenjang needs a value")?;
                jenjang = Some(v.split(',').map(|s| s.trim().to_string()).filter(|s| !s.is_empty()).collect());
            }
            other => anyhow::bail!("unknown argument: {other}"),
        }
    }

    let levels: Vec<String> = match jenjang {
        Some(list) => list,
        None if all => vec!["SD".into(), "SMP".into(), "SMA".into(), "SMK".into(), "SLB".into()],
        None => vec!["SMP".into(), "SMA".into(), "SMK".into(), "SLB".into()],
    };

    let database_url = if dry_run {
        None
    } else {
        let url = build_database_url()?;
        log("info", "connecting", &json!({"database_url": redact_url(&url)}));
        Some(url)
    };

    // Dry-run: fetch and report only — no DB needed.
    let pool = if let Some(url) = &database_url {
        let pool = sqlx::postgres::PgPoolOptions::new()
            .max_connections(4)
            .connect(url)
            .await
            .context("failed to connect to PostgreSQL")?;
        // Ensure the npsn column/index exists (migration 28) so upserts work.
        sqlx::migrate!("./migrations")
            .run(&pool)
            .await
            .context("failed to run migrations")?;
        // Existing/manual school rows may have been restored without advancing
        // the serial sequence. Align it before the first upsert so an import
        // never stops on an already-used primary-key value.
        sqlx::query(
            "SELECT setval(pg_get_serial_sequence('schools', 'id'), COALESCE((SELECT MAX(id) FROM schools), 1), true)",
        )
        .execute(&pool)
        .await
        .context("failed to align schools ID sequence")?;
        Some(pool)
    } else {
        None
    };

    let client = reqwest::Client::builder()
        .timeout(Duration::from_secs(30))
        .build()?;

    let mut imported = 0usize;
    let mut skipped = 0usize;
    let mut total_seen = 0usize;

    for level in &levels {
        let total = fetch_total(&client, level).await;
        log("info", "level-start", &json!({"level": level, "expected_total": total, "dry_run": dry_run}));
        let mut page: usize = 0;
        loop {
            page += 1;
            let rows = fetch_page(&client, level, page).await;
            if rows.is_empty() {
                break;
            }
            for row in &rows {
                total_seen += 1;
                let npsn = row.get("npsn").and_then(|v| v.as_str()).map(str::trim).unwrap_or("");
                let name = row.get("sekolah").and_then(|v| v.as_str()).map(str::trim).unwrap_or("");
                if npsn.is_empty() || name.is_empty() {
                    skipped += 1;
                    continue;
                }
                let address = row.get("alamat_jalan").and_then(|v| v.as_str()).map(|s| s.trim().to_string()).filter(|s| !s.is_empty());
                let city = row.get("kabupaten_kota").and_then(|v| v.as_str()).map(|s| s.trim().to_string()).filter(|s| !s.is_empty());
                let province = row.get("propinsi").and_then(|v| v.as_str()).map(|s| s.trim().to_string()).filter(|s| !s.is_empty());

                if let Some(pool) = &pool {
                    upsert_school(pool, npsn, name, address.as_deref(), city.as_deref(), province.as_deref()).await?;
                }
                imported += 1;
            }
            log("info", "page", &json!({"level": level, "page": page, "rows": rows.len(), "imported": imported}));
            if rows.len() < PER_PAGE {
                break;
            }
            // Be polite to the public API.
            tokio::time::sleep(Duration::from_millis(150)).await;
        }
    }

    log("info", "done", &json!({"total_seen": total_seen, "imported": imported, "skipped": skipped, "dry_run": dry_run}));
    Ok(())
}

async fn fetch_total(client: &reqwest::Client, level: &str) -> i64 {
    match request_json(client, &format!("{BASE_URL}/sekolah/{level}?page=1&perPage=1")).await {
        Ok(json) => json.get("total_data").and_then(|v| v.as_i64()).unwrap_or(0),
        Err(e) => {
            log("warn", "fetch-total-failed", &json!({"level": level, "error": e.to_string()}));
            0
        }
    }
}

async fn fetch_page(client: &reqwest::Client, level: &str, page: usize) -> Vec<Value> {
    let url = format!("{BASE_URL}/sekolah/{level}?page={page}&perPage={PER_PAGE}");
    match request_json(client, &url).await {
        Ok(json) => json.get("dataSekolah").and_then(|v| v.as_array()).cloned().unwrap_or_default(),
        Err(e) => {
            log("warn", "fetch-page-failed", &json!({"level": level, "page": page, "error": e.to_string()}));
            Vec::new()
        }
    }
}

async fn request_json(client: &reqwest::Client, url: &str) -> anyhow::Result<Value> {
    let resp = client.get(url).send().await.context("request failed")?;
    if !resp.status().is_success() {
        anyhow::bail!("HTTP {}", resp.status());
    }
    Ok(resp.json::<Value>().await.context("json decode failed")?)
}

async fn upsert_school(
    pool: &sqlx::PgPool,
    npsn: &str,
    name: &str,
    address: Option<&str>,
    city: Option<&str>,
    province: Option<&str>,
) -> anyhow::Result<()> {
    sqlx::query(
        "INSERT INTO schools (name, npsn, address, city, province, phone, email, created_at, updated_at) \
         VALUES ($1, $2, $3, $4, $5, NULL, NULL, NOW(), NOW()) \
         ON CONFLICT (npsn) WHERE npsn IS NOT NULL \
         DO UPDATE SET name = EXCLUDED.name, address = EXCLUDED.address, city = EXCLUDED.city, \
                       province = EXCLUDED.province, updated_at = NOW()",
    )
    .bind(name)
    .bind(npsn)
    .bind(address)
    .bind(city)
    .bind(province)
    .execute(pool)
    .await
    .map_err(|e| anyhow::anyhow!("upsert failed for npsn={npsn}: {e}"))?;
    Ok(())
}

fn log(level: &str, msg: &str, fields: &Value) {
    println!(
        "{}",
        json!({"ts": chrono::Utc::now().to_rfc3339(), "level": level, "msg": msg, "service": "import-schools", "fields": fields})
    );
}

fn redact_url(url: &str) -> String {
    match url.split_once('@') {
        Some((_, rest)) => format!("postgresql://***@{}", rest),
        None => url.to_string(),
    }
}

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
                            let value = value.trim().trim_matches('"').to_string();
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

fn build_database_url() -> anyhow::Result<String> {
    let raw = std::env::var("DATABASE_URL").unwrap_or_default();
    if raw.is_empty() {
        anyhow::bail!("DATABASE_URL is not set");
    }
    let (host, port, dbname) = parse_jdbc_url(&raw)
        .unwrap_or_else(|| ("localhost".to_string(), 5432, "assessment".to_string()));
    let username = std::env::var("DATABASE_USERNAME").unwrap_or_else(|_| "postgres".to_string());
    let password = std::env::var("DATABASE_PASSWORD").unwrap_or_default();
    let mut url = format!("postgresql://{username}:{password}@{host}:{port}/{dbname}");
    if let Some(rest) = raw.split('?').nth(1) {
        url.push('?');
        url.push_str(rest);
    }
    Ok(url)
}

fn parse_jdbc_url(raw: &str) -> Option<(String, u16, String)> {
    let body = raw
        .strip_prefix("jdbc:postgresql://")
        .or_else(|| raw.strip_prefix("postgresql://"))
        .or_else(|| raw.strip_prefix("postgres://"))?
        .split('?')
        .next()?;
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
