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

## What's missing (blockers)

### The actual answer key

Neither the legacy migrations nor any data dump in this workspace contains
the real `jawaban`/`jawaban2` values — Laravel migrations only define
schema, and `database/seeds/` never touches `soal_i_q_s`. The production
answer key only ever lived in the old MySQL rows, which don't exist here.

**What we did instead:** migrated a small **sample** of 12 real images (3
per subtest) from `/upload` into `frontend/static/cfit/` and seeded
`cfit_questions` (`V15__cfit_image_rework.sql`) with them, using a
placeholder answer key — always option "a" (and "b" for Subtest 2's second
pick). The images are real; the correct answers are **not**.

**To fix:** get the real answer key from a psychologist (or the original
CFIT test manual, since this is a standard published instrument — Cattell's
Culture Fair Intelligence Test — and the manual's scoring key may already be
available independent of the old production DB). Then:
1. Replace the placeholder `correct_answer`/`correct_answer2` values in
   `V15__cfit_image_rework.sql`.
2. Optionally migrate more of the ~50/332 images in `/upload` into
   `frontend/static/cfit/` and add the corresponding rows — the schema
   already supports the full set, we only seeded a sample.

### Score → IQ band calibration

`cfit_descriptions` (score ranges → IQ/category) still holds the placeholder
bands from `V8__seed_sample_data.sql`, calibrated for the *full* ~45-item
instrument. With only 12 sample items seeded, a perfect score won't reach
the "Sangat Tinggi" band — this is expected until the full item bank (with
a real answer key) is in place. No fix needed for the sample; re-verify
once the real answer key + full item set are seeded.

## How to replace

1. Edit `backend/src/main/resources/db/migration/V15__cfit_image_rework.sql`
   (or add a new migration — Flyway migrations already applied to a running
   DB shouldn't be edited in place; add `V16__cfit_real_answers.sql` instead
   once there's a real answer key).
2. Copy any additional images from `/Users/eko/dev/SuperApp/assessment/upload/`
   into `frontend/static/cfit/fotosoal/` and `.../fotoopsi/`, referenced by
   `/cfit/fotosoal/<file>` / `/cfit/fotoopsi/<file>` paths in `option_images`
   / `stem_image_url`.
3. No Java or frontend code changes are needed — `CfitQuestion`,
   `CfitScoringService`, and the exam UI already work against the real
   per-subtest structure; only the seeded rows need updating.
