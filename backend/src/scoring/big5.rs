use crate::models::big5::{BigFiveItem, BigFiveQuestion, BigFiveResultDto, BigFiveTrait};

/// Trait key per item (O/C/E/A/N), reversed flag. Statements are the exact
/// 30 Indonesian items from the Java BigFiveItemBank.
fn bank() -> Vec<BigFiveItem> {
    let items: &[(&str, char, bool)] = &[
        ("Saya menikmati mengeksplorasi ide-ide baru.", 'O', false),
        ("Saya lebih nyaman dengan rutinitas yang sudah pasti.", 'O', true),
        ("Saya tertarik pada seni, musik, dan keindahan.", 'O', false),
        ("Saya sering berpikir secara imajinatif dan kreatif.", 'O', false),
        ("Saya penasaran dengan hal-hal yang belum saya kenal.", 'O', false),
        ("Saya lebih suka hal-hal yang sederhana dan sudah dikenal.", 'O', true),
        ("Saya selalu menyelesaikan tugas tepat waktu.", 'C', false),
        ("Saya cenderung rapi dan terorganisir.", 'C', false),
        ("Saya sering menunda pekerjaan sampai menit terakhir.", 'C', true),
        ("Saya merencanakan sesuatu sebelum memulainya.", 'C', false),
        ("Saya mudah kehilangan fokus pada satu hal.", 'C', true),
        ("Saya bertanggung jawab atas setiap hal yang saya kerjakan.", 'C', false),
        ("Saya merasa berenergi saat berada di banyak orang.", 'E', false),
        ("Saya lebih suka diam dan menyendiri dalam kumpulan orang.", 'E', true),
        ("Saya mudah memulai percakapan dengan orang baru.", 'E', false),
        ("Saya lebih nyaman bekerja sendiri daripada berkelompok.", 'E', true),
        ("Saya menikmati menjadi pusat perhatian.", 'E', false),
        ("Saya merasa lelah setelah bersosialisasi terlalu lama.", 'E', true),
        ("Saya mudah memahami perasaan orang lain.", 'A', false),
        ("Saya lebih memilih bekerja sama daripada berkompetisi.", 'A', false),
        ("Saya cenderung kritis terhadap pendapat orang lain.", 'A', true),
        ("Saya berusaha membantu orang lain yang membutuhkan.", 'A', false),
        ("Saya umumnya mempercayai niat baik orang lain.", 'A', false),
        ("Dalam persaingan, saya lebih mementingkan diri sendiri.", 'A', true),
        ("Saya mudah merasa cemas terhadap hal-hal kecil.", 'N', false),
        ("Saya tetap tenang saat menghadapi tekanan.", 'N', true),
        ("Perasaan saya mudah berubah-ubah.", 'N', false),
        ("Saya sering mengkhawatirkan masa depan.", 'N', false),
        ("Saya jarang merasa sedih atau putus asa.", 'N', true),
        ("Saya mudah tersinggung oleh kritik.", 'N', false),
    ];
    items
        .iter()
        .enumerate()
        .map(|(i, (statement, key, reversed))| BigFiveItem {
            no: (i + 1) as i32,
            trait_key: *key,
            reversed: *reversed,
            statement: statement.to_string(),
        })
        .collect()
}

pub fn questions() -> Vec<BigFiveQuestion> {
    bank()
        .into_iter()
        .map(|item| BigFiveQuestion {
            no: item.no,
            statement: item.statement,
        })
        .collect()
}

const MAX_SCORE: f64 = 30.0; // 6 items × 5

/// Percent score per trait: round((sum * 1000) / MAX_SCORE) / 10.0 — matches
/// Java's Math.round on a double (round-half-up to nearest whole).
pub fn score(answers: &std::collections::HashMap<String, i32>) -> Result<Vec<(char, f64)>, String> {
    if answers.len() != 30 {
        return Err("Harap jawab seluruh pertanyaan sebelum melihat hasil.".to_string());
    }
    let items = bank();
    let mut sums: std::collections::HashMap<char, i64> = std::collections::HashMap::new();
    for item in &items {
        let raw = answers.get(&item.no.to_string()).copied().ok_or_else(|| {
            format!("Jawaban tidak valid pada pertanyaan nomor {}.", item.no)
        })?;
        if !(1..=5).contains(&raw) {
            return Err(format!("Jawaban tidak valid pada pertanyaan nomor {}.", item.no));
        }
        let scored = if item.reversed { 6 - raw } else { raw };
        *sums.entry(item.trait_key).or_insert(0) += scored as i64;
    }
    Ok(["O", "C", "E", "A", "N"]
        .iter()
        .map(|k| {
            let ch = k.chars().next().unwrap();
            let sum = sums.get(&ch).copied().unwrap_or(0) as f64;
            let pct = ((sum * 1000.0 / MAX_SCORE).round()) / 10.0;
            (ch, pct)
        })
        .collect())
}

fn label(key: &str) -> &'static str {
    match key {
        "openness" => "Keterbukaan",
        "conscientiousness" => "Ketelitian",
        "extraversion" => "Ekstroversi",
        "agreeableness" => "Keramahan",
        _ => "Stabilitas Emosi",
    }
}

fn description(label: &str, level: &str) -> String {
    match (label, level) {
        ("Keterbukaan", "Rendah") => "Anda merasa nyaman dengan hal-hal yang pasti dan teruji.".to_string(),
        ("Keterbukaan", "Tinggi") => "Anda senang menjelajahi ide, pengalaman, dan kemungkinan baru.".to_string(),
        ("Keterbukaan", "Sedang") => "Anda terbuka pada hal baru, namun tetap menikmati kenyamanan rutinitas.".to_string(),
        ("Ketelitian", "Rendah") => "Anda lebih spontan dan fleksibel dalam mengatur waktu.".to_string(),
        ("Ketelitian", "Tinggi") => "Anda terencana, teratur, dan dapat diandalkan.".to_string(),
        ("Ketelitian", "Sedang") => "Anda cukup teratur, meski kadang menyesuaikan rencana.".to_string(),
        ("Ekstroversi", "Rendah") => "Anda lebih tenang dan mengisi energi dari dalam diri.".to_string(),
        ("Ekstroversi", "Tinggi") => "Anda bergairah dalam pergaulan dan mudah terhubung dengan orang lain.".to_string(),
        ("Ekstroversi", "Sedang") => "Anda seimbang antara waktu bersama orang lain dan waktu sendiri.".to_string(),
        ("Keramahan", "Rendah") => "Anda cenderung terus terang dan mengutamakan ketegasan.".to_string(),
        ("Keramahan", "Tinggi") => "Anda empatik, kooperatif, dan peduli pada orang lain.".to_string(),
        ("Keramahan", "Sedang") => "Anda ramah, namun tetap menjaga batasan.".to_string(),
        ("Stabilitas Emosi", "Rendah") => "Anda cukup peka terhadap tekanan dan perubahan suasana hati.".to_string(),
        ("Stabilitas Emosi", "Tinggi") => "Anda tenang, tabah, dan tidak mudah goyah oleh tekanan.".to_string(),
        ("Stabilitas Emosi", "Sedang") => "Anda umumnya tenang, dengan sesekali merasa cemas.".to_string(),
        _ => String::new(),
    }
}

fn level(value: f64) -> &'static str {
    if value < 40.0 {
        "Rendah"
    } else if value > 60.0 {
        "Tinggi"
    } else {
        "Sedang"
    }
}

/// Builds the interpreted DTO from raw percent scores (key order O,C,E,A,N).
pub fn interpret(raw: &[(char, f64)]) -> BigFiveResultDto {
    let mut map = std::collections::HashMap::new();
    for (k, v) in raw {
        map.insert(k.to_string().to_lowercase(), *v);
    }
    let openness = map.get("o").copied().unwrap_or(0.0);
    let conscientiousness = map.get("c").copied().unwrap_or(0.0);
    let extraversion = map.get("e").copied().unwrap_or(0.0);
    let agreeableness = map.get("a").copied().unwrap_or(0.0);
    let neuroticism_raw = map.get("n").copied().unwrap_or(0.0);
    let neuroticism = (100.0 - neuroticism_raw).max(0.0);

    let traits = vec![
        trait_entry("openness", openness),
        trait_entry("conscientiousness", conscientiousness),
        trait_entry("extraversion", extraversion),
        trait_entry("agreeableness", agreeableness),
        trait_entry("neuroticism", neuroticism),
    ];

    // Headline archetype: trait with max display value; ties resolve to the
    // LAST maximal entry in O,C,E,A,N order (Java LinkedHashMap + max).
    let mut headline = "Sang Penyeimbang".to_string();
    let mut best: f64 = -1.0;
    for t in &traits {
        if t.value >= best {
            best = t.value;
            headline = match t.key.as_str() {
                "openness" => "Sang Penjelajah Ide".to_string(),
                "conscientiousness" => "Sang Perencana".to_string(),
                "extraversion" => "Sang Penghubung".to_string(),
                "agreeableness" => "Sang Pendukung".to_string(),
                _ => "Sang Penyeimbang".to_string(),
            };
        }
    }

    BigFiveResultDto {
        headline,
        openness,
        conscientiousness,
        extraversion,
        agreeableness,
        neuroticism: neuroticism_raw,
        traits,
    }
}

fn trait_entry(key: &str, value: f64) -> BigFiveTrait {
    let l = label(key);
    let lv = level(value);
    BigFiveTrait {
        key: key.to_string(),
        label: l.to_string(),
        value,
        level: lv.to_string(),
        description: description(l, lv),
    }
}
