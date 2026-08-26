-- Versioned, superadmin-owned rubric for the combined individual report.
-- A report keeps the rule version used when it was first issued, so changing
-- a rubric never rewrites an already official document.
CREATE TABLE IF NOT EXISTS psychological_report_rule_sets (
    id BIGSERIAL PRIMARY KEY,
    version INTEGER NOT NULL UNIQUE,
    rules JSONB NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_by VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_psychological_report_one_active_rule_set
    ON psychological_report_rule_sets ((is_active)) WHERE is_active = TRUE;

-- Immutable identity for an official individual report. The PDF is rendered
-- freshly so its print timestamp is current, while its report number and
-- issue date remain stable.
CREATE TABLE IF NOT EXISTS psychological_report_issues (
    id BIGSERIAL PRIMARY KEY,
    report_no VARCHAR(80) NOT NULL UNIQUE,
    assignment_id BIGINT NOT NULL REFERENCES test_assignments(id),
    student_id VARCHAR(255) NOT NULL REFERENCES assessment_users(auth_user_id),
    school_id BIGINT NOT NULL REFERENCES schools(id),
    rule_version INTEGER NOT NULL,
    issued_by VARCHAR(255) NOT NULL,
    issued_at TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE (assignment_id, student_id, rule_version)
);

CREATE INDEX IF NOT EXISTS idx_psychological_report_issue_student
    ON psychological_report_issues(student_id, issued_at DESC);
CREATE INDEX IF NOT EXISTS idx_psychological_report_issue_school
    ON psychological_report_issues(school_id, issued_at DESC);

CREATE TABLE IF NOT EXISTS psychological_report_downloads (
    id BIGSERIAL PRIMARY KEY,
    issue_id BIGINT NOT NULL REFERENCES psychological_report_issues(id) ON DELETE CASCADE,
    downloaded_by VARCHAR(255) NOT NULL,
    downloaded_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- A transparent initial version gives every deployment the documented mapping
-- from the assessment design. Superadmin can revise it in Rubrik Laporan;
-- later PDF issues retain their version number.
INSERT INTO psychological_report_rule_sets (version, rules, is_active, created_by)
VALUES (1, '{"note":"Rubrik awal berdasarkan definisi laporan; dapat dikonfigurasi superadmin.","aspects":[{"key":"intellectual","label":"Kemampuan intelektual dan logika berpikir","sources":["CFIT/IST"]},{"key":"achievement","label":"Motivasi berprestasi","sources":["PAPI N/G/A","EPPS Achievement"]},{"key":"confidence","label":"Kepercayaan diri","sources":["DISC D/C"]},{"key":"emotion","label":"Stabilitas emosi","sources":["PAPI Z/E/K","EPPS Endurance"]},{"key":"adjustment","label":"Penyesuaian diri","sources":["PAPI O/B/S/X","EPPS Affiliation"]}]}', true, 'system')
ON CONFLICT (version) DO NOTHING;
