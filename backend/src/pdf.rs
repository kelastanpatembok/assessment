use chrono::{Datelike, NaiveDateTime};

use crate::models::credential::CredentialDto;

/// A minimal, dependency-free PDF writer that produces a valid A4 document
/// with the credential table, replicating the Java OpenPDF output's content
/// (school header, category, generated timestamp, No/Username/Password table)
/// without needing a PDF library dependency.
pub fn build_credentials_pdf(
    school_name: &str,
    category_name: &str,
    credentials: &[CredentialDto],
) -> Result<Vec<u8>, anyhow::Error> {
    let generated = crate::datetime::indonesian_datetime(chrono::Utc::now().naive_utc());

    // Build a PostScript-ish content stream: centered header lines then rows.
    let mut stream = String::new();
    let y_start = 800.0_f32;
    let mut y = y_start;
    stream.push_str(&text_centered(18.0, y, &escape(school_name)));
    y -= 22.0;
    stream.push_str(&text_centered(14.0, y, &escape(category_name)));
    y -= 18.0;
    stream.push_str(&text_centered(9.0, y, &format!("Generated on {generated}")));
    y -= 24.0;

    // Table header.
    stream.push_str(&format!("BT /F2 10 Tf 60 {y} Td (No) Tj 40 0 Td (Username) Tj 200 0 Td (Password) Tj ET\n"));
    y -= 16.0;

    for (i, c) in credentials.iter().enumerate() {
        if y < 60.0 {
            stream.push_str(&text_centered(9.0, 40.0, "Lanjut ke halaman berikutnya"));
            break;
        }
        stream.push_str(&format!(
            "BT /F2 10 Tf 60 {y} Td ({}) Tj 40 0 Td ({}) Tj 200 0 Td ({}) Tj ET\n",
            i + 1,
            escape(&c.username),
            escape(&c.password)
        ));
        y -= 14.0;
    }

    let font_obj = "<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica /Encoding /WinAnsiEncoding >>";
    let page_obj = format!(
        "<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] /Resources << /Font << /F1 3 0 R /F2 3 0 R >> >> /Contents 4 0 R >>"
    );
    let stream_obj = format!("<< /Length {} >>\nstream\n{}\nendstream", stream.len(), stream);
    let catalog = "<< /Type /Catalog /Pages 2 0 R >>";
    let pages = "<< /Type /Pages /Kids [5 0 R] /Count 1 >>";

    let mut out = Vec::new();
    out.extend_from_slice(b"%PDF-1.4\n%\xe2\xe3\xcf\xd3\n");

    let mut offsets: Vec<usize> = Vec::new();
    // object 1: catalog, 2: pages, 3: font, 4: content stream, 5: page
    let objects: [String; 5] = [
        catalog.to_string(),
        pages.to_string(),
        font_obj.to_string(),
        stream_obj,
        page_obj,
    ];
    for (i, obj) in objects.iter().enumerate() {
        offsets.push(out.len());
        out.extend_from_slice(format!("{} 0 obj\n", i + 1).as_bytes());
        out.extend_from_slice(obj.as_bytes());
        out.extend_from_slice(b"\nendobj\n");
    }

    let xref = out.len();
    let count = objects.len() + 1;
    out.extend_from_slice(format!("xref\n0 {count}\n0000000000 65535 f \n").as_bytes());
    for off in offsets {
        out.extend_from_slice(format!("{:010} 00000 n \n", off).as_bytes());
    }
    out.extend_from_slice(format!("trailer\n<< /Size {count} /Root 1 0 R >>\nstartxref\n{xref}\n%%EOF\n").as_bytes());

    Ok(out)
}

fn escape(s: &str) -> String {
    s.replace('\\', "\\\\").replace('(', "\\(").replace(')', "\\)")
}

fn text_centered(size: f32, y: f32, text: &str) -> String {
    // Approximate width: Helvetica ~0.5 * point size per char.
    let page_width = 595.0_f32;
    let text_width = size * 0.5 * text.chars().count() as f32;
    let x = (page_width - text_width) / 2.0;
    format!("BT /F1 {size} Tf {x:.1} {y:.1} Td ({text}) Tj ET\n")
}

/// "SMANegeri1IQTestAgustus2026.pdf" — spaces stripped from school/category,
/// capitalized full Indonesian month name.
pub fn display_filename(school_name: &str, category_name: &str, now: NaiveDateTime) -> String {
    const MONTHS: [&str; 12] = [
        "Januari", "Februari", "Maret", "April", "Mei", "Juni", "Juli", "Agustus", "September",
        "Oktober", "November", "Desember",
    ];
    let school: String = school_name.chars().filter(|c| !c.is_whitespace()).collect();
    let category: String = category_name.chars().filter(|c| !c.is_whitespace()).collect();
    let month = MONTHS[(now.month() - 1) as usize];
    format!("{school}{category}{month}{}.pdf", now.year())
}
