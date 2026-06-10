#!/usr/bin/env bash
# pg.sh — manage the local, user-owned PostgreSQL 15 cluster for the assessment backend
# Usage: ./scripts/pg.sh [start|stop|status|init|createdb]
set -euo pipefail
export LC_ALL=C
export LANG=C

PGBIN=/usr/local/opt/postgresql@15/bin
PGDATA="$(cd "$(dirname "$0")/.." && pwd)/.postgres/data"
PGLOG="$(cd "$(dirname "$0")/.." && pwd)/.postgres/log"
PGPORT=5432
PGUSER=eko
PGDB=assessment

cmd="${1:-help}"

case "$cmd" in
  init)
    if [ -d "$PGDATA/global" ]; then
      echo "Cluster already initialized at $PGDATA — skipping initdb"
    else
      echo "Initializing PostgreSQL cluster at $PGDATA ..."
      "$PGBIN/initdb" -D "$PGDATA" -U "$PGUSER" --auth=trust -E UTF8
    fi
    ;;
  start)
    if "$PGBIN/pg_ctl" -D "$PGDATA" status >/dev/null 2>&1; then
      echo "PostgreSQL already running on :$PGPORT"
    else
      echo "Starting PostgreSQL on :$PGPORT ..."
      "$PGBIN/pg_ctl" -D "$PGDATA" -l "$PGLOG" -o "-p $PGPORT" start
      sleep 1
    fi
    ;;
  stop)
    "$PGBIN/pg_ctl" -D "$PGDATA" stop
    ;;
  status)
    "$PGBIN/pg_ctl" -D "$PGDATA" status
    ;;
  createdb)
    if "$PGBIN/psql" -p "$PGPORT" -U "$PGUSER" -lqt | cut -d'|' -f1 | grep -qw "$PGDB"; then
      echo "Database '$PGDB' already exists"
    else
      echo "Creating database '$PGDB' ..."
      "$PGBIN/createdb" -p "$PGPORT" -U "$PGUSER" "$PGDB"
      echo "Done."
    fi
    ;;
  setup)
    bash "$0" init
    bash "$0" start
    bash "$0" createdb
    ;;
  *)
    echo "Usage: $0 {init|start|stop|status|createdb|setup}"
    exit 1
    ;;
esac
