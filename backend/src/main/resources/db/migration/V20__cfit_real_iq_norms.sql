-- V20: Replace CFIT's placeholder score->IQ band calibration with the real norm table
-- and IQ classification, sourced from the official scoring tool "Software Skorings CFIT
-- Skala 3A & 3B.xls" (cell C70 = IQ via VLOOKUP of total raw score against its RS/IQ norm
-- table at AB16:AC66; cell D70 = IQ classification band, confirmed for one sample case:
-- raw score 9 -> IQ 60 -> "Mentally Retardation").
--
-- The RS(0-50) -> IQ mapping below is transcribed exactly from that norm table (51 rows,
-- confirmed against the sample: RS=9 -> IQ=60, matching the file's own C70 result).
-- The 7-tier classification band THRESHOLDS are the standard published CFIT/Wechsler-style
-- IQ classification (Mentally Retardation/Borderline/Low Average/Average/High Average/
-- Superior/Very Superior) — only the <70 band's label was directly confirmed against the
-- sample in the file (D70); the other 6 thresholds follow the same standard scheme but
-- weren't independently re-derived cell-by-cell (the sheet only had one sample row).
-- `description` text is our own addition (not present in the source file at all).
--
-- Note: our seeded item bank currently has 49 items (Subtest 2 is missing item 14 — see
-- docs/todo-cfit-test.md), one short of this table's full RS=50. A perfect score today
-- (RS=49) still lands on IQ 183, same as RS=50, so this is not a scoring gap in practice.

DELETE FROM cfit_descriptions;

INSERT INTO cfit_descriptions (score_min, score_max, iq_min, iq_max, category, description) VALUES
  (0, 0, 38, 38, 'Mentally Retardation', 'Kemampuan intelektual jauh di bawah rata-rata secara signifikan; disarankan evaluasi psikologis lebih lanjut.'),
  (1, 1, 40, 40, 'Mentally Retardation', 'Kemampuan intelektual jauh di bawah rata-rata secara signifikan; disarankan evaluasi psikologis lebih lanjut.'),
  (2, 2, 43, 43, 'Mentally Retardation', 'Kemampuan intelektual jauh di bawah rata-rata secara signifikan; disarankan evaluasi psikologis lebih lanjut.'),
  (3, 3, 45, 45, 'Mentally Retardation', 'Kemampuan intelektual jauh di bawah rata-rata secara signifikan; disarankan evaluasi psikologis lebih lanjut.'),
  (4, 4, 47, 47, 'Mentally Retardation', 'Kemampuan intelektual jauh di bawah rata-rata secara signifikan; disarankan evaluasi psikologis lebih lanjut.'),
  (5, 5, 48, 48, 'Mentally Retardation', 'Kemampuan intelektual jauh di bawah rata-rata secara signifikan; disarankan evaluasi psikologis lebih lanjut.'),
  (6, 6, 52, 52, 'Mentally Retardation', 'Kemampuan intelektual jauh di bawah rata-rata secara signifikan; disarankan evaluasi psikologis lebih lanjut.'),
  (7, 7, 55, 55, 'Mentally Retardation', 'Kemampuan intelektual jauh di bawah rata-rata secara signifikan; disarankan evaluasi psikologis lebih lanjut.'),
  (8, 8, 57, 57, 'Mentally Retardation', 'Kemampuan intelektual jauh di bawah rata-rata secara signifikan; disarankan evaluasi psikologis lebih lanjut.'),
  (9, 9, 60, 60, 'Mentally Retardation', 'Kemampuan intelektual jauh di bawah rata-rata secara signifikan; disarankan evaluasi psikologis lebih lanjut.'),
  (10, 10, 63, 63, 'Mentally Retardation', 'Kemampuan intelektual jauh di bawah rata-rata secara signifikan; disarankan evaluasi psikologis lebih lanjut.'),
  (11, 11, 67, 67, 'Mentally Retardation', 'Kemampuan intelektual jauh di bawah rata-rata secara signifikan; disarankan evaluasi psikologis lebih lanjut.'),
  (12, 12, 70, 70, 'Borderline', 'Kemampuan intelektual di batas bawah rata-rata; mungkin memerlukan dukungan tambahan dalam tugas yang menuntut penalaran abstrak.'),
  (13, 13, 72, 72, 'Borderline', 'Kemampuan intelektual di batas bawah rata-rata; mungkin memerlukan dukungan tambahan dalam tugas yang menuntut penalaran abstrak.'),
  (14, 14, 75, 75, 'Borderline', 'Kemampuan intelektual di batas bawah rata-rata; mungkin memerlukan dukungan tambahan dalam tugas yang menuntut penalaran abstrak.'),
  (15, 15, 78, 78, 'Borderline', 'Kemampuan intelektual di batas bawah rata-rata; mungkin memerlukan dukungan tambahan dalam tugas yang menuntut penalaran abstrak.'),
  (16, 16, 81, 81, 'Low Average', 'Kemampuan intelektual sedikit di bawah rata-rata.'),
  (17, 17, 85, 85, 'Low Average', 'Kemampuan intelektual sedikit di bawah rata-rata.'),
  (18, 18, 88, 88, 'Low Average', 'Kemampuan intelektual sedikit di bawah rata-rata.'),
  (19, 19, 91, 91, 'Average', 'Kemampuan intelektual rata-rata; mampu menangani tugas sehari-hari dan penalaran umum dengan baik.'),
  (20, 20, 94, 94, 'Average', 'Kemampuan intelektual rata-rata; mampu menangani tugas sehari-hari dan penalaran umum dengan baik.'),
  (21, 21, 96, 96, 'Average', 'Kemampuan intelektual rata-rata; mampu menangani tugas sehari-hari dan penalaran umum dengan baik.'),
  (22, 22, 100, 100, 'Average', 'Kemampuan intelektual rata-rata; mampu menangani tugas sehari-hari dan penalaran umum dengan baik.'),
  (23, 23, 103, 103, 'Average', 'Kemampuan intelektual rata-rata; mampu menangani tugas sehari-hari dan penalaran umum dengan baik.'),
  (24, 24, 106, 106, 'Average', 'Kemampuan intelektual rata-rata; mampu menangani tugas sehari-hari dan penalaran umum dengan baik.'),
  (25, 25, 109, 109, 'Average', 'Kemampuan intelektual rata-rata; mampu menangani tugas sehari-hari dan penalaran umum dengan baik.'),
  (26, 26, 113, 113, 'High Average', 'Kemampuan intelektual sedikit di atas rata-rata.'),
  (27, 27, 116, 116, 'High Average', 'Kemampuan intelektual sedikit di atas rata-rata.'),
  (28, 28, 119, 119, 'High Average', 'Kemampuan intelektual sedikit di atas rata-rata.'),
  (29, 29, 121, 121, 'Superior', 'Kemampuan intelektual di atas rata-rata; mampu berpikir abstrak dan memecahkan masalah dengan baik.'),
  (30, 30, 124, 124, 'Superior', 'Kemampuan intelektual di atas rata-rata; mampu berpikir abstrak dan memecahkan masalah dengan baik.'),
  (31, 31, 128, 128, 'Superior', 'Kemampuan intelektual di atas rata-rata; mampu berpikir abstrak dan memecahkan masalah dengan baik.'),
  (32, 32, 131, 131, 'Very Superior', 'Kemampuan intelektual superior; sangat cepat dalam memproses informasi dan memecahkan masalah kompleks.'),
  (33, 33, 133, 133, 'Very Superior', 'Kemampuan intelektual superior; sangat cepat dalam memproses informasi dan memecahkan masalah kompleks.'),
  (34, 34, 137, 137, 'Very Superior', 'Kemampuan intelektual superior; sangat cepat dalam memproses informasi dan memecahkan masalah kompleks.'),
  (35, 35, 140, 140, 'Very Superior', 'Kemampuan intelektual superior; sangat cepat dalam memproses informasi dan memecahkan masalah kompleks.'),
  (36, 36, 142, 142, 'Very Superior', 'Kemampuan intelektual superior; sangat cepat dalam memproses informasi dan memecahkan masalah kompleks.'),
  (37, 37, 145, 145, 'Very Superior', 'Kemampuan intelektual superior; sangat cepat dalam memproses informasi dan memecahkan masalah kompleks.'),
  (38, 38, 149, 149, 'Very Superior', 'Kemampuan intelektual superior; sangat cepat dalam memproses informasi dan memecahkan masalah kompleks.'),
  (39, 39, 152, 152, 'Very Superior', 'Kemampuan intelektual superior; sangat cepat dalam memproses informasi dan memecahkan masalah kompleks.'),
  (40, 40, 155, 155, 'Very Superior', 'Kemampuan intelektual superior; sangat cepat dalam memproses informasi dan memecahkan masalah kompleks.'),
  (41, 41, 157, 157, 'Very Superior', 'Kemampuan intelektual superior; sangat cepat dalam memproses informasi dan memecahkan masalah kompleks.'),
  (42, 42, 161, 161, 'Very Superior', 'Kemampuan intelektual superior; sangat cepat dalam memproses informasi dan memecahkan masalah kompleks.'),
  (43, 43, 165, 165, 'Very Superior', 'Kemampuan intelektual superior; sangat cepat dalam memproses informasi dan memecahkan masalah kompleks.'),
  (44, 44, 167, 167, 'Very Superior', 'Kemampuan intelektual superior; sangat cepat dalam memproses informasi dan memecahkan masalah kompleks.'),
  (45, 45, 169, 169, 'Very Superior', 'Kemampuan intelektual superior; sangat cepat dalam memproses informasi dan memecahkan masalah kompleks.'),
  (46, 46, 173, 173, 'Very Superior', 'Kemampuan intelektual superior; sangat cepat dalam memproses informasi dan memecahkan masalah kompleks.'),
  (47, 47, 176, 176, 'Very Superior', 'Kemampuan intelektual superior; sangat cepat dalam memproses informasi dan memecahkan masalah kompleks.'),
  (48, 48, 179, 179, 'Very Superior', 'Kemampuan intelektual superior; sangat cepat dalam memproses informasi dan memecahkan masalah kompleks.'),
  (49, 49, 183, 183, 'Very Superior', 'Kemampuan intelektual superior; sangat cepat dalam memproses informasi dan memecahkan masalah kompleks.'),
  (50, 50, 183, 183, 'Very Superior', 'Kemampuan intelektual superior; sangat cepat dalam memproses informasi dan memecahkan masalah kompleks.');
