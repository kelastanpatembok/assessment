CREATE TABLE IF NOT EXISTS access_requests (
    id BIGSERIAL PRIMARY KEY,
    auth_user_id VARCHAR(255) NOT NULL,
    requester_name VARCHAR(255) NOT NULL,
    requester_email VARCHAR(255) NOT NULL,
    requested_role VARCHAR(32) NOT NULL CHECK (requested_role IN ('siswa','gurubk','psikolog')),
    school_id BIGINT REFERENCES schools(id),
    note TEXT,
    status VARCHAR(16) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','approved','rejected','cancelled')),
    reviewed_by VARCHAR(255),
    review_note TEXT,
    reviewed_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT access_request_school_required CHECK ((requested_role = 'psikolog' AND school_id IS NULL) OR (requested_role IN ('siswa','gurubk') AND school_id IS NOT NULL))
);
CREATE UNIQUE INDEX IF NOT EXISTS idx_access_requests_one_pending
    ON access_requests(auth_user_id, requested_role, COALESCE(school_id, 0)) WHERE status = 'pending';
CREATE INDEX IF NOT EXISTS idx_access_requests_status_created ON access_requests(status, created_at DESC);

CREATE TABLE IF NOT EXISTS school_registration_requests (
    id BIGSERIAL PRIMARY KEY,
    requester_auth_user_id VARCHAR(255),
    contact_name VARCHAR(255) NOT NULL,
    contact_email VARCHAR(255) NOT NULL,
    school_name VARCHAR(255) NOT NULL,
    npsn VARCHAR(32),
    address TEXT,
    city VARCHAR(128),
    province VARCHAR(128),
    phone VARCHAR(64),
    note TEXT,
    status VARCHAR(16) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','approved','rejected')),
    school_id BIGINT REFERENCES schools(id),
    reviewed_by VARCHAR(255),
    review_note TEXT,
    reviewed_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);
CREATE UNIQUE INDEX IF NOT EXISTS idx_school_registration_pending_npsn
    ON school_registration_requests(npsn) WHERE status = 'pending' AND npsn IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_school_registration_status_created ON school_registration_requests(status, created_at DESC);

ALTER TABLE schools ADD COLUMN IF NOT EXISTS latitude DOUBLE PRECISION;
ALTER TABLE schools ADD COLUMN IF NOT EXISTS longitude DOUBLE PRECISION;
ALTER TABLE schools ADD COLUMN IF NOT EXISTS school_type VARCHAR(32);
CREATE INDEX IF NOT EXISTS idx_schools_map_coordinates ON schools(latitude, longitude) WHERE latitude IS NOT NULL AND longitude IS NOT NULL;
