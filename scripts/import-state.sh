#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SNAPSHOT_INPUT="${1:-}"
POSTGRES_ENV="${ROOT_DIR}/backend/.env"
AUTH_ENV="${ROOT_DIR}/../auth/backend/.env"
FORCE="${ECO_FORCE_RESTORE:-0}"

need_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

maybe_add_postgres_bin() {
  if command -v pg_restore >/dev/null 2>&1 && command -v psql >/dev/null 2>&1; then
    return
  fi

  local candidates=(
    "/Applications/Postgres.app/Contents/Versions/latest/bin"
    "/opt/homebrew/opt/postgresql@15/bin"
    "/usr/local/opt/postgresql@15/bin"
  )

  local candidate
  for candidate in "${candidates[@]}"; do
    if [ -x "${candidate}/pg_restore" ] && [ -x "${candidate}/psql" ]; then
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

resolve_snapshot_dir() {
  if [ -n "$SNAPSHOT_INPUT" ]; then
    if [ -d "$SNAPSHOT_INPUT" ]; then
      printf '%s\n' "$SNAPSHOT_INPUT"
      return
    fi
    if [ -d "${ROOT_DIR}/data-snapshots/${SNAPSHOT_INPUT}" ]; then
      printf '%s\n' "${ROOT_DIR}/data-snapshots/${SNAPSHOT_INPUT}"
      return
    fi
    echo "Snapshot not found: ${SNAPSHOT_INPUT}" >&2
    exit 1
  fi

  local latest
  latest="$(find "${ROOT_DIR}/data-snapshots" -mindepth 1 -maxdepth 1 -type d | sort | tail -n 1)"
  if [ -z "$latest" ]; then
    echo "No snapshots found in ${ROOT_DIR}/data-snapshots" >&2
    exit 1
  fi
  printf '%s\n' "$latest"
}

maybe_add_postgres_bin
need_cmd psql
need_cmd pg_restore
need_cmd mongorestore

SNAPSHOT_DIR="$(resolve_snapshot_dir)"
POSTGRES_DUMP="${SNAPSHOT_DIR}/postgres/assessment.dump"
MONGO_DUMP_DIR="${SNAPSHOT_DIR}/mongo"

if [ ! -f "$POSTGRES_DUMP" ]; then
  echo "Missing PostgreSQL dump: $POSTGRES_DUMP" >&2
  exit 1
fi

if [ ! -d "$MONGO_DUMP_DIR" ]; then
  echo "Missing Mongo dump dir: $MONGO_DUMP_DIR" >&2
  exit 1
fi

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

echo "Restore target"
echo "  Snapshot   ${SNAPSHOT_DIR}"
echo "  PostgreSQL ${PGDATABASE}@${PGHOST}:${PGPORT}"
echo "  MongoDB    ${MONGODB_URI_VALUE}"

if [ "$FORCE" != "1" ]; then
  printf "Type 'yes' to continue: "
  read -r confirm
  if [ "$confirm" != "yes" ]; then
    echo "Cancelled."
    exit 1
  fi
fi

echo "1. Restoring PostgreSQL"
PGPASSWORD="${POSTGRES_PASSWORD}" pg_restore \
  --host="$PGHOST" \
  --port="$PGPORT" \
  --username="$POSTGRES_USER" \
  --dbname="$PGDATABASE" \
  --clean \
  --if-exists \
  --no-owner \
  --no-privileges \
  "$POSTGRES_DUMP"

echo "2. Restoring MongoDB"
mongorestore \
  --uri="$MONGODB_URI_VALUE" \
  --drop \
  "$MONGO_DUMP_DIR"

echo "Done."
echo "Restored snapshot: ${SNAPSHOT_DIR}"
