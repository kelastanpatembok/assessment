CREATE TABLE IF NOT EXISTS big5_results (
    id               BIGSERIAL PRIMARY KEY,
    auth_user_id     VARCHAR(64)  NOT NULL UNIQUE,
    openness         NUMERIC(6,2) NOT NULL,
    conscientiousness NUMERIC(6,2) NOT NULL,
    extraversion     NUMERIC(6,2) NOT NULL,
    agreeableness    NUMERIC(6,2) NOT NULL,
    neuroticism      NUMERIC(6,2) NOT NULL,
    answers          jsonb,
    completed_at     TIMESTAMP    NOT NULL DEFAULT NOW()
);
