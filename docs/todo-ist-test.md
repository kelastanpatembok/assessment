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

## FA / WU — now fully real (V17__ist_fa_wu_real_answers.sql)

`docs/ist-result.docx` ("KUNCI JAWABAN IST") surfaced after the initial rework — a
genuine answer key covering items 1–176 across SE/WA/AN/RA/ZR/FA/WU/ME (GE is absent
from it, consistent with GE needing the separate tiered free-text model, see below).
Cross-referencing item numbers against `/upload/fotosoalist` confirmed FA = items
117–136 and WU = items 137–156, each with a complete stem + 5 option images. All 40
images check out with matching option sets, so **V17 replaced the 3-item placeholder
sample with the complete, real 20-item FA and 20-item WU subtests** — real images *and*
real answers, no more placeholders for these two.

More images exist in `/upload/fotosoalist` + `/upload/fotoopsiist` beyond 117–156 (an
earlier, messier batch of test/duplicate uploads around item "soal1–6") — not used,
since they don't correspond to any item number in the answer key.

### SE / WA / AN / RA / ZR / ME — answers now known, question text still missing

The same `ist-result.docx` also gives the real answer key for these six subtests,
confirming their real format: SE/WA/AN/ME are single-letter MC (items 1–20, 21–40,
41–60, 157–176), RA/ZR are numeric free-text (items 77–96, 97–116). **No source
document with the actual question/option text exists yet** (no `ist.pdf` equivalent to
`docs/papi.pdf` or `docs/Holland.pdf`), so seeding real MC option text isn't possible
yet — these six subtests keep placeholder question text. Recording the full answer key
here now so it isn't lost once the real question booklet turns up:

```
SE (1-20):  E C D D D B C A E B C D D E C A B B C B
WA (21-40): B B D C C C C D D A E A A B C A D E B C
AN (41-60): C E D D D A D B E D C C C C D C C D E E
RA (77-96, numeric): 35 280 205 26 30 70 45 50 84 78 19 6 75 90 120 17 24 5 48 3
ZR (97-116, numeric): 27 25 27 15 46 10 42 7 5 14 8 14 45 63 12 80 14 12 63 10
ME (157-176): D E B A C A D E C B B A E C D B E A C D
```
(Each list reads left-to-right in ascending item-number order within its range.)

### GE — no answer key here either, consistent with the tiered-scoring gap below

GE (items 61–76, the gap between AN and RA in the answer key) has no entry in
`ist-result.docx` at all — it can't have a single fixed MC answer per item, which lines
up with GE needing tiered free-text scoring rather than exact-match MC (see below).

### GE tiered scoring — known gap, NOT fixed in this pass

CLAUDE.md's own domain model (§7–§8) specifies Subtest 4 (GE) should be a **separate
tiered-scoring table** (`ist_subtest4_questions`, matching legacy `soal_ist_tes4s`:
free-text answer, full credit / partial credit / zero credit via `jawaban`/`jawaban2`/
`jawaban3`). The current implementation still treats GE as a plain multiple-choice
question scored by `scoreStandard` (exact string match, single credit tier) — this was
already the case before this rework and was out of scope for the FA/WU/ME fix. Flagged
here for a future pass; not touched to avoid scope creep beyond what was requested.

## How to add real text once the question booklet is found

1. Add a new migration updating `question_text`/`options` for the `SE`/`WA`/`AN`/`ME`
   rows (and `question_text` for `RA`/`ZR`) in `ist_questions` — the answer key above
   already tells you what `correct_answer` should be for each item number, so only the
   question/option text needs filling in.
2. For GE, see the tiered-scoring gap above — that needs a schema addition
   (`ist_subtest4_questions`-equivalent), not just a data update.
3. No Java or frontend code changes needed for SE/WA/AN/RA/ZR/ME — `IstQuestion`,
   `IstScoringService`, and the exam UI already work against the real per-subtest
   structure; only the seeded rows need updating.
