-- V5: IQ CFIT (Culture Fair Intelligence Test) — 4 subtests

-- CFIT questions: 4 subtests, each with image-based / pattern questions
-- subtest_no: 1–4
-- item_no: within subtest
-- correct_answer: A–E (single letter)
-- options stored as JSONB: {"A":"desc","B":"desc",...}
CREATE TABLE cfit_questions (
    id              BIGSERIAL PRIMARY KEY,
    subtest_no      INT NOT NULL CHECK (subtest_no BETWEEN 1 AND 4),
    item_no         INT NOT NULL,
    question_text   TEXT,
    image_url       VARCHAR(500),   -- optional image path
    options         JSONB,          -- {"A":"...", "B":"...", "C":"...", "D":"..."}
    correct_answer  VARCHAR(1) NOT NULL,
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    UNIQUE(subtest_no, item_no)
);

CREATE INDEX idx_cfit_q_subtest ON cfit_questions(subtest_no);

-- CFIT description table: one entry per score range
CREATE TABLE cfit_descriptions (
    id          BIGSERIAL PRIMARY KEY,
    score_min   INT NOT NULL,
    score_max   INT NOT NULL,
    iq_min      INT,
    iq_max      INT,
    category    VARCHAR(50),  -- e.g. "Sangat Tinggi", "Tinggi", "Rata-rata", "Rendah"
    description TEXT
);

-- CFIT results
CREATE TABLE cfit_results (
    id              BIGSERIAL PRIMARY KEY,
    auth_user_id    VARCHAR(64) NOT NULL UNIQUE REFERENCES assessment_users(auth_user_id),
    student_name    VARCHAR(255),
    school_name     VARCHAR(255),
    assignment_id   BIGINT REFERENCES test_assignments(id),
    -- subtest raw scores
    sub1_score INT NOT NULL DEFAULT 0,
    sub2_score INT NOT NULL DEFAULT 0,
    sub3_score INT NOT NULL DEFAULT 0,
    sub4_score INT NOT NULL DEFAULT 0,
    total_score INT NOT NULL DEFAULT 0,
    iq_score    INT,
    category    VARCHAR(50),
    description TEXT,
    -- raw answers per subtest: {"1":[{"item_no":1,"answer":"A"},...],"2":[...],...}
    answers         JSONB,
    completed_at    TIMESTAMP NOT NULL DEFAULT NOW()
);
