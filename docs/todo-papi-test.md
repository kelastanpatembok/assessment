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

## What's missing from the source documents (blockers)

### 1. The pair → trait answer key

Neither `papi.pdf` nor `papi-result.xls` states which trait each pair's
option A and option B actually score toward. `papi.pdf` has statement text
only; `papi-result.xls`'s `DATA` tab has raw picks for only 2 test-takers
(and only 1–2 questions filled in per person) — not enough to reverse-engineer
a 90-item key from 20 aggregate totals.

**What we did instead:** generated a structurally-balanced placeholder key
(`backend/scripts/initial-setup.sh`, the `papi_questions` INSERT block). Every
trait appears as an option in exactly 9 of the 90 pairs (built from a
9-regular circulant graph over the 20 traits), so scores land in the correct
0–9 range and the scoring pipeline works end-to-end — but the **specific**
trait assigned to each pair's A/B option is **not the real Kostick answer
key**. It was assigned by a deterministic algorithm, not sourced from an
official document.

**To fix:** get the official PAPI Kostick scoring key (which trait each of
the 90 items' A and B option maps to) from the psychologist, then replace the
`INSERT INTO papi_questions (...)` block in `backend/scripts/initial-setup.sh`
with the real trait codes (keep the same statement text — that part is
already correct) and rerun the script. No schema or backend code changes are
needed for this.

### 2. Per-score interpretive text ("Uraian")

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
