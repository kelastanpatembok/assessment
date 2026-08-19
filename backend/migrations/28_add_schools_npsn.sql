-- Add NPSN (national school number) so nationwide school imports can be
-- upserted and deduplicated. Nullable: manually-added schools may not have one.
ALTER TABLE schools ADD COLUMN IF NOT EXISTS npsn VARCHAR(20);

-- Allow at most one school per NPSN; NULLs (manual schools) stay unconstrained.
CREATE UNIQUE INDEX IF NOT EXISTS idx_schools_npsn ON schools (npsn) WHERE npsn IS NOT NULL;
