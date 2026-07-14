# IQ IST — What's Missing vs. What We Generated

Status as of the current IST rebuild. Companion to `docs/todo-cfit-test.md` — same
class of gap, different instrument. This documents which subtests are backed by real
source material and which are placeholder, so a future update knows precisely what to
replace and where.

## Source material available

- `/Users/eko/dev/SuperApp/assessment/upload/fotosoalist/` and `.../fotoopsiist/` —
  the legacy app's uploaded question/option images (48 stems, 248 options).
- `/Users/eko/dev/legacy/Odas+IST` — the legacy Laravel app's schema and view code
  (`database/migrations/2024_05_30_154714_create_soal_iq_ists_table.php`,
  `app/Http/Controllers/Superadmin/soalIQISTController.php`,
  `resources/views/Siswa/Ujian/IST/tesIQIST.blade.php`). No production data.

## What changed in this rework (V16__ist_fa_wu_me_rework.sql)

The previous iteration invented three subtest designs that don't match the legacy
source at all:

- **WU** was a fabricated true/false general-knowledge quiz ("Semua mamalia adalah
  hewan berdarah panas" → BENAR/SALAH). The real WU (Würfelaufgaben) is an
  **image-based cube-rotation test** — confirmed by opening actual images: item 150
  is a 3D cube with distinct face markings, the classic Amthauer IST design. There is
  no true/false concept anywhere in the legacy source for WU.
- **ME** was a fabricated "memorize these word pairs, then recall" UI phase. The
  legacy Blade view (`tesIQIST.blade.php`, step-9) shows ME is just a **plain
  single-answer MC question**, identical in shape to SE/WA/AN — no memorize phase
  exists in the legacy app.
- **FA** routed through the generic `ist_questions` table (which does have
  `image_url`/`options` columns) but only had one fake seed row with no image and no
  options. Real images exist: item 117 is a sliced-circle shape-completion figure
  (Figurenauswahl).

All three now fold back into the generic `ist_questions` table (matching the legacy's
single-table `soal_iq_ists` design), with a new `option_images` JSONB column (positional
array, same convention as `cfit_questions.option_images`) for the two genuinely
image-based subtests, FA and WU. The `ist_wu_questions` and `ist_me_pairs` tables were
dropped.

This also fixed a latent bug shared with CFIT's original implementation:
`IstQuestion.options` was mapped as a raw Java `String`, so any subtest that populated
it would have hit the exact same "options render as individual characters" bug fixed
in CFIT (see `docs/todo-cfit-test.md`). It's now a proper `Map<String,String>`. The
`/ist/questions` endpoint was also leaking `correct_answer` to the client for every
subtest (and `ist_zr_questions.correct_answer` too) — both now go through masked view
DTOs (`IstQuestionView`, `IstZrQuestionView`) that omit the answer key, matching the
fix already applied to `/cfit/questions`.

## What's missing (blockers)

### The real FA/WU answer key

Same blocker as CFIT: no production DB dump exists anywhere in this workspace, and the
legacy Laravel migrations only define schema — `database/seeds/` never touches
`soal_iq_ists`. **What we did instead:** migrated 3 real images each for FA and WU
(from `/upload/fotosoalist` + `/upload/fotoopsiist`, timestamps 117/119/121 for FA and
138/140/150 for WU) into `frontend/static/ist/`, seeded with a placeholder answer key
(always option "a"). The images are real; the correct answers are not.

**To fix:** get the real answer key from a psychologist or the official IST manual
(Amthauer's Intelligenz-Struktur-Test), then replace the placeholder `correct_answer`
values for FA/WU in a new migration (don't edit `V16` in place once applied — see
`docs/todo-cfit-test.md`'s "How to replace" section, same procedure applies here).
More of the 48/248 images in `/upload` can be migrated the same way to expand past the
3-item sample per subtest.

### SE / WA / AN / GE / RA / ME text content

No source document exists for IST (no `ist.pdf` equivalent to `docs/papi.pdf` or
`docs/Holland.pdf`) — these six subtests' question text was placeholder before this
rework and remains placeholder; this rework did not touch their content, only ME's
*structure* (removed the fabricated memorize phase, kept it as simple placeholder MC
like the others).

### GE tiered scoring — known gap, NOT fixed in this pass

CLAUDE.md's own domain model (§7–§8) specifies Subtest 4 (GE) should be a **separate
tiered-scoring table** (`ist_subtest4_questions`, matching legacy `soal_ist_tes4s`:
free-text answer, full credit / partial credit / zero credit via `jawaban`/`jawaban2`/
`jawaban3`). The current implementation still treats GE as a plain multiple-choice
question scored by `scoreStandard` (exact string match, single credit tier) — this was
already the case before this rework and was out of scope for the FA/WU/ME fix. Flagged
here for a future pass; not touched to avoid scope creep beyond what was requested.

## How to replace FA/WU content

1. Add a new migration (e.g. `V17__ist_real_answers.sql`) updating `correct_answer` for
   the `FA`/`WU` rows in `ist_questions`, and/or inserting more rows sourced from
   additional images in `/upload/fotosoalist` + `/upload/fotoopsiist`.
2. Copy any additional images into `frontend/static/ist/fotosoalist/` and
   `.../fotoopsiist/`, referenced by `/ist/fotosoalist/<file>` / `/ist/fotoopsiist/<file>`
   paths in `option_images` / `image_url`.
3. No Java or frontend code changes needed — `IstQuestion`, `IstScoringService`, and the
   exam UI already work against the real per-subtest structure; only the seeded rows
   need updating.
