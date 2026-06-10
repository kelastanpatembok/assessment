-- V6: IQ IST (Intelligenz-Struktur-Test) — 9 subtests

-- IST subtests: SE, WA, AN, GE, RA, ZR, FA, WU, ME
-- Each has different question formats and answer types.

-- Main IST question table — for subtests SE/WA/AN/GE/RA/FA
-- subtest_code: SE|WA|AN|GE|RA|FA
-- correct_answer: for single-answer subtests
-- options: JSON for multiple-choice subtests
CREATE TABLE ist_questions (
    id              BIGSERIAL PRIMARY KEY,
    subtest_code    VARCHAR(3) NOT NULL,
    item_no         INT NOT NULL,
    question_text   TEXT,
    image_url       VARCHAR(500),
    options         JSONB,          -- for MC subtests: {"A":"...","B":"...","C":"...","D":"...","E":"..."}
    correct_answer  VARCHAR(20),    -- single letter or short text (SE/WA/AN are free-text checked)
    time_limit_sec  INT,            -- per-item override (for timed subtests)
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    UNIQUE(subtest_code, item_no)
);

CREATE INDEX idx_ist_q_subtest ON ist_questions(subtest_code);

-- ZR subtest has numeric sequence questions with a numeric answer
-- Stored separately as the LEGACY had them as a distinct table
CREATE TABLE ist_zr_questions (
    id              BIGSERIAL PRIMARY KEY,
    item_no         INT NOT NULL UNIQUE,
    sequence_text   TEXT NOT NULL,  -- e.g. "2 4 6 8 ?"
    correct_answer  INT NOT NULL
);

-- ME subtest: word-pair memory (show pairs, then test recall)
-- Stores as JSONB array of {word1, word2, correct_answer}
CREATE TABLE ist_me_pairs (
    id              BIGSERIAL PRIMARY KEY,
    item_no         INT NOT NULL UNIQUE,
    word1           VARCHAR(100) NOT NULL,
    word2           VARCHAR(100) NOT NULL,
    options         JSONB,          -- MC options for recall phase
    correct_answer  VARCHAR(50) NOT NULL
);

-- WU subtest: sentence re-arrangement / logic
CREATE TABLE ist_wu_questions (
    id              BIGSERIAL PRIMARY KEY,
    item_no         INT NOT NULL UNIQUE,
    statement       TEXT NOT NULL,
    correct_answer  VARCHAR(10) NOT NULL  -- "BENAR" or "SALAH"
);

-- IST norma table: convert raw score to Wert (standard score) per subtest
-- used in step 3 of the IST scoring algorithm
CREATE TABLE ist_norma (
    id              BIGSERIAL PRIMARY KEY,
    subtest_code    VARCHAR(3) NOT NULL,
    raw_score       INT NOT NULL,
    wert            INT NOT NULL,
    UNIQUE(subtest_code, raw_score)
);

-- IQ band table: total Wert sum → IQ score range
CREATE TABLE ist_iq_bands (
    id          BIGSERIAL PRIMARY KEY,
    wert_min    INT NOT NULL,
    wert_max    INT NOT NULL,
    iq_min      INT NOT NULL,
    iq_max      INT NOT NULL,
    category    VARCHAR(50),  -- e.g. "Sangat Tinggi","Di Atas Rata-rata","Rata-rata","Di Bawah Rata-rata"
    UNIQUE(wert_min, wert_max)
);

-- IST results
CREATE TABLE ist_results (
    id              BIGSERIAL PRIMARY KEY,
    auth_user_id    VARCHAR(64) NOT NULL UNIQUE REFERENCES assessment_users(auth_user_id),
    student_name    VARCHAR(255),
    school_name     VARCHAR(255),
    assignment_id   BIGINT REFERENCES test_assignments(id),
    -- per-subtest raw scores and wert
    subtest_scores  JSONB NOT NULL DEFAULT '{}', -- {"SE":{"raw":12,"wert":8},...}
    total_wert      INT,
    iq_score        INT,
    iq_category     VARCHAR(50),
    -- raw answers per subtest
    answers         JSONB,
    completed_at    TIMESTAMP NOT NULL DEFAULT NOW()
);
