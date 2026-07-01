#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
AUTH_ENV="${ROOT_DIR}/../auth/backend/.env"
NAME_DATA_FILE="${ROOT_DIR}/scripts/data/indonesian-name-parts.json"

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

  set -a
  # shellcheck disable=SC1090
  . "$1"
  set +a
}

need_cmd mongosh
load_env_file "$AUTH_ENV"

MONGODB_URI_VALUE="${MONGODB_URI:-}"
if [ -z "$MONGODB_URI_VALUE" ]; then
  echo "MongoDB env is incomplete in ${AUTH_ENV}" >&2
  exit 1
fi

if [ ! -f "$NAME_DATA_FILE" ]; then
  echo "Missing name data file: ${NAME_DATA_FILE}" >&2
  exit 1
fi

NAME_DATA_JSON="$(tr -d '\n' < "$NAME_DATA_FILE")"

echo "Assigning randomized Indonesian names to users except Kahfi..."
echo "MongoDB: ${MONGODB_URI_VALUE}"

mongosh "$MONGODB_URI_VALUE" --quiet <<EOF
const nameData = ${NAME_DATA_JSON};

function pick(list) {
  return list[Math.floor(Math.random() * list.length)];
}

function buildName() {
  const first = pick(nameData.firstNames);
  const middle = Math.random() < 0.65 ? pick(nameData.middleNames) : null;
  const last = Math.random() < 0.8 ? pick(nameData.lastNames) : null;
  return [first, middle, last].filter(Boolean).join(" ");
}

const filter = {
  name: { \$ne: "Kahfi" }
};

const users = db.users.find(filter, { _id: 1, username: 1, name: 1 }).toArray();
print(\`Users to rename: \${users.length}\`);

if (users.length === 0) {
  quit(0);
}

let updated = 0;
for (const user of users) {
  const newName = buildName();
  const result = db.users.updateOne(
    { _id: user._id },
    {
      \$set: {
        name: newName,
        updatedAt: new Date()
      }
    }
  );

  if (result.modifiedCount === 1) {
    updated += 1;
  }
}

print(\`Users updated: \${updated}\`);
print("Sample names after update:");
db.users.find({}, { username: 1, name: 1 }).limit(10).forEach(doc => print(\`\${doc.username}: \${doc.name}\`));
EOF

echo "Done."
