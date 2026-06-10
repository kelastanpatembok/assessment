#!/usr/bin/env bash
# seed-admin.sh — idempotent superadmin seeder for the assessment platform
# Calls the auth /register endpoint with role=superadmin.
# If the username already exists the auth server returns the existing user — safe to re-run.
set -euo pipefail

AUTH_BASE="${AUTH_BASE_URL:-http://localhost:2000/api}"
USERNAME="${ADMIN_USERNAME:-admin}"
EMAIL="${ADMIN_EMAIL:-admin@odas.local}"
PASSWORD="${ADMIN_PASSWORD:-Admin@Assessment2025!}"
NAME="Superadmin"
PLATFORM_ID="assessment"

echo "Seeding superadmin user '${USERNAME}' ..."
RESPONSE=$(curl -sf -X POST "${AUTH_BASE}/auth/register" \
  -d "username=${USERNAME}" \
  -d "email=${EMAIL}" \
  -d "password=${PASSWORD}" \
  -d "name=${NAME}" \
  -d "platformId=${PLATFORM_ID}" \
  -d "role=superadmin")

ROLE=$(echo "$RESPONSE" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('user',{}).get('role','?'))" 2>/dev/null || echo "?")
echo "Done — role in response: ${ROLE}"
