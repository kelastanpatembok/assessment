//! Role-based access control system untuk aplikasi assessment
//!
//! Sistem ini mendefinisikan roles dan permissions untuk setiap role:
//! 1. SUPERADMIN - Akses penuh ke semua fitur
//! 2. PSIKOLOG - Baca hasil siswa, konsultasi, laporan
//! 3. GURUBK - Baca hasil siswa di sekolahnya, manajemen siswa
//! 4. SISWA - Kerjakan assessment, lihat hasil sendiri
//! 5. AFILIATOR - Marketing, referral, laporan komisi
//! 6. ADMIN_SEKOLAH - Manajemen sekolah, guru, siswa
//! 7. ORTU_SISWA - Lihat hasil anaknya, monitoring progress

use serde::{Deserialize, Serialize};

/// Semua roles yang tersedia dalam sistem
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
#[serde(rename_all = "SCREAMING_SNAKE_CASE")]
pub enum Role {
    Superadmin,
    Psikolog,
    GuruBk,
    Siswa,
    Afiliator,
    AdminSekolah,
    OrtuSiswa,
}

impl Role {
    /// Convert string to Role
    pub fn from_str(s: &str) -> Option<Self> {
        match s.to_uppercase().as_str() {
            "SUPERADMIN" => Some(Role::Superadmin),
            "PSIKOLOG" => Some(Role::Psikolog),
            "GURUBK" => Some(Role::GuruBk),
            "SISWA" => Some(Role::Siswa),
            "AFILIATOR" => Some(Role::Afiliator),
            "ADMIN_SEKOLAH" => Some(Role::AdminSekolah),
            "ORTU_SISWA" => Some(Role::OrtuSiswa),
            _ => None,
        }
    }

    /// Convert Role to string
    pub fn as_str(&self) -> &'static str {
        match self {
            Role::Superadmin => "SUPERADMIN",
            Role::Psikolog => "PSIKOLOG",
            Role::GuruBk => "GURUBK",
            Role::Siswa => "SISWA",
            Role::Afiliator => "AFILIATOR",
            Role::AdminSekolah => "ADMIN_SEKOLAH",
            Role::OrtuSiswa => "ORTU_SISWA",
        }
    }
}

/// Permissions yang tersedia dalam sistem
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum Permission {
    // User management
    CreateUser,
    ReadUser,
    UpdateUser,
    DeleteUser,
    
    // School management
    CreateSchool,
    ReadSchool,
    UpdateSchool,
    DeleteSchool,
    
    // Assessment management
    CreateAssessment,
    ReadAssessment,
    UpdateAssessment,
    DeleteAssessment,
    
    // Test execution
    TakeTest,
    SubmitTest,
    
    // Results access
    ReadOwnResults,
    ReadStudentResults,
    ReadAllResults,
    
    // Reports
    GenerateReports,
    ExportReports,
    
    // Financial
    ReadFees,
    UpdateFees,
    
    // System
    AccessAdminPanel,
    ManageSystemSettings,
}

/// Struktur yang mendefinisikan permissions untuk setiap role
pub struct RolePermissions {
    pub role: Role,
    pub permissions: Vec<Permission>,
}

impl RolePermissions {
    /// Dapatkan permissions untuk role tertentu
    pub fn for_role(role: Role) -> &'static [Permission] {
        match role {
            Role::Superadmin => &[
                Permission::CreateUser,
                Permission::ReadUser,
                Permission::UpdateUser,
                Permission::DeleteUser,
                Permission::CreateSchool,
                Permission::ReadSchool,
                Permission::UpdateSchool,
                Permission::DeleteSchool,
                Permission::CreateAssessment,
                Permission::ReadAssessment,
                Permission::UpdateAssessment,
                Permission::DeleteAssessment,
                Permission::TakeTest,
                Permission::SubmitTest,
                Permission::ReadOwnResults,
                Permission::ReadStudentResults,
                Permission::ReadAllResults,
                Permission::GenerateReports,
                Permission::ExportReports,
                Permission::ReadFees,
                Permission::UpdateFees,
                Permission::AccessAdminPanel,
                Permission::ManageSystemSettings,
            ],
            Role::Psikolog => &[
                Permission::ReadUser,
                Permission::ReadAssessment,
                Permission::ReadAllResults,
                Permission::GenerateReports,
                Permission::ExportReports,
            ],
            Role::GuruBk => &[
                Permission::ReadUser,
                Permission::ReadSchool,
                Permission::ReadAssessment,
                Permission::ReadStudentResults,
                Permission::GenerateReports,
            ],
            Role::Siswa => &[
                Permission::ReadOwnResults,
                Permission::TakeTest,
                Permission::SubmitTest,
            ],
            Role::Afiliator => &[
                Permission::ReadUser,
                Permission::ReadFees,
            ],
            Role::AdminSekolah => &[
                Permission::CreateUser,
                Permission::ReadUser,
                Permission::UpdateUser,
                Permission::ReadSchool,
                Permission::UpdateSchool,
                Permission::ReadAssessment,
                Permission::ReadStudentResults,
                Permission::GenerateReports,
            ],
            Role::OrtuSiswa => &[
                Permission::ReadOwnResults,
            ],
        }
    }
    
    /// Cek apakah role memiliki permission tertentu
    pub fn has_permission(role: Role, permission: Permission) -> bool {
        Self::for_role(role).contains(&permission)
    }
    
    /// Cek apakah role dapat mengakses endpoint tertentu berdasarkan permission
    pub fn can_access_endpoint(role: Role, endpoint: &str, method: &str) -> bool {
        // Mapping endpoint ke permission
        match (endpoint, method) {
            // User management endpoints
            ("/api/users", "GET") => Self::has_permission(role, Permission::ReadUser),
            ("/api/users", "POST") => Self::has_permission(role, Permission::CreateUser),
            ("/api/users/{id}", "PUT") => Self::has_permission(role, Permission::UpdateUser),
            ("/api/users/{id}", "DELETE") => Self::has_permission(role, Permission::DeleteUser),
            
            // School management endpoints
            ("/api/schools", "GET") => Self::has_permission(role, Permission::ReadSchool),
            ("/api/schools", "POST") => Self::has_permission(role, Permission::CreateSchool),
            ("/api/schools/{id}", "PUT") => Self::has_permission(role, Permission::UpdateSchool),
            ("/api/schools/{id}", "DELETE") => Self::has_permission(role, Permission::DeleteSchool),
            
            // Assessment endpoints
            ("/api/big5/questions", "GET") => Self::has_permission(role, Permission::TakeTest),
            ("/api/big5/submit", "POST") => Self::has_permission(role, Permission::SubmitTest),
            ("/api/big5/result/me", "GET") => Self::has_permission(role, Permission::ReadOwnResults),
            
            // Results endpoints
            ("/api/results", "GET") => Self::has_permission(role, Permission::ReadStudentResults),
            ("/api/results/all", "GET") => Self::has_permission(role, Permission::ReadAllResults),
            
            // Reports endpoints
            ("/api/reports", "GET") => Self::has_permission(role, Permission::GenerateReports),
            ("/api/reports/export", "GET") => Self::has_permission(role, Permission::ExportReports),
            
            // Default: izinkan jika tidak ada aturan spesifik
            _ => true,
        }
    }
}

/// Helper function untuk mengecek permission pada AuthUser
pub fn check_permission(user_role: &str, permission: Permission) -> bool {
    if let Some(role) = Role::from_str(user_role) {
        RolePermissions::has_permission(role, permission)
    } else {
        false
    }
}