-- V3: Holland RIASEC test

-- Holland questions: 18 groups (R1–C3), 11 statements each
-- group_code: R1, R2, R3, I1, I2, I3, A1, A2, A3, S1, S2, S3, E1, E2, E3, C1, C2, C3
-- item_no: 1–11
-- riasec_type: R | I | A | S | E | C
CREATE TABLE holland_questions (
    id           BIGSERIAL PRIMARY KEY,
    group_code   VARCHAR(3) NOT NULL,
    item_no      INT NOT NULL,
    riasec_type  VARCHAR(1) NOT NULL,
    statement    TEXT NOT NULL,
    is_active    BOOLEAN NOT NULL DEFAULT TRUE,
    UNIQUE(group_code, item_no)
);

CREATE INDEX idx_holland_q_group ON holland_questions(group_code);

-- Holland description table: one row per riasec_type
CREATE TABLE holland_descriptions (
    id           BIGSERIAL PRIMARY KEY,
    riasec_type  VARCHAR(1) NOT NULL UNIQUE,
    name         VARCHAR(50) NOT NULL,      -- e.g. "Realistic"
    description  TEXT,
    careers      TEXT                        -- comma-separated career suggestions
);

-- Holland results
CREATE TABLE holland_results (
    id              BIGSERIAL PRIMARY KEY,
    auth_user_id    VARCHAR(64) NOT NULL UNIQUE REFERENCES assessment_users(auth_user_id),
    student_name    VARCHAR(255),
    school_name     VARCHAR(255),
    assignment_id   BIGINT REFERENCES test_assignments(id),
    -- raw RIASEC scores
    r_score INT NOT NULL DEFAULT 0,
    i_score INT NOT NULL DEFAULT 0,
    a_score INT NOT NULL DEFAULT 0,
    s_score INT NOT NULL DEFAULT 0,
    e_score INT NOT NULL DEFAULT 0,
    c_score INT NOT NULL DEFAULT 0,
    -- top types (ordered)
    type1   VARCHAR(1),
    type2   VARCHAR(1),
    type3   VARCHAR(1),
    holland_code VARCHAR(3),   -- e.g. "RIA"
    -- descriptions for top type
    type1_name       VARCHAR(50),
    type1_desc       TEXT,
    -- raw answers (JSON array of {question_id, score (1-5)})
    answers         JSONB,
    completed_at    TIMESTAMP NOT NULL DEFAULT NOW()
);
