use chrono::{Datelike, NaiveDateTime, Timelike, Utc};

/// Replicates java.time.LocalDateTime.toString() formatting exactly:
/// ISO-8601 "yyyy-MM-dd'T'HH:mm:ss" plus a fractional-second group of
/// 3, 6, or 9 digits (Java picks the smallest group that represents the
/// value exactly, and omits the fraction when nanos are zero).
pub fn java_local_date_time(dt: NaiveDateTime) -> String {
    let base = dt.format("%Y-%m-%dT%H:%M:%S").to_string();
    let nanos = dt.nanosecond();
    if nanos == 0 {
        return base;
    }
    if nanos % 1_000_000 == 0 {
        format!("{}.{:03}", base, nanos / 1_000_000)
    } else if nanos % 1_000 == 0 {
        format!("{}.{:06}", base, nanos / 1_000)
    } else {
        format!("{}.{:09}", base, nanos)
    }
}

/// java.time.Instant.toString() for the error envelope timestamp (UTC,
/// 9-digit fractional seconds, trailing 'Z').
pub fn java_now_utc() -> String {
    let now = Utc::now();
    let nanos = now.timestamp_subsec_nanos();
    if nanos == 0 {
        format!("{}Z", now.format("%Y-%m-%dT%H:%M:%S"))
    } else if nanos % 1_000_000 == 0 {
        format!("{}.{:03}Z", now.format("%Y-%m-%dT%H:%M:%S"), nanos / 1_000_000)
    } else if nanos % 1_000 == 0 {
        format!("{}.{:06}Z", now.format("%Y-%m-%dT%H:%M:%S"), nanos / 1_000)
    } else {
        format!("{}.{:09}Z", now.format("%Y-%m-%dT%H:%M:%S"), nanos)
    }
}

/// LocalDateTime value without a fixed zone (used for display "yyyy-MM-dd").
pub fn java_local_date(dt: NaiveDateTime) -> String {
    dt.format("%Y-%m-%d").to_string()
}

/// Format a LocalDateTime as Java's "EEE, d MMMM yyyy HH:mm" would require
/// locale data we don't ship; callers needing the exact Indonesian month/day
/// names use `indonesian_datetime` instead.
pub fn indonesian_datetime(dt: NaiveDateTime) -> String {
    const DAYS: [&str; 7] = [
        "Senin", "Selasa", "Rabu", "Kamis", "Jumat", "Sabtu", "Minggu",
    ];
    const MONTHS: [&str; 12] = [
        "Januari",
        "Februari",
        "Maret",
        "April",
        "Mei",
        "Juni",
        "Juli",
        "Agustus",
        "September",
        "Oktober",
        "November",
        "Desember",
    ];
    let day = DAYS[dt.weekday().num_days_from_monday() as usize];
    let month = MONTHS[(dt.month() - 1) as usize];
    format!(
        "{}, {} {} {} {:02}:{:02}",
        day,
        dt.day(),
        month,
        dt.year(),
        dt.hour(),
        dt.minute()
    )
}
