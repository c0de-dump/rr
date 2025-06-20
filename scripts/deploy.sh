#!/bin/bash

# Docker Compose deployment script for Rails application

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Starting Rails application with Docker Compose${NC}"

# Check if .env file exists
if [ ! -f .env ]; then
    echo -e "${YELLOW}⚠️  .env file not found. Creating from template...${NC}"
    cp .env.example .env
    echo -e "${RED}❗ Please update the .env file with your actual values before proceeding${NC}"
    exit 1
fi

# Build and start services
echo -e "${GREEN}📦 Building Docker images...${NC}"
docker compose build

echo -e "${GREEN}🗄️  Starting database...${NC}"
docker compose up -d db zipkin

# Wait for database to be ready
echo -e "${YELLOW}⏳ Waiting for database to be ready...${NC}"
until docker compose exec db pg_isready -U postgres; do
    sleep 2
done

echo -e "${GREEN}🗃️  Setting up database...${NC}"
docker compose run --rm web bin/rails db:create db:migrate

echo -e "${GREEN}🚀 Starting all services...${NC}"
docker compose up -d

echo -e "${GREEN}✅ Application is starting up!${NC}"
echo -e "${GREEN}📊 Services status:${NC}"
docker compose ps

echo -e "${GREEN}🌐 Access points:${NC}"
echo -e "  • Web Application: http://localhost:3000"
echo -e "  • Health Check: http://localhost:3000/health"
echo -e "  • Create Job: POST http://localhost:3000/jobs"
echo -e "  • List Jobs: GET http://localhost:3000/jobs"
echo -e "  • Zipkin UI: http://localhost:9411"

echo -e "${YELLOW}📝 Example job creation:${NC}"
echo -e "curl -X POST http://localhost:3000/jobs \\"
echo -e "  -H 'Content-Type: application/json' \\"
echo -e "  -d '{\"message\":\"Hello from API!\", \"delay\":5}'"

echo -e "${GREEN}📋 To view logs:${NC}"
echo -e "  • Web server: docker compose logs -f web"
echo -e "  • Worker: docker compose logs -f worker"
echo -e "  • All services: docker compose logs -f"
