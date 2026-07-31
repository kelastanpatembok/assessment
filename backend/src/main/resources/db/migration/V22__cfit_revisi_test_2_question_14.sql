-- The prior Test 2 item 2 option B was mapped to an unrelated animal image.
-- The supplied booklet page confirms it is the two-horizontal-lines option.
UPDATE cfit_questions
SET option_images = jsonb_set(
    option_images,
    '{1}',
    '"/cfit/revisi/t2/2b.jpg"'::jsonb
)
WHERE subtest_no = 2 AND item_no = 2;

-- The revised CFIT source set supplies the previously missing Test 2 item 14.
-- Test 2 is a classification task, so students must select both A and B.
INSERT INTO cfit_questions (
    subtest_no,
    item_no,
    stem_image_url,
    option_images,
    correct_answer,
    correct_answer2
) VALUES (
    2,
    14,
    NULL,
    '["/cfit/revisi/t2/14a.jpg", "/cfit/revisi/t2/14b.jpg", "/cfit/revisi/t2/14c.jpg", "/cfit/revisi/t2/14d.jpg", "/cfit/revisi/t2/14e.jpg"]',
    'a',
    'b'
);
