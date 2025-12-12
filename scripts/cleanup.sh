#!/bin/bash

###############################################################################
# Docker Cleanup Script
# Safe cleanup of Docker containers, images, and volumes with warnings
###############################################################################

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

confirm() {
    local prompt="$1"
    local response
    
    while true; do
        read -p "$(echo -e ${YELLOW}$prompt${NC})" -n 1 -r
        echo
        case $REPLY in
            [Yy])
                return 0
                ;;
            [Nn])
                return 1
                ;;
            *)
                echo "Please answer y or n"
                ;;
        esac
    done
}

show_disk_usage() {
    echo -e "${BLUE}Current Docker Disk Usage:${NC}"
    docker system df || true
    echo
}

# Level 1: Light cleanup (safe)
light_cleanup() {
    print_header "Level 1: Light Cleanup (SAFE)"
    
    echo "This will:"
    echo "  • Remove stopped containers"
    echo "  • Remove dangling images"
    echo "  • Remove unused build cache"
    echo

    if ! confirm "Continue? (y/n) "; then
        print_warning "Cancelled"
        return
    fi

    cd "$PROJECT_ROOT"

    print_warning "Stopping running containers..."
    docker-compose down || true
    print_success "Containers stopped"

    print_warning "Removing stopped containers..."
    docker container prune -f
    print_success "Stopped containers removed"

    print_warning "Removing dangling images..."
    docker image prune -f
    print_success "Dangling images removed"

    print_warning "Removing build cache..."
    docker builder prune -f
    print_success "Build cache cleaned"

    print_success "Level 1 cleanup complete!"
}

# Level 2: Medium cleanup (moderate risk)
medium_cleanup() {
    print_header "Level 2: Medium Cleanup (MODERATE RISK)"
    
    echo "This will:"
    echo "  • Do everything in Level 1"
    echo "  • Remove ALL unused images"
    echo "  • Remove unused networks"
    echo "  ⚠ WARNING: Images will need to be rebuilt"
    echo

    if ! confirm "Continue? (y/n) "; then
        print_warning "Cancelled"
        return
    fi

    # Run light cleanup first
    light_cleanup

    print_warning "Removing all unused images..."
    docker image prune -a -f
    print_success "Unused images removed"

    print_warning "Removing unused networks..."
    docker network prune -f
    print_success "Unused networks removed"

    print_success "Level 2 cleanup complete!"
}

# Level 3: Deep cleanup (high risk - data loss possible)
deep_cleanup() {
    print_header "Level 3: Deep Cleanup (HIGH RISK - DATA LOSS POSSIBLE)"
    
    echo -e "${RED}WARNING: This is destructive!${NC}"
    echo "This will:"
    echo "  • Do everything in Level 1 and 2"
    echo "  • Remove ALL unused volumes (except named volumes)"
    echo "  • ⚠ DATA LOSS: Temporary volumes will be deleted"
    echo

    print_error "This operation may delete data!"
    
    if ! confirm "Continue? (y/n) "; then
        print_warning "Cancelled"
        return
    fi

    # Run medium cleanup first
    medium_cleanup

    print_warning "Removing unused volumes..."
    docker volume prune -f
    print_success "Unused volumes removed"

    print_success "Level 3 cleanup complete!"
}

# Level 4: Full reset (⚠️ EXTREME DANGER)
full_reset() {
    print_header "Level 4: FULL RESET (⚠️ EXTREME DANGER - COMPLETE DATA LOSS)"
    
    echo -e "${RED}═══════════════════════════════════${NC}"
    echo -e "${RED}DANGER: THIS WILL DELETE ALL DATA!${NC}"
    echo -e "${RED}═══════════════════════════════════${NC}"
    echo
    echo "This will:"
    echo "  • Delete ALL containers"
    echo "  • Delete ALL images"
    echo "  • Delete ALL volumes (⚠️ DATABASE DATA WILL BE LOST)"
    echo "  • Delete ALL networks"
    echo "  • Delete ALL build cache"
    echo

    print_error "Type 'DELETE ALL DATA' (without quotes) to confirm"
    read -r confirmation
    
    if [ "$confirmation" != "DELETE ALL DATA" ]; then
        print_warning "Cancelled"
        return
    fi

    print_error "Starting full system reset..."
    sleep 2

    cd "$PROJECT_ROOT"

    print_warning "Stopping containers..."
    docker-compose down -v || true

    print_warning "Removing all containers..."
    docker container rm -f $(docker container ls -aq) 2>/dev/null || true

    print_warning "Removing all images..."
    docker image rm -f $(docker image ls -aq) 2>/dev/null || true

    print_warning "Removing all volumes..."
    docker volume rm -f $(docker volume ls -q) 2>/dev/null || true

    print_warning "Removing all networks..."
    docker network rm $(docker network ls -q) 2>/dev/null || true

    print_warning "Removing all build cache..."
    docker builder prune -a -f || true

    print_success "Full system reset complete!"
    print_warning "You will need to rebuild everything"
}

# Database-specific cleanup
db_cleanup() {
    print_header "Database Cleanup"
    
    echo "Options:"
    echo "1. Clean data (reset database)"
    echo "2. Backup database"
    echo "3. Cancel"
    echo

    read -p "Select option (1-3): " option

    case $option in
        1)
            if ! confirm "Reset database (data will be lost)? (y/n) "; then
                print_warning "Cancelled"
                return
            fi

            cd "$PROJECT_ROOT"

            print_warning "Dropping database..."
            docker-compose exec web rails db:drop --force || true
            print_success "Database dropped"

            print_warning "Creating database..."
            docker-compose run --rm rails_cli db:create
            print_success "Database created"

            print_warning "Running migrations..."
            docker-compose run --rm rails_cli db:migrate
            print_success "Migrations complete"

            print_success "Database reset complete!"
            ;;
        2)
            cd "$PROJECT_ROOT"
            
            BACKUP_FILE="backups/db_backup_$(date +%Y%m%d_%H%M%S).sql"
            mkdir -p backups

            print_warning "Backing up database to $BACKUP_FILE..."
            
            if docker-compose exec db pg_dump -U rails_user rails_development > "$BACKUP_FILE"; then
                print_success "Database backed up successfully"
                print_success "Backup location: $BACKUP_FILE"
            else
                print_error "Backup failed"
            fi
            ;;
        3)
            print_warning "Cancelled"
            ;;
        *)
            print_error "Invalid option"
            ;;
    esac
}

# Show help
show_help() {
    cat << EOF

${BLUE}Docker Cleanup Utility${NC}

Usage: bash cleanup.sh [OPTION]

Options:
  1, light      Run light cleanup (safe)
  2, medium     Run medium cleanup (moderate risk)
  3, deep       Run deep cleanup (high risk)
  4, full       Run full reset (⚠️ EXTREME DANGER)
  db            Database-specific cleanup
  status        Show disk usage
  help          Show this help message

Examples:
  bash cleanup.sh light
  bash cleanup.sh medium
  bash cleanup.sh db
  bash cleanup.sh status

${YELLOW}Safety Levels:${NC}
  Level 1 (Light):   Safe, removes stopped containers and dangling images
  Level 2 (Medium):  Moderate, removes all unused images
  Level 3 (Deep):    Risky, removes unused volumes (may lose data)
  Level 4 (Full):    ⚠️ DANGEROUS, complete system reset, DATA LOSS

${YELLOW}Recommendations:${NC}
  • Use Level 1 weekly: bash cleanup.sh light
  • Use Level 2 monthly: bash cleanup.sh medium
  • Use Level 3 only when low on disk: bash cleanup.sh deep
  • Avoid Level 4 unless absolutely necessary

${YELLOW}Before cleanup:${NC}
  • Backup important data
  • Stop all services gracefully
  • Review what will be deleted

For more information, see README.md

EOF
}

# Interactive menu
show_menu() {
    print_header "Docker Cleanup Utility"
    
    show_disk_usage

    echo "Select cleanup level:"
    echo "  1) Light cleanup (safe)"
    echo "  2) Medium cleanup (moderate risk)"
    echo "  3) Deep cleanup (high risk)"
    echo "  4) Full reset (⚠️ EXTREME DANGER)"
    echo "  5) Database cleanup"
    echo "  6) Show disk usage"
    echo "  0) Exit"
    echo

    read -p "Enter your choice (0-6): " choice

    case $choice in
        1)
            light_cleanup
            ;;
        2)
            medium_cleanup
            ;;
        3)
            deep_cleanup
            ;;
        4)
            full_reset
            ;;
        5)
            db_cleanup
            ;;
        6)
            show_disk_usage
            ;;
        0)
            print_success "Goodbye!"
            exit 0
            ;;
        *)
            print_error "Invalid option"
            show_menu
            ;;
    esac

    echo
    if confirm "Run another cleanup? (y/n) "; then
        show_menu
    else
        print_success "Goodbye!"
    fi
}

# Main
if [ $# -eq 0 ]; then
    show_menu
else
    case "$1" in
        1|light)
            light_cleanup
            show_disk_usage
            ;;
        2|medium)
            medium_cleanup
            show_disk_usage
            ;;
        3|deep)
            deep_cleanup
            show_disk_usage
            ;;
        4|full)
            full_reset
            show_disk_usage
            ;;
        db|database)
            db_cleanup
            ;;
        status|usage)
            show_disk_usage
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            print_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
fi
