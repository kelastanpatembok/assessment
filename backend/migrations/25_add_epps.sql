CREATE TABLE IF NOT EXISTS epps_results (
    id BIGSERIAL PRIMARY KEY,
    auth_user_id VARCHAR(64) NOT NULL UNIQUE,
    student_name VARCHAR(255),
    school_name VARCHAR(255),
    assignment_id BIGINT,
    gender VARCHAR(16) NOT NULL,
    trait_scores JSONB NOT NULL DEFAULT '{}'::jsonb,
    consistency_raw INTEGER NOT NULL,
    consistency_percentile INTEGER NOT NULL,
    answers JSONB NOT NULL,
    completed_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_epps_results_assignment ON epps_results(assignment_id);
