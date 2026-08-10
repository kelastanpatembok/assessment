use serde::Deserialize;
use serde_json::json;

#[derive(Debug, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct AuthRegisterResponse {
    pub token: String,
    pub user: AuthUserInfo,
    pub expires_in: i64,
}

#[derive(Debug, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct AuthUserInfo {
    pub id: String,
    pub username: String,
    pub email: String,
    pub name: String,
    pub role: String,
}

#[derive(Debug, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct CheckUsernameResponse {
    pub existing: Vec<String>,
}

#[derive(Debug, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct UserInfoResponse {
    pub id: String,
    pub username: String,
    pub email: String,
    pub name: String,
    pub role: String,
}

#[derive(Clone)]
pub struct AuthClient {
    client: reqwest::Client,
    base_url: String,
}

impl AuthClient {
    pub fn new(base_url: String) -> Self {
        Self {
            client: reqwest::Client::new(),
            base_url,
        }
    }

    /// Registers a new user. Uses the JSON body contract that the Rust auth
    /// service accepts (the legacy Java client sent query params, which now
    /// returns 415 against the Rust auth service).
    pub async fn register(
        &self,
        username: &str,
        email: &str,
        password: &str,
        name: &str,
        role: &str,
    ) -> anyhow::Result<AuthRegisterResponse> {
        let url = format!("{}/auth/register", self.base_url.trim_end_matches('/'));
        let body = json!({
            "username": username,
            "email": email,
            "password": password,
            "name": name,
            "role": role,
        });
        let resp = self
            .client
            .post(&url)
            .json(&body)
            .send()
            .await?
            .error_for_status()?;
        let parsed: AuthRegisterResponse = resp.json().await?;
        Ok(parsed)
    }

    /// Batch username existence check against auth.
    pub async fn check_usernames_exist(
        &self,
        usernames: &[String],
    ) -> anyhow::Result<std::collections::HashSet<String>> {
        if usernames.is_empty() {
            return Ok(std::collections::HashSet::new());
        }
        let url = format!("{}/auth/users/check-existence", self.base_url.trim_end_matches('/'));
        let resp = self.client.post(&url).json(&json!({ "usernames": usernames })).send().await;
        let resp = match resp {
            Ok(r) => r,
            Err(_) => return Ok(std::collections::HashSet::new()),
        };
        if resp.status() == reqwest::StatusCode::NOT_FOUND {
            return Ok(std::collections::HashSet::new());
        }
        let parsed: CheckUsernameResponse = match resp.error_for_status() {
            Ok(r) => match r.json().await {
                Ok(p) => p,
                Err(_) => return Ok(std::collections::HashSet::new()),
            },
            Err(_) => return Ok(std::collections::HashSet::new()),
        };
        Ok(parsed.existing.into_iter().collect())
    }

    /// Best-effort deletes a user from auth. Used for compensating rollback
    /// when bulk credential creation fails partway; failures are swallowed
    /// (the Java client did the same and the auth endpoint now requires an
    /// OWNER-role caller that this service is not).
    pub async fn delete_user(&self, user_id: &str) {
        let url = format!(
            "{}/users/{}",
            self.base_url.trim_end_matches('/'),
            user_id
        );
        let _ = self.client.delete(&url).send().await;
    }

    /// Best-effort password change for a target user. The Rust auth service
    /// only permits a caller to change its OWN password (needs currentPassword
    /// + bearer), so an admin-driven reset against another user fails here.
    /// The legacy Java client's query-param shape returned 500 from prod, so
    /// a failed change is surfaced as an internal error to match that result.
    pub async fn change_password(
        &self,
        _auth_user_id: &str,
        _username: &str,
        _new_password: &str,
    ) -> anyhow::Result<()> {
        // Attempt the legacy shape; the Rust auth service rejects it (missing
        // bearer + currentPassword), matching the Java backend's 500.
        let url = format!(
            "{}/auth/change-password?userId={}&newPassword={}",
            self.base_url.trim_end_matches('/'),
            _auth_user_id,
            _new_password
        );
        let resp = self.client.put(&url).send().await;
        match resp {
            Ok(r) if r.status().is_success() => Ok(()),
            Ok(r) => anyhow::bail!("auth change-password failed: HTTP {}", r.status()),
            Err(e) => anyhow::bail!("auth change-password error: {e}"),
        }
    }
}
