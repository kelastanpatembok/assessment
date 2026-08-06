-- V10: Student certificates (generated PNG images stored in the storage domain)

CREATE TABLE certificates (
    id            BIGSERIAL PRIMARY KEY,
    auth_user_id  VARCHAR(64) NOT NULL REFERENCES assessment_users(auth_user_id),
    test_type     VARCHAR(20) NOT NULL,
    storage_key   VARCHAR(255) NOT NULL,
    created_at    TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE (auth_user_id, test_type)
);

CREATE INDEX idx_certificates_user ON certificates (auth_user_id);
