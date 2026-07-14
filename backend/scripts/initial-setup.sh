#!/usr/bin/env bash
# initial-setup.sh — idempotent DISC question bank reset
#
# The DISC question bank must always have 24 blocks x 4 statements (96 rows),
# sourced from "Psikogram DISC_simulasidewi.xlsx" (tab "DISC Test", cross-checked
# against the P/K scoring formulas on the "Input" tab). This project is still in
# development, so this script clears disc_questions (and disc_results, which are
# stale once block numbering changes) and reseeds from scratch. Safe to rerun.
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
