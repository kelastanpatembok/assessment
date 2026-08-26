-- Tabel untuk menyimpan role dinamis
CREATE TABLE IF NOT EXISTS roles (
    id VARCHAR(50) PRIMARY KEY,
    display_name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Tabel untuk relasi role dan permission (many-to-many atau list of permissions)
CREATE TABLE IF NOT EXISTS role_permissions (
    role_id VARCHAR(50) REFERENCES roles(id) ON DELETE CASCADE,
    permission VARCHAR(100) NOT NULL,
    PRIMARY KEY (role_id, permission)
);

-- Insert default roles (SUPERADMIN, dll)
INSERT INTO roles (id, display_name, description) VALUES
    ('SUPERADMIN', 'Super Administrator', 'Akses penuh ke semua fitur sistem. Dapat mengelola semua user, sekolah, assessment, dan laporan.'),
    ('PSIKOLOG', 'Psikolog', 'Dapat membaca hasil assessment siswa, memberikan konsultasi, dan membuat laporan psikologis.'),
    ('GURUBK', 'Guru BK/Bimbingan Konseling', 'Dapat membaca hasil siswa di sekolahnya, memantau progress, dan membuat laporan untuk sekolah.'),
    ('SISWA', 'Siswa', 'Dapat mengerjakan assessment yang ditugaskan dan melihat hasil pribadi.'),
    ('AFILIATOR', 'Afiliator/Marketing', 'Dapat melihat statistik referral dan komisi dari siswa yang direferensikan.'),
    ('ADMIN_SEKOLAH', 'Admin Sekolah', 'Dapat mengelola data sekolah, guru, dan siswa di sekolahnya.'),
    ('ORTU_SISWA', 'Orang Tua Siswa', 'Dapat melihat hasil assessment anaknya dan memantau progress belajar.')
ON CONFLICT (id) DO NOTHING;

-- Insert default permissions for SUPERADMIN
INSERT INTO role_permissions (role_id, permission) VALUES
    ('SUPERADMIN', 'CreateUser'), ('SUPERADMIN', 'ReadUser'), ('SUPERADMIN', 'UpdateUser'), ('SUPERADMIN', 'DeleteUser'),
    ('SUPERADMIN', 'CreateSchool'), ('SUPERADMIN', 'ReadSchool'), ('SUPERADMIN', 'UpdateSchool'), ('SUPERADMIN', 'DeleteSchool'),
    ('SUPERADMIN', 'CreateAssessment'), ('SUPERADMIN', 'ReadAssessment'), ('SUPERADMIN', 'UpdateAssessment'), ('SUPERADMIN', 'DeleteAssessment'),
    ('SUPERADMIN', 'TakeTest'), ('SUPERADMIN', 'SubmitTest'),
    ('SUPERADMIN', 'ReadOwnResults'), ('SUPERADMIN', 'ReadStudentResults'), ('SUPERADMIN', 'ReadAllResults'),
    ('SUPERADMIN', 'GenerateReports'), ('SUPERADMIN', 'ExportReports'),
    ('SUPERADMIN', 'ReadFees'), ('SUPERADMIN', 'UpdateFees'),
    ('SUPERADMIN', 'AccessAdminPanel'), ('SUPERADMIN', 'ManageSystemSettings')
ON CONFLICT (role_id, permission) DO NOTHING;

-- For other default roles, we'll let the application code sync them if needed or use application logic as fallback initially.
