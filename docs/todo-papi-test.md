# PAPI Kostick — What's Missing vs. What We Generated

Status as of the current PAPI Kostick rebuild. This documents exactly which
parts of the PAPI test are backed by the real source documents (`docs/papi.pdf`,
`docs/papi-result.xls`) and which parts are **placeholder content pending
psychologist review**, so a future update knows precisely what to replace and
where.

## Source documents available

- `docs/papi.pdf` — the 90-item test booklet. Pages 1–5 contain the 90
  forced-choice pairs (statement A / statement B). Page 6 (the *last* page) is
  the instructions ("PETUNJUK"), not the first page — the PDF's pages are
  ordered booklet-first, instructions-last.
- `docs/papi-result.xls` — a legacy `.xls` (BIFF) workbook with one sample
  scored report (test-taker "Eko Sriwindu"), tabs: `PESERTA`, `DATA`,
  `POLA DASAR`, `CHART PAPIKOSTIK`, `URAIAN PAPIKOSTIK`.

## What's solid (sourced directly, verified)

- **All 90 pair statements** (`papi_questions.statement`) — transcribed
  programmatically from `docs/papi.pdf` pages 1–5, cross-checked for gaps/dupes
  (none found). These are accurate.
- **The 20 trait codes** (G N A P X B O Z K F L I T V S R D E C W) and their
  **7 category groupings** — Work Direction (N,G,A), Leadership (L,P,I),
  Activity (T,V), Social Nature (X,S,B,O), Workstyle (R,D,C), Temperament
  (Z,E,K), Followership (F,W) — read from the `POLA DASAR` tab of
  `papi-result.xls`. This grouping is used for the result page's chart
  sections.
- **The 0–9 score range per trait** — confirmed structurally: each of the 20
  traits is designed to appear in exactly 9 of the 90 pairs (9 × 20 = 180 =
  90 × 2 option slots), matching the raw counts seen in `POLA DASAR` for the
  one example test-taker (all 20 values sum to 90). `PapiScoringService`'s
  simple tally-per-trait algorithm is therefore correct as-is.

## Resolved

### The pair → trait answer key — DONE (2026-07-22)

`papi.pdf` and `papi-result.xls` never stated which trait each pair's option
A and option B score toward, so the initial build used a structurally-balanced
generated placeholder (every trait appearing in exactly 9 of 90 pairs, but the
*specific* assignment was algorithmic, not sourced).

**What replaced it:** the user photographed the official PAPI Kostick manual
scoring key/stencil (the diagonal answer-sheet grid used for manual scoring)
and a filled-in worked example. The item→trait-pair assignment was transcribed
row by row directly from the user reading the physical sheet (not OCR/guessed
from the photos — the photos alone were too small/ambiguous to read reliably;
the user read out each row's arrows explicitly). Verified with a checksum:
every one of the 20 traits appears in exactly 9 of the 90 pairs (matches the
structural requirement), and the worked example's per-trait totals matched
what the transcribed key would produce.

`backend/scripts/initial-setup.sh`'s `papi_questions` INSERT block now has the
real trait codes (statement text unchanged — it was already correct). Rerun
the script to load it into the DB (`papi_results` gets truncated alongside,
same as any reseed).

## What's still missing from the source documents (blockers)

### Per-score interpretive text ("Uraian")

`URAIAN PAPIKOSTIK` in `papi-result.xls` shows only **one example paragraph
per trait**, for whatever score that one test-taker happened to get (e.g.
"A = 4 → ..."). It does not contain text for all 10 possible score values
(0–9) per trait — that would require the official interpretation manual,
which isn't in the provided files.

**What we did instead:** wrote a two-band placeholder (`high_desc` /
`low_desc` per trait, threshold at score ≥ 5) in the `papi_descriptions`
INSERT block, same file. Each trait's `description`, `high_desc`, and
`low_desc` were drafted using the one real example sentence from `URAIAN
PAPIKOSTIK` as grounding (not invented from nothing), extended to cover both
the high and low direction. This is **not** official interpretation text.

**To fix:** once the psychologist supplies the real manual (ideally full
per-score-band text, or at minimum a verified high/low description per
trait), replace the `INSERT INTO papi_descriptions (...)` block the same way
and rerun `backend/scripts/initial-setup.sh`. `PapiInterpretationService`
computes the band (high/low) and looks up description text **at read time**
(not denormalized into `papi_results` at submission), so replacing
`papi_descriptions` immediately updates every existing student's result too —
no data migration needed.

## How to replace either piece

1. Edit the relevant `INSERT` block in `backend/scripts/initial-setup.sh`
   (search for `papi_questions` or `papi_descriptions`).
2. Rerun `./backend/scripts/initial-setup.sh`. It's idempotent — it
   `TRUNCATE`s and reseeds `papi_questions`, `papi_descriptions`, and
   `papi_results` (stale results are cleared the same way `disc_results` is
   cleared when `disc_questions` is reseeded).
3. No Flyway migration, no Java code change, no frontend change required for
   either replacement — the schema and interpretation logic already support
   real data once it arrives.
