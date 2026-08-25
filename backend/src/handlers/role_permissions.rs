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

/// Get all available roles and their permissions
pub async fn get_roles(
    State(_state): State<AppState>,
    auth: AuthUser,
) -> AppResult<Json<serde_json::Value>> {
    auth.require_permission(Permission::ReadUser)?;

    let roles = vec![
        Role::Superadmin,
        Role::Psikolog,
        Role::GuruBk,
        Role::Siswa,
        Role::Afiliator,
        Role::AdminSekolah,
        Role::OrtuSiswa,
    ];

    let role_infos: Vec<RoleInfo> = roles.into_iter().map(|role| {
        let (display_name, description) = match role {
            Role::Superadmin => (
                "Super Administrator",
                "Akses penuh ke semua fitur sistem. Dapat mengelola semua user, sekolah, assessment, dan laporan."
            ),
            Role::Psikolog => (
                "Psikolog",
                "Dapat membaca hasil assessment siswa, memberikan konsultasi, dan membuat laporan psikologis."
            ),
            Role::GuruBk => (
                "Guru BK/Bimbingan Konseling",
                "Dapat membaca hasil siswa di sekolahnya, memantau progress, dan membuat laporan untuk sekolah."
            ),
            Role::Siswa => (
                "Siswa",
                "Dapat mengerjakan assessment yang ditugaskan dan melihat hasil pribadi."
            ),
            Role::Afiliator => (
                "Afiliator/Marketing",
                "Dapat melihat statistik referral dan komisi dari siswa yang direferensikan."
            ),
            Role::AdminSekolah => (
                "Admin Sekolah",
                "Dapat mengelola data sekolah, guru, dan siswa di sekolahnya."
            ),
            Role::OrtuSiswa => (
                "Orang Tua Siswa",
                "Dapat melihat hasil assessment anaknya dan memantau progress belajar."
            ),
        };

        let permissions: Vec<PermissionInfo> = permissions::RolePermissions::for_role(role)
            .iter()
            .map(|&perm| {
                let (display_name, description) = match perm {
                    Permission::CreateUser => ("Buat User", "Membuat user baru"),
                    Permission::ReadUser => ("Baca User", "Melihat daftar user"),
                    Permission::UpdateUser => ("Update User", "Mengubah data user"),
                    Permission::DeleteUser => ("Hapus User", "Menghapus user"),
                    Permission::CreateSchool => ("Buat Sekolah", "Membuat data sekolah baru"),
                    Permission::ReadSchool => ("Baca Sekolah", "Melihat data sekolah"),
                    Permission::UpdateSchool => ("Update Sekolah", "Mengubah data sekolah"),
                    Permission::DeleteSchool => ("Hapus Sekolah", "Menghapus data sekolah"),
                    Permission::CreateAssessment => ("Buat Assessment", "Membuat assessment baru"),
                    Permission::ReadAssessment => ("Baca Assessment", "Melihat daftar assessment"),
                    Permission::UpdateAssessment => ("Update Assessment", "Mengubah assessment"),
                    Permission::DeleteAssessment => ("Hapus Assessment", "Menghapus assessment"),
                    Permission::TakeTest => ("Kerjakan Test", "Mengerjakan assessment"),
                    Permission::SubmitTest => ("Submit Test", "Mengumpulkan hasil assessment"),
                    Permission::ReadOwnResults => ("Baca Hasil Sendiri", "Melihat hasil pribadi"),
                    Permission::ReadStudentResults => ("Baca Hasil Siswa", "Melihat hasil siswa"),
                    Permission::ReadAllResults => ("Baca Semua Hasil", "Melihat semua hasil"),
                    Permission::GenerateReports => ("Buat Laporan", "Membuat laporan"),
                    Permission::ExportReports => ("Export Laporan", "Mengekspor laporan"),
                    Permission::ReadFees => ("Baca Biaya", "Melihat data biaya"),
                    Permission::UpdateFees => ("Update Biaya", "Mengubah data biaya"),
                    Permission::AccessAdminPanel => ("Akses Admin", "Mengakses panel admin"),
                    Permission::ManageSystemSettings => ("Kelola Sistem", "Mengelola pengaturan sistem"),
                };

                PermissionInfo {
                    permission: format!("{:?}", perm),
                    display_name: display_name.to_string(),
                    description: description.to_string(),
                }
            })
            .collect();

        RoleInfo {
            role: role.as_str().to_string(),
            display_name: display_name.to_string(),
            description: description.to_string(),
            permissions,
        }
    }).collect();

    Ok(Json(serde_json::json!(role_infos)))
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