# Assessment Project — CLAUDE.md

Guidance for building the **Assessment** platform: a rebuild of the LEGACY Laravel "ODAS+IST" psychometric assessment system for Indonesian schools, implemented as a **Svelte frontend** (`frontend/`) + **Java Spring Boot backend** (`backend/`) sharing the workspace-level JWT auth server (`../auth`).

---

## 1. Project Overview

**What it is:** an online platform where Indonesian schools administer standardized psychological/career assessments to students, managed by guidance counselors (guru BK) and affiliate psychologists. Students complete tests, receive scored results, and download certificates. Administrators maintain question banks, scoring tables, and school assignments.

**Five psychometric instruments:**
1. **DISC** — personality profile (Dominance / Influence / Steadiness / Compliance), MOST/LEAST forced-choice.
2. **Holland RIASEC** — vocational interest inventory (Realistic / Investigative / Artistic / Social / Enterprising / Conventional).
3. **PAPI Kostick** — work personality, 20 traits (G N A P X B O Z K F L I T V S R D E C W), 90 forced-choice items.
4. **IQ CFIT** — Culture Fair Intelligence Test, 4 subtests.
5. **IQ IST** — Intelligenz-Struktur-Test, 9 subtests (SE WA AN GE RA ZR FA WU ME), produces an IQ score.

**Build scope (phased):**
- **v1 milestone** (build first): auth wiring + school/student/user management + DISC end-to-end + Holland end-to-end.
- **Roadmap** (documented here, built later): PAPI Kostick, IQ CFIT, IQ IST, PDF certificates, fee/commission system, Google Sheets student import.

**Naming convention:** English identifiers in all code and APIs (`Student`, `School`, `Counselor`, `Question`, `Result`). User-facing Svelte UI text stays **Indonesian** (end users are Indonesian school staff and students). Standard instrument names (DISC, RIASEC, PAPI, CFIT, IST) are universal and kept as-is.

---

## 2. Service Topology & Ports

```
┌─────────────────────────────────────────────────────────────┐
│  workspace: /Users/eko/dev/SuperApp/assessment/             │
│                                                             │
│  ../auth/backend       ← existing, DO NOT break            │
│  port 2000, /api       JWT issuer (MongoDB)                 │
│         ▲                    ▲                              │
│  validates token       issues token                         │
│         │                    │                              │
│  backend/              frontend/                            │
│  port 2002, /api       port 2001                            │
│  Spring Boot + PG      SvelteKit 2 + shadcn-svelte          │
│  (this repo)           (this repo)                          │
└─────────────────────────────────────────────────────────────┘
```

| Service | Dir | Port | Stack | DB |
|---|---|---|---|---|
| Auth server | `../auth/backend` | **2000** | Spring Boot 3.2 / Java 17 / Maven | MongoDB `:27017/auth_backend_assessment` |
| Assessment backend | `backend/` | **2002** | Spring Boot 3.2 / Java 17 / Maven | PostgreSQL `assessment` |
| Assessment frontend | `frontend/` | **2001** | SvelteKit 2 + Svelte 5 + Vite 8 | — |

PM2 (`ecosystem.config.js` at workspace root) currently has apps for auth (2000) and frontend (2001). **Add a third app** for the new backend:

```js
{
  name: "assessment-backend",
  cwd: "backend",
  script: "mvn",
  args: "spring-boot:run",
  exec_mode: "fork",
  interpreter: "none",
  env: { PORT: 2002 },
  watch: ["src/main/java/**/*.java", "src/main/resources/**/*.yml"],
  watch_delay: 1500,
  ignore_watch: ["target"],
},
```

Alternatively re-run `../../core/configure.sh` after creating `backend/pom.xml` — the orchestrator auto-discovers Spring Boot services by `pom.xml` and assigns the next port.

---

## 3. Auth Server — Integration Contract

**Source files:** `../auth/backend/src/main/java/com/rwid/`
- `controller/AuthController.java` — endpoints
- `security/JwtTokenProvider.java` — token generation/validation
- `security/JwtAuthenticationFilter.java` — per-request filter
- `config/SecurityConfig.java` — security chain
- `dto/AuthResponse.java`, `dto/UserDTO.java`
- `.env`, `src/main/resources/application.yml`

### Endpoints (base URL `http://localhost:2000/api`)

| Method | Path | Request | Response | Notes |
|---|---|---|---|---|
| `POST` | `/api/auth/login` | **JSON body** `{username, password}` | `AuthResponse` | Finds user by username; BCrypt match |
| `POST` | `/api/auth/register` | **query params**: `username, email, password, name, platformId` | `AuthResponse` 201 | Currently hardcodes `role = "member"` — **we extend this** |
| `POST` | `/api/auth/register-with-profile` | **query params**: `email, password, name, whatsappNumber, province` | `AuthResponse` 201 | Derives username from email prefix |
| `GET` | `/api/users/{userId}` | — | `UserDTO` | Profile lookup by Mongo id |
| `GET` | `/api/users/username/{username}` | — | `UserDTO` | Profile lookup by username |

**No endpoints for:** refresh token, logout, token validation, or `/me`. **Logout is client-side** (discard the token). Re-login on expiry.

`AuthResponse` shape:
```json
{ "token": "<jwt>", "user": { "id": "...", "username": "...", "role": "...", ... }, "expiresIn": 86400 }
```

### JWT Details

- **Algorithm:** HS512 (HMAC-SHA512), **symmetric** shared secret.
- **Key derivation:** `Keys.hmacShaKeyFor(jwtSecret.getBytes())` — the secret is the raw UTF-8 bytes; must be ≥64 bytes for HS512.
- **Claims:** `sub` = MongoDB userId string, `username`, `role`, `platformId`, `iat`, `exp`.
- **Expiry:** 24 hours (`jwt.expiration = 86400000` ms). No refresh mechanism.
- **Header:** `Authorization: Bearer <token>`.

### Validating tokens in the assessment backend

Copy (or extract as a shared util) the auth server's `JwtTokenProvider` / `JwtAuthenticationFilter` pattern into the backend's `security/` package. Key points:
- Use the **same `JWT_SECRET`** env var (set identically in both `.env` files).
- The filter extracts `sub` (userId), `username`, `role` from the token and registers a Spring `UsernamePasswordAuthenticationToken` with authority `ROLE_<ROLE.toUpperCase()>`.
- The filter sets `JwtAuthenticationDetails(userId, username, role)` — downstream controllers read this from the `SecurityContext` to identify the caller without a DB round-trip.
- Sessions are stateless; CSRF is disabled.

### Required env vars & gotchas

In `../auth/backend/.env`:
```
JWT_SECRET=          # BLANK — MUST be set (≥64 UTF-8 bytes) before auth boots
CORS_ALLOWED_ORIGINS=http://localhost:3000   # MUST add http://localhost:2001
APP_KAFKA_ENABLED=false   # add this to disable Kafka (otherwise auth tries to connect)
```

In the new `backend/.env`:
```
JWT_SECRET=<same value as auth>  # shared secret
```

`CORS_ALLOWED_ORIGINS` and `JWT_SECRET` have **no fallback in code** — `SecurityConfig` injects them directly via `@Value`; the auth app will **fail to start** if either is missing or empty. The `jwt.secret` fallback in `application.yml` (`your-secret-key-change-in-production`) is only 36 bytes and will cause JJWT to throw for HS512.

### Auth server extension (role support)

**Goal:** make the JWT `role` claim carry assessment roles (`superadmin`, `gurubk`, `siswa`, `afiliator`) by adding an optional `role` query param to `POST /api/auth/register`. The assessment backend trusts whatever role the JWT carries; it does **not** issue tokens itself.

Changes to make in `../auth` (scoped — don't touch anything else):
1. `AuthController.register` — add `@RequestParam(required=false, defaultValue="member") String role`.
2. `AuthService.register` — pass `role` through to `UserService.registerUser` and into the `User` entity.
3. Add a `/api/auth/seed-admin` endpoint (or a `SetupController`-style one-shot) that creates a `superadmin` user idempotently (check by username before inserting). Protect it so it only works when no superadmin exists yet.

---

## 4. Roles, Scoping & Multi-Tenancy

### The four roles (JWT `role` claim → Spring authority)

| JWT role | Spring authority | Indonesian name | Scope | Can do |
|---|---|---|---|---|
| `superadmin` | `ROLE_SUPERADMIN` | Superadmin | Global | Full CRUD: schools, all users, all question banks, scoring tables, test categories/assignments, fee config. View all results. |
| `gurubk` | `ROLE_GURUBK` | Guru BK (guidance counselor) | One school (`schoolId`) | CRUD students of own school, import via Sheets, view results for own school's students. |
| `siswa` | `ROLE_SISWA` | Siswa (student) | Own account | Take assigned tests, view own results, download certificates (when enabled). |
| `afiliator` | `ROLE_AFILIATOR` | Afiliator (affiliate psychologist) | Students under their affiliatorId | CRUD students, view results, view fee report. |

### Assessment-side user profile

The auth server stores identity (Mongo `users` collection). Assessment roles and school linkage are **relational and live in the assessment backend's PostgreSQL DB** in an `assessment_users` (or `user_profile`) table keyed by the JWT `sub` (MongoDB userId string). This is created/updated when a user first logs in (lazy provisioning) or when a superadmin creates accounts.

```sql
assessment_users (
  auth_user_id   VARCHAR(36) PRIMARY KEY,   -- JWT sub (Mongo _id)
  username       VARCHAR(100) UNIQUE NOT NULL,
  role           VARCHAR(20)  NOT NULL,      -- superadmin|gurubk|siswa|afiliator
  status         VARCHAR(10)  NOT NULL DEFAULT 'aktif',  -- aktif|pasif
  school_id      BIGINT REFERENCES schools(id),     -- null for superadmin/afiliator
  affiliator_id  VARCHAR(36),                        -- FK to another assessment_users.auth_user_id
  counselor_id   VARCHAR(36),                        -- FK for students
  nisn           VARCHAR(20),     -- national student ID (siswa only)
  nip            VARCHAR(20),     -- teacher ID (gurubk only)
  name           VARCHAR(200) NOT NULL,
  gender         VARCHAR(20),    -- Laki-Laki | Perempuan
  date_of_birth  DATE,
  last_education VARCHAR(100),
  created_at     TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at     TIMESTAMP NOT NULL DEFAULT NOW()
)
```

### Domain name translation table

| LEGACY (Indonesian) | English (code) | Notes |
|---|---|---|
| `siswa` | `Student` / `student` | role = siswa |
| `sekolah` / `sekolahs` | `School` | |
| `gurubk` | `Counselor` | role = gurubk |
| `afiliator` | `Affiliate` | role = afiliator |
| `soal` (question) | `Question` | e.g. `DiscQuestion` |
| `pilihan` (answer option) | `Option` | |
| `jawaban` (correct answer) | `answerKey` | |
| `hasil` / `hasilakhir` | `Result` | e.g. `DiscResult` |
| `setsoal` | `TestAssignment` | per-school schedule |
| `kategori` / `kategorisoal` | `TestCategory` | the 25 bundle types |
| `kepribadian` | `PersonalityProfile` | DISC interpretation DB |
| `rumus` | `ScoringFormula` | |
| `presentase` | `FeeConfig` | |
| `share_b_k_s` | `FeeShare` | |
| `log_records` | `ActivityLog` | |
| `namasekolah` | `schoolName` | |
| `tanggalmulai/selesai` | `startDate/endDate` | |
| `sertifikat` | `certificateEnabled` | boolean in TestAssignment |
| `ket` | `description` / `note` | |

---

## 5. Backend Stack & Project Layout

### Dependencies (`pom.xml`)

```xml
<!-- Core -->
<parent>spring-boot-starter-parent 3.2.x</parent>
<java.version>17</java.version>

<dependencies>
  spring-boot-starter-web
  spring-boot-starter-data-jpa
  spring-boot-starter-security
  spring-boot-starter-validation
  org.flywaydb:flyway-core
  org.postgresql:postgresql
  io.jsonwebtoken:jjwt-api:0.11.5          <!-- same version as auth -->
  io.jsonwebtoken:jjwt-impl:0.11.5
  io.jsonwebtoken:jjwt-jackson:0.11.5
  org.projectlombok:lombok
  me.paulschwarz:spring-dotenv             <!-- loads .env -->
</dependencies>
```

### Package layout

```
src/main/java/com/assessment/
  AssessmentApplication.java
  config/
    SecurityConfig.java          -- stateless, CSRF off, JWT filter
    CorsConfig.java
    AppConfig.java
  security/
    JwtTokenProvider.java        -- copy/adapt from auth; same JJWT API
    JwtAuthenticationFilter.java
    JwtAuthenticationDetails.java
  controller/
    AuthProfileController.java   -- POST /api/auth/profile (lazy provision)
    SchoolController.java
    UserController.java          -- admin CRUD for all users
    StudentController.java       -- counselor/affiliate student mgmt
    TestCategoryController.java
    TestAssignmentController.java
    DiscQuestionController.java
    DiscResultController.java
    HollandQuestionController.java
    HollandResultController.java
    -- (later: PapiKostickController, CfitController, IstController, ...)
    ReportController.java        -- cross-role result reports
    FeeController.java           -- (roadmap)
  dto/                           -- request/response records
  model/                         -- @Entity classes
  repository/                    -- JpaRepository interfaces
  service/
    UserService.java
    SchoolService.java
    TestAssignmentService.java
    DiscScoringService.java      -- the scoring algorithm
    HollandScoringService.java
    ReportService.java
  exception/
    GlobalExceptionHandler.java
    ResourceNotFoundException.java
src/main/resources/
  application.yml
  db/migration/                  -- Flyway scripts (V1__*.sql, V2__*.sql, ...)
```

### `application.yml` skeleton

```yaml
spring:
  config:
    import: optional:file:.env[.properties]
  application:
    name: assessment-api
  datasource:
    url: ${DB_URL:jdbc:postgresql://localhost:5432/assessment}
    username: ${DB_USER:postgres}
    password: ${DB_PASSWORD:}
  jpa:
    hibernate:
      ddl-auto: validate    # Flyway owns schema; Hibernate only validates
    show-sql: false
  flyway:
    locations: classpath:db/migration

server:
  port: ${SERVER_PORT:2002}
  servlet:
    context-path: /api

jwt:
  secret: ${JWT_SECRET:}       # must match auth server — no default

app:
  auth-base-url: ${AUTH_BASE_URL:http://localhost:2000/api}
  cors-allowed-origins: ${CORS_ALLOWED_ORIGINS:http://localhost:2001}

logging:
  level:
    com.assessment: DEBUG
```

### `backend/.env` template

```
SERVER_PORT=2002
DB_URL=jdbc:postgresql://localhost:5432/assessment
DB_USER=postgres
DB_PASSWORD=
JWT_SECRET=          # same value as ../auth/backend/.env JWT_SECRET (≥64 bytes)
CORS_ALLOWED_ORIGINS=http://localhost:2001
AUTH_BASE_URL=http://localhost:2000/api
APP_KAFKA_ENABLED=false
```

---

## 6. Frontend Stack & Auth Wiring

### Existing scaffold (do not change these)

- **SvelteKit 2.63** / **Svelte 5.56** (runes mode forced in `vite.config.ts`)
- **Vite 8**, port from `PORT` env (= **2001**), `@sveltejs/adapter-node`
- **Tailwind CSS v4** (`@tailwindcss/vite`); CSS at `src/routes/layout.css`
- **shadcn-svelte 1.3**, style `maia`, icon library `hugeicons`, baseColor `neutral`
  - `components.json` aliases: `$lib/components`, `$lib/components/ui`, `$lib/hooks`, `$lib/utils`
- Already-installed components: `avatar`, `badge`, `button`, `card`, `input`, `label`, `separator`
- `src/app.d.ts` has empty `App.Locals` and `App.PageData` — **extend these**.

### Auth wiring to add

**`src/app.d.ts`** — add user type to Locals:
```ts
declare global {
  namespace App {
    interface Locals {
      user: { userId: string; username: string; role: string; platformId: string } | null;
      token: string | null;
    }
  }
}
```

**`src/hooks.server.ts`** — read auth cookie, validate JWT presence (backend does the cryptographic validation):
```ts
// On every SSR request: extract token from cookie/header, decode claims, populate locals.
// The backend validates the signature; hooks.server.ts only reads the payload for routing.
```

**`$lib/api/index.ts`** — typed fetch client injecting `Authorization: Bearer`:
- Points to the assessment backend at `http://localhost:2002/api` (via env `PUBLIC_API_URL`).
- Points to auth at `http://localhost:2000/api` for login only.

**`src/routes/login/`** — `+page.svelte` with form; calls `POST /api/auth/login` (JSON); stores token in an httpOnly cookie via a `+page.server.ts` action.

**Role-gated route groups:**
```
src/routes/
  login/           -- public
  (admin)/         -- requires ROLE_SUPERADMIN
    +layout.server.ts  -- redirect if not superadmin
    schools/
    users/
    questions/      -- question bank CRUD
    assignments/    -- TestAssignment CRUD
  (counselor)/     -- ROLE_GURUBK
    +layout.server.ts
    students/
    results/
  (student)/       -- ROLE_SISWA
    +layout.server.ts
    dashboard/      -- shows available tests
    disc/           -- instructions → exam → result
    holland/
  (affiliate)/     -- ROLE_AFILIATOR
    students/
    results/
```

---

## 7. Domain Model (Full Reference)

### Core entities (PostgreSQL, Flyway-managed)

**`schools`**
```
id BIGSERIAL PK, school_name VARCHAR(200) NOT NULL, address TEXT, created_at, updated_at
```

**`assessment_users`** (see §4 — the relational extension of auth's MongoDB users)

**`test_categories`** (seed data — 25 pre-defined combinations)
```
id BIGSERIAL PK, name VARCHAR(100) -- e.g. "DISC", "Holland", "DISC+Holland", "All"
```
The 25 combinations (from LEGACY `kategoris`):

| ID | Bundle |
|---|---|
| 1 | DISC |
| 2 | Holland |
| 3 | DISC + Holland |
| 4 | PAPI Kostick |
| 5 | DISC + PAPI |
| 6 | Holland + PAPI |
| 7 | DISC + Holland + PAPI |
| 8 | IQ CFIT |
| 9 | DISC + Holland + PAPI (SMP bundle) |
| 10 | DISC + Holland + PAPI (SMA bundle) |
| 11 | DISC + Holland + PAPI + CFIT |
| 12-16 | various +CFIT combos |
| 17 | IQ IST |
| 18-24 | various +IST combos |
| 25 | All |

**`test_assignments`** (per-school test schedule — maps to LEGACY `setsoals`)
```
id BIGSERIAL PK
school_id BIGINT REFERENCES schools(id)
category_id BIGINT REFERENCES test_categories(id)
status VARCHAR(10) NOT NULL DEFAULT 'aktif'   -- aktif | pasif
start_date DATE NOT NULL
end_date DATE NOT NULL
certificate_enabled BOOLEAN NOT NULL DEFAULT false
created_at, updated_at
UNIQUE(school_id, category_id)
```

### Question banks (one table per instrument)

**`disc_questions`** (maps to LEGACY `soaldiscs`)
```
id BIGSERIAL PK
option_a/b/c/d VARCHAR(500)        -- the 4 statement texts
key_most_a/b/c/d VARCHAR(1)        -- d|i|s|c|* (the DISC letter for each option when chosen as MOST)
key_least_a/b/c/d VARCHAR(1)       -- same for LEAST
created_at, updated_at
```

**`holland_questions`** (maps to LEGACY `soal_hollands`)
```
id BIGSERIAL PK
question_type VARCHAR(5)  -- R1|R2|R3|I1|I2|I3|A1|A2|A3|S1|S2|S3|E1|E2|E3|C1|C2|C3
statement_1 through statement_11 VARCHAR(500)
created_at, updated_at
```

**`papi_questions`** (maps to LEGACY `soal_papi_kosticks`)
```
id BIGSERIAL PK
option CHAR(1)   -- a|b
statement TEXT
trait CHAR(1)    -- one of the 20 PAPI trait letters
created_at, updated_at
```

**`cfit_questions`** (maps to LEGACY `soal_i_q_s`)
```
id BIGSERIAL PK
subtest VARCHAR(10)   -- tes_1..tes_4
question TEXT
options JSONB         -- nullable for image-based
answer VARCHAR(100)
answer2 VARCHAR(100)  -- nullable
created_at, updated_at
```

**`ist_questions`** (maps to LEGACY `soal_iq_ists`)
```
id BIGSERIAL PK
subtest VARCHAR(10)   -- tes_1..tes_9 (excluding tes_4 which has its own table)
question TEXT
question_image VARCHAR(300)  -- nullable
options JSONB        -- text or image paths
options_image JSONB  -- nullable
answer VARCHAR(100)
answer2 VARCHAR(100)
created_at, updated_at
```

**`ist_subtest4_questions`** (maps to LEGACY `soal_ist_tes4s` — tiered scoring)
```
id BIGSERIAL PK
question TEXT
answer JSONB       -- full credit answers
answer2 JSONB      -- partial credit answers (1 point)
answer3 JSONB      -- nullable, 0 points fallback
created_at, updated_at
```

### Scoring / description lookup tables (seed data via Flyway)

These tables are **read-only at runtime**; superadmin edits them via CRUD UI.

**`disc_personality_profiles`** (maps to LEGACY `kepribadians`)
```
id BIGSERIAL PK
type_key VARCHAR(20) UNIQUE  -- e.g. "D", "D,I", "D,I,S"
traits TEXT
description TEXT
job_recommendations TEXT
major_recommendations TEXT
```

**`disc_scoring_most`** / **`disc_scoring_least`** / **`disc_scoring_dif`** (maps to LEGACY `rumus_mosts/lests/difs`)
```
id BIGSERIAL PK
raw_value INT UNIQUE
d VARCHAR(10), i VARCHAR(10), s VARCHAR(10), c VARCHAR(10)
```

**`holland_descriptions`** (maps to LEGACY `desk_hollands`)
```
id BIGSERIAL PK
type CHAR(1) UNIQUE  -- R|I|A|S|E|C
description TEXT, character TEXT, strengths TEXT, weaknesses TEXT, job_match TEXT
```

**`papi_descriptions`** (maps to LEGACY `desk_papi_kosticks`)
```
id BIGSERIAL PK
trait CHAR(1) UNIQUE
min_description TEXT, max_description TEXT, traits TEXT, description TEXT
```

**`cfit_descriptions`** (maps to LEGACY `desk_i_q_s`)
```
id BIGSERIAL PK, category VARCHAR(100)   -- IQ band label
```

**`ist_norma`** (maps to LEGACY `db_norma_ists` — raw → normed per subtest)
```
id BIGSERIAL PK
subtest VARCHAR(5)   -- SE|WA|AN|GE|RA|ZR|FA|WU|ME
raw_score INT
normed_score INT
UNIQUE(subtest, raw_score)
```

**`ist_iq_bands`** (maps to LEGACY `db_iq_ists` — total raw → IQ)
```
id BIGSERIAL PK
range_min INT, range_max INT, iq INT
```

### Result tables (one per instrument; denormalize student snapshot intentionally)

Denormalization preserves historical results even if user profiles change later.

**`disc_results`** (maps to LEGACY `hasilakhirs`)
```
id BIGSERIAL PK
auth_user_id VARCHAR(36) NOT NULL   -- JWT sub
student_name VARCHAR(200), school_name VARCHAR(200), school_id BIGINT, affiliator_id VARCHAR(36)
nisn VARCHAR(20), gender VARCHAR(20), date_of_birth DATE
-- MOST tallies:
d_most INT, i_most INT, s_most INT, c_most INT, star_most INT
-- LEAST tallies:
d_least INT, i_least INT, s_least INT, c_least INT, star_least INT
created_at TIMESTAMP NOT NULL DEFAULT NOW()
UNIQUE(auth_user_id)   -- one result per student
```

**`holland_results`**
```
auth_user_id VARCHAR(36) NOT NULL UNIQUE, + student snapshot
total_r INT, total_i INT, total_a INT, total_s INT, total_e INT, total_c INT
created_at
```

**`papi_results`**
```
auth_user_id VARCHAR(36) NOT NULL UNIQUE, + student snapshot
result_g INT, result_n INT, result_a INT, result_p INT, result_x INT,
result_b INT, result_o INT, result_z INT, result_k INT, result_f INT,
result_l INT, result_i INT, result_t INT, result_v INT, result_s INT,
result_r INT, result_d INT, result_e INT, result_c INT, result_w INT
created_at
```

**`cfit_results`**
```
auth_user_id VARCHAR(36) NOT NULL UNIQUE, + student snapshot
subtest1 INT, subtest2 INT, subtest3 INT, subtest4 INT
raw_score INT
created_at
```

**`ist_results`**
```
auth_user_id VARCHAR(36) NOT NULL UNIQUE, + student snapshot
-- raw subtest sums:
subtest1_raw through subtest9_raw INT
-- normed values:
se INT, wa INT, an INT, ge INT, ra INT, zr INT, fa INT, wu INT, me INT
raw_score INT     -- sum of all 9 raw sums
iq_score INT      -- nullable, from ist_iq_bands lookup
created_at
```

### Fee & audit tables (roadmap)

**`fee_config`** (maps to LEGACY `presentases` — singleton row)
```
id BIGSERIAL PK
price NUMERIC(12,2), system_pct NUMERIC(5,2), affiliator_pct NUMERIC(5,2), counselor_pct NUMERIC(5,2)
```

**`fee_shares`** (maps to LEGACY `share_b_k_s` — one row per student)
```
id BIGSERIAL PK
student_auth_id VARCHAR(36), counselor_auth_id VARCHAR(36), affiliator_auth_id VARCHAR(36)
system_fee NUMERIC(12,2), counselor_fee NUMERIC(12,2), affiliator_fee NUMERIC(12,2)
created_at
```

**`activity_logs`** (maps to LEGACY `log_records`)
```
id BIGSERIAL PK
student_name VARCHAR(200), school_name VARCHAR(200), nisn VARCHAR(20)
log_date DATE, log_time TIME, description VARCHAR(300)
created_at
```

---

## 8. Scoring Algorithms (Port Exactly)

These are the domain core. Each is in LEGACY `LEGACY/app/Http/Controllers/Siswa/ujianController.php`.

### DISC Scoring (`storedisc`)

**Input:** form fields named `{n}M` (MOST choice, value = d|i|s|c|*) and `{n}L` (LEAST choice) for each question. Odd-indexed fields = MOST; even-indexed = LEAST.

**Algorithm:**
```
for each posted answer:
  if key ends with "M": increment d_most / i_most / s_most / c_most / star_most
  if key ends with "L": increment d_least / i_least / s_least / c_least / star_least
```

**Persisted:** raw letter tallies in `disc_results`.

**Interpretation** (at result-display time — **not** at submit time; encapsulate in a single `DiscInterpretationService`):
1. For MOST: look up each raw count (d_most, i_most, s_most, c_most) in `disc_scoring_most` by `raw_value` → get converted D/I/S/C values.
2. For LEAST: same using `disc_scoring_least`.
3. Compute DIF = MOST_converted − LEAST_converted per dimension; look up each DIF in `disc_scoring_dif` by `raw_value`.
4. Take the **top 3 non-zero** dimensions by DIF score, sort descending.
5. Build the type key string, e.g. `"D,I"` (comma-separated, only non-zero dims).
6. Look up `disc_personality_profiles` by `type_key` → fetch `description`, `job_recommendations`, `major_recommendations`.
7. Return MOST/LEAST/DIF arrays (for Chart.js bar chart) + personality profile.

> **LEGACY bug to avoid:** DISC interpretation logic was duplicated across `Superadmin/allReportController`, `GuruBK/hasilController`, and `Afiliator/allReportController`. The new backend centralises this in ONE service method.

### Holland RIASEC Scoring (`storeHolland`)

**Input:** 18 groups of 11 Likert-scale inputs each. Group names: `r1_1..r1_11`, `r2_1..r2_11`, `r3_1..r3_11`, then i1/i2/i3, a1/a2/a3, s1/s2/s3, e1/e2/e3, c1/c2/c3.

**Algorithm:**
```
total_R = sum(r1_1..r1_11) + sum(r2_1..r2_11) + sum(r3_1..r3_11)
total_I = sum(i1_*) + sum(i2_*) + sum(i3_*)
total_A = sum(a1_*) + sum(a2_*) + sum(a3_*)
total_S = sum(s1_*) + sum(s2_*) + sum(s3_*)
total_E = sum(e1_*) + sum(e2_*) + sum(e3_*)
total_C = sum(c1_*) + sum(c2_*) + sum(c3_*)
```

**Persisted:** 6 totals in `holland_results`.

**Interpretation:** look up each dimension's description from `holland_descriptions` by `type` (R/I/A/S/E/C). Sort dimensions by total descending; top 3 form the Holland code (e.g. "RIA").

### PAPI Kostick Scoring (`storepapikostick`)

**Input:** 90 forced-choice answers in 3 steps of 30 (`step1_1..step1_30`, `step2_1..30`, `step3_1..30`). Each answer value is one of the 20 PAPI trait letters (G N A P X B O Z K F L I T V S R D E C W).

**Algorithm:**
```
Concatenate all 90 answers into one array.
Count occurrences of each of the 20 trait letters.
result_G = count('G'), result_N = count('N'), ..., result_W = count('W')
```

**Persisted:** 20 counts in `papi_results`.

**Interpretation:** for each trait, look up band description from `papi_descriptions` based on the count (low/mid/high — use `min_description`/`max_description`).

### IQ CFIT Scoring (`storeIQ`)

**Input:** 4 subtests.
- subtest1: simple integer answers (1/0).
- subtest2: each item is an array of sub-answers; score = 1 only if **all** sub-answers equal "1" (strict all-or-nothing).
- subtest3: simple integer answers.
- subtest4: simple integer answers.

**Algorithm:**
```
subtest1_score = sum(intval(each answer))
subtest2_score = sum(1 if all elements in item == "1" else 0, for each item)
subtest3_score = sum(intval(each answer))
subtest4_score = sum(intval(each answer))
raw_score = subtest1_score + subtest2_score + subtest3_score + subtest4_score
```

**Persisted:** 4 subtest scores + RS in `cfit_results`.

**Interpretation:** look up IQ band from `cfit_descriptions` using the raw score.

### IQ IST Scoring (`storeIQIST`)

**Input:** 9 subtests.

**Per-subtest scoring:**
- subtests 1, 2, 3, 7, 8, 9: `sum(intval(each answer))`.
- subtest 4 (GE) — **tiered scoring** (`nilaiJawaban`): for each item, compare against `ist_subtest4_questions`:
  - answer in `answer` (JSONB list) → 2 points.
  - answer in `answer2` (JSONB list) → 1 point.
  - otherwise → 0 points.
- subtest 5 (RA) — exact-match against `ist_questions.answer` = 1, else 0.
- subtest 6 (ZR) — exact-match against `ist_questions.answer` = 1, else 0.

**Norming:** for each subtest raw sum, look up `ist_norma` by `(subtest, raw_score)` → `normed_score`. Subtests map to norma types: 1→SE, 2→WA, 3→AN, 4→GE, 5→RA, 6→ZR, 7→FA, 8→WU, 9→ME.

**IQ derivation:**
```
raw_score = subtest1_raw + subtest2_raw + ... + subtest9_raw
iq_score = ist_iq_bands WHERE range_min <= raw_score AND raw_score <= range_max → iq
```

**Persisted:** 9 raw sums, 9 normed values (SE..ME), RS, WS(=IQ) in `ist_results`.

### Exam gating

Before serving the exam form, check:
1. The student's school has an active `test_assignment` for the relevant test category.
2. `test_assignment.status = 'aktif'` AND `today` is between `start_date` and `end_date`.
3. The student does NOT already have a result for this test (no retake).

Fail any check → return an appropriate error (map to HTTP 403 / 422 in the API).

### Activity logging

Write an `activity_logs` row:
- On exam start (when instructions page is fetched successfully): `description = "Mulai Mengerjakan {TestName}"`.
- On exam submit (after result is persisted): `description = "Selesai Mengerjakan {TestName}"`.

---

## 9. API Surface

Context path: `/api`. All responses JSON. Auth via `Authorization: Bearer <token>`. Validation errors return 400 with field-level messages. 403 for role/scope violations.

### v1 Endpoints (build first)

**Auth & profile**

| Method | Path | Roles | Description |
|---|---|---|---|
| `POST` | `/api/profile` | any authenticated | Lazy-provision assessment_users row from JWT claims on first login |
| `GET` | `/api/profile/me` | any | Return own assessment profile |

**Schools (admin)**

| Method | Path | Roles | Description |
|---|---|---|---|
| `GET` | `/api/schools` | superadmin | List all schools (paginated, search by name) |
| `POST` | `/api/schools` | superadmin | Create school |
| `GET` | `/api/schools/{id}` | superadmin | Get school |
| `PUT` | `/api/schools/{id}` | superadmin | Update school |
| `DELETE` | `/api/schools/{id}` | superadmin | Delete school |

**Users (admin)**

| Method | Path | Roles | Description |
|---|---|---|---|
| `GET` | `/api/users` | superadmin | List users (paginated, filter by role/school) |
| `POST` | `/api/users` | superadmin | Create user (calls auth register + creates assessment_users row) |
| `PUT` | `/api/users/{authUserId}` | superadmin | Update user profile/role/status |
| `DELETE` | `/api/users/{authUserId}` | superadmin | Delete user |

**Students (counselor / affiliate)**

| Method | Path | Roles | Description |
|---|---|---|---|
| `GET` | `/api/students` | gurubk, afiliator | List own students (paginated, search by name/NISN) |
| `POST` | `/api/students` | gurubk, afiliator | Create student (calls auth register, creates profile, creates fee_share row) |
| `GET` | `/api/students/{authUserId}` | gurubk, afiliator, superadmin | Get student |
| `PUT` | `/api/students/{authUserId}` | gurubk, afiliator | Update student |
| `DELETE` | `/api/students/{authUserId}` | gurubk, afiliator | Delete student (cascades fee_share) |

**Test categories & assignments (admin)**

| Method | Path | Roles | Description |
|---|---|---|---|
| `GET` | `/api/test-categories` | superadmin | List all 25 categories |
| `GET` | `/api/test-assignments` | superadmin | List all assignments (filter by schoolId) |
| `POST` | `/api/test-assignments` | superadmin | Create assignment |
| `PUT` | `/api/test-assignments/{id}` | superadmin | Update (dates, status, cert flag) |
| `DELETE` | `/api/test-assignments/{id}` | superadmin | Delete |

**DISC (v1)**

| Method | Path | Roles | Description |
|---|---|---|---|
| `GET` | `/api/disc/questions` | siswa | Get all DISC questions (ordered) |
| `GET` | `/api/disc/assignment-check` | siswa | Check if test is open + not yet taken |
| `POST` | `/api/disc/submit` | siswa | Submit answers → score → persist result |
| `GET` | `/api/disc/result/me` | siswa | Get own DISC result + interpretation |
| `GET` | `/api/disc/results` | superadmin, gurubk, afiliator | Paginated results (scoped by role) |
| `GET` | `/api/disc/results/{authUserId}` | superadmin, gurubk, afiliator | Single result + interpretation |

**DISC master data (admin)**

| Method | Path | Description |
|---|---|---|
| `GET/POST/PUT/DELETE` | `/api/disc/questions/{id}` | Question bank CRUD |
| `GET/POST/PUT/DELETE` | `/api/disc/personality-profiles/{id}` | kepribadian CRUD |
| `GET/POST/PUT/DELETE` | `/api/disc/scoring-most/{id}` | rumus_most CRUD |
| `GET/POST/PUT/DELETE` | `/api/disc/scoring-least/{id}` | rumus_least CRUD |
| `GET/POST/PUT/DELETE` | `/api/disc/scoring-dif/{id}` | rumus_dif CRUD |

**Holland (v1)**

| Method | Path | Roles | Description |
|---|---|---|---|
| `GET` | `/api/holland/questions` | siswa | Get all Holland questions (18 groups) |
| `GET` | `/api/holland/assignment-check` | siswa | Check if open + not yet taken |
| `POST` | `/api/holland/submit` | siswa | Submit answers → score → persist |
| `GET` | `/api/holland/result/me` | siswa | Own Holland result + top-3 code |
| `GET` | `/api/holland/results` | superadmin, gurubk, afiliator | Paginated (scoped) |
| `GET` | `/api/holland/results/{authUserId}` | superadmin, gurubk, afiliator | Single result |
| (admin CRUD) | `/api/holland/questions`, `/api/holland/descriptions` | superadmin | Question bank + description table CRUD |

### Roadmap Endpoints

- `GET|POST /api/papi/...`, `/api/cfit/...`, `/api/ist/...` — PAPI, CFIT, IST (same pattern)
- `GET /api/certificates/disc/{authUserId}` — certificate data for print
- `GET|POST /api/fee-config` — fee % configuration
- `GET /api/fees/me` — own fee report (counselor/affiliate)
- `POST /api/students/import` — Google Sheets bulk import

---

## 10. Build Phases

### Phase 0 — Scaffold & auth wiring
1. Create `backend/pom.xml`, `application.yml`, `backend/.env` (from template above).
2. Implement JWT security layer: copy `JwtTokenProvider` + `JwtAuthenticationFilter` (same JJWT API, same HS512); wire `SecurityConfig`.
3. Create Flyway `V1__init.sql` with `schools` and `assessment_users` tables.
4. Implement `POST /api/profile` (lazy-provision user from JWT claims).
5. Extend auth server: add optional `role` param to `POST /api/auth/register` and a `/api/auth/seed-admin` endpoint.
6. Set `JWT_SECRET` (≥64 bytes) in both `../auth/backend/.env` and `backend/.env`. Add `http://localhost:2001` to `CORS_ALLOWED_ORIGINS` in auth `.env`. Set `APP_KAFKA_ENABLED=false` in auth `.env`.
7. Add PM2 app for backend (port 2002) to `ecosystem.config.js`.
8. Frontend: implement `src/hooks.server.ts`, extend `app.d.ts`, add `$lib/api/index.ts`, add `routes/login/`.
9. **Verify:** can register a `superadmin` via `/api/auth/register?role=superadmin`, log in, receive JWT, call `POST /api/profile` on backend with the token, get back the provisioned profile.

### Phase 1 — School & user management
1. Flyway `V2__schools_and_users.sql`.
2. `School` entity, repository, service, `SchoolController` (full CRUD).
3. `UserController` (superadmin manages all users), `StudentController` (counselor/affiliate manages own students). Creating a student calls auth's `/register` to issue auth credentials, then creates the `assessment_users` row.
4. Frontend: `/admin/schools`, `/admin/users`, `/counselor/students` pages (data tables + CRUD forms, Indonesian labels).
5. **Verify:** superadmin can create a school, create a counselor, counselor can create a student, student can log in.

### Phase 2 — DISC end-to-end
1. Flyway `V3__disc.sql`: `disc_questions`, `disc_results`, `disc_personality_profiles`, `disc_scoring_most/least/dif`, `test_categories`, `test_assignments`.
2. Migrate seed data: populate `disc_scoring_most/least/dif` from LEGACY `rumus_*` tables; populate `disc_personality_profiles` from LEGACY `kepribadians`. Seed the 25 test categories.
3. `DiscScoringService.score(Map<String,String> answers)` → `DiscResult`.
4. `DiscInterpretationService.interpret(DiscResult)` → profile + chart data.
5. All DISC endpoints (questions, assignment-check, submit, result, results list, admin CRUD).
6. Frontend: DISC question banks admin page, test assignment admin page, student DISC flow (dashboard tile → instructions → exam form → result page with chart), counselor/admin results list + detail.
7. **Verify:** full DISC flow from student POV; admin can view result; interpretation matches LEGACY for same inputs.

### Phase 3 — Holland end-to-end
1. Flyway `V4__holland.sql`.
2. Migrate seed data from LEGACY `desk_hollands`.
3. `HollandScoringService`.
4. All Holland endpoints.
5. Frontend: Holland flow + results.
6. **Verify:** same pattern.

### Roadmap
- Phase 4: PAPI Kostick.
- Phase 5: IQ CFIT.
- Phase 6: IQ IST (most complex — tiered scoring + norma + IQ lookup + image questions).
- Phase 7: Certificate generation (server-side or browser-print).
- Phase 8: Fee/commission system.
- Phase 9: Google Sheets bulk import.

---

## 11. Local Dev Runbook

### Prerequisites
- Java 17, Maven 3.9+
- Node 20+, npm 10+
- PostgreSQL (local or Docker): database `assessment`, user `postgres`
- MongoDB (local or Docker): `localhost:27017`

### First-time setup

```bash
# 1. Set JWT_SECRET (≥64 bytes) consistently in both:
echo "JWT_SECRET=<your-64-char-secret>" >> ../auth/backend/.env

# 2. Update auth CORS and disable Kafka in ../auth/backend/.env:
# CORS_ALLOWED_ORIGINS=http://localhost:2001
# APP_KAFKA_ENABLED=false

# 3. New backend .env (copy template from §5 and fill DB_PASSWORD + JWT_SECRET).

# 4. Create Postgres DB:
createdb assessment

# 5. Start auth server:
cd ../auth/backend && mvn spring-boot:run

# 6. Seed a superadmin (once):
curl -X POST "http://localhost:2000/api/auth/seed-admin"

# 7. Start assessment backend:
cd ../../assessment/backend && mvn spring-boot:run

# 8. Start frontend:
cd ../frontend && npm run dev
```

Or via PM2 (after adding the backend app to `ecosystem.config.js`):
```bash
cd ..   # assessment/ workspace root
pm2 start ecosystem.config.js
pm2 logs
```

### Useful checks

```bash
# Auth health:
curl http://localhost:2000/api/health

# Login (returns JWT):
curl -X POST http://localhost:2000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"..."}'

# Backend health:
curl http://localhost:2002/api/actuator/health   # (add actuator dep if desired)

# Frontend:
open http://localhost:2001
```

---

## 12. Conventions & Gotchas

### Naming
- All Java entities, DTOs, repositories, services, and REST paths: **English**.
- All Svelte UI text (labels, buttons, messages, validation errors): **Indonesian**.
- Instrument/test names: DISC, Holland, RIASEC, PAPI Kostick, CFIT, IST — keep as-is everywhere.
- The `platformId` claim in the JWT represents the tenant/platform (from the auth server). For this project, use a fixed value such as `assessment` or `odas`.

### Do NOT carry over from LEGACY
- `App\Camaba` model and `camaba_id` column — dead artifact, never used.
- `hasils` table and `App\hasil` model — legacy, unused, never referenced.
- Empty `desk_iq_ists` / `deskIqIst` model — seed data was never entered.
- `vue-template-compiler` in frontend deps — leftover from an unused Vue setup.
- `barryvdh/laravel-dompdf` — imported in sertifikatController but never called; "certificates" in LEGACY are browser-print HTML pages. In the rebuild, decide at Phase 7 between browser print and server-side PDF.
- `email_verified_at` column/cast — there is no email on users in LEGACY; don't add vestigial fields.

### Security
- Do NOT default student passwords to their NISN. Students should set their own password on first login, or a counselor sets a temporary password with forced reset.
- Do NOT hardcode `sekolahid=1, afiliatorid=2, gurubkid=3` in public registration. Public self-registration should require school lookup by name or be disabled by default.
- The SheetDB key (`76cfbicpg3v5m`) is a hardcoded LEGACY credential. Put it in `SHEETS_DB_ID` env var when implementing Phase 9.

### JWT / auth
- `JWT_SECRET` must be ≥64 UTF-8 bytes for HS512. Use a random 64-char base64 string.
- No refresh tokens exist. On 401 from the backend, redirect to `/login`. The 24h expiry means users re-login daily.
- The auth server's `/api/auth/register` takes **query parameters, not JSON**. The login endpoint takes **JSON**. Don't mix them.
- The auth server `CORS_ALLOWED_ORIGINS` has **no code default** — if the env var is missing, the app fails to start.
- Set `APP_KAFKA_ENABLED=false` in auth `.env` unless you have a Kafka broker running locally.

### Database
- Use Flyway for all schema changes. Never set `spring.jpa.hibernate.ddl-auto` to anything other than `validate` or `none` in non-development environments.
- Scoring/description tables (`disc_scoring_*`, `disc_personality_profiles`, `holland_descriptions`, `papi_descriptions`, `ist_norma`, `ist_iq_bands`) are populated by the superadmin via CRUD. Seed them from LEGACY data in the Flyway migration so the app works immediately after a fresh deploy.
- Result tables denormalize student identity (name, school, NISN, gender, DOB) intentionally — this preserves historical results if student profiles are later changed.

### Frontend scaffold
- Svelte 5 runes mode is forced by `vite.config.ts`. Use `$state`, `$derived`, `$effect`, `$props` — not the old `let`/reactive-declarations syntax.
- The shadcn-svelte style is `maia` (not default). Don't switch it. Add components with `npx shadcn-svelte@latest add <component>`.
- `components.json` iconLibrary is `hugeicons` — import icons from `@hugeicons/svelte`.
- `@sveltejs/adapter-node` is used (not static or vercel) — the built frontend is a Node server on port 2001.

---

## 13. Reference: LEGACY Source Paths

For comparison or deeper investigation during implementation:

| Topic | LEGACY file |
|---|---|
| All 5 scoring algorithms | `LEGACY/app/Http/Controllers/Siswa/ujianController.php` (1245 lines) |
| DISC interpretation (MOST/LEST/DIF + kepribadian lookup) | `LEGACY/app/Http/Controllers/Superadmin/allReportController.php` |
| All routes | `LEGACY/routes/web.php` |
| All migrations | `LEGACY/database/migrations/` |
| Role/auth middleware | `LEGACY/app/Http/Middleware/CekRole.php` |
| Student creation + fee calculation | `LEGACY/app/Http/Controllers/GuruBK/siswaController.php` |
| Google Sheets import | `LEGACY/app/Http/Controllers/GuruBK/siswaController.php::refresh()` |
| IST subtest-4 tiered scoring | `LEGACY/app/Http/Controllers/Siswa/ujianController.php::nilaiJawaban()` |
| Test category ID→bundle map | `LEGACY/app/Http/Controllers/Siswa/ujianController.php::index()` |
| Certificate views | `LEGACY/resources/views/Siswa/Sertifikat/` |
| Exam form views | `LEGACY/resources/views/Siswa/Ujian/` and `LEGACY/app/View/Components/` |

Auth server source (for JWT integration reference):

| Topic | Auth source file |
|---|---|
| Token generation/validation | `../auth/backend/src/main/java/com/rwid/security/JwtTokenProvider.java` |
| Per-request auth filter | `../auth/backend/src/main/java/com/rwid/security/JwtAuthenticationFilter.java` |
| Security chain | `../auth/backend/src/main/java/com/rwid/config/SecurityConfig.java` |
| Login/register endpoints | `../auth/backend/src/main/java/com/rwid/controller/AuthController.java` |
| AuthResponse shape | `../auth/backend/src/main/java/com/rwid/dto/AuthResponse.java` |
| UserDTO shape | `../auth/backend/src/main/java/com/rwid/dto/UserDTO.java` |
| Auth `.env` | `../auth/backend/.env` |
| Auth `application.yml` | `../auth/backend/src/main/resources/application.yml` |

Frontend scaffold (to understand what already exists before adding code):

| Topic | File |
|---|---|
| Package versions | `frontend/package.json` |
| shadcn config | `frontend/components.json` |
| Vite / port / runes config | `frontend/vite.config.ts` |
| App.Locals (extend for auth) | `frontend/src/app.d.ts` |
| PM2 / port assignments | `ecosystem.config.js` |
