-- V2: DISC test — questions, scoring lookup tables, results

-- DISC question bank: each row is one "pernyataan" (statement)
-- block_no: grouping number (1-N, each block has 4 items presented together)
-- item_no: position within the block (1–4)
-- category: D | I | S | C
-- column_type: MOST | LEAST (student picks one from each block per column type)
CREATE TABLE disc_questions (
    id           BIGSERIAL PRIMARY KEY,
    block_no     INT NOT NULL,
    item_no      INT NOT NULL,
    category     VARCHAR(1) NOT NULL,           -- D, I, S, C
    statement    TEXT NOT NULL,
    is_active    BOOLEAN NOT NULL DEFAULT TRUE,
    UNIQUE(block_no, item_no)
);

CREATE INDEX idx_disc_q_block ON disc_questions(block_no);

-- DISC MOST scoring: given a D_most, I_most, S_most, C_most combination,
-- look up which personality key applies (there are 64 possible quadrants)
-- Keys stored as short codes, e.g. "D", "DI", "DC", "I", ...
CREATE TABLE disc_scoring_most (
    id        BIGSERIAL PRIMARY KEY,
    d_score   INT NOT NULL,
    i_score   INT NOT NULL,
    s_score   INT NOT NULL,
    c_score   INT NOT NULL,
    key       VARCHAR(10) NOT NULL,
    UNIQUE(d_score, i_score, s_score, c_score)
);

CREATE TABLE disc_scoring_least (
    id        BIGSERIAL PRIMARY KEY,
    d_score   INT NOT NULL,
    i_score   INT NOT NULL,
    s_score   INT NOT NULL,
    c_score   INT NOT NULL,
    key       VARCHAR(10) NOT NULL,
    UNIQUE(d_score, i_score, s_score, c_score)
);

CREATE TABLE disc_scoring_dif (
    id        BIGSERIAL PRIMARY KEY,
    d_score   INT NOT NULL,
    i_score   INT NOT NULL,
    s_score   INT NOT NULL,
    c_score   INT NOT NULL,
    key       VARCHAR(10) NOT NULL,
    UNIQUE(d_score, i_score, s_score, c_score)
);

-- Full personality profiles keyed by 3-part combination (most_key, least_key, dif_key)
CREATE TABLE disc_personality_profiles (
    id           BIGSERIAL PRIMARY KEY,
    most_key     VARCHAR(10) NOT NULL,
    least_key    VARCHAR(10) NOT NULL,
    dif_key      VARCHAR(10) NOT NULL,
    title        VARCHAR(100) NOT NULL,
    description  TEXT,
    UNIQUE(most_key, least_key, dif_key)
);

-- DISC results per student (one result per test_assignment; retake replaces)
CREATE TABLE disc_results (
    id                  BIGSERIAL PRIMARY KEY,
    auth_user_id        VARCHAR(64) NOT NULL UNIQUE REFERENCES assessment_users(auth_user_id),
    student_name        VARCHAR(255),
    school_name         VARCHAR(255),
    assignment_id       BIGINT REFERENCES test_assignments(id),
    -- raw tallies
    d_most INT NOT NULL DEFAULT 0, i_most INT NOT NULL DEFAULT 0,
    s_most INT NOT NULL DEFAULT 0, c_most INT NOT NULL DEFAULT 0,
    d_least INT NOT NULL DEFAULT 0, i_least INT NOT NULL DEFAULT 0,
    s_least INT NOT NULL DEFAULT 0, c_least INT NOT NULL DEFAULT 0,
    d_dif INT NOT NULL DEFAULT 0, i_dif INT NOT NULL DEFAULT 0,
    s_dif INT NOT NULL DEFAULT 0, c_dif INT NOT NULL DEFAULT 0,
    -- derived keys
    most_key    VARCHAR(10),
    least_key   VARCHAR(10),
    dif_key     VARCHAR(10),
    -- profile
    profile_title   VARCHAR(100),
    profile_desc    TEXT,
    -- raw answers (JSON array of {block_no, most_item_no, least_item_no})
    answers         JSONB,
    completed_at    TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_disc_results_user ON disc_results(auth_user_id);
