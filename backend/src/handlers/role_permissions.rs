use axum::{extract::State, Json};
use serde::Serialize;

use crate::{
    auth_extractor::AuthUser,
    error::AppResult,
    permissions::{self, Permission, Role},
    state::AppState,
};

#[derive(Debug, Clone, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct RoleInfo {
    pub role: String,
    pub display_name: String,
    pub description: String,
    pub permissions: Vec<PermissionInfo>,
}

#[derive(Debug, Clone, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct PermissionInfo {
    pub permission: String,
    pub display_name: String,
    pub description: String,
}

#[derive(Debug, Clone, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct UserRoleInfo {
    pub user_role: String,
    pub display_name: String,
    pub permissions: Vec<String>,
    pub can_access_admin: bool,
}

use std::collections::HashMap;

/// Get all available roles and their permissions
pub async fn get_roles(
    State(state): State<AppState>,
    auth: AuthUser,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_permission(Permission::ReadUser)?;

    let rows: Vec<(String, String, Option<String>, Option<String>)> = sqlx::query_as(
        "SELECT r.id, r.display_name, r.description, rp.permission 
         FROM roles r 
         LEFT JOIN role_permissions rp ON r.id = rp.role_id 
         ORDER BY r.created_at ASC"
    )
    .fetch_all(&state.pool)
    .await
    .map_err(|e| crate::error::AppError::from_sqlx("get_roles", e))?;

    let mut role_map: HashMap<String, RoleInfo> = HashMap::new();

    for (id, display_name, description, permission) in rows {
        let role_info = role_map.entry(id.clone()).or_insert_with(|| RoleInfo {
            role: id.clone(),
            display_name,
            description: description.unwrap_or_default(),
            permissions: Vec::new(),
        });

        if let Some(perm_str) = permission {
            let perm_enum = parse_permission(&perm_str);
            let (perm_display, perm_desc) = permission_metadata(&perm_str);
            
            role_info.permissions.push(PermissionInfo {
                permission: perm_str,
                display_name: perm_display.to_string(),
                description: perm_desc.to_string(),
            });
        }
    }

    let mut role_infos: Vec<RoleInfo> = role_map.into_values().collect();
    role_infos.sort_by_key(|r| r.role.clone());

    Ok(Json(serde_json::json!(role_infos)))
}

fn parse_permission(s: &str) -> Option<Permission> {
    match s {
        "CreateUser" => Some(Permission::CreateUser),
        "ReadUser" => Some(Permission::ReadUser),
        "UpdateUser" => Some(Permission::UpdateUser),
        "DeleteUser" => Some(Permission::DeleteUser),
        "CreateSchool" => Some(Permission::CreateSchool),
        "ReadSchool" => Some(Permission::ReadSchool),
        "UpdateSchool" => Some(Permission::UpdateSchool),
        "DeleteSchool" => Some(Permission::DeleteSchool),
        "CreateAssessment" => Some(Permission::CreateAssessment),
        "ReadAssessment" => Some(Permission::ReadAssessment),
        "UpdateAssessment" => Some(Permission::UpdateAssessment),
        "DeleteAssessment" => Some(Permission::DeleteAssessment),
        "TakeTest" => Some(Permission::TakeTest),
        "SubmitTest" => Some(Permission::SubmitTest),
        "ReadOwnResults" => Some(Permission::ReadOwnResults),
        "ReadStudentResults" => Some(Permission::ReadStudentResults),
        "ReadAllResults" => Some(Permission::ReadAllResults),
        "GenerateReports" => Some(Permission::GenerateReports),
        "ExportReports" => Some(Permission::ExportReports),
        "ReadFees" => Some(Permission::ReadFees),
        "UpdateFees" => Some(Permission::UpdateFees),
        "AccessAdminPanel" => Some(Permission::AccessAdminPanel),
        "ManageSystemSettings" => Some(Permission::ManageSystemSettings),
        _ => None,
    }
}

fn permission_metadata(s: &str) -> (&'static str, &'static str) {
    match s {
        "CreateUser" => ("Buat User", "Membuat user baru"),
        "ReadUser" => ("Baca User", "Melihat daftar user"),
        "UpdateUser" => ("Update User", "Mengubah data user"),
        "DeleteUser" => ("Hapus User", "Menghapus user"),
        "CreateSchool" => ("Buat Sekolah", "Membuat data sekolah baru"),
        "ReadSchool" => ("Baca Sekolah", "Melihat data sekolah"),
        "UpdateSchool" => ("Update Sekolah", "Mengubah data sekolah"),
        "DeleteSchool" => ("Hapus Sekolah", "Menghapus data sekolah"),
        "CreateAssessment" => ("Buat Assessment", "Membuat assessment baru"),
        "ReadAssessment" => ("Baca Assessment", "Melihat daftar assessment"),
        "UpdateAssessment" => ("Update Assessment", "Mengubah assessment"),
        "DeleteAssessment" => ("Hapus Assessment", "Menghapus assessment"),
        "TakeTest" => ("Kerjakan Test", "Mengerjakan assessment"),
        "SubmitTest" => ("Submit Test", "Mengumpulkan hasil assessment"),
        "ReadOwnResults" => ("Baca Hasil Sendiri", "Melihat hasil pribadi"),
        "ReadStudentResults" => ("Baca Hasil Siswa", "Melihat hasil siswa"),
        "ReadAllResults" => ("Baca Semua Hasil", "Melihat semua hasil"),
        "GenerateReports" => ("Buat Laporan", "Membuat laporan"),
        "ExportReports" => ("Export Laporan", "Mengekspor laporan"),
        "ReadFees" => ("Baca Biaya", "Melihat data biaya"),
        "UpdateFees" => ("Update Biaya", "Mengubah data biaya"),
        "AccessAdminPanel" => ("Akses Admin", "Mengakses panel admin"),
        "ManageSystemSettings" => ("Kelola Sistem", "Mengelola pengaturan sistem"),
        _ => ("Custom Permission", "Akses custom"),
    }
}

use serde::Deserialize;

#[derive(Deserialize)]
pub struct CreateRoleRequest {
    pub id: String,
    #[serde(rename = "displayName")]
    pub display_name: String,
    pub description: Option<String>,
    pub permissions: Vec<String>,
}

#[derive(Deserialize)]
pub struct UpdateRoleRequest {
    #[serde(rename = "displayName")]
    pub display_name: String,
    pub description: Option<String>,
    pub permissions: Vec<String>,
}

pub async fn create_role(
    State(state): State<AppState>,
    auth: AuthUser,
    Json(req): Json<CreateRoleRequest>,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SUPERADMIN"])?;
    
    let id_upper = req.id.to_uppercase();
    
    // insert role
    sqlx::query("INSERT INTO roles (id, display_name, description) VALUES ($1, $2, $3)")
        .bind(&id_upper)
        .bind(&req.display_name)
        .bind(&req.description)
        .execute(&state.pool)
        .await
        .map_err(|e| crate::error::AppError::from_sqlx("create_role", e))?;
        
    // insert permissions
    for p in &req.permissions {
        sqlx::query("INSERT INTO role_permissions (role_id, permission) VALUES ($1, $2)")
            .bind(&id_upper)
            .bind(p)
            .execute(&state.pool)
            .await
            .map_err(|e| crate::error::AppError::from_sqlx("create_role_perm", e))?;
    }
    
    Ok(Json(serde_json::json!({ "success": true, "id": id_upper })))
}

pub async fn update_role(
    State(state): State<AppState>,
    auth: AuthUser,
    axum::extract::Path(id): axum::extract::Path<String>,
    Json(req): Json<UpdateRoleRequest>,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SUPERADMIN"])?;
    let id_upper = id.to_uppercase();
    
    let mut tx = state.pool.begin().await.map_err(|e| crate::error::AppError::from_sqlx("begin_tx", e))?;
    
    sqlx::query("UPDATE roles SET display_name = $1, description = $2, updated_at = NOW() WHERE id = $3")
        .bind(&req.display_name)
        .bind(&req.description)
        .bind(&id_upper)
        .execute(&mut *tx)
        .await
        .map_err(|e| crate::error::AppError::from_sqlx("update_role", e))?;
        
    sqlx::query("DELETE FROM role_permissions WHERE role_id = $1")
        .bind(&id_upper)
        .execute(&mut *tx)
        .await
        .map_err(|e| crate::error::AppError::from_sqlx("delete_role_perms", e))?;
        
    for p in &req.permissions {
        sqlx::query("INSERT INTO role_permissions (role_id, permission) VALUES ($1, $2)")
            .bind(&id_upper)
            .bind(p)
            .execute(&mut *tx)
            .await
            .map_err(|e| crate::error::AppError::from_sqlx("insert_role_perm", e))?;
    }
    
    tx.commit().await.map_err(|e| crate::error::AppError::from_sqlx("commit_tx", e))?;
    
    Ok(Json(serde_json::json!({ "success": true, "id": id_upper })))
}

pub async fn delete_role(
    State(state): State<AppState>,
    auth: AuthUser,
    axum::extract::Path(id): axum::extract::Path<String>,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_role(&["SUPERADMIN"])?;
    let id_upper = id.to_uppercase();
    
    if id_upper == "SUPERADMIN" {
        return Err(crate::error::AppError::BadRequest("Cannot delete SUPERADMIN role".to_string()));
    }
    
    sqlx::query("DELETE FROM roles WHERE id = $1")
        .bind(&id_upper)
        .execute(&state.pool)
        .await
        .map_err(|e| crate::error::AppError::from_sqlx("delete_role", e))?;
        
    Ok(Json(serde_json::json!({ "success": true })))
}

/// Get current user's role information
pub async fn get_my_role_info(
    State(_state): State<AppState>,
    auth: AuthUser,
) -> AppResult<Json<serde_json::Value>> {
    let role = permissions::Role::from_str(&auth.role).unwrap_or(Role::Siswa);
    
    let display_name = match role {
        Role::Superadmin => "Super Administrator",
        Role::Psikolog => "Psikolog",
        Role::GuruBk => "Guru BK",
        Role::Siswa => "Siswa",
        Role::Afiliator => "Afiliator",
        Role::AdminSekolah => "Admin Sekolah",
        Role::OrtuSiswa => "Orang Tua Siswa",
    };

    let permissions: Vec<String> = permissions::RolePermissions::for_role(role)
        .iter()
        .map(|perm| format!("{:?}", perm))
        .collect();

    let can_access_admin = auth.has_permission(Permission::AccessAdminPanel);

    let user_role_info = UserRoleInfo {
        user_role: auth.role.clone(),
        display_name: display_name.to_string(),
        permissions,
        can_access_admin,
    };

    Ok(Json(serde_json::json!(user_role_info)))
}

/// Check if user has specific permission
pub async fn check_permission(
    State(_state): State<AppState>,
    auth: AuthUser,
    permission: String,
) -> AppResult<Json<serde_json::Value>> {
    // Parse permission string
    let perm = match permission.as_str() {
        "CreateUser" => Permission::CreateUser,
        "ReadUser" => Permission::ReadUser,
        "UpdateUser" => Permission::UpdateUser,
        "DeleteUser" => Permission::DeleteUser,
        "CreateSchool" => Permission::CreateSchool,
        "ReadSchool" => Permission::ReadSchool,
        "UpdateSchool" => Permission::UpdateSchool,
        "DeleteSchool" => Permission::DeleteSchool,
        "CreateAssessment" => Permission::CreateAssessment,
        "ReadAssessment" => Permission::ReadAssessment,
        "UpdateAssessment" => Permission::UpdateAssessment,
        "DeleteAssessment" => Permission::DeleteAssessment,
        "TakeTest" => Permission::TakeTest,
        "SubmitTest" => Permission::SubmitTest,
        "ReadOwnResults" => Permission::ReadOwnResults,
        "ReadStudentResults" => Permission::ReadStudentResults,
        "ReadAllResults" => Permission::ReadAllResults,
        "GenerateReports" => Permission::GenerateReports,
        "ExportReports" => Permission::ExportReports,
        "ReadFees" => Permission::ReadFees,
        "UpdateFees" => Permission::UpdateFees,
        "AccessAdminPanel" => Permission::AccessAdminPanel,
        "ManageSystemSettings" => Permission::ManageSystemSettings,
        _ => return Ok(Json(serde_json::json!({
            "hasPermission": false,
            "error": "Invalid permission name"
        }))),
    };

    let has_permission = auth.has_permission(perm);

    Ok(Json(serde_json::json!({
        "hasPermission": has_permission,
        "permission": permission,
        "userRole": auth.role
    })))
}