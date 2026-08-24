#!/bin/bash

# Development Environment Startup Script
# Usage: ./start-dev.sh

set -e

echo "==========================================="
echo "Starting Assessment System Development Environment"
echo "==========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}"

# Check PostgreSQL
if ! pg_isready > /dev/null 2>&1; then
    echo -e "${RED}PostgreSQL is not running${NC}"
    echo "Starting PostgreSQL..."
    brew services start postgresql@18 2>/dev/null || true
    sleep 3
fi

if pg_isready; then
    echo -e "${GREEN}✓ PostgreSQL is running${NC}"
else
    echo -e "${RED}✗ PostgreSQL failed to start${NC}"
    exit 1
fi

# Check database exists
if psql -lqt | cut -d \| -f 1 | grep -qw assessment; then
    echo -e "${GREEN}✓ Database 'assessment' exists${NC}"
else
    echo -e "${YELLOW}Database 'assessment' does not exist, creating...${NC}"
    createdb assessment
    echo -e "${GREEN}✓ Database created${NC}"
fi

# Check if schema is imported
TABLE_COUNT=$(psql -d assessment -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';" | xargs)
if [ "$TABLE_COUNT" -gt 0 ]; then
    echo -e "${GREEN}✓ Database schema exists ($TABLE_COUNT tables)${NC}"
else
    echo -e "${YELLOW}Importing database schema...${NC}"
    psql assessment < data-snapshots/20260701_084123_sql/postgres/assessment.sql
    echo -e "${GREEN}✓ Schema imported${NC}"
fi

# Check Python dependencies for auth mock
echo -e "${YELLOW}Checking Python dependencies...${NC}"
if command -v python3 &> /dev/null; then
    echo -e "${GREEN}✓ Python3 is installed${NC}"
    
    # Check Flask
    if python3 -c "import flask" &> /dev/null; then
        echo -e "${GREEN}✓ Flask is installed${NC}"
    else
        echo -e "${YELLOW}Installing Flask...${NC}"
        pip3 install Flask PyJWT
        echo -e "${GREEN}✓ Flask installed${NC}"
    fi
else
    echo -e "${RED}✗ Python3 is not installed${NC}"
    echo "Please install Python3: https://www.python.org/downloads/"
    exit 1
fi

# Start services
echo -e "\n${YELLOW}Starting services...${NC}"

# Function to cleanup on exit
cleanup() {
    echo -e "\n${YELLOW}Shutting down services...${NC}"
    kill $AUTH_PID $ASSESSMENT_PID 2>/dev/null || true
    echo -e "${GREEN}Services stopped${NC}"
    exit 0
}

trap cleanup INT TERM EXIT

# Start Auth Mock Service
echo -e "${YELLOW}Starting Auth Mock Service on port 2000...${NC}"
cd backend
python3 auth_mock.py &
AUTH_PID=$!
sleep 3

if curl -s http://localhost:2000/api/auth/health > /dev/null; then
    echo -e "${GREEN}✓ Auth Mock Service is running${NC}"
else
    echo -e "${RED}✗ Auth Mock Service failed to start${NC}"
    exit 1
fi

# Start Assessment Service
echo -e "${YELLOW}Starting Assessment Service on port 2002...${NC}"
cargo run --bin assessment-backend &
ASSESSMENT_PID=$!
sleep 5

if curl -s http://localhost:2002/api/health > /dev/null; then
    echo -e "${GREEN}✓ Assessment Service is running${NC}"
else
    echo -e "${RED}✗ Assessment Service failed to start${NC}"
    exit 1
fi

# Display information
echo -e "\n${GREEN}===========================================${NC}"
echo -e "${GREEN}Development Environment Ready!${NC}"
echo -e "${GREEN}===========================================${NC}"
echo ""
echo -e "${YELLOW}Services:${NC}"
echo "  Auth Mock:      http://localhost:2000"
echo "  Assessment API: http://localhost:2002"
echo ""
echo -e "${YELLOW}Test Users:${NC}"
echo "  Username: testuser     Password: test123     Role: SUPERADMIN"
echo "  Username: gurubk       Password: gurubk123   Role: GURUBK"
echo "  Username: student      Password: student123  Role: SISWA"
echo ""
echo -e "${YELLOW}API Endpoints:${NC}"
echo "  Health Check:   curl http://localhost:2002/api/health"
echo "  Login:          curl -X POST http://localhost:2000/api/auth/login \\"
echo "                    -H 'Content-Type: application/json' \\"
echo "                    -d '{\"username\":\"testuser\",\"password\":\"test123\"}'"
echo ""
echo -e "${YELLOW}Press Ctrl+C to stop all services${NC}"

# Wait for user interrupt
wait $AUTH_PID $ASSESSMENT_PID