-- V12: persist the converted (normalized) D/I/S/C values used by
-- DiscPatternClassifier, so the result page can render the classic DISC
-- line graphs (Psikogram report's GRAPH 1 MOST / GRAPH 2 LEAST /
-- GRAPH 3 CHANGE) — these plot the converted scores, not the raw tallies
-- already stored in d_most/i_most/etc.

ALTER TABLE disc_results
    ADD COLUMN most_d_conv  NUMERIC(4,2),
    ADD COLUMN most_i_conv  NUMERIC(4,2),
    ADD COLUMN most_s_conv  NUMERIC(4,2),
    ADD COLUMN most_c_conv  NUMERIC(4,2),
    ADD COLUMN least_d_conv NUMERIC(4,2),
    ADD COLUMN least_i_conv NUMERIC(4,2),
    ADD COLUMN least_s_conv NUMERIC(4,2),
    ADD COLUMN least_c_conv NUMERIC(4,2),
    ADD COLUMN dif_d_conv   NUMERIC(4,2),
    ADD COLUMN dif_i_conv   NUMERIC(4,2),
    ADD COLUMN dif_s_conv   NUMERIC(4,2),
    ADD COLUMN dif_c_conv   NUMERIC(4,2);

-- Dev-only data; existing rows predate these columns and are otherwise
-- worthless to keep (per the standing "no need to preserve data" call).
TRUNCATE TABLE disc_results RESTART IDENTITY;
