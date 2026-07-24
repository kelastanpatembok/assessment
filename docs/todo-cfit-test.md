# IQ CFIT — What's Missing vs. What We Generated

Status as of the current CFIT rebuild. This documents which parts of the CFIT
test are backed by real source material and which parts are **placeholder
content pending psychologist review**, so a future update knows precisely
what to replace and where.

## Source material available

- `/Users/eko/dev/SuperApp/assessment/upload/fotosoal/` and `.../fotoopsi/` —
  the legacy app's uploaded question/option images (50 stem images, 332
  option images), copied from a photographed CFIT booklet. These are real
  test images.
- `/Users/eko/dev/legacy/Odas+IST` — the legacy Laravel app's **schema and
  view code** (`database/migrations/2024_04_26_113154_create_soal_i_q_s_table.php`,
  `app/Http/Controllers/Superadmin/soalIQController.php`,
  `resources/views/Siswa/Ujian/IQ/*.blade.php`). No production data — only
  structure.

## What's solid (sourced directly, verified)

- **The image assets themselves** — genuinely photographed CFIT test
  material (nonverbal pattern/shape items), not invented.
- **The per-subtest structure**, confirmed from the legacy Blade views:
  - Subtest 1 (Series): stem image + N option images, pick **one**.
  - Subtest 2 (Classification): **no stem image**, N option images, pick the
    **two** that match each other — this is why `cfit_questions` has both
    `correct_answer` and `correct_answer2`.
  - Subtest 3 (Matrices): stem image + N option images, pick **one**.
  - Subtest 4 (Conditions): stem image + N option images, pick **one**.
- **The option-image data model**: legacy `soal_i_q_s.opsi` is a *positional*
  JSON array of image paths — the option "letter" is derived from array
  index (`chr(97+index)` → a, b, c...), not a lettered map. `cfit_questions`
  now mirrors this (`option_images` as a JSONB array).
- **Scoring algorithm** (`CfitScoringService`): sum of correct answers per
  subtest, confirmed against the legacy `ujianController::storeIQ` — matches
  CLAUDE.md §8 exactly, except we score against `correct_answer`/
  `correct_answer2` **server-side on submit**. The legacy app instead baked
  `isCorrect` into the HTML `value` attribute at render time, which leaked
  the answer key into the page source before submission — not carried over.

## Resolved

### The full item bank + real answer key — DONE (2026-07-24)

The user obtained the official answer key (via a Scribd copy of "Kunci
Jawaban Tes Psikotes CFIT", cross-checked item-by-item against a photographed
physical booklet in `~/Downloads/Soal CFIT/{Soal,Jawaban}/`) and asked to
discard the old placeholder set entirely.

**What we did:** confirmed by direct visual comparison that the legacy
`/upload/fotosoal/` + `/upload/fotoopsi/` corpus (50 stem images, 332 option
images — same corpus V15 only sampled 12 items from) is the *exact same*
physical CFIT Skala 3 Bentuk B booklet as the user's new photos, just
already cropped per stem/option instead of full-page photos. Grouped the
corpus by upload timestamp into per-item stem+option sets, matched each
group's content against the new booklet's item order to confirm sequencing,
copied the full set into `frontend/static/cfit/{fotosoal,fotoopsi}/`, and
wrote `V19__cfit_real_answers.sql` (`DELETE FROM cfit_questions` + full
re-seed) using the real answer key.

Final item counts seeded: Subtest 1 = 13, Subtest 2 = **13 of 14** (item
14's images were never uploaded to the legacy corpus, and the new photo set
also didn't capture that page — a genuine source gap, not a transcription
error), Subtest 3 = 13, Subtest 4 = 10. Total 49 items (up from 12).

**Still open:** Subtest 2 item 14 has no source images at all. If the user
later photographs that page (TES 2, continuation past item 6), add it as
`(2, 14, NULL, [...5 option paths...], 'a', 'b')` in a new migration — the
answer for it (from the Scribd key) is **A & B**.

### Score → IQ band calibration

`cfit_descriptions` (score ranges → IQ/category) still holds the placeholder
bands from `V8__seed_sample_data.sql`, calibrated for the *full* ~45-item
instrument — now close to accurate given 49 real items are seeded, but not
re-verified against a real scoring manual. Re-check if a psychologist
provides the real IQ conversion table.
