Project-owned database snapshots live here during export/import workflows.

Contents are intentionally ignored by git except this file.

Expected structure:

- `data-snapshots/<snapshot>/postgres/assessment.dump`
- `data-snapshots/<snapshot>/postgres/assessment.sql`
- `data-snapshots/<snapshot>/mongo/<mongo-db>/*`
- `data-snapshots/<snapshot>/manifest.txt`

Usage:

```bash
./scripts/export-state.sh
./scripts/import-state.sh
./scripts/import-state.sh 20260701_083000
```
