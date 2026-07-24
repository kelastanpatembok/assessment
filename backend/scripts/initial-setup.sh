#!/usr/bin/env bash
# initial-setup.sh — idempotent DISC + PAPI Kostick question bank reset
#
# The DISC question bank must always have 24 blocks x 4 statements (96 rows),
# sourced from "Psikogram DISC_simulasidewi.xlsx" (tab "DISC Test", cross-checked
# against the P/K scoring formulas on the "Input" tab). This project is still in
# development, so this script clears disc_questions (and disc_results, which are
# stale once block numbering changes) and reseeds from scratch. Safe to rerun.
#
# The PAPI Kostick section reseeds papi_questions (90 pairs x 2 statements = 180
# rows) and papi_descriptions (20 traits). Statement text is transcribed verbatim
# from docs/papi.pdf (pages 1-5; the instructions page is page 6, the LAST page
# of that PDF). The pair_no -> trait_code assignment was transcribed from the
# official PAPI Kostick manual scoring key/stencil (photographed 2026-07-22) and
# cross-checked against a filled-in worked example (each of the 20 traits appears
# in exactly 9 of the 90 pairs, and the worked example's per-trait totals matched
# the transcribed key exactly) — no longer a generated placeholder. See
# docs/todo-papi-test.md for the transcription record. papi_descriptions'
# high_desc/low_desc text is still a two-band placeholder grounded in the one
# example paragraph per trait visible in the "URAIAN PAPIKOSTIK" tab of
# docs/papi-result.xls, not an official manual — that piece is still open.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
POSTGRES_ENV="${ROOT_DIR}/backend/.env"

maybe_add_postgres_bin() {
  if command -v psql >/dev/null 2>&1; then
    return
  fi

  local candidates=(
    "/Applications/Postgres.app/Contents/Versions/latest/bin"
    "/opt/homebrew/opt/postgresql@15/bin"
    "/usr/local/opt/postgresql@15/bin"
  )

  local candidate
  for candidate in "${candidates[@]}"; do
    if [ -x "${candidate}/psql" ]; then
      export PATH="${candidate}:$PATH"
      return
    fi
  done
}

need_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

load_env_file() {
  if [ ! -f "$1" ]; then
    echo "Missing env file: $1" >&2
    exit 1
  fi

  # Extract only the keys we need — the file has non-bash-safe lines
  # (e.g. dotted keys) so it can't be safely `source`d wholesale.
  DATABASE_URL=$(sed -nE 's/^DATABASE_URL=(.*)$/\1/p' "$1" | head -1)
  DATABASE_USERNAME=$(sed -nE 's/^DATABASE_USERNAME=(.*)$/\1/p' "$1" | head -1)
  DATABASE_PASSWORD=$(sed -nE 's/^DATABASE_PASSWORD=(.*)$/\1/p' "$1" | head -1)
}

parse_jdbc_url() {
  local jdbc_url="$1"
  PGHOST=$(printf '%s' "$jdbc_url" | sed -E 's#^jdbc:postgresql://([^:/]+).*#\1#')
  PGPORT=$(printf '%s' "$jdbc_url" | sed -nE 's#^jdbc:postgresql://[^:/]+:([0-9]+)/.*#\1#p')
  PGDATABASE=$(printf '%s' "$jdbc_url" | sed -E 's#^.*/([^/?]+)(\?.*)?$#\1#')
  PGPORT="${PGPORT:-5432}"
}

maybe_add_postgres_bin
need_cmd psql

load_env_file "$POSTGRES_ENV"
DATABASE_URL_VALUE="${DATABASE_URL:-}"
DATABASE_USERNAME_VALUE="${DATABASE_USERNAME:-}"
DATABASE_PASSWORD_VALUE="${DATABASE_PASSWORD:-}"

if [ -z "$DATABASE_URL_VALUE" ] || [ -z "$DATABASE_USERNAME_VALUE" ]; then
  echo "PostgreSQL env is incomplete in ${POSTGRES_ENV}" >&2
  exit 1
fi

parse_jdbc_url "$DATABASE_URL_VALUE"

echo "Resetting DISC question bank on ${PGDATABASE}@${PGHOST}:${PGPORT} ..."

PGPASSWORD="${DATABASE_PASSWORD_VALUE}" psql \
  --host="$PGHOST" \
  --port="$PGPORT" \
  --username="$DATABASE_USERNAME_VALUE" \
  --dbname="$PGDATABASE" \
  --set=ON_ERROR_STOP=1 \
  -v ON_ERROR_STOP=1 <<'SQL'
BEGIN;

-- Dev-only data: safe to wipe. disc_results block/item refs (in the answers
-- JSONB) go stale the moment disc_questions is reseeded with new block_no
-- values, so results are cleared alongside the question bank.
TRUNCATE TABLE disc_results RESTART IDENTITY;
TRUNCATE TABLE disc_questions RESTART IDENTITY;

-- 24 blocks x 4 statements, transcribed from "Psikogram DISC_simulasidewi.xlsx"
-- (tab "DISC Test"). Category per item derived from the "Input" tab's P/K
-- scoring formulas — each block yields exactly one D, one I, one S, one C.
INSERT INTO disc_questions (block_no, item_no, category, statement) VALUES
  (1, 1, 'S', 'Gampangan, Mudah setuju'),
  (1, 2, 'I', 'Percaya, Mudah percaya pada orang'),
  (1, 3, 'D', 'Petualang, Mengambil resiko'),
  (1, 4, 'C', 'Toleran, Menghormati'),
  (2, 1, 'C', 'Lembut suara, Pendiam'),
  (2, 2, 'D', 'Optimistik, Visioner'),
  (2, 3, 'I', 'Pusat Perhatian, Suka gaul'),
  (2, 4, 'S', 'Pendamai, Membawa Harmoni'),
  (3, 1, 'I', 'Menyemangati orang'),
  (3, 2, 'C', 'Berusaha sempurna'),
  (3, 3, 'S', 'Bagian dari kelompok'),
  (3, 4, 'D', 'Ingin membuat tujuan'),
  (4, 1, 'C', 'Menjadi frustrasi'),
  (4, 2, 'S', 'Menyimpan perasaan saya'),
  (4, 3, 'I', 'Menceritakan sisi saya'),
  (4, 4, 'D', 'Siap beroposisi'),
  (5, 1, 'I', 'Hidup, Suka bicara'),
  (5, 2, 'D', 'Gerak cepat, Tekun'),
  (5, 3, 'S', 'Usaha menjaga keseimbangan'),
  (5, 4, 'C', 'Usaha mengikuti aturan'),
  (6, 1, 'C', 'Kelola waktu secara efisien'),
  (6, 2, 'D', 'Sering terburu-buru, Merasa tertekan'),
  (6, 3, 'I', 'Masalah sosial itu penting'),
  (6, 4, 'S', 'Suka selesaikan apa yang saya mulai'),
  (7, 1, 'S', 'Tolak perubahan mendadak'),
  (7, 2, 'I', 'Cenderung janji berlebihan'),
  (7, 3, 'C', 'Tarik diri di tengah tekanan'),
  (7, 4, 'D', 'Tidak takut bertempur'),
  (8, 1, 'I', 'Penyemangat yang baik'),
  (8, 2, 'S', 'Pendengar yang baik'),
  (8, 3, 'C', 'Penganalisa yang baik'),
  (8, 4, 'D', 'Delegator yang baik'),
  (9, 1, 'D', 'Hasil adalah penting'),
  (9, 2, 'C', 'Lakukan dengan benar, Akurasi penting'),
  (9, 3, 'I', 'Dibuat menyenangkan'),
  (9, 4, 'S', 'Mari kerjakan bersama'),
  (10, 1, 'C', 'Akan berjalan terus tanpa kontrol diri'),
  (10, 2, 'D', 'Akan membeli sesuai dorongan hati'),
  (10, 3, 'S', 'Akan menunggu, Tanpa tekanan'),
  (10, 4, 'I', 'Akan mengusahakan yang kuinginkan'),
  (11, 1, 'S', 'Ramah, Mudah bergabung'),
  (11, 2, 'I', 'Unik, Bosan rutinitas'),
  (11, 3, 'D', 'Aktif mengubah sesuatu'),
  (11, 4, 'C', 'Ingin hal-hal yang pasti'),
  (12, 1, 'S', 'Non-konfrontasi, Menyerah'),
  (12, 2, 'C', 'Dipenuhi hal detail'),
  (12, 3, 'I', 'Perubahan pada menit terakhir'),
  (12, 4, 'D', 'Menuntut, Kasar'),
  (13, 1, 'D', 'Ingin kemajuan'),
  (13, 2, 'S', 'Puas dengan segalanya'),
  (13, 3, 'I', 'Terbuka memperlihatkan perasaan'),
  (13, 4, 'C', 'Rendah hati, Sederhana'),
  (14, 1, 'C', 'Tenang, Pendiam'),
  (14, 2, 'I', 'Bahagia, Tanpa beban'),
  (14, 3, 'S', 'Menyenangkan, Baik hati'),
  (14, 4, 'D', 'Tak gentar, Berani'),
  (15, 1, 'S', 'Menggunakan waktu berkualitas dgn teman'),
  (15, 2, 'C', 'Rencanakan masa depan, Bersiap'),
  (15, 3, 'I', 'Bepergian demi petualangan baru'),
  (15, 4, 'D', 'Menerima ganjaran atas tujuan yg dicapai'),
  (16, 1, 'D', 'Aturan perlu dipertanyakan'),
  (16, 2, 'C', 'Aturan membuat adil'),
  (16, 3, 'I', 'Aturan membuat bosan'),
  (16, 4, 'S', 'Aturan membuat aman'),
  (17, 1, 'C', 'Pendidikan, Kebudayaan'),
  (17, 2, 'D', 'Prestasi, Ganjaran'),
  (17, 3, 'S', 'Keselamatan, keamanan'),
  (17, 4, 'I', 'Sosial, Perkumpulan kelompok'),
  (18, 1, 'D', 'Memimpin, Pendekatan langsung'),
  (18, 2, 'I', 'Suka bergaul, Antusias'),
  (18, 3, 'S', 'Dapat diramal, Konsisten'),
  (18, 4, 'C', 'Waspada, Hati-hati'),
  (19, 1, 'D', 'Tidak mudah dikalahkan'),
  (19, 2, 'S', 'Kerjakan sesuai perintah, Ikut pimpinan'),
  (19, 3, 'I', 'Mudah terangsang, Riang'),
  (19, 4, 'C', 'Ingin segalanya teratur, Rapi'),
  (20, 1, 'D', 'Saya akan pimpin mereka'),
  (20, 2, 'S', 'Saya akan melaksanakan'),
  (20, 3, 'I', 'Saya akan meyakinkan mereka'),
  (20, 4, 'C', 'Saya dapatkan fakta'),
  (21, 1, 'S', 'Memikirkan orang dahulu'),
  (21, 2, 'D', 'Kompetitif, Suka tantangan'),
  (21, 3, 'I', 'Optimis, Positif'),
  (21, 4, 'C', 'Pemikir logis, Sistematik'),
  (22, 1, 'S', 'Menyenangkan orang, Mudah setuju'),
  (22, 2, 'I', 'Tertawa lepas, Hidup'),
  (22, 3, 'D', 'Berani, Tak gentar'),
  (22, 4, 'C', 'Tenang, Pendiam'),
  (23, 1, 'D', 'Ingin otoritas lebih'),
  (23, 2, 'I', 'Ingin kesempatan baru'),
  (23, 3, 'S', 'Menghindari konflik'),
  (23, 4, 'C', 'Ingin petunjuk yang jelas'),
  (24, 1, 'S', 'Dapat diandalkan, Dapat dipercaya'),
  (24, 2, 'I', 'Kreatif, Unik'),
  (24, 3, 'D', 'Garis dasar, Orientasi hasil'),
  (24, 4, 'C', 'Jalankan standar yang tinggi, Akurat');

COMMIT;
SQL

COUNT=$(PGPASSWORD="${DATABASE_PASSWORD_VALUE}" psql \
  --host="$PGHOST" \
  --port="$PGPORT" \
  --username="$DATABASE_USERNAME_VALUE" \
  --dbname="$PGDATABASE" \
  --tuples-only --no-align \
  -c "SELECT count(*) FROM disc_questions;")

echo "Done — disc_questions now has ${COUNT} rows (24 blocks x 4 items expected)."

echo "Resetting PAPI Kostick question bank on ${PGDATABASE}@${PGHOST}:${PGPORT} ..."

PGPASSWORD="${DATABASE_PASSWORD_VALUE}" psql \
  --host="$PGHOST" \
  --port="$PGPORT" \
  --username="$DATABASE_USERNAME_VALUE" \
  --dbname="$PGDATABASE" \
  --set=ON_ERROR_STOP=1 \
  -v ON_ERROR_STOP=1 <<'SQL'
BEGIN;

-- Dev-only data: safe to wipe. papi_results.answers references pair_no values
-- that go stale the moment papi_questions is reseeded, so results are cleared
-- alongside the question bank (same convention as disc_results above).
TRUNCATE TABLE papi_results RESTART IDENTITY;
TRUNCATE TABLE papi_questions RESTART IDENTITY;
TRUNCATE TABLE papi_descriptions RESTART IDENTITY;

-- 90 pairs x 2 statements (A/B), transcribed verbatim from docs/papi.pdf
-- pages 1-5. trait_code assignment is the official PAPI Kostick scoring key,
-- transcribed from the manual's scoring stencil and cross-checked against a
-- worked example (see comment header of this script).
INSERT INTO papi_questions (pair_no, item_letter, trait_code, statement) VALUES
  (1, 'A', 'G', 'Saya seorang pekerja “keras”'),
  (1, 'B', 'E', 'Saya bukan seorang “pemurung”'),
  (2, 'A', 'A', 'Saya suka bekerja lebih baik dari orang lain'),
  (2, 'B', 'N', 'Saya suka bekerja sampai selesai'),
  (3, 'A', 'P', 'Saya suka memperagakan kepada orang lain tentang bagaimana caranya melakukan sesuatu'),
  (3, 'B', 'A', 'Saya ingin bekerja sebaik mungkin'),
  (4, 'A', 'X', 'Saya suka berkelakar'),
  (4, 'B', 'P', 'Saya suka mengatakan kepada orang lain apa yang harus dikerjakannya'),
  (5, 'A', 'B', 'Saya suka berkumpul dengan kelompok-kelompok'),
  (5, 'B', 'X', 'Saya suka diperhatikan oleh orang lain'),
  (6, 'A', 'O', 'Saya senang bersahabat dengan intim (sangat dekat)'),
  (6, 'B', 'B', 'Saya senang berkelompok'),
  (7, 'A', 'Z', 'Saya cepat berubah bila saya rasa hal itu diperlukan'),
  (7, 'B', 'O', 'Saya berusaha untuk intim (dekat) dengan teman-teman'),
  (8, 'A', 'K', 'Saya suka “memukul balik” (membalas) jika saya benar-benar disakiti'),
  (8, 'B', 'Z', 'Saya suka melakukan hal-hal yang baru dan berbeda'),
  (9, 'A', 'F', 'Saya ingin atasan saya menyukai saya'),
  (9, 'B', 'K', 'Saya suka mengatakan kepada orang lain jika mereka salah'),
  (10, 'A', 'W', 'Saya suka mengikuti perintah-perintah yang diberikan kepada saya'),
  (10, 'B', 'F', 'Saya suka membiarkan orang lain mengatur saya'),
  (11, 'A', 'G', 'Saya bekerja “keras” (sekuat tenaga)'),
  (11, 'B', 'C', 'Saya orang yang tertib, saya meletakkan segala sesuatu pada tempatnya'),
  (12, 'A', 'L', 'Saya bujuk orang lain untuk melakukan apa yang saya inginkan'),
  (12, 'B', 'E', 'Saya bukan orang yang cepat marah'),
  (13, 'A', 'P', 'Saya suka mengatakan kepada kelompok apa yang harus dilakukan'),
  (13, 'B', 'N', 'Saya selalu tetap bekerja sampai selesai'),
  (14, 'A', 'X', 'Saya selalu ingin diperhatikan'),
  (14, 'B', 'A', 'Saya selalu ingin berhasil'),
  (15, 'A', 'B', 'Saya ingin “diterima” oleh kelompok'),
  (15, 'B', 'P', 'Saya suka membantu menyadarkan pemikiran orang lain'),
  (16, 'A', 'O', 'Saya cemas jika orang lain tidak menyukai saya'),
  (16, 'B', 'X', 'Saya senang jika orang-orang memperhatikan saya'),
  (17, 'A', 'Z', 'Saya suka mencoba sesuatu yang baru'),
  (17, 'B', 'B', 'Saya lebih menyukai bekerja bersama orang lain daripada bekerja sendiri'),
  (18, 'A', 'K', 'Terkadang saya memaki orang lain jika ada kesalahan'),
  (18, 'B', 'O', 'Saya bingung jika seseorang tidak menyukai saya'),
  (19, 'A', 'F', 'Saya suka membiarkan jika orang lain mengatur saya'),
  (19, 'B', 'Z', 'Saya suka mencoba pekerjaan baru dan berbeda'),
  (20, 'A', 'W', 'Saya menyukai petunjuk-petunjuk yang terperinci'),
  (20, 'B', 'K', 'Saya suka mengatakan kepada orang lain jika mereka mengganggu saya'),
  (21, 'A', 'G', 'Saya selalu bekerja “keras”'),
  (21, 'B', 'D', 'Saya suka bekerja dengan cermat dan terperinci'),
  (22, 'A', 'L', 'Saya berusaha untuk menjadi pemimpin yang baik'),
  (22, 'B', 'C', 'Saya seorang organisator yang baik'),
  (23, 'A', 'I', 'Saya seorang yang cepat marah'),
  (23, 'B', 'E', 'Saya seorang yang lambat dalam mengambil keputusan'),
  (24, 'A', 'X', 'Saya senang mengerjakan beberapa pekerjaan dalam waktu yang bersamaan'),
  (24, 'B', 'N', 'Saya lebih suka diam jika berada di dalam kelompok'),
  (25, 'A', 'B', 'Saya senang jika diundang'),
  (25, 'B', 'A', 'Saya ingin melakukan sesuatu lebih baik dari yang lain'),
  (26, 'A', 'O', 'Saya suka berteman secara intim (sangat dekat)'),
  (26, 'B', 'P', 'Saya suka memberi nasihat kepada orang lain'),
  (27, 'A', 'Z', 'Saya suka melakukan hal yang baru dan berbeda'),
  (27, 'B', 'X', 'Saya suka bercerita mengenai bagaimana saya mengelola tugas –tugas yang saya kerjakan'),
  (28, 'A', 'K', 'Saya sangat mempertahankan kebenaran'),
  (28, 'B', 'B', 'Saya suka bergabung di dalam suatu kelompok'),
  (29, 'A', 'F', 'Saya tidak mau berbeda dengan orang lain'),
  (29, 'B', 'O', 'Saya berusaha untuk sangat intim (dekat) dengan orang lain'),
  (30, 'A', 'W', 'Saya suka dipandu oleh orang lain bagaimana cara mengerjakan suatu pekerjaan tertentu'),
  (30, 'B', 'Z', 'Saya mudah merasa bosan'),
  (31, 'A', 'G', 'Saya bekerja keras'),
  (31, 'B', 'R', 'Saya banyak berfikir dan berencana'),
  (32, 'A', 'L', 'Saya memimpin kelompok'),
  (32, 'B', 'D', 'Saya tertarik dengan hal-hal kecil (detail)'),
  (33, 'A', 'I', 'Saya cepat dan mudah mengambil keputusan'),
  (33, 'B', 'C', 'Saya meletakkan segala sesuatu secara rapi dan teratur'),
  (34, 'A', 'T', 'Saya mengerjakan tugas-tugas dengan cepat'),
  (34, 'B', 'E', 'Saya jarang marah atau sedih'),
  (35, 'A', 'B', 'Saya ingin menjadi bagian dalam kelompok'),
  (35, 'B', 'N', 'Pada suatu waktu, saya hanya ingin mengerjakan satu tugas saja'),
  (36, 'A', 'O', 'Saya berusaha untuk dekat dengan teman-teman saya'),
  (36, 'B', 'A', 'Saya berusaha keras untuk menjadi yang terbaik'),
  (37, 'A', 'Z', 'Saya menyukai mode baju baru dan tipe-tipe mobil baru'),
  (37, 'B', 'P', 'Saya ingin menjadi penanggung jawab bagi orang lain'),
  (38, 'A', 'K', 'Saya suka berdebat'),
  (38, 'B', 'X', 'Saya ingin diperhatikan'),
  (39, 'A', 'F', 'Saya senang diatur oleh orang lain'),
  (39, 'B', 'B', 'Saya senang menjadi anggota dari suatu kelompok'),
  (40, 'A', 'W', 'Saya senang mengikuti tata tertib peraturan'),
  (40, 'B', 'O', 'Saya menyukai orang-orang yang mengenal diri saya'),
  (41, 'A', 'G', 'Saya bekerja sangat keras'),
  (41, 'B', 'S', 'Saya sangat bersahabat'),
  (42, 'A', 'L', 'Orang lain beranggapan bahwa saya adalah seorang pemimpin yang baik'),
  (42, 'B', 'R', 'Saya berfikir jauh kedepan dan terperinci'),
  (43, 'A', 'I', 'Terkadang saya memanfaatkan peluang'),
  (43, 'B', 'D', 'Saya sering meributkan hal sepele'),
  (44, 'A', 'T', 'Orang lain menganggap saya bekerja secara cepat'),
  (44, 'B', 'C', 'Orang lain menganggap saya menempatkan segala sesuatu secara rapi dan teratur'),
  (45, 'A', 'V', 'Saya suka dengan permainan dan olahraga'),
  (45, 'B', 'E', 'Saya sangat ramah'),
  (46, 'A', 'O', 'Saya menyukai jika orang lain bersikap intim dan bersahabat'),
  (46, 'B', 'N', 'Saya selalu berusaha untuk menyelesaikan apa yang saya mulai'),
  (47, 'A', 'Z', 'Saya suka bereksperimen dan mencoba sesuatu yang baru'),
  (47, 'B', 'A', 'Saya suka mengerjakan pekerjaan yang sulit dengan baik'),
  (48, 'A', 'K', 'Saya ingin diperlakukan secara adil'),
  (48, 'B', 'P', 'Saya suka memberi tahu orang lain bagaimana cara mengerjakan suatu hal'),
  (49, 'A', 'F', 'Saya suka mengerjakan apa yang dituntut kepada saya'),
  (49, 'B', 'X', 'Saya suka menarik perhatian'),
  (50, 'A', 'W', 'Saya suka petunjuk yang terperinci untuk melakukan sesuatu'),
  (50, 'B', 'B', 'Saya merasa diri saya tidak mengenal lelah dalam bekerja sehari -hari'),
  (51, 'A', 'G', 'Saya selalu berusaha mengerjakan tugas secara sempurna'),
  (51, 'B', 'V', 'Saya merasa bahwa saya tidak mengenal lelah dalam mengerjakan pekerjaan sehari-hari'),
  (52, 'A', 'L', 'Saya adalah tipe seorang pemimpin'),
  (52, 'B', 'S', 'Saya mudah berteman'),
  (53, 'A', 'I', 'Saya memanfaatkan peluang'),
  (53, 'B', 'R', 'Saya banyak berfikir'),
  (54, 'A', 'T', 'Saya bekerja dengan cara yang cepat'),
  (54, 'B', 'D', 'Saya mengerjakan hal-hal yang detail'),
  (55, 'A', 'V', 'Banyak energi saya tercurah pada permainan dan olahraga'),
  (55, 'B', 'C', 'Saya menempatkan segala sesuatu secara rapi dan teratur'),
  (56, 'A', 'S', 'Saya bergaul dengan semua orang'),
  (56, 'B', 'E', 'Saya pandai mengendalikan diri'),
  (57, 'A', 'Z', 'Saya ingin berkenalan dengan orang baru dan mengerjakan sesuatu yang baru'),
  (57, 'B', 'N', 'Saya selalu ingin menyelesaikan pekerjaan yang saya mulai'),
  (58, 'A', 'K', 'Biasanya saya mempertahankan apa yang saya yakini'),
  (58, 'B', 'A', 'Biasanya saya bekerja keras'),
  (59, 'A', 'F', 'Saya menyukai saran dari orang yang saya kagumi'),
  (59, 'B', 'P', 'Saya senang diatur orang lain'),
  (60, 'A', 'W', 'Saya biarkan orang lain mempengaruhi saya'),
  (60, 'B', 'X', 'Saya suka menerima banyak perhatian'),
  (61, 'A', 'G', 'Biasanya saya bekerja sangat keras'),
  (61, 'B', 'T', 'Biasanya saya bekerja cepat'),
  (62, 'A', 'L', 'Jika saya berbicara, kelompok saya mendengarkan'),
  (62, 'B', 'V', 'Saya terampil menggunakan alat-alat kerja'),
  (63, 'A', 'I', 'Saya lambat dalam pergaulan'),
  (63, 'B', 'S', 'Saya lambat dalam mengatur pemikiran saya'),
  (64, 'A', 'T', 'Biasanya saya makan secara cepat'),
  (64, 'B', 'R', 'Saya suka membaca'),
  (65, 'A', 'V', 'Saya suka berganti-ganti pekerjaan'),
  (65, 'B', 'D', 'Saya suka pekerjaan yang dilakukan secara teliti'),
  (66, 'A', 'S', 'Saya berteman sebanyak mungkin'),
  (66, 'B', 'C', 'Saya dapat menemukan bagian yang hilang'),
  (67, 'A', 'R', 'Perencanaan saya jauh ke masa depan'),
  (67, 'B', 'E', 'Saya selalu bersikap ramah tamah'),
  (68, 'A', 'K', 'Saya merasa bangga akan nama baik saya'),
  (68, 'B', 'N', 'Saya menghadapi permasalahan sampai terpecahkan'),
  (69, 'A', 'F', 'Saya patuh kepada orang yang saya kagumi'),
  (69, 'B', 'A', 'Saya ingin menjadi orang yang berhasil'),
  (70, 'A', 'W', 'Saya senang jika orang lain mengambil keputusan untuk kelompok saya'),
  (70, 'B', 'P', 'Saya suka mengambil keputusan untuk kelompok saya'),
  (71, 'A', 'G', 'Saya selalu berusaha sangat “keras”'),
  (71, 'B', 'I', 'Saya cepat dan mudah mengambil keputusan'),
  (72, 'A', 'L', 'Biasanya kelompok saya mengerjakan hal yang saya inginkan'),
  (72, 'B', 'T', 'Biasanya saya tergesa-gesa'),
  (73, 'A', 'I', 'Seringkali saya merasa lelah'),
  (73, 'B', 'V', 'Saya lambat dalam mengambil keputusan'),
  (74, 'A', 'T', 'Saya bekerja secara cepat'),
  (74, 'B', 'S', 'Saya mudah mendapat teman'),
  (75, 'A', 'V', 'Biasanya saya bersemangat atau bergairah'),
  (75, 'B', 'R', 'Saya memanfaatkan sebagian besar waktu saya untuk berfikir'),
  (76, 'A', 'S', 'Saya sangat hangat (ramah) kepada orang lain'),
  (76, 'B', 'D', 'Saya menyukai pekerjaan yang menuntut ketepatan'),
  (77, 'A', 'R', 'Saya banyak berfikir dan berencana'),
  (77, 'B', 'C', 'Saya meletakkan segala sesuatu pada tempatnya'),
  (78, 'A', 'D', 'Saya menyukai pekerjaan yang mudah'),
  (78, 'B', 'E', 'Saya tidak cepat marah'),
  (79, 'A', 'F', 'Saya senang mengikuti orang yang saya kagumi'),
  (79, 'B', 'N', 'Saya selalu menyelesaikan pekerjaan yang saya mulai'),
  (80, 'A', 'W', 'Saya menyukai petunjuk yang jelas'),
  (80, 'B', 'A', 'Saya suka bekerja keras'),
  (81, 'A', 'G', 'Saya mengikuti apa yang saya inginkan'),
  (81, 'B', 'L', 'Saya seorang pemimpin yang baik'),
  (82, 'A', 'L', 'Saya meminta orang lain untuk bekerja keras'),
  (82, 'B', 'I', 'Saya seorang yang senang bergembira'),
  (83, 'A', 'I', 'Saya membuat keputusan secara cepat'),
  (83, 'B', 'T', 'Saya berbicara dengan cepat'),
  (84, 'A', 'T', 'Biasanya saya bekerja secara tergesa - gesa'),
  (84, 'B', 'V', 'Saya berlatih sesuatu secara teratur'),
  (85, 'A', 'V', 'Saya tidak suka bertemu dengan orang lain'),
  (85, 'B', 'S', 'Saya cepat lelah'),
  (86, 'A', 'S', 'Saya mempunyai banyak sekali teman'),
  (86, 'B', 'R', 'Banyak waktu saya untuk berpikir'),
  (87, 'A', 'R', 'Saya suka bekerja dengan teori'),
  (87, 'B', 'D', 'Saya suka bekerja secara detail'),
  (88, 'A', 'D', 'Saya suka bekerja secara detail'),
  (88, 'B', 'C', 'Saya suka mengorganisir pekerjaan saya'),
  (89, 'A', 'C', 'Saya meletakkan segala sesuatu pada tempatnya'),
  (89, 'B', 'E', 'Saya selalu ramah'),
  (90, 'A', 'W', 'Saya senang diberi petunjuk mengenai apa yang harus saya lakukan'),
  (90, 'B', 'N', 'Saya harus menyelesaikan apa yang saya mulai');
-- 20 PAPI traits. description/high_desc/low_desc are a two-band placeholder
-- grounded in the single example paragraph per trait in the "URAIAN
-- PAPIKOSTIK" tab of docs/papi-result.xls — not an official interpretation
-- manual. Replace wholesale once the psychologist supplies one.
INSERT INTO papi_descriptions (trait_code, trait_name, description, high_desc, low_desc) VALUES
  ('N', 'Ketuntasan Tugas', 'Mengukur dorongan untuk menuntaskan sendiri setiap tugas yang sudah dimulai hingga selesai.', 'Sangat berkomitmen menyelesaikan sendiri setiap tugas hingga tuntas, enggan mendelegasikan sebelum pekerjaan benar-benar selesai.', 'Cukup nyaman mendelegasikan sebagian pekerjaan kepada orang lain begitu ada kesempatan, tidak selalu menuntaskan sendiri hingga akhir.'),
  ('G', 'Orientasi Hasil', 'Mengukur dorongan untuk bekerja keras dengan arah dan target yang jelas.', 'Bekerja sangat keras dengan tujuan yang tegas dan terarah, gigih mengejar target yang ditetapkan.', 'Bekerja santai tanpa target yang jelas, kurang terdorong untuk mengejar pencapaian tertentu.'),
  ('A', 'Kebutuhan Berprestasi', 'Mengukur dorongan internal untuk mencapai sukses dan memanfaatkan kemampuan diri secara optimal.', 'Sangat kompetitif dan haus akan prestasi, berinisiatif tinggi, terus berusaha memanfaatkan kemampuan diri secara maksimal untuk mencapai sukses.', 'Tidak kompetitif, merasa mapan dan puas dengan capaian saat ini, tidak terlalu terdorong untuk menghasilkan prestasi, membutuhkan dorongan dari luar untuk berusaha mencapai sukses, kurang berinisiatif memanfaatkan kemampuan diri secara optimal.'),
  ('L', 'Kepercayaan Diri Memimpin', 'Mengukur kepercayaan diri dan kesiapan mengambil peran memimpin.', 'Sangat percaya diri dan aktif mencari posisi kepemimpinan, nyaman mengambil tanggung jawab memimpin orang lain.', 'Kurang percaya diri untuk memimpin, cenderung menghindari posisi yang menuntut tanggung jawab kepemimpinan.'),
  ('P', 'Kontrol terhadap Orang Lain', 'Mengukur kebutuhan untuk mengendalikan dan mengawasi pekerjaan orang lain.', 'Aktif mengontrol dan mengarahkan pekerjaan orang lain, serta bersedia mempertanggungjawabkan hasil kerja timnya secara langsung.', 'Enggan mengontrol atau mengarahkan orang lain, lebih memberi kebebasan penuh kepada bawahan untuk bekerja dengan caranya sendiri.'),
  ('I', 'Kecepatan Mengambil Keputusan', 'Mengukur kecepatan, keyakinan, dan keberanian dalam mengambil keputusan.', 'Sangat yakin dan cepat dalam mengambil keputusan, berani mengambil risiko dan memanfaatkan peluang, namun cenderung impulsif, tidak sabar, dan kurang mempertimbangkan akurasi.', 'Berhati-hati dan mempertimbangkan matang-matang sebelum mengambil keputusan, cenderung menghindari risiko.'),
  ('T', 'Tempo Mental', 'Mengukur tingkat aktivitas mental dan kemampuan menyesuaikan tempo kerja.', 'Sangat aktif secara mental, mampu menyesuaikan tempo kerja dengan cepat sesuai tuntutan pekerjaan dan lingkungan.', 'Lebih menyukai tempo kerja yang stabil dan konsisten, kurang nyaman jika harus sering menyesuaikan kecepatan kerja.'),
  ('V', 'Energi Fisik', 'Mengukur tingkat energi fisik dan preferensi terhadap aktivitas yang menuntut stamina.', 'Enerjik dan menyukai aktivitas fisik, memiliki stamina tinggi untuk menangani tugas berat, namun kurang betah bekerja lama di belakang meja.', 'Lebih nyaman dengan pekerjaan yang tidak menuntut banyak aktivitas fisik, betah bekerja di belakang meja dalam waktu lama.'),
  ('X', 'Kebutuhan Tampil Beda', 'Mengukur kebutuhan untuk tampil menonjol dan berbeda dari orang lain.', 'Senang menjadi pusat perhatian, aktif menonjolkan diri dan tampil beda dari orang lain.', 'Sederhana, cenderung pendiam dan pemalu, tidak suka menonjolkan diri di depan orang lain.'),
  ('S', 'Kebutuhan Sosial', 'Mengukur kebutuhan akan kehadiran dan interaksi dengan orang lain dalam bekerja.', 'Sangat membutuhkan kehadiran dan interaksi dengan orang lain, luwes dan nyaman dalam situasi sosial.', 'Dapat bekerja sendiri tanpa membutuhkan kehadiran orang lain, cenderung menarik diri dan canggung dalam situasi sosial.'),
  ('B', 'Kebutuhan Berkelompok', 'Mengukur kebutuhan untuk menjadi bagian dari suatu kelompok dan diterima olehnya.', 'Sangat suka bergabung dan menjadi bagian dari kelompok, mengutamakan kerja sama, ingin disukai dan diakui lingkungan, cenderung bergantung pada kelompok.', 'Cukup nyaman bekerja sendiri tanpa harus menjadi bagian dari kelompok tertentu, tidak terlalu bergantung pada penerimaan kelompok.'),
  ('O', 'Kepekaan terhadap Orang Lain', 'Mengukur kepekaan dan perhatian terhadap kebutuhan emosional orang lain.', 'Sangat peka terhadap kebutuhan dan perasaan orang lain, suka menjalin hubungan persahabatan yang hangat dan tulus, namun mudah tersinggung dan sangat perasa.', 'Kurang memperhatikan kebutuhan emosional orang lain, lebih berfokus pada hal-hal di luar hubungan personal, tidak mudah tersinggung.'),
  ('R', 'Orientasi Teoritis', 'Mengukur kecenderungan berpikir teoritis-konseptual dibandingkan praktis-berdasarkan pengalaman.', 'Sangat menyukai dan mengutamakan pemikiran teoritis, konsep, dan ide-ide baru dibanding pengalaman praktis.', 'Lebih mengutamakan pengalaman praktis dan konkret dibanding pemikiran teoritis atau konsep abstrak.'),
  ('D', 'Perhatian pada Detail', 'Mengukur tingkat perhatian dan ketelitian terhadap detail pekerjaan.', 'Sangat memperhatikan detail dan kecermatan dalam bekerja, teliti terhadap hal-hal kecil.', 'Melihat pekerjaan secara makro/garis besar, cenderung menghindari detail dan mendelegasikannya kepada orang lain, berisiko bertindak tanpa data yang cukup akurat.'),
  ('C', 'Kebutuhan Keteraturan', 'Mengukur kebutuhan akan keteraturan, struktur, dan kerapian dalam bekerja.', 'Sangat menyukai keteraturan dan struktur yang jelas, bekerja sesuai rencana yang sudah disusun rapi sebelumnya.', 'Lebih mementingkan fleksibilitas daripada struktur, bekerja sesuai situasi ketimbang rencana yang sudah disusun, kurang mempedulikan keteraturan dan kerapian.'),
  ('Z', 'Kebutuhan akan Perubahan', 'Mengukur seberapa besar kebutuhan akan perubahan dan variasi dalam bekerja.', 'Sangat mudah beradaptasi dan menyukai perubahan, senang menghadapi situasi baru yang dinamis.', 'Lebih menyukai kestabilan dan rutinitas, kurang nyaman menghadapi perubahan mendadak.'),
  ('E', 'Pengendalian Emosi', 'Mengukur kemampuan mengendalikan dan mengelola ekspresi emosi.', 'Mampu mengendalikan dan mengelola emosi dengan baik, tenang dan stabil dalam menghadapi tekanan.', 'Cenderung ekspresif dan reaktif secara emosional, mudah menunjukkan perasaan secara terbuka.'),
  ('K', 'Sikap terhadap Konflik', 'Mengukur ketegasan dan kesiapan menghadapi situasi konflik.', 'Berani menghadapi konflik secara langsung dan tegas mempertahankan posisinya.', 'Cenderung menghindari konflik, memilih mencari titik temu dan memahami sudut pandang orang lain daripada berkonfrontasi.'),
  ('F', 'Loyalitas', 'Mengukur loyalitas dan kepatuhan terhadap organisasi atau atasan.', 'Sangat loyal dan patuh terhadap organisasi/atasan, dapat diandalkan untuk mengikuti arahan.', 'Kurang terikat secara loyalitas terhadap organisasi/atasan, lebih mengutamakan penilaian pribadi.'),
  ('W', 'Kejelasan Tugas dan Wewenang', 'Mengukur kebutuhan akan kejelasan uraian tugas, tanggung jawab, dan wewenang.', 'Sangat membutuhkan uraian tugas yang rinci serta batasan tanggung jawab dan wewenang yang jelas sebelum bekerja.', 'Nyaman bekerja tanpa batasan tugas dan wewenang yang terlalu rinci, dapat menyesuaikan diri dengan ambiguitas peran.');
COMMIT;
SQL

PAPI_COUNT=$(PGPASSWORD="${DATABASE_PASSWORD_VALUE}" psql \
  --host="$PGHOST" \
  --port="$PGPORT" \
  --username="$DATABASE_USERNAME_VALUE" \
  --dbname="$PGDATABASE" \
  --tuples-only --no-align \
  -c "SELECT count(*) FROM papi_questions;")

echo "Done — papi_questions now has ${PAPI_COUNT} rows (90 pairs x 2 items expected)."
