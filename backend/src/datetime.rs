use chrono::{Datelike, NaiveDateTime, Timelike, Utc};

/// Replicates java.time.LocalDateTime.toString() formatting exactly:
/// "yyyy-MM-dd'T'HH:mm:ss" plus a fractional-second part. Java prints the
/// fraction in groups of 3 digits (minimum one group) with trailing zeros
/// removed — e.g. .026820 -> .02682, .500000 -> .5, .000000 -> (none).
pub fn java_local_date_time(dt: NaiveDateTime) -> String {
    let base = dt.format("%Y-%m-%dT%H:%M:%S").to_string();
    let nanos = dt.nanosecond();
    if nanos == 0 {
        return base;
    }
    // Fractional part with leading zeros to 9 digits, then trim trailing zeros.
    let frac = format!("{:09}", nanos);
    let frac = frac.trim_end_matches('0');
    format!("{base}.{frac}")
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
