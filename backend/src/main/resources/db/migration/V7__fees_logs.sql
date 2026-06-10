-- V7: Fee/commission tables and activity logs

-- fee_config: global or school-level fee settings per test category
CREATE TABLE fee_config (
    id                  BIGSERIAL PRIMARY KEY,
    category_id         BIGINT UNIQUE REFERENCES test_categories(id),   -- NULL = global default
    student_fee         NUMERIC(14,2) NOT NULL DEFAULT 0,
    afiliator_share_pct NUMERIC(5,2) NOT NULL DEFAULT 0,  -- percentage 0–100
    gurubk_share_pct    NUMERIC(5,2) NOT NULL DEFAULT 0,
    platform_share_pct  NUMERIC(5,2) NOT NULL DEFAULT 100,
    updated_at          TIMESTAMP NOT NULL DEFAULT NOW()
);

-- fee_shares: actual computed share per student registration
CREATE TABLE fee_shares (
    id              BIGSERIAL PRIMARY KEY,
    student_id      VARCHAR(64) NOT NULL REFERENCES assessment_users(auth_user_id),
    category_id     BIGINT NOT NULL REFERENCES test_categories(id),
    afiliator_id    VARCHAR(64),
    gurubk_id       VARCHAR(64),
    total_fee       NUMERIC(14,2) NOT NULL DEFAULT 0,
    afiliator_share NUMERIC(14,2) NOT NULL DEFAULT 0,
    gurubk_share    NUMERIC(14,2) NOT NULL DEFAULT 0,
    platform_share  NUMERIC(14,2) NOT NULL DEFAULT 0,
    created_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_fee_shares_student   ON fee_shares(student_id);
CREATE INDEX idx_fee_shares_afiliator ON fee_shares(afiliator_id);

-- activity_log: audit trail for exam start/finish events
CREATE TABLE activity_logs (
    id              BIGSERIAL PRIMARY KEY,
    auth_user_id    VARCHAR(64) NOT NULL,
    test_type       VARCHAR(20) NOT NULL,   -- disc | holland | papi | cfit | ist
    event_type      VARCHAR(20) NOT NULL,   -- START | FINISH
    metadata        JSONB,
    created_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_activity_user ON activity_logs(auth_user_id);
CREATE INDEX idx_activity_test ON activity_logs(test_type);
