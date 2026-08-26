use std::{collections::BTreeMap, sync::Arc};

use lopdf::{
    content::{Content, Operation},
    dictionary,
    encryption::crypt_filters::{Aes128CryptFilter, CryptFilter},
    Document, EncryptionState, EncryptionVersion, Object, Stream,
};

#[derive(Debug, Clone)]
pub struct MethodInfo {
    pub key: String,
    pub label: String,
    pub academic_description: String,
    pub benefit: String,
    pub reference: String,
}

#[derive(Debug, Clone)]
pub struct MethodResult {
    pub key: String,
    pub label: String,
    pub summary: String,
    pub detail: String,
    pub rating: Option<u8>,
    pub completed: bool,
}

#[derive(Debug, Clone)]
pub struct StudentReport {
    pub name: String,
    pub date_of_birth: Option<String>,
    pub gender: Option<String>,
    pub results: Vec<MethodResult>,
}

#[derive(Debug, Clone)]
pub struct ReportData {
    pub report_no: String,
    pub school_name: String,
    pub official_email: String,
    pub package_name: String,
    pub generated_date: String,
    pub methods: Vec<MethodInfo>,
    pub students: Vec<StudentReport>,
}

/// The individual report deliberately has its own data model.  The older
/// school-wide report above remains available for historical deliveries.
#[derive(Debug, Clone)]
pub struct PsychologicalAspect {
    pub label: String,
    pub definition: String,
    pub result: String,
}

#[derive(Debug, Clone)]
pub struct PsychologicalReport {
    pub report_no: String,
    pub issued_date: String,
    pub printed_date: String,
    pub school_name: String,
    pub student_name: String,
    pub student_identity: String,
    pub aspects: Vec<PsychologicalAspect>,
    pub holland: String,
}

pub fn build_psychological_report(data: &PsychologicalReport) -> anyhow::Result<Vec<u8>> {
    let mut cover = PageCanvas::new(595.0, 842.0);
    cover.centered(760.0, 11.0, "Yogyakarta, ", false);
    cover.text(343.0, 760.0, 11.0, &data.issued_date, false);
    cover.text(58.0, 712.0, 11.0, &format!("Nomor     : {}", data.report_no), false);
    cover.text(58.0, 692.0, 11.0, "Perihal     : Surat Pengantar Hasil Asesmen Psikologis", false);
    cover.text(58.0, 672.0, 11.0, "Lampiran : 1 Laporan", false);
    cover.text(58.0, 625.0, 11.0, &format!("Yth. Pimpinan {}", data.school_name), false);
    cover.text(58.0, 607.0, 11.0, "di Tempat", false);
    cover.text(58.0, 565.0, 11.0, "Assalamualaikum Wr. Wb.", false);
    let letter = format!("Bersama surat ini kami sampaikan hasil asesmen psikologis atas nama {}. Laporan ini disusun sebagai bahan pemahaman potensi dan pendampingan peserta didik, serta perlu dibaca dalam konteks profesional.", data.student_name);
    let mut y = 535.0;
    for line in wrap_text(&letter, 470.0, 10.5, false) { cover.text(58.0, y, 10.5, &line, false); y -= 17.0; }
    cover.text(58.0, y - 18.0, 10.5, "Demikian surat pengantar ini disampaikan. Terima kasih atas perhatian dan kerja samanya.", false);
    cover.text(58.0, 255.0, 11.0, "Wassalamualaikum Wr. Wb.", false);
    cover.text(355.0, 205.0, 11.0, "Hormat kami,", false);
    cover.text(318.0, 142.0, 11.0, "Dewi Handayani Harahap, S.Psi, M.Psi", true);
    cover.text(385.0, 125.0, 10.0, "Direktur", false);

    let mut page = PageCanvas::new(595.0, 842.0);
    page.centered(780.0, 16.0, "HASIL LAPORAN PSIKOLOGIS", true);
    page.centered(759.0, 9.0, &data.report_no, false);
    page.text(48.0, 720.0, 10.0, &format!("Nama peserta : {}", data.student_name), false);
    page.text(48.0, 702.0, 10.0, &format!("Identitas       : {}", data.student_identity), false);
    page.text(48.0, 684.0, 10.0, &format!("Sekolah        : {}", data.school_name), false);
    let mut y = 648.0;
    for (i, aspect) in data.aspects.iter().enumerate() {
        page.fill_rect(45.0, y - 18.0, 505.0, 20.0, LIGHT_PURPLE);
        page.text(52.0, y - 4.0, 10.0, &format!("{}. {}", i + 1, aspect.label), true);
        y -= 34.0;
        for line in wrap_text(&format!("{} Hasil: {}", aspect.definition, aspect.result), 490.0, 9.0, false) {
            page.text(55.0, y, 9.0, &line, false); y -= 14.0;
        }
        y -= 10.0;
    }
    page.fill_rect(45.0, y - 18.0, 505.0, 20.0, LIGHT_PURPLE);
    page.text(52.0, y - 4.0, 10.0, "Minat karier (Holland RIASEC)", true);
    y -= 34.0;
    for line in wrap_text(&data.holland, 490.0, 9.0, false) { page.text(55.0, y, 9.0, &line, false); y -= 14.0; }
    page.text(48.0, 48.0, 7.5, &format!("Dicetak pada {}. Dokumen rahasia; interpretasi memerlukan konteks profesional.", data.printed_date), false);
    encode_encrypted_pdf(vec![cover, page], &data.report_no, "")
}

const PURPLE: (f32, f32, f32) = (0.39, 0.13, 0.65);
const PURPLE_DARK: (f32, f32, f32) = (0.24, 0.08, 0.43);
const LIGHT_PURPLE: (f32, f32, f32) = (0.96, 0.94, 0.98);
const LIGHT_GRAY: (f32, f32, f32) = (0.92, 0.92, 0.92);
const MID_GRAY: (f32, f32, f32) = (0.75, 0.75, 0.75);
const TEXT: (f32, f32, f32) = (0.10, 0.10, 0.12);

struct PageCanvas {
    width: f32,
    height: f32,
    ops: Vec<Operation>,
}

impl PageCanvas {
    fn new(width: f32, height: f32) -> Self {
        Self {
            width,
            height,
            ops: Vec::new(),
        }
    }

    fn text(&mut self, x: f32, y: f32, size: f32, value: &str, bold: bool) {
        self.text_colored(x, y, size, value, bold, TEXT);
    }

    fn text_colored(
        &mut self,
        x: f32,
        y: f32,
        size: f32,
        value: &str,
        bold: bool,
        color: (f32, f32, f32),
    ) {
        self.text_color(color);
        self.ops.push(Operation::new("BT", vec![]));
        self.ops.push(Operation::new(
            "Tf",
            vec![
                Object::Name(if bold { b"F2".to_vec() } else { b"F1".to_vec() }),
                size.into(),
            ],
        ));
        self.ops
            .push(Operation::new("Td", vec![x.into(), y.into()]));
        self.ops.push(Operation::new(
            "Tj",
            vec![Object::string_literal(clean_text(value))],
        ));
        self.ops.push(Operation::new("ET", vec![]));
    }

    fn centered(&mut self, y: f32, size: f32, value: &str, bold: bool) {
        let width = approx_width(value, size, bold);
        self.text(((self.width - width) / 2.0).max(10.0), y, size, value, bold);
    }

    fn centered_colored(
        &mut self,
        y: f32,
        size: f32,
        value: &str,
        bold: bool,
        color: (f32, f32, f32),
    ) {
        let width = approx_width(value, size, bold);
        self.text_colored(
            ((self.width - width) / 2.0).max(10.0),
            y,
            size,
            value,
            bold,
            color,
        );
    }

    fn wrapped_text(
        &mut self,
        x: f32,
        mut y: f32,
        width: f32,
        size: f32,
        leading: f32,
        value: &str,
        bold: bool,
        max_lines: usize,
    ) -> f32 {
        for line in wrap_text(value, width, size, bold)
            .into_iter()
            .take(max_lines)
        {
            self.text(x, y, size, &line, bold);
            y -= leading;
        }
        y
    }

    fn fill_rect(&mut self, x: f32, y: f32, width: f32, height: f32, color: (f32, f32, f32)) {
        self.ops.push(Operation::new(
            "rg",
            vec![color.0.into(), color.1.into(), color.2.into()],
        ));
        self.ops.push(Operation::new(
            "re",
            vec![x.into(), y.into(), width.into(), height.into()],
        ));
        self.ops.push(Operation::new("f", vec![]));
    }

    fn stroke_rect(&mut self, x: f32, y: f32, width: f32, height: f32, line_width: f32) {
        self.ops
            .push(Operation::new("RG", vec![0.into(), 0.into(), 0.into()]));
        self.ops.push(Operation::new("w", vec![line_width.into()]));
        self.ops.push(Operation::new(
            "re",
            vec![x.into(), y.into(), width.into(), height.into()],
        ));
        self.ops.push(Operation::new("S", vec![]));
    }

    fn line(&mut self, x1: f32, y1: f32, x2: f32, y2: f32, line_width: f32) {
        self.ops
            .push(Operation::new("RG", vec![0.into(), 0.into(), 0.into()]));
        self.ops.push(Operation::new("w", vec![line_width.into()]));
        self.ops
            .push(Operation::new("m", vec![x1.into(), y1.into()]));
        self.ops
            .push(Operation::new("l", vec![x2.into(), y2.into()]));
        self.ops.push(Operation::new("S", vec![]));
    }

    fn text_color(&mut self, color: (f32, f32, f32)) {
        self.ops.push(Operation::new(
            "rg",
            vec![color.0.into(), color.1.into(), color.2.into()],
        ));
    }
}

pub fn build_assessment_report(data: &ReportData, password: &str) -> anyhow::Result<Vec<u8>> {
    let mut pages = vec![build_summary_page(data)];
    pages.extend(build_method_pages(data));
    pages.extend(
        data.students
            .iter()
            .map(|student| build_student_page(data, student)),
    );
    encode_encrypted_pdf(pages, &data.report_no, password)
}

fn build_summary_page(data: &ReportData) -> PageCanvas {
    let mut page = PageCanvas::new(842.0, 595.0);
    let margin = 28.0;
    page.fill_rect(0.0, 0.0, page.width, page.height, (1.0, 1.0, 1.0));
    page.fill_rect(margin, 530.0, page.width - margin * 2.0, 38.0, PURPLE_DARK);
    page.centered_colored(
        545.0,
        15.0,
        "LAPORAN HASIL ASESMEN PSIKOLOGI SISWA",
        true,
        (1.0, 1.0, 1.0),
    );
    page.text(
        margin,
        512.0,
        8.5,
        &format!("Nomor laporan: {}", data.report_no),
        false,
    );
    page.text(
        580.0,
        512.0,
        8.5,
        &format!("Tanggal: {}", data.generated_date),
        false,
    );

    let preamble = format!(
        "Kepada Yth. Pimpinan dan PIC {}. Bersama laporan ini kami menyampaikan hasil asesmen siswa untuk paket {}. Laporan dapat dikirim meskipun sebagian hasil belum lengkap; status tersebut ditandai secara eksplisit pada tabel.",
        data.school_name, data.package_name
    );
    page.wrapped_text(
        margin,
        494.0,
        page.width - margin * 2.0,
        8.5,
        11.0,
        &preamble,
        false,
        3,
    );

    let table_top = 451.0;
    let table_width = page.width - margin * 2.0;
    let name_width = 148.0;
    let method_width = ((table_width - name_width) / data.methods.len().max(1) as f32).max(72.0);
    let header_height = 34.0;
    let row_height =
        ((table_top - 145.0 - header_height) / data.students.len().max(1) as f32).clamp(22.0, 29.0);
    page.fill_rect(
        margin,
        table_top - header_height,
        table_width,
        header_height,
        PURPLE,
    );
    page.stroke_rect(
        margin,
        table_top - header_height,
        table_width,
        header_height,
        0.8,
    );
    page.text_colored(
        margin + 6.0,
        table_top - 20.0,
        8.5,
        "Nama siswa",
        true,
        (1.0, 1.0, 1.0),
    );
    for (index, method) in data.methods.iter().enumerate() {
        let x = margin + name_width + method_width * index as f32;
        page.line(x, table_top - header_height, x, table_top, 0.5);
        let label = clip_text(&method.label, method_width - 8.0, 7.5, true);
        page.text_colored(
            x + 4.0,
            table_top - 20.0,
            7.5,
            &label,
            true,
            (1.0, 1.0, 1.0),
        );
    }

    let mut y = table_top - header_height;
    for (row_index, student) in data.students.iter().enumerate() {
        y -= row_height;
        if row_index % 2 == 0 {
            page.fill_rect(margin, y, table_width, row_height, (0.975, 0.975, 0.98));
        }
        page.stroke_rect(margin, y, table_width, row_height, 0.45);
        page.text(
            margin + 5.0,
            y + row_height / 2.0 - 3.0,
            7.5,
            &clip_text(&student.name, name_width - 10.0, 7.5, true),
            true,
        );
        for (index, method) in data.methods.iter().enumerate() {
            let x = margin + name_width + method_width * index as f32;
            page.line(x, y, x, y + row_height, 0.35);
            let result = student.results.iter().find(|r| r.key == method.key);
            let value = result
                .map(|r| {
                    if r.completed {
                        r.summary.as_str()
                    } else {
                        "BELUM"
                    }
                })
                .unwrap_or("BELUM");
            let clipped = clip_text(value, method_width - 7.0, 6.8, false);
            page.text(x + 3.5, y + row_height / 2.0 - 2.8, 6.8, &clipped, false);
        }
    }

    let incomplete = data
        .students
        .iter()
        .filter(|student| student.results.iter().any(|result| !result.completed))
        .count();
    page.text(
        margin,
        119.0,
        7.5,
        "Keterangan: BELUM = siswa belum menyelesaikan metode tersebut.",
        false,
    );
    page.text(
        margin,
        105.0,
        8.0,
        &format!(
            "Ringkasan: {} siswa, {} lengkap, {} masih memiliki hasil yang belum lengkap.",
            data.students.len(),
            data.students.len().saturating_sub(incomplete),
            incomplete
        ),
        true,
    );
    page.text(margin, 78.0, 8.0, "Pengirim laporan", true);
    page.text(
        margin,
        62.0,
        9.5,
        "a.n. Dewi Handayani H, M.Psi, Psikolog",
        true,
    );
    page.text(
        margin,
        48.0,
        8.0,
        "SIPP: 20120111 - 2024 - 02 - 3622",
        false,
    );
    page.text(
        540.0,
        62.0,
        7.5,
        &format!("Tujuan: {}", data.official_email),
        false,
    );
    page.text(
        540.0,
        48.0,
        7.5,
        "Dokumen rahasia - hanya untuk pihak sekolah terkait",
        true,
    );
    page
}

fn build_method_pages(data: &ReportData) -> Vec<PageCanvas> {
    let mut pages = Vec::new();
    for (page_index, chunk) in data.methods.chunks(3).enumerate() {
        let mut page = PageCanvas::new(595.0, 842.0);
        page.fill_rect(0.0, 0.0, page.width, page.height, (1.0, 1.0, 1.0));
        page.fill_rect(34.0, 775.0, 527.0, 36.0, PURPLE_DARK);
        page.centered_colored(
            788.0,
            14.0,
            "METODE ASESMEN DAN MANFAATNYA",
            true,
            (1.0, 1.0, 1.0),
        );
        page.wrapped_text(
            38.0,
            753.0,
            519.0,
            8.5,
            11.0,
            "Penjelasan berikut hanya memuat metode yang dipilih dalam paket ini. Interpretasi harus dibaca bersama konteks siswa dan tidak digunakan sebagai diagnosis tunggal.",
            false,
            4,
        );
        let mut y = 697.0;
        for method in chunk {
            page.fill_rect(38.0, y - 8.0, 519.0, 30.0, LIGHT_PURPLE);
            page.stroke_rect(38.0, y - 112.0, 519.0, 134.0, 0.55);
            page.text(50.0, y + 2.0, 11.0, &method.label, true);
            page.text(50.0, y - 22.0, 8.0, "Landasan dan cakupan", true);
            let next = page.wrapped_text(
                50.0,
                y - 36.0,
                495.0,
                8.0,
                10.5,
                &method.academic_description,
                false,
                5,
            );
            page.text(50.0, next - 5.0, 8.0, "Manfaat penggunaan", true);
            page.wrapped_text(
                50.0,
                next - 19.0,
                495.0,
                8.0,
                10.5,
                &method.benefit,
                false,
                4,
            );
            page.text(50.0, y - 99.0, 6.6, "Acuan utama", true);
            page.text(
                111.0,
                y - 99.0,
                6.6,
                &clip_text(&method.reference, 432.0, 6.6, false),
                false,
            );
            y -= 158.0;
        }
        page.text(
            38.0,
            36.0,
            7.5,
            &format!("{} - halaman metode {}", data.report_no, page_index + 1),
            false,
        );
        pages.push(page);
    }
    pages
}

fn build_student_page(data: &ReportData, student: &StudentReport) -> PageCanvas {
    let mut page = PageCanvas::new(595.0, 842.0);
    let x = 34.0;
    let width = 527.0;
    page.fill_rect(0.0, 0.0, page.width, page.height, (1.0, 1.0, 1.0));
    page.fill_rect(x, 782.0, width, 30.0, MID_GRAY);
    page.stroke_rect(x, 782.0, width, 30.0, 0.8);
    page.centered(793.0, 11.0, "HASIL LAPORAN PSIKOLOGIS", true);

    page.stroke_rect(x, 730.0, width, 52.0, 0.7);
    page.line(x, 756.0, x + width, 756.0, 0.45);
    page.text(x + 8.0, 765.0, 7.5, "NAMA", true);
    page.text(
        x + 92.0,
        765.0,
        8.0,
        &clip_text(&student.name, 210.0, 8.0, false),
        false,
    );
    page.text(x + 310.0, 765.0, 7.5, "TANGGAL LAHIR", true);
    page.text(
        x + 405.0,
        765.0,
        8.0,
        student.date_of_birth.as_deref().unwrap_or("-"),
        false,
    );
    page.text(x + 8.0, 739.0, 7.5, "JENIS KELAMIN", true);
    page.text(
        x + 92.0,
        739.0,
        8.0,
        student.gender.as_deref().unwrap_or("-"),
        false,
    );
    page.text(x + 310.0, 739.0, 7.5, "TANGGAL TES", true);
    page.text(x + 405.0, 739.0, 8.0, &data.generated_date, false);

    let table_top = 711.0;
    let header_h = 35.0;
    let row_h = 32.0;
    let no_w = 22.0;
    let aspect_w = 104.0;
    let desc_w = 281.0;
    let rating_w = 24.0;
    page.fill_rect(x, table_top - header_h, width, header_h, PURPLE);
    page.stroke_rect(x, table_top - header_h, width, header_h, 0.7);
    page.text_colored(x + 8.0, table_top - 21.0, 7.5, "NO", true, (1.0, 1.0, 1.0));
    page.text_colored(
        x + no_w + 7.0,
        table_top - 21.0,
        7.5,
        "ASPEK / METODE",
        true,
        (1.0, 1.0, 1.0),
    );
    page.text_colored(
        x + no_w + aspect_w + 7.0,
        table_top - 21.0,
        7.5,
        "HASIL DAN INTERPRETASI RINGKAS",
        true,
        (1.0, 1.0, 1.0),
    );
    for (index, label) in ["KS", "K", "C", "B", "BS"].iter().enumerate() {
        let cell_x = x + no_w + aspect_w + desc_w + rating_w * index as f32;
        page.line(cell_x, table_top - header_h, cell_x, table_top, 0.4);
        page.text_colored(
            cell_x + 6.0,
            table_top - 21.0,
            7.0,
            label,
            true,
            (1.0, 1.0, 1.0),
        );
    }

    let mut y = table_top - header_h;
    for (index, result) in student.results.iter().enumerate() {
        y -= row_h;
        if !result.completed {
            page.fill_rect(x, y, width, row_h, LIGHT_GRAY);
        } else if index % 2 == 0 {
            page.fill_rect(x, y, width, row_h, (0.98, 0.98, 0.985));
        }
        page.stroke_rect(x, y, width, row_h, 0.4);
        let col1 = x + no_w;
        let col2 = col1 + aspect_w;
        let col3 = col2 + desc_w;
        page.line(col1, y, col1, y + row_h, 0.35);
        page.line(col2, y, col2, y + row_h, 0.35);
        page.line(col3, y, col3, y + row_h, 0.35);
        page.text(x + 7.0, y + 12.0, 7.0, &(index + 1).to_string(), false);
        page.text(
            col1 + 5.0,
            y + 12.0,
            7.2,
            &clip_text(&result.label, aspect_w - 10.0, 7.2, true),
            true,
        );
        let summary = if result.completed {
            &result.summary
        } else {
            "Belum dikerjakan"
        };
        page.wrapped_text(
            col2 + 5.0,
            y + 19.0,
            desc_w - 10.0,
            6.8,
            8.2,
            summary,
            false,
            2,
        );
        for rating_index in 0..5 {
            let cell_x = col3 + rating_w * rating_index as f32;
            page.line(cell_x, y, cell_x, y + row_h, 0.3);
            if result.rating == Some((rating_index + 1) as u8) {
                page.fill_rect(
                    cell_x + 1.0,
                    y + 1.0,
                    rating_w - 2.0,
                    row_h - 2.0,
                    LIGHT_GRAY,
                );
                page.text(cell_x + 8.0, y + 12.0, 7.5, "X", true);
            }
        }
    }
    page.text(
        x,
        y - 13.0,
        6.7,
        "KS: Kurang Sekali   K: Kurang   C: Cukup   B: Baik   BS: Baik Sekali. Skala hanya untuk hasil normatif.",
        true,
    );

    let detail_top = y - 34.0;
    page.text(x, detail_top, 8.5, "Interpretasi per metode", true);
    let mut detail_y = detail_top - 15.0;
    for result in &student.results {
        let text = if result.completed {
            format!("{}: {}", result.label, result.detail)
        } else {
            format!(
                "{}: belum tersedia karena siswa belum menyelesaikan tes.",
                result.label
            )
        };
        page.text(x + 4.0, detail_y, 7.2, "-", true);
        detail_y =
            page.wrapped_text(x + 13.0, detail_y, width - 17.0, 7.1, 8.8, &text, false, 3) - 3.0;
        if detail_y < 185.0 {
            break;
        }
    }

    let completed = student
        .results
        .iter()
        .filter(|result| result.completed)
        .count();
    let recommendation = if completed == student.results.len() {
        "Hasil dapat digunakan sebagai bahan diskusi pengembangan siswa bersama psikolog dan Guru BK. Keputusan pendidikan tetap perlu mempertimbangkan observasi, riwayat belajar, serta konteks lingkungan siswa."
    } else {
        "Laporan ini bersifat parsial. Lengkapi metode yang masih berstatus belum dikerjakan sebelum mengambil kesimpulan menyeluruh. Hasil yang tersedia dapat digunakan sebagai bahan diskusi awal bersama psikolog dan Guru BK."
    };
    page.fill_rect(x, 98.0, 203.0, 72.0, LIGHT_PURPLE);
    page.stroke_rect(x, 98.0, 203.0, 72.0, 0.55);
    page.text(x + 8.0, 154.0, 8.0, "REKOMENDASI", true);
    page.wrapped_text(x + 8.0, 138.0, 187.0, 6.8, 8.2, recommendation, false, 5);

    page.stroke_rect(x + 203.0, 98.0, 324.0, 72.0, 0.55);
    page.text(x + 215.0, 154.0, 7.5, "Yogyakarta, 2026", true);
    page.text(x + 215.0, 140.0, 7.5, "Psikolog", true);
    page.text(
        x + 215.0,
        118.0,
        8.2,
        "Dewi Handayani H, M.Psi, Psikolog",
        true,
    );
    page.text(
        x + 215.0,
        105.0,
        7.0,
        "SIPP: 20120111 - 2024 - 02 - 3622",
        false,
    );
    page.text(
        x,
        74.0,
        6.8,
        &format!(
            "{} | {} | {}/{} metode selesai",
            data.report_no,
            data.school_name,
            completed,
            student.results.len()
        ),
        false,
    );
    page.text(
        x,
        60.0,
        6.8,
        "Dokumen rahasia. Interpretasi bukan diagnosis tunggal dan memerlukan konteks profesional.",
        true,
    );
    page
}

fn encode_encrypted_pdf(
    pages: Vec<PageCanvas>,
    title: &str,
    password: &str,
) -> anyhow::Result<Vec<u8>> {
    let mut document = Document::with_version("1.7");
    let pages_id = document.new_object_id();
    let regular_font = document.add_object(dictionary! {
        "Type" => "Font",
        "Subtype" => "Type1",
        "BaseFont" => "Helvetica",
        "Encoding" => "WinAnsiEncoding",
    });
    let bold_font = document.add_object(dictionary! {
        "Type" => "Font",
        "Subtype" => "Type1",
        "BaseFont" => "Helvetica-Bold",
        "Encoding" => "WinAnsiEncoding",
    });
    let resources_id = document.add_object(dictionary! {
        "Font" => dictionary! { "F1" => regular_font, "F2" => bold_font },
    });
    let mut page_ids = Vec::new();
    for page in pages {
        let content = Content {
            operations: page.ops,
        };
        let content_id = document.add_object(Stream::new(dictionary! {}, content.encode()?));
        let page_id = document.add_object(dictionary! {
            "Type" => "Page",
            "Parent" => pages_id,
            "Resources" => resources_id,
            "MediaBox" => vec![0.into(), 0.into(), page.width.into(), page.height.into()],
            "Contents" => content_id,
        });
        page_ids.push(page_id);
    }
    document.objects.insert(
        pages_id,
        Object::Dictionary(dictionary! {
            "Type" => "Pages",
            "Kids" => page_ids.iter().copied().map(Object::Reference).collect::<Vec<_>>(),
            "Count" => page_ids.len() as i64,
        }),
    );
    let catalog_id = document.add_object(dictionary! { "Type" => "Catalog", "Pages" => pages_id });
    let info_id = document.add_object(dictionary! {
        "Title" => Object::string_literal(clean_text(title)),
        "Author" => Object::string_literal("Dewi Handayani H, M.Psi, Psikolog"),
        "Subject" => Object::string_literal("Laporan hasil asesmen psikologi siswa"),
    });
    document.trailer.set("Root", catalog_id);
    document.trailer.set("Info", info_id);
    let file_id = uuid::Uuid::new_v4().as_bytes().to_vec();
    document.trailer.set(
        "ID",
        vec![
            Object::string_literal(file_id.clone()),
            Object::string_literal(file_id),
        ],
    );
    document.compress();

    let owner_password = format!("owner-{}", uuid::Uuid::new_v4().simple());
    let crypt_filter: Arc<dyn CryptFilter> = Arc::new(Aes128CryptFilter);
    let state = EncryptionState::try_from(EncryptionVersion::V4 {
        document: &document,
        encrypt_metadata: true,
        crypt_filters: BTreeMap::from([(b"StdCF".to_vec(), crypt_filter)]),
        stream_filter: b"StdCF".to_vec(),
        string_filter: b"StdCF".to_vec(),
        owner_password: &owner_password,
        user_password: password,
        permissions: lopdf::Permissions::PRINTABLE
            | lopdf::Permissions::PRINTABLE_IN_HIGH_QUALITY
            | lopdf::Permissions::COPYABLE_FOR_ACCESSIBILITY,
    })?;
    document.encrypt(&state)?;
    let mut output = Vec::new();
    document.save_to(&mut output)?;
    Ok(output)
}

fn clean_text(value: &str) -> String {
    value
        .replace(['\n', '\r', '\t'], " ")
        .replace('–', "-")
        .replace('—', "-")
        .replace('“', "\"")
        .replace('”', "\"")
        .replace('’', "'")
}

fn approx_width(value: &str, size: f32, bold: bool) -> f32 {
    value.chars().count() as f32 * size * if bold { 0.54 } else { 0.50 }
}

fn clip_text(value: &str, width: f32, size: f32, bold: bool) -> String {
    let cleaned = clean_text(value);
    if approx_width(&cleaned, size, bold) <= width {
        return cleaned;
    }
    let max_chars = ((width / (size * if bold { 0.54 } else { 0.50 })) as usize).max(4);
    let mut clipped: String = cleaned.chars().take(max_chars.saturating_sub(3)).collect();
    clipped.push_str("...");
    clipped
}

fn wrap_text(value: &str, width: f32, size: f32, bold: bool) -> Vec<String> {
    let max_chars = ((width / (size * if bold { 0.54 } else { 0.50 })) as usize).max(4);
    let mut lines = Vec::new();
    let mut current = String::new();
    for word in clean_text(value).split_whitespace() {
        if current.is_empty() {
            current.push_str(word);
        } else if current.chars().count() + 1 + word.chars().count() <= max_chars {
            current.push(' ');
            current.push_str(word);
        } else {
            lines.push(current);
            current = word.to_string();
        }
    }
    if !current.is_empty() {
        lines.push(current);
    }
    if lines.is_empty() {
        lines.push(String::new());
    }
    lines
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn report_is_encrypted_and_password_opens_it() {
        let data = ReportData {
            report_no: "LAP-TEST".into(),
            school_name: "SMA Uji".into(),
            official_email: "sekolah@example.com".into(),
            package_name: "Paket Uji".into(),
            generated_date: "20 Agustus 2026".into(),
            methods: vec![MethodInfo {
                key: "holland".into(),
                label: "Holland RIASEC".into(),
                academic_description: "Inventori minat vokasional.".into(),
                benefit: "Mendukung eksplorasi pilihan studi.".into(),
                reference: "Holland (1997); O*NET Interest Profiler Manual (2021).".into(),
            }],
            students: vec![StudentReport {
                name: "Siswa Uji".into(),
                date_of_birth: None,
                gender: None,
                results: vec![MethodResult {
                    key: "holland".into(),
                    label: "Holland RIASEC".into(),
                    summary: "Kode AS".into(),
                    detail: "Minat artistik dan sosial menonjol.".into(),
                    rating: Some(4),
                    completed: true,
                }],
            }],
        };
        let bytes = build_assessment_report(&data, "Test-9472").expect("pdf");
        if let Ok(path) = std::env::var("REPORT_PDF_SAMPLE_PATH") {
            std::fs::write(path, &bytes).expect("write sample report");
        }
        let document = Document::load_mem(&bytes).expect("encrypted pdf structure");
        assert!(document.is_encrypted());
        assert!(document.authenticate_password("Test-9472").is_ok());
        assert!(document.authenticate_password("wrong-password").is_err());
    }
}
