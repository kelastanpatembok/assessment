-- V4: PAPI Kostick test

-- PAPI questions: 90 forced-choice pairs, each item belongs to one of 20 traits
-- pair_no: 1–90 (each pair has 2 items; student picks one)
-- item_letter: A or B
-- trait_code: one of 20 PAPI trait codes (N, G, A, L, P, I, T, V, X, S, B, O, R, D, C, E, K, F, W, Z)
CREATE TABLE papi_questions (
    id           BIGSERIAL PRIMARY KEY,
    pair_no      INT NOT NULL,
    item_letter  VARCHAR(1) NOT NULL,   -- A or B
    trait_code   VARCHAR(2) NOT NULL,
    statement    TEXT NOT NULL,
    is_active    BOOLEAN NOT NULL DEFAULT TRUE,
    UNIQUE(pair_no, item_letter)
);

CREATE INDEX idx_papi_q_pair  ON papi_questions(pair_no);
CREATE INDEX idx_papi_q_trait ON papi_questions(trait_code);

-- PAPI descriptions per trait
CREATE TABLE papi_descriptions (
    id          BIGSERIAL PRIMARY KEY,
    trait_code  VARCHAR(2) NOT NULL UNIQUE,
    trait_name  VARCHAR(100) NOT NULL,
    description TEXT,
    high_desc   TEXT,
    low_desc    TEXT
);

-- PAPI results
CREATE TABLE papi_results (
    id              BIGSERIAL PRIMARY KEY,
    auth_user_id    VARCHAR(64) NOT NULL UNIQUE REFERENCES assessment_users(auth_user_id),
    student_name    VARCHAR(255),
    school_name     VARCHAR(255),
    assignment_id   BIGINT REFERENCES test_assignments(id),
    -- trait scores (20 traits, stored as JSONB map trait_code -> score)
    trait_scores    JSONB NOT NULL DEFAULT '{}',
    -- raw answers (JSON array of {pair_no, chosen_letter})
    answers         JSONB,
    completed_at    TIMESTAMP NOT NULL DEFAULT NOW()
);
