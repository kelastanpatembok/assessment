-- School report recipients are registered assessment accounts. A PIC may be
-- a Guru BK or another school staff account, but must belong to the school.
CREATE TABLE IF NOT EXISTS school_pics (
    school_id BIGINT NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    auth_user_id VARCHAR(255) NOT NULL REFERENCES assessment_users(auth_user_id) ON DELETE CASCADE,
    is_primary BOOLEAN NOT NULL DEFAULT FALSE,
    created_by VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    PRIMARY KEY (school_id, auth_user_id)
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_school_pics_one_primary
    ON school_pics(school_id) WHERE is_primary = TRUE;

-- Demographics used by the official individual-result page. Kept separate
-- from assessment_users so the existing auth/profile contract stays stable.
CREATE TABLE IF NOT EXISTS student_profiles (
    auth_user_id VARCHAR(255) PRIMARY KEY REFERENCES assessment_users(auth_user_id) ON DELETE CASCADE,
    date_of_birth DATE,
    gender VARCHAR(20),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Immutable delivery snapshot. The encrypted PDF is retained in PostgreSQL so
-- history downloads do not depend on a release directory on the app CT.
CREATE TABLE IF NOT EXISTS assessment_report_deliveries (
    id BIGSERIAL PRIMARY KEY,
    report_no VARCHAR(80) NOT NULL UNIQUE,
    assignment_id BIGINT NOT NULL REFERENCES test_assignments(id),
    school_id BIGINT NOT NULL REFERENCES schools(id),
    created_by VARCHAR(255) NOT NULL,
    official_email VARCHAR(320) NOT NULL,
    pic_emails TEXT[] NOT NULL DEFAULT '{}',
    subject TEXT NOT NULL,
    pdf_filename TEXT NOT NULL,
    pdf_data BYTEA NOT NULL,
    method_keys TEXT[] NOT NULL DEFAULT '{}',
    student_count INTEGER NOT NULL,
    incomplete_student_count INTEGER NOT NULL,
    email_message_id VARCHAR(100),
    status VARCHAR(30) NOT NULL DEFAULT 'queued',
    error TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    sent_at TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_assessment_report_history_created
    ON assessment_report_deliveries(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_assessment_report_history_school
    ON assessment_report_deliveries(school_id, created_at DESC);
