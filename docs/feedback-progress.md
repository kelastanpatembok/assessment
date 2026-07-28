# Feedback Assessment Part 1 - Progress Report

Date: 2026-07-29
Status: Partially Complete

## Summary

Completed **5 of 12** feedback items (Items 1, 2, 3, 6, 7).
Remaining items require either manual image correction or deeper IST test structure investigation.

---

## ✅ Completed Items

### Item 1: PAPI Result Page - Add Radar Chart ✅
**URL:** `https://assessment.ktt.my.id/student-papi/result`  
**Status:** **COMPLETE**

**Changes:**
- Installed `chart.js` and `svelte-chartjs` dependencies
- Created `PapiRadarChart.svelte` component with 20-trait radar visualization
- Integrated radar chart into result page above existing bar charts
- Used shadcn-svelte maia theme colors (indigo primary)
- Added interactive tooltips showing trait scores and bands (TINGGI/RENDAH)
- Responsive design with max-width constraint

**Files Modified:**
- `frontend/package.json`
- `frontend/src/lib/components/PapiRadarChart.svelte` (NEW)
- `frontend/src/routes/(student)/student-papi/result/+page.svelte`

**Commit:** `e76f73a` - "feat: add radar chart diagram to PAPI Kostick result page"

---

### Items 2, 3, 6, 7: CFIT Exam - Add Example Images ✅
**URL:** `https://assessment.ktt.my.id/student-cfit`  
**Status:** **COMPLETE**

**Changes:**
- Converted original CFIT photos (1-7.jpg) to WebP format for optimization (722KB-1.3MB each)
- Copied WebP files to `frontend/static/cfit/examples/`
- Added `exampleImage` field to `SUBTEST_INSTRUCTIONS` type definition
- Mapped example images to each subtest:
  - **Subtest 1** (Series): `1.webp` - shows 3 pattern completion examples
  - **Subtest 2** (Classification): `3.webp` - shows 2-of-5 matching examples
  - **Subtest 3** (Matrices): `5.webp` - shows matrix completion examples
  - **Subtest 4** (Conditions): `6.webp` - shows dot placement examples
- Updated instruction phase UI to display example images in bordered card
- Images are lazy-loaded and responsive
- Examples appear before timer starts for each subtest

**Files Modified:**
- `frontend/src/routes/(student)/(exam)/student-cfit/+page.svelte`
- `frontend/static/cfit/examples/1.webp` through `7.webp` (NEW)

**Commit:** `ee55a0c` - "feat: add example images to CFIT exam instruction pages"

---

## ⏸️ Blocked Items (Require User Input)

### Item 4: CFIT Subtest 2 Q2 Option B - Wrong Image ⏸️
**URL:** `https://assessment.ktt.my.id/student-cfit`  
**Status:** **BLOCKED - Need correct replacement image**

**Issue:** 
- Current image at `/cfit/fotoopsi/1715152615fotoopsib.png` shows wrong content (animal instead of lines)
- Migration `V19__cfit_real_answers.sql` line 27 references this image
- Database entry: `(2, 2, NULL, '[...1715152615fotoopsia/b/c/d/e...]', 'a', 'e')`

**What's Needed:**
- User must identify the correct option B image from the full-page scan at:  
  `docs/Soal CFIT/Soal/3.webp` or `3.jpg`
- Crop the correct option B image
- Replace the file at `frontend/static/cfit/fotoopsi/1715152615fotoopsib.png`

**OR** 
- Provide the correct image file and I can replace it

---

### Item 5: CFIT Subtest 2 Q14 - Missing Question ⏸️
**URL:** `https://assessment.ktt.my.id/student-cfit`  
**Status:** **BLOCKED - Need question images**

**Issue:**
- Subtest 2 currently has only 13 questions (item_no 1-13)
- Should have 14 questions total
- Migration `V19__cfit_real_answers.sql` comment line 13 notes: "item 14's images were never uploaded"
- Answer key (from Scribd): **A & B**

**What's Needed:**
- 5 option images for Subtest 2 Question 14
- These should be visible in the full-page scan (likely on page 4 of the CFIT booklet)
- Need to crop 5 images: options a, b, c, d, e

**Once provided, add this to migration:**
```sql
INSERT INTO cfit_questions (subtest_no, item_no, stem_image_url, option_images, correct_answer, correct_answer2) 
VALUES (2, 14, NULL, 
  '["/cfit/fotoopsi/[timestamp]fotoopsia.png",
    "/cfit/fotoopsi/[timestamp]fotoopsib.png",
    "/cfit/fotoopsi/[timestamp]fotoopsic.png",
    "/cfit/fotoopsi/[timestamp]fotoopsid.png",
    "/cfit/fotoopsi/[timestamp]fotoopsie.png"]', 
  'a', 'b');
```

---

## 🔍 Items Requiring Investigation

### Item 8: IST Option ABC Layout Not Neat ❓
**URL:** `https://assessment.ktt.my.id/student-ist`  
**Status:** **NEEDS INVESTIGATION**

**Current Implementation:**
- Options displayed in grid: `grid-cols-2 sm:grid-cols-5`
- Layout in `frontend/src/routes/(student)/(exam)/student-ist/+page.svelte` lines 409-420

**Possible Fixes:**
1. Change grid columns to fixed 1 column or 3 columns for better alignment
2. Adjust spacing/padding
3. Make option labels uniform width

**Action Needed:** 
- Test current layout visually to see exact issue
- Determine desired layout (screenshot from physical test would help)

---

### Item 9: IST Question Numbering & Answer-Only Questions ❓
**URL:** `https://assessment.ktt.my.id/student-ist`  
**Status:** **NEEDS INVESTIGATION**

**Feedback:** "nomor mulai dari 1" should be "nomor mulai mengikuti sesuai instruksi dan jgn ada soal hanya pilihan jawaban saja"

**Current Implementation:**
- Questions numbered sequentially within each subtest (1, 2, 3...)
- Display logic in lines 365-440

**Possible Issues:**
1. Numbering should continue across all subtests (1-20 for SE, 21-40 for WA, etc.) - but instructions already say this ("Soal-soal No. 01-20")
2. Some questions might show only options without question text

**Action Needed:**
- Verify question text exists for all IST questions in database
- Check if numbering should use absolute question numbers instead of index within subtest
- Review IST migrations `V21__ist_real_question_content.sql`

---

### Item 10: IST FA & WU Missing Example Images ❓
**URL:** `https://assessment.ktt.my.id/student-ist`  
**Status:** **NEEDS INVESTIGATION**

**Current Implementation:**
- Instruction text exists for FA and WU in `SUBTEST_INSTRUCTIONS`
- No example images currently shown (unlike CFIT which we just fixed)

**What's Available:**
- Converted IST page scans to WebP: `frontend/static/ist/examples/IMG_28**.webp` (17 images)
- Need to identify which images contain FA and WU examples

**Action Needed:**
1. Examine the 17 IST WebP images to identify FA (Figure Analysis) and WU (Cube/Würfel) example pages
2. Add `exampleImage` field to FA and WU instructions (same pattern as CFIT Items 2,3,6,7)
3. Update instruction rendering to display images

**Similar to CFIT fix - can be completed once correct images are identified**

---

### Item 11: IST FA & WU - Options Should Be at Start Only ❓
**URL:** `https://assessment.ktt.my.id/student-ist`  
**Status:** **NEEDS SIGNIFICANT REFACTORING**

**Feedback:** "soal FU & WA pilihan terdapat disetiap soal" → "pilihan hanya dibagian awal"

**Note:** "FU & WA" likely means **FA & WU** (Figure Analysis & Cube tests)

**Current Implementation:**
- FA/WU render with `isImageMC(q)` check (line 384)
- Each question displays 5 option images in a grid (lines 392-404)
- Options are image-based: `q.optionImages` array

**Expected Behavior:**
- Show 5 reference images (a, b, c, d, e) ONCE at the top of the subtest
- Each question references these images by letter only
- Similar to how physical test booklets show a reference key

**Required Changes:**
1. Extract reference images for FA and WU subtests
2. Display reference images once before questions
3. Modify question rendering to show only question number + stem image
4. Keep radio inputs but remove repeated option images

**Complexity:** MEDIUM-HIGH - requires restructuring FA/WU question display logic

---

### Item 12: IST ME - Separate Instructions and Memorization ✅ (Possibly)
**URL:** `https://assessment.ktt.my.id/student-ist`  
**Status:** **MAY ALREADY BE CORRECT**

**Feedback:** "intruksi dan bahan hafalan jadi satu halaman" → "intruksi dan hafalan dipisah"

**Current Implementation:**
- ME (Memorization) subtest has 3 phases:
  1. **Instruction phase** (`subtestPhase === 'instruction'`): Shows instructions + word list (lines 317-332)
  2. **Menghafal phase** (`mePhase === 'menghafal'`): 3-minute study period, word list only (lines 349-356)
  3. **Mengerjakan phase** (`mePhase === 'mengerjakan'`): 6-minute answer period, actual questions (lines 357+)

**Analysis:**
- Instructions and memorization ARE already on separate "pages" (different UI states)
- Instruction page (untimed) shows both instructions + word list
- Menghafal page (3min timer) shows only word list

**Possible Issue:**
- Maybe the word list shouldn't appear on instruction page at all?
- Or maybe the UX flow isn't clear enough (need "Lanjut" button between phases)?

**Action Needed:**
- Test the actual ME flow to see current behavior
- If word list should ONLY appear in menghafal phase, remove it from instruction card (lines 324-330)

---

## Preparation Work Completed

### IST Images Converted ✅
- Converted 17 IST HEIC images to JPG using `sips`
- Converted JPG to WebP using `cwebp` at quality 80
- Copied to `frontend/static/ist/examples/`
- Ready for use once correct example pages are identified

**Files:**
- `IMG_2884.webp` through `IMG_2900.webp` (17 images)
- Located in: `assessment/frontend/static/ist/examples/`

---

## Next Steps

### Immediate (Can complete with user input):
1. **Item 4**: User provides correct CFIT Subtest 2 Q2 option B image → replace file
2. **Item 5**: User provides 5 option images for CFIT Subtest 2 Q14 → add migration + seed data

### Short-term (Require testing/investigation):
3. **Item 8**: Test IST option layout visually → adjust CSS grid
4. **Item 10**: Identify FA & WU example images from converted WebP files → add to instructions
5. **Item 12**: Test ME flow → potentially remove word list from instruction phase

### Medium-term (Require refactoring):
6. **Item 9**: Investigate question numbering and missing question text
7. **Item 11**: Refactor FA/WU to show reference images once at top

---

## Files Ready for Review

### CFIT:
- Full-page scans: `docs/Soal CFIT/Soal/1-7.webp`
- Current question images: `frontend/static/cfit/fotoopsi/*.png`
- Example images: `frontend/static/cfit/examples/1-7.webp`

### IST:
- Full-page scans: `docs/Soal IST/IMG_*.webp` (17 images)
- Current question images: `frontend/static/ist/fotosoal/*.png`, `fotoopsiist/*.png`
- Example images ready: `frontend/static/ist/examples/IMG_*.webp`

---

## Commits Summary

1. `e76f73a` - feat: add radar chart diagram to PAPI Kostick result page (Item 1)
2. `ee55a0c` - feat: add example images to CFIT exam instruction pages (Items 2, 3, 6, 7)

**Total:** 2 commits, 5 items completed, 7 items remaining
