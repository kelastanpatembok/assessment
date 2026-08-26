-- Add phone to assessment_users
ALTER TABLE assessment_users ADD COLUMN IF NOT EXISTS phone VARCHAR(30);

-- Registration leads table (self-registration from public form)
CREATE TABLE IF NOT EXISTS registrations (
    id            BIGSERIAL PRIMARY KEY,
    name          VARCHAR(255) NOT NULL,
    email         VARCHAR(255) NOT NULL,
    phone         VARCHAR(30),
    school_name   VARCHAR(255),
    school_address TEXT,
    role          VARCHAR(30) NOT NULL DEFAULT 'SISWA',
    status        VARCHAR(20) NOT NULL DEFAULT 'pending',  -- pending | approved | rejected
    notes         TEXT,
    auth_user_id  VARCHAR(64) REFERENCES assessment_users(auth_user_id) ON DELETE SET NULL,
    created_at    TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_registrations_status ON registrations(status);
CREATE INDEX IF NOT EXISTS idx_registrations_email  ON registrations(email);
