/// IST subtest codes in canonical order.
pub const IST_SUBTEST_CODES: [&str; 9] = ["SE", "WA", "AN", "GE", "RA", "ZR", "FA", "WU", "ME"];

/// ZR is scored against its own ist_zr_questions table with integer answers;
/// every other subtest matches ist_questions.correct_answer as a
/// case-insensitive string comparison.
pub fn ist_standard_correct(answer: &str, correct_answer: Option<&str>) -> bool {
    match correct_answer {
        Some(ca) => !ca.trim().is_empty() && answer.trim().eq_ignore_ascii_case(ca.trim()),
        None => false,
    }
}

pub fn ist_zr_correct(answer: &str, correct_answer: i32) -> bool {
    match answer.trim().parse::<i32>() {
        Ok(v) => v == correct_answer,
        Err(_) => false,
    }
}
