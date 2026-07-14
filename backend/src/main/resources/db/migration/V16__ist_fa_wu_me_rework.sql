-- V16: Fix IQ IST Subtests FA, WU, ME to match the real instrument, mirroring the
-- CFIT image rework (V15) — confirmed against the legacy source
-- (~/dev/legacy/Odas+IST — database/migrations/2024_05_30_154714_create_soal_iq_ists_table.php
-- + app/Http/Controllers/Superadmin/soalIQISTController.php
-- + resources/views/Siswa/Ujian/IST/tesIQIST.blade.php).
--
-- All 9 IST subtests live in ONE generic table in the legacy app (soal_iq_ists), with
-- soal/opsi for text items and soal_foto/opsi_foto for image items — never a per-subtest
-- table. The previous iteration invented three subtest-specific tables that don't match:
--
--   - ist_wu_questions: fabricated WU as true/false general-knowledge trivia
--     ("Semua mamalia adalah hewan berdarah panas" -> BENAR/SALAH). The real WU
--     (Wuerfelaufgaben) is an image-based cube-rotation test — confirmed by opening
--     actual images from /Users/eko/dev/SuperApp/assessment/upload/fotosoalist: item 150
--     is a 3D cube with distinct face markings, exactly the classic Amthauer IST design.
--     There is no true/false concept anywhere in the legacy source for WU.
--   - ist_me_pairs: fabricated ME as a memorize-pairs-then-recall UI phase. The legacy
--     blade view (tesIQIST.blade.php step-9) shows ME is just a plain single-answer MC
--     question, identical in shape to SE/WA/AN — no "memorize this" phase exists.
--   - FA routed through the generic ist_questions table (which already has image_url/
--     options columns) but only ever had ONE fake seed row with no image and no options
--     at all — confirmed real images exist: item 117 is a sliced-circle shape-completion
--     figure (Figurenauswahl).
--
-- This migration drops the two fabricated tables and folds FA/WU/ME back into the
-- generic ist_questions table, adding option_images (positional JSONB array, same
-- convention as cfit_questions.option_images) for the two image-based subtests (FA, WU).
--
-- Real answer keys for FA/WU still don't exist anywhere in this workspace (same class of
-- gap as CFIT/PAPI) — seeded with placeholder answers, documented in docs/todo-ist-test.md.

DROP TABLE IF EXISTS ist_wu_questions;
DROP TABLE IF EXISTS ist_me_pairs;

ALTER TABLE ist_questions ADD COLUMN option_images JSONB;

-- Remove the old placeholder FA row (no image, no options) — real image-based rows
-- are inserted below.
DELETE FROM ist_questions WHERE subtest_code = 'FA';

-- FA (Figurenauswahl / figure selection) — stem + 5 option images, pick 1.
-- Placeholder answer: "a".
INSERT INTO ist_questions (subtest_code, item_no, image_url, option_images, correct_answer) VALUES
('FA', 1, '/ist/fotosoalist/1719046295fotosoalist117.png',
 '["/ist/fotoopsiist/1719046295fotoopsiist117 a.png","/ist/fotoopsiist/1719046295fotoopsiist117 b.png","/ist/fotoopsiist/1719046295fotoopsiist117 c.png","/ist/fotoopsiist/1719046295fotoopsiist117 d.png","/ist/fotoopsiist/1719046295fotoopsiist117 e.png"]',
 'a'),
('FA', 2, '/ist/fotosoalist/1719046402fotosoalist119.png',
 '["/ist/fotoopsiist/1719046402fotoopsiist117 a.png","/ist/fotoopsiist/1719046402fotoopsiist117 b.png","/ist/fotoopsiist/1719046402fotoopsiist117 c.png","/ist/fotoopsiist/1719046402fotoopsiist117 d.png","/ist/fotoopsiist/1719046402fotoopsiist117 e.png"]',
 'a'),
('FA', 3, '/ist/fotosoalist/1719046483fotosoalist121.png',
 '["/ist/fotoopsiist/1719046483fotoopsiist117 a.png","/ist/fotoopsiist/1719046483fotoopsiist117 b.png","/ist/fotoopsiist/1719046483fotoopsiist117 c.png","/ist/fotoopsiist/1719046483fotoopsiist117 d.png","/ist/fotoopsiist/1719046483fotoopsiist117 e.png"]',
 'a');

-- WU (Wuerfelaufgaben / cube rotation) — stem + 5 option images, pick 1.
-- Placeholder answer: "a".
INSERT INTO ist_questions (subtest_code, item_no, image_url, option_images, correct_answer) VALUES
('WU', 1, '/ist/fotosoalist/1719051978fotosoalist138.png',
 '["/ist/fotoopsiist/1719051978fotoopsiista.png","/ist/fotoopsiist/1719051978fotoopsiistb.png","/ist/fotoopsiist/1719051978fotoopsiistc.png","/ist/fotoopsiist/1719051978fotoopsiistd.png","/ist/fotoopsiist/1719051978fotoopsiiste.png"]',
 'a'),
('WU', 2, '/ist/fotosoalist/1719058786fotosoalist140.png',
 '["/ist/fotoopsiist/1719058786fotoopsiista.png","/ist/fotoopsiist/1719058786fotoopsiistb.png","/ist/fotoopsiist/1719058786fotoopsiistc.png","/ist/fotoopsiist/1719058786fotoopsiistd.png","/ist/fotoopsiist/1719058786fotoopsiiste.png"]',
 'a'),
('WU', 3, '/ist/fotosoalist/1719059731fotosoalist150.png',
 '["/ist/fotoopsiist/1719059731fotoopsiista.png","/ist/fotoopsiist/1719059731fotoopsiistb.png","/ist/fotoopsiist/1719059731fotoopsiistc.png","/ist/fotoopsiist/1719059731fotoopsiistd.png","/ist/fotoopsiist/1719059731fotoopsiiste.png"]',
 'a');

-- ME (Merkaufgaben) — plain single-answer MC, same shape as SE/WA/AN (legacy has no
-- memorize-then-recall UI phase — that was fabricated by the previous iteration). No
-- source material exists for real content (same as SE/WA/AN/GE/RA), so this is dev
-- placeholder text like the others.
INSERT INTO ist_questions (subtest_code, item_no, question_text, options, correct_answer) VALUES
('ME', 1, 'Kata yang paling berkaitan dengan "Meja" adalah?',
 '{"A":"Kursi","B":"Lemari","C":"Sofa","D":"Kasur"}', 'A'),
('ME', 2, 'Kata yang paling berkaitan dengan "Buku" adalah?',
 '{"A":"Penghapus","B":"Pensil","C":"Pulpen","D":"Kertas"}', 'B'),
('ME', 3, 'Kata yang paling berkaitan dengan "Langit" adalah?',
 '{"A":"Putih","B":"Abu-abu","C":"Biru","D":"Hitam"}', 'C');
