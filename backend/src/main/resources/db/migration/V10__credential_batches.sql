-- V10: credential_batches — tracks server-stored PDF exports of generated student credentials.
-- The PDF is the only place the plaintext passwords are kept after generation; access is
-- restricted to SUPERADMIN via the API (no public file path is ever exposed).

CREATE TABLE credential_batches (
    id                 BIGSERIAL PRIMARY KEY,
    test_assignment_id BIGINT NOT NULL REFERENCES test_assignments(id) ON DELETE CASCADE,
    school_id          BIGINT REFERENCES schools(id) ON DELETE SET NULL,
    school_name        VARCHAR(200) NOT NULL,
    category_name      VARCHAR(100) NOT NULL,
    credential_count   INT NOT NULL,
    pdf_filename       VARCHAR(300) NOT NULL,
    generated_by       VARCHAR(100) NOT NULL,
    created_at         TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_credential_batches_assignment ON credential_batches(test_assignment_id);
