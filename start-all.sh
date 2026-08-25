#!/bin/bash

# Full Stack Development Environment Startup Script
# Starts: Auth Mock + Assessment Backend + Frontend

set -e

echo "==========================================="
echo "Starting Full Stack Development Environment"
echo "==========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to cleanup on exit
cleanup() {
    echo -e "\n${YELLOW}Shutting down all services...${NC}"
    kill $AUTH_PID $BACKEND_PID $FRONTEND_PID 2>/dev/null || true
    echo -e "${GREEN}All services stopped${NC}"
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

# Start Assessment Backend Service
echo -e "${YELLOW}Starting Assessment Backend on port 2002...${NC}"
cargo run --bin assessment-backend &
BACKEND_PID=$!
sleep 5

if curl -s http://localhost:2002/api/health > /dev/null; then
    echo -e "${GREEN}✓ Assessment Backend is running${NC}"
else
    echo -e "${RED}✗ Assessment Backend failed to start${NC}"
    exit 1
fi

# Start Frontend
echo -e "${YELLOW}Starting Frontend on port 5173...${NC}"
cd ../frontend
npm run dev &
FRONTEND_PID=$!
sleep 5

if curl -s http://localhost:5173 > /dev/null; then
    echo -e "${GREEN}✓ Frontend is running${NC}"
else
    echo -e "${YELLOW}⚠ Frontend might take a moment to start...${NC}"
    sleep 3
fi

# Display information
echo -e "\n${GREEN}===========================================${NC}"
echo -e "${GREEN}Full Stack Development Environment Ready!${NC}"
echo -e "${GREEN}===========================================${NC}"
echo ""
echo -e "${YELLOW}Services:${NC}"
echo "  Auth Mock:      http://localhost:2000"
echo "  Assessment API: http://localhost:2002/api"
echo "  Frontend:       http://localhost:5173"
echo ""
echo -e "${YELLOW}Test Users:${NC}"
echo "  Username: testuser     Password: test123     Role: SUPERADMIN"
echo "  Username: gurubk       Password: gurubk123   Role: GURUBK"
echo "  Username: student      Password: student123  Role: SISWA"
echo ""
echo -e "${YELLOW}Testing CORS:${NC}"
echo "  curl -H 'Origin: http://localhost:5173' \\"
echo "    -H 'Access-Control-Request-Method: GET' \\"
echo "    -H 'Access-Control-Request-Headers: Content-Type,Authorization' \\"
echo "    -X OPTIONS http://localhost:2002/api/big5/questions"
echo ""
echo -e "${YELLOW}Press Ctrl+C to stop all services${NC}"

# Test CORS configuration
echo -e "\n${YELLOW}Testing CORS configuration...${NC}"
if curl -s -H "Origin: http://localhost:5173" \
  -H "Access-Control-Request-Method: GET" \
  -X OPTIONS http://localhost:2002/api/big5/questions \
  --head | grep -q "Access-Control-Allow-Origin"; then
    echo -e "${GREEN}✓ CORS is properly configured${NC}"
else
    echo -e "${YELLOW}⚠ CORS might need additional configuration${NC}"
fi

# Wait for user interrupt
wait $AUTH_PID $BACKEND_PID $FRONTEND_PID