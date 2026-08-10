use crate::models::disc::DiscAnswerDto;

/// DISC pattern classification: 40 mutually-exclusive ordered rules,
/// first match wins (Excel MATCH(1,range,0) semantics). Mirrors the Java
/// DiscPatternClassifier exactly.
pub fn classify(d: f64, i: f64, s: f64, c: f64) -> i32 {
    // Rule order from the Java port.
    if d <= 0.0 && i <= 0.0 && s <= 0.0 && c > 0.0 { return 1; }
    if d > 0.0 && i <= 0.0 && s <= 0.0 && c <= 0.0 { return 2; }
    if d > 0.0 && i <= 0.0 && s <= 0.0 && c > 0.0 && c >= d { return 3; }
    if d > 0.0 && i > 0.0 && s <= 0.0 && c <= 0.0 && i >= d { return 4; }
    if d > 0.0 && i > 0.0 && s <= 0.0 && c > 0.0 && i >= d && d >= c { return 5; }
    if d > 0.0 && i > 0.0 && s > 0.0 && c <= 0.0 && i >= d && d >= s { return 6; }
    if d > 0.0 && i > 0.0 && s > 0.0 && c <= 0.0 && i >= s && s >= d { return 7; }
    if d > 0.0 && i <= 0.0 && s > 0.0 && c > 0.0 && s >= d && d >= c { return 8; }
    if d > 0.0 && i > 0.0 && s <= 0.0 && c <= 0.0 && d >= i { return 9; }
    if d > 0.0 && i > 0.0 && s > 0.0 && c <= 0.0 && d >= i && i >= s { return 10; }
    if d > 0.0 && i <= 0.0 && s > 0.0 && c <= 0.0 && d >= s { return 11; }
    if d <= 0.0 && i > 0.0 && s > 0.0 && c > 0.0 && c >= i && i >= s { return 12; }
    if d <= 0.0 && i > 0.0 && s > 0.0 && c > 0.0 && c >= s && s >= i { return 13; }
    if d <= 0.0 && i > 0.0 && s > 0.0 && c > 0.0 && i >= s && i >= c { return 14; }
    if d <= 0.0 && i <= 0.0 && s > 0.0 && c <= 0.0 { return 15; }
    if d <= 0.0 && i <= 0.0 && s > 0.0 && c > 0.0 && c >= s { return 16; }
    if d <= 0.0 && i <= 0.0 && s > 0.0 && c > 0.0 && s >= c { return 17; }
    if i <= 0.0 && s <= 0.0 && d > 0.0 && c > 0.0 && d >= c { return 18; }
    if d > 0.0 && i > 0.0 && c > 0.0 && s <= 0.0 && d >= i && i >= c { return 19; }
    if d > 0.0 && s > 0.0 && i > 0.0 && c <= 0.0 && d >= s && s >= i { return 20; }
    if d > 0.0 && s > 0.0 && c > 0.0 && i <= 0.0 && d >= s && s >= c { return 21; }
    if d > 0.0 && i > 0.0 && c > 0.0 && s <= 0.0 && d >= c && c >= i { return 22; }
    if d > 0.0 && s > 0.0 && c > 0.0 && i <= 0.0 && d >= c && c >= s { return 23; }
    if d <= 0.0 && s <= 0.0 && c <= 0.0 && i > 0.0 { return 24; }
    if i > 0.0 && s > 0.0 && d <= 0.0 && c <= 0.0 && i >= s { return 25; }
    if i > 0.0 && c > 0.0 && d <= 0.0 && s <= 0.0 && i >= c { return 26; }
    if d > 0.0 && i > 0.0 && c > 0.0 && s <= 0.0 && i >= c && c >= d { return 27; }
    if d <= 0.0 && i > 0.0 && s > 0.0 && c > 0.0 && i >= c && c >= s { return 28; }
    if d > 0.0 && i <= 0.0 && s > 0.0 && c <= 0.0 && s >= d { return 29; }
    if i > 0.0 && s > 0.0 && d <= 0.0 && c <= 0.0 && s >= i { return 30; }
    if d > 0.0 && i > 0.0 && s > 0.0 && c <= 0.0 && s >= d && d >= i { return 31; }
    if d > 0.0 && i > 0.0 && s > 0.0 && c <= 0.0 && s >= i && i >= d { return 32; }
    if i > 0.0 && s > 0.0 && c > 0.0 && d <= 0.0 && s >= i && i >= c { return 33; }
    if d > 0.0 && i <= 0.0 && s > 0.0 && c > 0.0 && s >= c && c >= d { return 34; }
    if i > 0.0 && s > 0.0 && c > 0.0 && d <= 0.0 && s >= c && c >= i { return 35; }
    if i > 0.0 && c > 0.0 && d <= 0.0 && s <= 0.0 && c >= i { return 36; }
    if d > 0.0 && i > 0.0 && c > 0.0 && s <= 0.0 && c >= d && d >= i { return 37; }
    if d > 0.0 && s > 0.0 && c > 0.0 && i <= 0.0 && c >= d && d >= s { return 38; }
    if d > 0.0 && i > 0.0 && c > 0.0 && s <= 0.0 && c >= i && i >= d { return 39; }
    if d > 0.0 && s > 0.0 && c > 0.0 && i <= 0.0 && c >= s && s >= d { return 40; }

    // Fallback (Java Math.max chain; ties resolve d, i, s order).
    let max = d.max(i).max(s).max(c);
    if max == d {
        2
    } else if max == i {
        24
    } else if max == s {
        15
    } else {
        1
    }
}

/// Convenience for DISC answer JSON round-tripping (used to persist the
/// answers column as a jsonb string).
pub fn answers_to_json_string(answers: &[DiscAnswerDto]) -> String {
    serde_json::to_string(answers).unwrap_or_else(|_| "[]".to_string())
}
