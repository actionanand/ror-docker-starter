#!/bin/bash

###############################################################################
# Quick Docker Management Script
# Simple commands for daily development
###############################################################################

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

print_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}\n"
}

# Start services
start() {
    print_header "Starting Services"
    cd "$PROJECT_ROOT"
    docker-compose up -d
    sleep 2
    echo -e "${GREEN}✓ Services started${NC}"
    echo -e "${BLUE}Application: http://localhost:3000${NC}"
}

# Stop services
stop() {
    print_header "Stopping Services"
    cd "$PROJECT_ROOT"
    docker-compose stop
    echo -e "${GREEN}✓ Services stopped${NC}"
}

# View logs
logs() {
    print_header "Service Logs"
    cd "$PROJECT_ROOT"
    docker-compose logs -f "${@:-web}"
}

# Rails console
console() {
    print_header "Rails Console"
    cd "$PROJECT_ROOT"
    docker-compose exec web rails console
}

# Database migration
migrate() {
    print_header "Running Migrations"
    cd "$PROJECT_ROOT"
    docker-compose exec web rails db:migrate
    echo -e "${GREEN}✓ Migrations complete${NC}"
}

# Run tests
test() {
    print_header "Running Tests"
    cd "$PROJECT_ROOT"
    docker-compose run --rm web bundle exec rspec "${@:-.}"
}

# Add a gem
add_gem() {
    if [ -z "$1" ]; then
        echo "Usage: $0 add_gem <gem_name>"
        exit 1
    fi
    
    print_header "Adding Gem: $1"
    cd "$PROJECT_ROOT"
    docker-compose run --rm bundler add "$1"
    echo -e "${GREEN}✓ Gem added: $1${NC}"
}

# Shell access
shell() {
    print_header "Shell Access"
    cd "$PROJECT_ROOT"
    docker-compose exec web bash
}

# Status check
status() {
    print_header "Service Status"
    cd "$PROJECT_ROOT"
    docker-compose ps
    echo
    echo -e "${BLUE}Docker Disk Usage:${NC}"
    docker system df | head -10
}

# Show help
show_help() {
    cat << EOF

${BLUE}Quick Docker Management${NC}

Usage: bash quick.sh <command> [options]

Commands:
  start              Start all services
  stop               Stop all services
  logs [service]     View logs (default: web)
  status             Show service status
  console            Open Rails console
  shell              Get shell access
  migrate            Run database migrations
  test [path]        Run tests
  add_gem <name>     Add a new gem
  help               Show this help

Examples:
  bash quick.sh start
  bash quick.sh logs sidekiq
  bash quick.sh add_gem devise
  bash quick.sh test spec/models/user_spec.rb
  bash quick.sh console

${YELLOW}Quick Reference:${NC}
  • Start development:       bash quick.sh start
  • View logs:               bash quick.sh logs -f
  • Open console:            bash quick.sh console
  • Run migrations:          bash quick.sh migrate
  • Stop all services:       bash quick.sh stop

EOF
}

# Main
case "${1:-help}" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    logs)
        logs "${@:2}"
        ;;
    console)
        console
        ;;
    migrate)
        migrate
        ;;
    test)
        test "${@:2}"
        ;;
    add_gem)
        add_gem "$2"
        ;;
    shell)
        shell
        ;;
    status)
        status
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo -e "${RED}Unknown command: $1${NC}"
        show_help
        exit 1
        ;;
esac
