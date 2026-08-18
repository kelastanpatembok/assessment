-- Include the EPPS assessment in the "Paket Lengkap" test category so
-- assignments built from it unlock the student EPPS flow.
UPDATE test_categories
SET tests = array_append(tests, 'epps'),
    description = 'DISC + Holland + PAPI + CFIT + IST + EPPS'
WHERE slug = 'paket-lengkap'
  AND NOT ('epps' = ANY(tests));
