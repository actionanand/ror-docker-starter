.PHONY: help setup start stop logs console migrate test clean clean-light clean-full ps status

# Colors for output
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[1;33m
NC := \033[0m # No Color

help:
	@echo "$(BLUE)=== Rails Docker Management ===$(NC)"
	@echo ""
	@echo "$(BLUE)Setup Commands:$(NC)"
	@echo "  make setup          - Run complete setup (builds images, creates DB, etc.)"
	@echo ""
	@echo "$(BLUE)Development Commands:$(NC)"
	@echo "  make start          - Start all services"
	@echo "  make stop           - Stop all services"
	@echo "  make restart        - Restart all services"
	@echo "  make logs           - Show logs (all services)"
	@echo "  make logs-web       - Show Rails web server logs"
	@echo "  make logs-db        - Show database logs"
	@echo "  make logs-sidekiq   - Show Sidekiq worker logs"
	@echo "  make logs-nginx     - Show Nginx logs"
	@echo ""
	@echo "$(BLUE)Database Commands:$(NC)"
	@echo "  make migrate        - Run database migrations"
	@echo "  make migrate-status - Check migration status"
	@echo "  make migrate-reset  - Reset database (⚠️ DATA LOSS)"
	@echo "  make seed           - Run database seeds"
	@echo "  make db-backup      - Backup database"
	@echo ""
	@echo "$(BLUE)Rails Commands:$(NC)"
	@echo "  make console        - Open Rails console"
	@echo "  make shell          - Get container shell"
	@echo "  make test           - Run tests"
	@echo "  make lint           - Run RuboCop linter"
	@echo ""
	@echo "$(BLUE)Asset & Gem Commands:$(NC)"
	@echo "  make assets         - Precompile assets"
	@echo "  make gem-list       - List installed gems"
	@echo "  make gem-update     - Update all gems"
	@echo "  make npm-install    - Install Node dependencies"
	@echo "  make npm-build      - Build JavaScript assets"
	@echo ""
	@echo "$(BLUE)Maintenance Commands:$(NC)"
	@echo "  make ps             - Show service status"
	@echo "  make status         - Show detailed status and disk usage"
	@echo "  make clean          - Safe cleanup (light)"
	@echo "  make clean-medium   - Medium cleanup (moderate risk)"
	@echo "  make clean-full     - Full reset (⚠️ EXTREME DANGER)"
	@echo "  make docker-stats   - Show Docker statistics"
	@echo ""
	@echo "$(BLUE)Examples:$(NC)"
	@echo "  make start && make logs          - Start and watch logs"
	@echo "  make migrate && make console     - Migrate and open console"
	@echo "  make test                        - Run all tests"
	@echo "  make clean                       - Run light cleanup"
	@echo ""

# Setup
setup:
	@bash scripts/setup.sh

# Start/Stop
start:
	@docker-compose up -d
	@echo "$(GREEN)✓ Services started$(NC)"
	@echo "$(BLUE)Access: http://localhost:3000$(NC)"

stop:
	@docker-compose stop
	@echo "$(GREEN)✓ Services stopped$(NC)"

restart:
	@docker-compose restart
	@echo "$(GREEN)✓ Services restarted$(NC)"

# Logs
logs:
	@docker-compose logs -f

logs-web:
	@docker-compose logs -f web

logs-db:
	@docker-compose logs -f db

logs-sidekiq:
	@docker-compose logs -f sidekiq

logs-nginx:
	@docker-compose logs -f nginx

# Database
migrate:
	@docker-compose exec web rails db:migrate
	@echo "$(GREEN)✓ Migrations complete$(NC)"

migrate-status:
	@docker-compose exec web rails db:migrate:status

migrate-reset:
	@echo "$(YELLOW)⚠ This will DELETE all data!$(NC)"
	@read -p "Type 'reset' to confirm: " confirm; \
	if [ "$$confirm" = "reset" ]; then \
		docker-compose exec web rails db:drop --force || true; \
		docker-compose run --rm rails_cli db:create; \
		docker-compose exec web rails db:migrate; \
		echo "$(GREEN)✓ Database reset complete$(NC)"; \
	else \
		echo "$(YELLOW)Cancelled$(NC)"; \
	fi

seed:
	@docker-compose exec web rails db:seed
	@echo "$(GREEN)✓ Database seeded$(NC)"

db-backup:
	@mkdir -p backups
	@docker-compose exec db pg_dump -U rails_user rails_development > backups/db_backup_$(shell date +%Y%m%d_%H%M%S).sql
	@echo "$(GREEN)✓ Database backed up$(NC)"

# Rails
console:
	@docker-compose exec web rails console

shell:
	@docker-compose exec web bash

test:
	@docker-compose run --rm web bundle exec rspec

test-watch:
	@docker-compose run --rm web bundle exec guard

lint:
	@docker-compose run --rm web bundle exec rubocop

lint-fix:
	@docker-compose run --rm web bundle exec rubocop -a

security:
	@docker-compose run --rm web bundle exec brakeman

# Assets
assets:
	@docker-compose exec web rails assets:precompile
	@echo "$(GREEN)✓ Assets precompiled$(NC)"

assets-clean:
	@docker-compose exec web rails assets:clobber
	@echo "$(GREEN)✓ Assets cleaned$(NC)"

# Gems
gem-list:
	@docker-compose run --rm bundler list

gem-update:
	@docker-compose run --rm bundler update
	@echo "$(GREEN)✓ Gems updated$(NC)"

# NPM
npm-install:
	@docker-compose run --rm npm install
	@echo "$(GREEN)✓ NPM dependencies installed$(NC)"

npm-build:
	@docker-compose run --rm npm run build
	@echo "$(GREEN)✓ JavaScript built$(NC)"

npm-watch:
	@docker-compose run --rm npm run watch

# Status
ps:
	@docker-compose ps

status:
	@docker-compose ps
	@echo ""
	@echo "$(BLUE)Docker Disk Usage:$(NC)"
	@docker system df
	@echo ""
	@echo "$(BLUE)Container Memory:$(NC)"
	@docker stats --no-stream 2>/dev/null || echo "Docker stats not available"

docker-stats:
	@docker stats

# Cleanup
clean:
	@bash scripts/cleanup.sh light

clean-medium:
	@bash scripts/cleanup.sh medium

clean-full:
	@bash scripts/cleanup.sh full

clean-db:
	@bash scripts/cleanup.sh db

# Docker compose helpers
build:
	@docker-compose build

up:
	@docker-compose up -d

down:
	@docker-compose down

down-full:
	@docker-compose down -v
	@echo "$(GREEN)✓ All containers, networks, and volumes removed$(NC)"

# Shortcuts
dev: start logs
prod-like: build start
test-all: test
ship: lint test
