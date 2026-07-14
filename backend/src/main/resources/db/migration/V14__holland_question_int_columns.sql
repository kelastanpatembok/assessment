-- Hibernate maps the HollandQuestion entity's `round`/`itemNo` (java.lang.Integer)
-- to SQL INTEGER by default; V13 declared them SMALLINT, which fails schema
-- validation on boot ("wrong column type ... found int2, but expecting integer").
ALTER TABLE holland_questions ALTER COLUMN round TYPE INTEGER;
ALTER TABLE holland_questions ALTER COLUMN item_no TYPE INTEGER;
