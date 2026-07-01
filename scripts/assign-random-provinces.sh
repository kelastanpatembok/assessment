#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
AUTH_ENV="${ROOT_DIR}/../auth/backend/.env"

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

echo "Assigning random provinces to users without province..."
echo "MongoDB: ${MONGODB_URI_VALUE}"

mongosh "$MONGODB_URI_VALUE" --quiet <<'EOF'
const provinces = [
  "Aceh",
  "Sumatera Utara",
  "Sumatera Barat",
  "Riau",
  "Jambi",
  "Sumatera Selatan",
  "Bengkulu",
  "Lampung",
  "Kepulauan Bangka Belitung",
  "Kepulauan Riau",
  "DKI Jakarta",
  "Jawa Barat",
  "Jawa Tengah",
  "DI Yogyakarta",
  "Jawa Timur",
  "Banten",
  "Bali",
  "Nusa Tenggara Barat",
  "Nusa Tenggara Timur",
  "Kalimantan Barat",
  "Kalimantan Tengah",
  "Kalimantan Selatan",
  "Kalimantan Timur",
  "Kalimantan Utara",
  "Sulawesi Utara",
  "Sulawesi Tengah",
  "Sulawesi Selatan",
  "Sulawesi Tenggara",
  "Gorontalo",
  "Sulawesi Barat",
  "Maluku",
  "Maluku Utara",
  "Papua Barat",
  "Papua",
  "Papua Selatan",
  "Papua Tengah",
  "Papua Pegunungan"
];

const filter = {
  $or: [
    { province: { $exists: false } },
    { province: null },
    { province: "" }
  ]
};

const users = db.users.find(filter, { _id: 1, username: 1 }).toArray();
print(`Users missing province: ${users.length}`);

if (users.length === 0) {
  quit(0);
}

let updated = 0;
for (const user of users) {
  const province = provinces[Math.floor(Math.random() * provinces.length)];
  const result = db.users.updateOne(
    { _id: user._id },
    {
      $set: {
        province,
        updatedAt: new Date()
      }
    }
  );

  if (result.modifiedCount === 1) {
    updated += 1;
  }
}

print(`Users updated: ${updated}`);
print("Top province counts after update:");
db.users.aggregate([
  { $match: { province: { $exists: true, $ne: null, $ne: "" } } },
  { $group: { _id: "$province", count: { $sum: 1 } } },
  { $sort: { count: -1, _id: 1 } },
  { $limit: 10 }
]).forEach(doc => print(`${doc._id}: ${doc.count}`));
EOF

echo "Done."
