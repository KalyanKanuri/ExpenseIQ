# Variables
BINARY_NAME=expenseiq
Backend_DIR=./Backend
FRONTEND_DIR=./Frontend
DOCKER_COMPOSE=docker-compose.yml

# Go commands
GOCMD=go
GOBUILD=$(GOCMD) build
GOTEST=$(GOCMD) test
GOGET=$(GOCMD) get
GOMOD=$(GOCMD) mod
GOFMT=$(GOCMD) fmt

# Docker commands
DOCKER=docker
DOCKER_COMPOSE_CMD=docker-compose

DB_PATH=./Backend/database/expenseiq.db

.PHONY: all build test clean run docker-build docker-run docker-stop help fmt lint migrate-up migrate-down

# Default target
all: clean init-db build

# Help command to list all available commands
help:
	@echo "Available commands:"
	@echo "  make all          - Clean and build the project"
	@echo "  make build        - Build both Frontend and Backend"
	@echo "  make run          - Run the application locally"
	@echo "  make test         - Run tests for both Frontend and Backend"
	@echo "  make clean        - Clean build files"
	@echo "  make fmt          - Format Go code"
	@echo "  make lint         - Run linters"
	@echo "  make docker-build - Build Docker images"
	@echo "  make docker-run   - Run application in Docker"
	@echo "  make docker-stop  - Stop Docker containers"
	@echo "  make migrate-up   - Run database migrations up"
	@echo "  make migrate-down - Run database migrations down"
	@echo "  make deps         - Download dependencies"
	@echo "  make dev          - Run development environment"

# Build commands
build: build-backend build-frontend

build-backend:
	@echo "Building Backend..."
	cd $(Backend_DIR) && $(GOBUILD) -o $(BINARY_NAME) ./cmd

build-frontend:
	@echo "Building frontend..."
	cd $(FRONTEND_DIR) && npm install && npm run build

# Test commands
test: test-Backend test-frontend

test-backend:
	@echo "Testing Backend..."
	cd $(Backend_DIR) && $(GOTEST) ./...

test-frontend:
	@echo "Testing frontend..."
	cd $(FRONTEND_DIR) && npm test

# Clean commands
clean: clean-backend clean-frontend
	@echo "Cleaning up..."

clean-backend:
	@echo "Cleaning Backend..."
	cd $(Backend_DIR) && rm -f $(BINARY_NAME)

clean-frontend:
	@echo "Cleaning frontend..."
	cd $(FRONTEND_DIR) && rm -rf node_modules build dist

# Run commands
run: run-Backend run-frontend

run-backend:
	@echo "Running Backend..."
	cd $(Backend_DIR) && ./$(BINARY_NAME)

run-frontend:
	@echo "Running frontend..."
	cd $(FRONTEND_DIR) && npm start

# Development environment
dev:
	@echo "Starting development environment..."
	$(DOCKER_COMPOSE_CMD) -f $(DOCKER_COMPOSE) up --build

# Docker commands
docker-build:
	@echo "Building Docker images..."
	$(DOCKER_COMPOSE_CMD) -f $(DOCKER_COMPOSE) build

docker-run:
	@echo "Running Docker containers..."
	$(DOCKER_COMPOSE_CMD) -f $(DOCKER_COMPOSE) up -d

docker-stop:
	@echo "Stopping Docker containers..."
	$(DOCKER_COMPOSE_CMD) -f $(DOCKER_COMPOSE) down

# Code quality commands
fmt:
	@echo "Formatting Go code..."
	cd $(Backend_DIR) && $(GOFMT) ./...

lint: lint-Backend lint-frontend

lint-backend:
	@echo "Linting Backend..."
	cd $(Backend_DIR) && golangci-lint run

lint-frontend:
	@echo "Linting frontend..."
	cd $(FRONTEND_DIR) && npm run lint

# Database commands
# Database initialization
init-db:
	@echo "Initializing database directory..."
	touch $(DB_PATH)

migrate-up:
	@echo "Running database migrations up..."
	cd $(Backend_DIR) && migrate -path migrations -database "sqlite3://$(DB_PATH)" up

migrate-down:
	@echo "Running database migrations down..."
	cd $(Backend_DIR) && migrate -path migrations -database "sqlite3://$(DB_PATH)" down

# Dependency management
deps: deps-Backend deps-frontend

deps-backend:
	@echo "Downloading Backend dependencies..."
	cd $(Backend_DIR) && $(GOMOD) download

deps-frontend:
	@echo "Downloading frontend dependencies..."
	cd $(FRONTEND_DIR) && npm install

# Generate API documentation
docs:
	@echo "Generating API documentation..."
	cd $(Backend_DIR) && swag init -g cmd/server.go

# Security audit
security-audit: security-audit-Backend security-audit-frontend

security-audit-backend:
	@echo "Running security audit for Backend..."
	cd $(Backend_DIR) && govulncheck ./...

security-audit-frontend:
	@echo "Running security audit for frontend..."
	cd $(FRONTEND_DIR) && npm audit