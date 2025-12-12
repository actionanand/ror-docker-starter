#!/bin/bash

###############################################################################
# Rails Docker Setup Script
# Complete setup automation for Rails Docker environment
###############################################################################

set -e  # Exit on error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_header() {
    echo -e "\n${BLUE}==================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}==================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Check prerequisites
check_prerequisites() {
    print_header "Checking Prerequisites"

    # Check Docker
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed"
        exit 1
    fi
    print_success "Docker is installed ($(docker --version))"

    # Check Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose is not installed"
        exit 1
    fi
    print_success "Docker Compose is installed ($(docker-compose --version))"

    # Check Docker daemon
    if ! docker info &> /dev/null; then
        print_error "Docker daemon is not running"
        exit 1
    fi
    print_success "Docker daemon is running"
}

# Check if Rails app exists
check_rails_app() {
    if [ ! -f "$PROJECT_ROOT/src/Gemfile" ]; then
        print_warning "Rails application not found in src/ directory"
        return 1
    fi
    print_success "Rails application found"
    return 0
}

# Build Docker images
build_images() {
    print_header "Building Docker Images"

    cd "$PROJECT_ROOT"
    
    if docker-compose build; then
        print_success "Docker images built successfully"
    else
        print_error "Failed to build Docker images"
        exit 1
    fi
}

# Create and setup database
setup_database() {
    print_header "Setting Up Database"

    cd "$PROJECT_ROOT"

    # Create database
    print_warning "Creating PostgreSQL database..."
    if docker-compose run --rm rails_cli db:create; then
        print_success "Database created"
    else
        print_warning "Database might already exist (continuing...)"
    fi

    # Run migrations
    print_warning "Running migrations..."
    if docker-compose run --rm rails_cli db:migrate; then
        print_success "Migrations completed"
    else
        print_error "Migration failed"
        exit 1
    fi

    # Optional: Seed database
    if [ -f "$PROJECT_ROOT/src/db/seeds.rb" ]; then
        read -p "Run database seeds? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_warning "Seeding database..."
            docker-compose run --rm rails_cli db:seed
            print_success "Database seeded"
        fi
    fi
}

# Generate Rails secret
generate_secret() {
    print_header "Generating Rails Secret"

    # Check if secret already exists in rails.env
    if grep -q "SECRET_KEY_BASE=" "$PROJECT_ROOT/env/rails.env" && \
       ! grep -q "SECRET_KEY_BASE=change_me" "$PROJECT_ROOT/env/rails.env"; then
        print_success "SECRET_KEY_BASE already configured"
        return
    fi

    print_warning "Generating new SECRET_KEY_BASE..."
    SECRET=$(docker-compose run --rm rails_cli secret)
    
    # Update rails.env (different approach for different OS)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s/SECRET_KEY_BASE=.*/SECRET_KEY_BASE=$SECRET/" "$PROJECT_ROOT/env/rails.env"
    else
        sed -i "s/SECRET_KEY_BASE=.*/SECRET_KEY_BASE=$SECRET/" "$PROJECT_ROOT/env/rails.env"
    fi
    
    print_success "SECRET_KEY_BASE updated in env/rails.env"
}

# Create public directory if needed
setup_directories() {
    print_header "Setting Up Directories"

    mkdir -p "$PROJECT_ROOT/src/public"
    mkdir -p "$PROJECT_ROOT/src/tmp/pids"
    mkdir -p "$PROJECT_ROOT/src/tmp/cache"
    mkdir -p "$PROJECT_ROOT/src/log"
    
    print_success "Directories created/verified"
}

# Install dependencies
install_dependencies() {
    print_header "Installing Dependencies"

    cd "$PROJECT_ROOT"

    # Check if Gemfile.lock exists
    if [ ! -f "$PROJECT_ROOT/src/Gemfile.lock" ]; then
        print_warning "Installing Ruby gems..."
        docker-compose run --rm bundler install
        print_success "Ruby gems installed"
    else
        print_success "Gemfile.lock already exists"
    fi

    # Check for package.json and install npm dependencies
    if [ -f "$PROJECT_ROOT/src/package.json" ]; then
        read -p "Install Node dependencies? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_warning "Installing Node packages..."
            docker-compose run --rm npm install
            print_success "Node packages installed"
        fi
    fi
}

# Final checks
final_checks() {
    print_header "Final Checks"

    cd "$PROJECT_ROOT"

    # Check if all services can start
    print_warning "Starting services (this may take a moment)..."
    
    if ! docker-compose up -d 2>/dev/null; then
        print_error "Failed to start services"
        return 1
    fi

    sleep 5

    # Check services status
    print_warning "Checking service status..."
    
    if docker-compose ps | grep -q "unhealthy"; then
        print_warning "Some services are not healthy yet"
        print_warning "View logs with: docker-compose logs -f"
    fi

    if docker-compose ps | grep -q "Up"; then
        print_success "Services started successfully"
    else
        print_error "Services failed to start"
        return 1
    fi
}

# Show summary
show_summary() {
    print_header "Setup Complete!"

    echo "Next steps:"
    echo ""
    echo -e "${BLUE}1. View application logs:${NC}"
    echo "   docker-compose logs -f web"
    echo ""
    echo -e "${BLUE}2. Access the application:${NC}"
    echo "   http://localhost:3000"
    echo ""
    echo -e "${BLUE}3. Open Rails console:${NC}"
    echo "   docker-compose exec web rails console"
    echo ""
    echo -e "${BLUE}4. Run database commands:${NC}"
    echo "   docker-compose exec web rails db:migrate:status"
    echo ""
    echo -e "${BLUE}5. Stop services:${NC}"
    echo "   docker-compose down"
    echo ""
    echo "For more commands, see README.md"
}

# Main execution
main() {
    print_header "Rails Docker Setup"

    # Run checks
    check_prerequisites
    
    if ! check_rails_app; then
        print_warning "Setting up new Rails application..."
        cd "$PROJECT_ROOT"
        docker-compose run --rm rails_cli new src --database=postgresql --skip-test
        cd src
    fi

    # Setup process
    setup_directories
    build_images
    generate_secret
    install_dependencies
    setup_database
    final_checks
    show_summary
}

# Run main function
main "$@"
