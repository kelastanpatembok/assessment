#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SNAPSHOT_NAME="${1:-$(date +%Y%m%d_%H%M%S)}"
SNAPSHOT_DIR="${ROOT_DIR}/data-snapshots/${SNAPSHOT_NAME}"
POSTGRES_ENV="${ROOT_DIR}/backend/.env"
AUTH_ENV="${ROOT_DIR}/../auth/backend/.env"

need_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

maybe_add_postgres_bin() {
  if command -v pg_dump >/dev/null 2>&1; then
    return
  fi

  local candidates=(
    "/Applications/Postgres.app/Contents/Versions/latest/bin"
    "/opt/homebrew/opt/postgresql@15/bin"
    "/usr/local/opt/postgresql@15/bin"
  )

  local candidate
  for candidate in "${candidates[@]}"; do
    if [ -x "${candidate}/pg_dump" ]; then
      export PATH="${candidate}:$PATH"
      return
    fi
  done
}

load_env_file() {
  if [ ! -f "$1" ]; then
    echo "Missing env file: $1" >&2
    exit 1
  fi

  set -a
  # shellcheck disable=SC1090
  . "$1"
  set +a
}

parse_jdbc_url() {
  local jdbc_url="$1"
  PGHOST=$(printf '%s' "$jdbc_url" | sed -E 's#^jdbc:postgresql://([^:/]+).*#\1#')
  PGPORT=$(printf '%s' "$jdbc_url" | sed -nE 's#^jdbc:postgresql://[^:/]+:([0-9]+)/.*#\1#p')
  PGDATABASE=$(printf '%s' "$jdbc_url" | sed -E 's#^.*/([^/?]+)(\?.*)?$#\1#')
  PGPORT="${PGPORT:-5432}"
}

mongo_db_name() {
  printf '%s' "$1" | sed -E 's#^mongodb://[^/]+/([^?]+).*$#\1#'
}

maybe_add_postgres_bin
need_cmd pg_dump
need_cmd mongodump

load_env_file "$POSTGRES_ENV"
DATABASE_URL_VALUE="${DATABASE_URL:-}"
DATABASE_USERNAME_VALUE="${DATABASE_USERNAME:-}"
DATABASE_PASSWORD_VALUE="${DATABASE_PASSWORD:-}"

if [ -z "$DATABASE_URL_VALUE" ] || [ -z "$DATABASE_USERNAME_VALUE" ]; then
  echo "PostgreSQL env is incomplete in ${POSTGRES_ENV}" >&2
  exit 1
fi

parse_jdbc_url "$DATABASE_URL_VALUE"
POSTGRES_USER="$DATABASE_USERNAME_VALUE"
POSTGRES_PASSWORD="$DATABASE_PASSWORD_VALUE"

load_env_file "$AUTH_ENV"
MONGODB_URI_VALUE="${MONGODB_URI:-}"
if [ -z "$MONGODB_URI_VALUE" ]; then
  echo "MongoDB env is incomplete in ${AUTH_ENV}" >&2
  exit 1
fi
MONGO_DB="$(mongo_db_name "$MONGODB_URI_VALUE")"

mkdir -p "$SNAPSHOT_DIR/postgres" "$SNAPSHOT_DIR/mongo"

echo "Exporting project state to ${SNAPSHOT_DIR}"

echo "1. PostgreSQL: ${PGDATABASE}@${PGHOST}:${PGPORT}"
PGPASSWORD="${POSTGRES_PASSWORD}" pg_dump \
  --host="$PGHOST" \
  --port="$PGPORT" \
  --username="$POSTGRES_USER" \
  --format=plain \
  --clean \
  --if-exists \
  --no-owner \
  --no-privileges \
  --file="$SNAPSHOT_DIR/postgres/assessment.sql" \
  "$PGDATABASE"

echo "2. MongoDB: ${MONGO_DB}"
mongodump \
  --uri="$MONGODB_URI_VALUE" \
  --out="$SNAPSHOT_DIR/mongo"

cat >"$SNAPSHOT_DIR/manifest.txt" <<EOF
snapshot=${SNAPSHOT_NAME}
created_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
postgres_database=${PGDATABASE}
postgres_host=${PGHOST}
postgres_port=${PGPORT}
mongo_database=${MONGO_DB}
EOF

echo "Done."
echo "Snapshot: ${SNAPSHOT_DIR}"
