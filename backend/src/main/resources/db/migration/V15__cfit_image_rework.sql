-- V15: Rework IQ CFIT to match the real instrument structure found in the legacy
-- source (~/dev/legacy/Odas+IST — database/migrations/2024_04_26_113154_create_soal_i_q_s_table.php
-- + app/Http/Controllers/Superadmin/soalIQController.php + resources/views/Siswa/Ujian/IQ/*.blade.php).
--
-- CFIT is entirely image-based (culture-fair, nonverbal) — every subtest presents pictures,
-- never vocabulary/word items. The legacy schema stored:
--   soal   -> path to a single STEM image (nullable — Subtest 2 has no stem, see below)
--   opsi   -> {"opsi": [path, path, ...]}  a POSITIONAL array of OPTION images (not lettered A/B/C/D;
--             the option letter is derived from array index: chr(97+index) -> a, b, c...)
--   jawaban / jawaban2 -> correct option letter(s). jawaban2 is only ever used by Subtest 2.
--
-- The 4 subtests are NOT identical multiple-choice — confirmed from the Blade views:
--   Subtest 1 (Series):          stem image + N option images, pick ONE.
--   Subtest 2 (Classification):  NO stem image, only option images, pick the TWO that match
--                                 each other (out of the rest) — hence jawaban + jawaban2.
--   Subtest 3 (Matrices):        stem image + N option images, pick ONE.
--   Subtest 4 (Conditions):      stem image + N option images, pick ONE.
--
-- Supersedes the placeholder text-based schema/seed from V5__cfit.sql + V8__seed_sample_data.sql:
-- those invented verbal items (antonyms, geometry word problems) that aren't the right *kind* of
-- content for a nonverbal test, and stored options as a lettered JSONB text map, which doesn't
-- match how the real instrument is structured and was also the root cause of a separate
-- serialization bug (options rendered as a raw JSON string, one character per "option").
--
-- Real per-item content (which image is the correct answer) was never available — the legacy
-- migrations only define schema, no seeders touch soal_i_q_s, and no production DB dump exists
-- in this workspace. This migration seeds a small SAMPLE of real, actually-migrated images
-- (from /Users/eko/dev/SuperApp/assessment/upload, copied into frontend/static/cfit/) with
-- PLACEHOLDER correct answers (always option "a", or "a"+"b" for Subtest 2) — same class of gap
-- as PAPI Kostick, see docs/todo-papi-test.md and the CFIT counterpart docs/todo-cfit-test.md.

DROP TABLE IF EXISTS cfit_questions;

CREATE TABLE cfit_questions (
    id                BIGSERIAL PRIMARY KEY,
    subtest_no        INT NOT NULL CHECK (subtest_no BETWEEN 1 AND 4),
    item_no           INT NOT NULL,
    stem_image_url    VARCHAR(500),   -- nullable: Subtest 2 items have no stem image
    option_images     JSONB NOT NULL, -- positional array of option image paths; letter = index (a, b, c...)
    correct_answer    VARCHAR(1) NOT NULL,
    correct_answer2   VARCHAR(1),     -- Subtest 2 only: the second required correct letter
    is_active         BOOLEAN NOT NULL DEFAULT TRUE,
    UNIQUE(subtest_no, item_no)
);

CREATE INDEX idx_cfit_q_subtest ON cfit_questions(subtest_no);

-- Subtest 1 (Series) — stem + 6 options, pick 1. Placeholder answer: "a".
INSERT INTO cfit_questions (subtest_no, item_no, stem_image_url, option_images, correct_answer) VALUES
(1, 1, '/cfit/fotosoal/1715151808fotosoalsoal1.png',
 '["/cfit/fotoopsi/1715151808fotoopsia.png","/cfit/fotoopsi/1715151808fotoopsib.png","/cfit/fotoopsi/1715151808fotoopsic.png","/cfit/fotoopsi/1715151808fotoopsid.png","/cfit/fotoopsi/1715151808fotoopsie.png","/cfit/fotoopsi/1715151808fotoopsif.png"]',
 'a'),
(1, 2, '/cfit/fotosoal/1715151968fotosoalsoal4.png',
 '["/cfit/fotoopsi/1715151968fotoopsia.png","/cfit/fotoopsi/1715151968fotoopsib.png","/cfit/fotoopsi/1715151968fotoopsic.png","/cfit/fotoopsi/1715151968fotoopsid.png","/cfit/fotoopsi/1715151968fotoopsie.png","/cfit/fotoopsi/1715151968fotoopsif.png"]',
 'a'),
(1, 3, '/cfit/fotosoal/1715152018fotosoalsoal5.png',
 '["/cfit/fotoopsi/1715152018fotoopsia.png","/cfit/fotoopsi/1715152018fotoopsib.png","/cfit/fotoopsi/1715152018fotoopsic.png","/cfit/fotoopsi/1715152018fotoopsid.png","/cfit/fotoopsi/1715152018fotoopsie.png","/cfit/fotoopsi/1715152018fotoopsif.png"]',
 'a');

-- Subtest 2 (Classification) — no stem, 5 options, pick the 2 that match. Placeholder answer: "a"+"b".
INSERT INTO cfit_questions (subtest_no, item_no, stem_image_url, option_images, correct_answer, correct_answer2) VALUES
(2, 1, NULL,
 '["/cfit/fotoopsi/1715152477fotoopsia.png","/cfit/fotoopsi/1715152477fotoopsib.png","/cfit/fotoopsi/1715152477fotoopsic.png","/cfit/fotoopsi/1715152477fotoopsid.png","/cfit/fotoopsi/1715152477fotoopsie.png"]',
 'a', 'b'),
(2, 2, NULL,
 '["/cfit/fotoopsi/1715152766fotoopsia.png","/cfit/fotoopsi/1715152766fotoopsib.png","/cfit/fotoopsi/1715152766fotoopsic.png","/cfit/fotoopsi/1715152766fotoopsid.png","/cfit/fotoopsi/1715152766fotoopsie.png"]',
 'a', 'b'),
(2, 3, NULL,
 '["/cfit/fotoopsi/1715152800fotoopsia.png","/cfit/fotoopsi/1715152800fotoopsib.png","/cfit/fotoopsi/1715152800fotoopsic.png","/cfit/fotoopsi/1715152800fotoopsid.png","/cfit/fotoopsi/1715152800fotoopsie.png"]',
 'a', 'b');

-- Subtest 3 (Matrices) — stem + 6 options, pick 1. Placeholder answer: "a".
INSERT INTO cfit_questions (subtest_no, item_no, stem_image_url, option_images, correct_answer) VALUES
(3, 1, '/cfit/fotosoal/1715153236fotosoalsoal1.png',
 '["/cfit/fotoopsi/1715153236fotoopsia.png","/cfit/fotoopsi/1715153236fotoopsib.png","/cfit/fotoopsi/1715153236fotoopsic.png","/cfit/fotoopsi/1715153236fotoopsid.png","/cfit/fotoopsi/1715153236fotoopsie.png","/cfit/fotoopsi/1715153236fotoopsif.png"]',
 'a'),
(3, 2, '/cfit/fotosoal/1715153277fotosoalsoal2.png',
 '["/cfit/fotoopsi/1715153277fotoopsia.png","/cfit/fotoopsi/1715153277fotoopsib.png","/cfit/fotoopsi/1715153277fotoopsic.png","/cfit/fotoopsi/1715153277fotoopsid.png","/cfit/fotoopsi/1715153277fotoopsie.png","/cfit/fotoopsi/1715153277fotoopsif.png"]',
 'a'),
(3, 3, '/cfit/fotosoal/1715153321fotosoalsoal3.png',
 '["/cfit/fotoopsi/1715153321fotoopsia.png","/cfit/fotoopsi/1715153321fotoopsib.png","/cfit/fotoopsi/1715153321fotoopsic.png","/cfit/fotoopsi/1715153321fotoopsid.png","/cfit/fotoopsi/1715153321fotoopsie.png","/cfit/fotoopsi/1715153321fotoopsif.png"]',
 'a');

-- Subtest 4 (Conditions) — stem + 5 options, pick 1. Placeholder answer: "a".
INSERT INTO cfit_questions (subtest_no, item_no, stem_image_url, option_images, correct_answer) VALUES
(4, 1, '/cfit/fotosoal/1715153752fotosoalsoal1.png',
 '["/cfit/fotoopsi/1715153752fotoopsia.png","/cfit/fotoopsi/1715153752fotoopsib.png","/cfit/fotoopsi/1715153752fotoopsic.png","/cfit/fotoopsi/1715153752fotoopsid.png","/cfit/fotoopsi/1715153752fotoopsie.png"]',
 'a'),
(4, 2, '/cfit/fotosoal/1715153782fotosoalsoal2.png',
 '["/cfit/fotoopsi/1715153782fotoopsia.png","/cfit/fotoopsi/1715153782fotoopsib.png","/cfit/fotoopsi/1715153782fotoopsic.png","/cfit/fotoopsi/1715153782fotoopsid.png","/cfit/fotoopsi/1715153782fotoopsie.png"]',
 'a'),
(4, 3, '/cfit/fotosoal/1715153816fotosoalsoal3.png',
 '["/cfit/fotoopsi/1715153816fotoopsia.png","/cfit/fotoopsi/1715153816fotoopsib.png","/cfit/fotoopsi/1715153816fotoopsic.png","/cfit/fotoopsi/1715153816fotoopsid.png","/cfit/fotoopsi/1715153816fotoopsie.png"]',
 'a');
