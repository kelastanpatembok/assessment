-- V1: Core tables — schools, users, test categories, assignments, activity log

CREATE TABLE schools (
    id          BIGSERIAL PRIMARY KEY,
    name        VARCHAR(255) NOT NULL,
    address     TEXT,
    city        VARCHAR(100),
    province    VARCHAR(100),
    phone       VARCHAR(30),
    email       VARCHAR(255),
    created_at  TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMP NOT NULL DEFAULT NOW()
);

-- assessment_users links an auth-server userId to an assessment-domain profile
CREATE TABLE assessment_users (
    auth_user_id  VARCHAR(64) PRIMARY KEY,   -- MongoDB ObjectId from auth server
    name          VARCHAR(255) NOT NULL,
    email         VARCHAR(255) NOT NULL,
    username      VARCHAR(100) NOT NULL,
    role          VARCHAR(30)  NOT NULL,     -- superadmin | gurubk | siswa | afiliator
    school_id     BIGINT REFERENCES schools(id) ON DELETE SET NULL,
    afiliator_id  VARCHAR(64),               -- auth_user_id of the sponsoring afiliator
    created_at    TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_assessment_users_school  ON assessment_users(school_id);
CREATE INDEX idx_assessment_users_role    ON assessment_users(role);
CREATE INDEX idx_assessment_users_afil    ON assessment_users(afiliator_id);

-- test_categories: the 25 ODAS+ bundles (each maps to one or more test types)
CREATE TABLE test_categories (
    id          BIGSERIAL PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    slug        VARCHAR(100) NOT NULL UNIQUE,  -- e.g. "paket-a", "ist-only"
    description TEXT,
    tests       TEXT[] NOT NULL DEFAULT '{}',  -- e.g. {'disc','holland','papi','cfit','ist'}
    price       NUMERIC(14,2) NOT NULL DEFAULT 0,
    is_active   BOOLEAN NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMP NOT NULL DEFAULT NOW()
);

-- test_assignments: which students (or whole schools) may take which category in which window
CREATE TABLE test_assignments (
    id             BIGSERIAL PRIMARY KEY,
    category_id    BIGINT NOT NULL REFERENCES test_categories(id),
    school_id      BIGINT REFERENCES schools(id) ON DELETE CASCADE,
    student_id     VARCHAR(64) REFERENCES assessment_users(auth_user_id) ON DELETE CASCADE,
    assigned_by    VARCHAR(64) NOT NULL,  -- auth_user_id of gurubk/superadmin
    window_start   TIMESTAMP,
    window_end     TIMESTAMP,
    is_active      BOOLEAN NOT NULL DEFAULT TRUE,
    created_at     TIMESTAMP NOT NULL DEFAULT NOW(),
    -- At least one of school_id or student_id must be set (enforced at app level)
    CONSTRAINT ck_assignment_target CHECK (school_id IS NOT NULL OR student_id IS NOT NULL)
);

CREATE INDEX idx_assignments_category ON test_assignments(category_id);
CREATE INDEX idx_assignments_school   ON test_assignments(school_id);
CREATE INDEX idx_assignments_student  ON test_assignments(student_id);
