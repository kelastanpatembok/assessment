/// CFIT subtest 2 items are scored all-or-nothing on a set of letters; other
/// subtests require exactly the one correct letter.
pub fn cfit_item_is_correct(
    submitted: &[String],
    correct_answer: &str,
    correct_answer2: Option<&str>,
) -> bool {
    if submitted.is_empty() {
        return false;
    }
    let given: std::collections::HashSet<String> = submitted
        .iter()
        .filter_map(|a| {
            let t = a.trim();
            if t.is_empty() {
                None
            } else {
                Some(t.to_lowercase())
            }
        })
        .collect();

    match correct_answer2 {
        Some(second) => {
            let expected: std::collections::HashSet<String> = vec![
                correct_answer.trim().to_lowercase(),
                second.trim().to_lowercase(),
            ]
            .into_iter()
            .collect();
            given == expected
        }
        None => {
            given.len() == 1 && given.contains(&correct_answer.trim().to_lowercase())
        }
    }
}
