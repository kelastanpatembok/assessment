/// Holland RIASEC canonical order — also the tie-break order.
pub const RIASEC_ORDER: [char; 6] = ['R', 'I', 'A', 'S', 'E', 'C'];

/// Sorts the six RIASEC types by descending total. Ties break by canonical
/// order (R, I, A, S, E, C). Mirrors the Java comparator exactly.
pub fn rank_types(totals: &std::collections::HashMap<char, i64>) -> Vec<char> {
    let mut types: Vec<char> = RIASEC_ORDER.to_vec();
    types.sort_by(|a, b| {
        let ca = totals.get(a).copied().unwrap_or(0);
        let cb = totals.get(b).copied().unwrap_or(0);
        let cmp = cb.cmp(&ca);
        if cmp != std::cmp::Ordering::Equal {
            cmp
        } else {
            let ia = RIASEC_ORDER.iter().position(|x| x == a).unwrap();
            let ib = RIASEC_ORDER.iter().position(|x| x == b).unwrap();
            ia.cmp(&ib)
        }
    });
    types
}
