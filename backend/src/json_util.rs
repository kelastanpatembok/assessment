use std::collections::BTreeMap;

/// Jackson in the Java backend serializes objects with
/// SORT_PROPERTIES_ALPHABETICALLY, so every JSON object's keys come back in
/// byte order regardless of declaration order. Recursively re-sort object
/// keys to reproduce that exactly.
pub fn sorted(value: serde_json::Value) -> serde_json::Value {
    match value {
        serde_json::Value::Object(map) => {
            let mut sorted_map = BTreeMap::new();
            for (k, v) in map {
                sorted_map.insert(k, sorted(v));
            }
            serde_json::Value::Object(sorted_map.into_iter().collect())
        }
        serde_json::Value::Array(items) => {
            serde_json::Value::Array(items.into_iter().map(sorted).collect())
        }
        other => other,
    }
}

/// Convenience wrapper: build a value then sort it.
pub fn json_sorted(inner: serde_json::Value) -> serde_json::Value {
    sorted(inner)
}
