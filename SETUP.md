# Setup Development Environment Lokal

## Prerequisites

### 1. PostgreSQL
```bash
# Install PostgreSQL (macOS dengan Homebrew)
brew install postgresql@18
brew services start postgresql@18

# Atau jika sudah terinstall, pastikan running
pg_isready
```

### 2. Rust & Cargo
```bash
# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Install dependencies
cargo install sqlx-cli --no-default-features --features postgres
```

## Setup Database

### 1. Buat Database
```bash
createdb assessment
```

### 2. Import Schema Dasar
```bash
psql assessment < data-snapshots/20260701_084123_sql/postgres/assessment.sql
```

### 3. Jalankan Migrasi
```bash
cd backend
DATABASE_URL=postgresql://[username]@localhost:5432/assessment sqlx migrate run
```

## Setup Environment Variables

Buat file `.env` di `backend/.env`:

```env
# PostgreSQL (JDBC-style vars, same as the Java backend read)
DATABASE_URL=jdbc:postgresql://localhost:5432/assessment
DATABASE_USERNAME=[your_username]
DATABASE_PASSWORD=

# JWT (must match the estate's shared secret -- this service only validates)
JWT_SECRET=test-jwt-secret-that-must-be-at-least-32-bytes-long-for-testing-123456

# Server
SERVER_PORT=2002

# CORS (comma-separated)
CORS_ALLOWED_ORIGINS=http://localhost:2001,http://localhost:3000

# Peer domain dependencies (resolved automatically by 'eco configure')
AUTH_BASE_URL=http://localhost:2000/api
EMAIL_MANAGER_URL=http://localhost:3142/api/email

# Credential PDF storage directory
CREDENTIALS_STORAGE_PATH=./storage/credentials

# Enables the dev-only "clear my own result" endpoint (retakes while testing)
DEV_TOOLS_ENABLED=true
```

## Running the Application

### 1. Build dan Run
```bash
cd backend
cargo run --bin assessment-backend
```

### 2. Verifikasi
```bash
curl http://localhost:2002/api/health
# Harus return: {"status":"UP"}
```

## Setup Auth Service Mock (Untuk Development)

Karena aplikasi ini menggunakan external auth service, untuk development lokal kita bisa:

### Option A: Gunakan Mock Server Sederhana
```bash
# Install Python jika belum ada
python3 -m http.server 2000
```

Atau buat file `auth_mock.py`:

```python
from flask import Flask, jsonify, request
import jwt
import time

app = Flask(__name__)

JWT_SECRET = "test-jwt-secret-that-must-be-at-least-32-bytes-long-for-testing-123456"

@app.route('/api/auth/login', methods=['POST'])
def login():
    # Mock login - selalu success untuk testing
    data = request.json
    token = jwt.encode({
        'sub': 'test-user-id',
        'username': data.get('username', 'testuser'),
        'role': 'SUPERADMIN',
        'iat': int(time.time()),
        'exp': int(time.time()) + 3600
    }, JWT_SECRET, algorithm='HS512')
    
    return jsonify({
        'token': token,
        'user': {
            'id': 'test-user-id',
            'username': data.get('username', 'testuser'),
            'email': 'test@example.com',
            'name': 'Test User',
            'role': 'SUPERADMIN'
        },
        'expiresIn': 3600
    })

@app.route('/api/auth/register', methods=['POST'])
def register():
    # Mock register
    return jsonify({
        'token': 'mock-jwt-token',
        'user': {
            'id': 'new-user-id',
            'username': 'newuser',
            'email': 'new@example.com',
            'name': 'New User',
            'role': 'USER'
        },
        'expiresIn': 3600
    })

if __name__ == '__main__':
    app.run(port=2000, debug=True)
```

### Option B: Disable Auth untuk Development
Modifikasi kode sementara untuk bypass auth (tidak direkomendasikan untuk production).

## Testing Endpoints

### Health Check
```bash
curl http://localhost:2002/api/health
```

### Create Test User (via Mock Auth)
```bash
# First, provision profile (requires valid JWT token)
curl -X POST http://localhost:2002/api/profile/provision \
  -H "Authorization: Bearer mock-token" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "username": "testuser",
    "role": "SUPERADMIN"
  }'
```

## Troubleshooting

### 1. Database Connection Error
```
Error: failed to connect to PostgreSQL
```
- Pastikan PostgreSQL running: `pg_isready`
- Cek username di `.env` file
- Verifikasi database exists: `psql -l | grep assessment`

### 2. Migration Error
```
relation "test_categories" does not exist
```
- Pastikan sudah import schema dasar dari `data-snapshots`

### 3. Auth Service Error
```
auth change-password failed: HTTP 500
```
- Pastikan auth mock service running di port 2000
- Atau update `AUTH_BASE_URL` di `.env` jika menggunakan service lain

## Development Notes

1. **JWT Secret**: Harus sama antara auth service dan assessment service
2. **CORS**: Konfigurasi di `.env` untuk frontend development
3. **Ports**:
   - Assessment Service: 2002
   - Auth Service: 2000 (mock)
   - Frontend: 3000 atau 2001

## Commit & Push

```bash
# Add changes
git add SETUP.md backend/.env

# Commit
git commit -m "feat: add local development setup documentation"

# Push to remote
git push origin setup-local-dev
```