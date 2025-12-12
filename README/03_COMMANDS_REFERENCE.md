# 🔧 All Commands Reference

Complete list of all available commands.

## Make Commands (50+ Available)

Run `make help` to see all commands in your terminal.

### Getting Help
```bash
make help                # Show all available commands
make help | grep -i start  # Search for specific commands
```

### Development Commands

#### Start/Stop Services
```bash
make start              # Start all services
make stop               # Stop all services
make restart            # Restart all services
make ps                 # Show service status
make status             # Show detailed status + disk usage
```

#### View Logs
```bash
make logs               # View all service logs
make logs-web           # View Rails web server logs
make logs-db            # View PostgreSQL logs
make logs-sidekiq       # View Sidekiq worker logs
make logs-nginx         # View Nginx logs
make docker-stats       # Real-time memory/CPU usage
```

#### Rails Commands
```bash
make console            # Open Rails interactive console
make shell              # Get container shell access
make test               # Run all tests
make test-watch         # Watch and re-run tests
make lint               # Run RuboCop linter
make lint-fix           # Auto-fix linting issues
make security           # Run security checks (Brakeman)
```

#### Database Commands
```bash
make migrate            # Run pending migrations
make migrate-status     # Show migration status
make migrate-reset      # Reset database (⚠️ data loss)
make seed               # Run database seeds
make db-backup          # Create database backup
```

#### Asset & Gem Commands
```bash
make assets             # Precompile assets
make assets-clean       # Clean compiled assets
make gem-list           # List installed gems
make gem-update         # Update all gems
make npm-install        # Install Node dependencies
make npm-build          # Build JavaScript assets
make npm-watch          # Watch and rebuild JS
```

#### Build Commands
```bash
make build              # Build Docker images
make up                 # Start containers (keeps running)
make down               # Stop and remove containers
make down-full          # Stop and remove with volumes ⚠️
```

### Cleanup Commands

#### Light Cleanup (Safe)
```bash
make clean              # Remove stopped containers & dangling images
# Time: ~30 seconds
# Frees: 100-500MB
# Risk: None
```

#### Medium Cleanup (Moderate)
```bash
make clean-medium       # Remove unused images
# Time: ~1 minute
# Frees: 500MB-2GB
# Risk: Low (images rebuild on next docker-compose build)
```

#### Database Cleanup
```bash
make clean-db           # Reset database via menu
# Time: ~1 minute
# Frees: Varies
# Risk: Moderate (deletes all data)
```

---

## Docker Compose Commands

Direct Docker commands (alternative to Make):

### Service Management
```bash
docker-compose up -d                    # Start services
docker-compose down                     # Stop services
docker-compose restart                  # Restart services
docker-compose ps                       # List containers
docker-compose logs -f                  # View logs
docker-compose logs -f web              # View specific service
```

### Execute Commands
```bash
docker-compose exec web bash            # Get shell in container
docker-compose exec web pwd             # Run single command
docker-compose exec db psql -U rails_user rails_development  # Connect to DB
```

### Running Services as One-Off
```bash
docker-compose run --rm rails_cli db:create      # Create DB
docker-compose run --rm rails_cli db:migrate     # Migrate
docker-compose run --rm bundler install          # Install gems
docker-compose run --rm npm install              # Install packages
```

---

## Bash Script Commands

### Setup Script
```bash
bash scripts/setup.sh                   # Complete automated setup
bash scripts/setup.sh --help            # Show help
```

### Quick Script
```bash
bash scripts/quick.sh start             # Start services
bash scripts/quick.sh stop              # Stop services
bash scripts/quick.sh logs              # View logs
bash scripts/quick.sh console           # Rails console
bash scripts/quick.sh migrate           # Run migrations
bash scripts/quick.sh test [path]       # Run tests
bash scripts/quick.sh add_gem <name>    # Add a gem
bash scripts/quick.sh shell             # Container shell
bash scripts/quick.sh status            # Show status
bash scripts/quick.sh help              # Show help
```

### Cleanup Script
```bash
bash scripts/cleanup.sh light           # Light cleanup
bash scripts/cleanup.sh medium          # Medium cleanup
bash scripts/cleanup.sh deep            # Deep cleanup
bash scripts/cleanup.sh full            # Full reset ⚠️
bash scripts/cleanup.sh db              # Database cleanup
bash scripts/cleanup.sh status          # Show disk usage
bash scripts/cleanup.sh help            # Show help
```

### Visual Guide
```bash
bash scripts/README.sh                  # Show ASCII art structure
```

---

## Rails-Specific Commands

```bash
# Run inside container
docker-compose exec web rails console
docker-compose exec web rails routes
docker-compose exec web rails db:migrate:status
docker-compose exec web rails generate model Post title:string
docker-compose exec web rails generate migration AddFields
docker-compose exec web rails c                    # Short for console
docker-compose exec web rails s -b 0.0.0.0        # Start server
```

---

## Database Commands

```bash
# Inside container
docker-compose exec web rails db:create
docker-compose exec web rails db:migrate
docker-compose exec web rails db:seed
docker-compose exec web rails db:reset
docker-compose exec web rails db:rollback
docker-compose exec web rails db:drop

# Direct PostgreSQL
docker-compose exec db psql -U rails_user rails_development
docker-compose exec db pg_dump -U rails_user rails_development > backup.sql
docker-compose exec db psql -U rails_user rails_development < backup.sql

# Check connections
docker-compose exec db psql -U rails_user -c "SELECT * FROM pg_stat_activity;"
```

---

## Bundler Commands

```bash
docker-compose run --rm bundler install          # Install gems
docker-compose run --rm bundler add devise       # Add gem
docker-compose run --rm bundler update           # Update gems
docker-compose run --rm bundler list             # List gems
docker-compose run --rm bundler show             # Show gem info
docker-compose run --rm bundler check            # Check requirements
```

---

## NPM/JavaScript Commands

```bash
docker-compose run --rm npm install              # Install packages
docker-compose run --rm npm add lodash           # Add package
docker-compose run --rm npm update               # Update packages
docker-compose run --rm npm run build            # Build assets
docker-compose run --rm npm run watch            # Watch & rebuild
docker-compose run --rm npm list                 # List packages
docker-compose run --rm npm audit                # Check security
```

---

## Testing Commands

```bash
# RSpec
docker-compose run --rm web bundle exec rspec
docker-compose run --rm web bundle exec rspec spec/models/
docker-compose run --rm web bundle exec rspec spec/models/user_spec.rb

# RuboCop (linting)
docker-compose run --rm web bundle exec rubocop
docker-compose run --rm web bundle exec rubocop -a    # Auto-fix

# Brakeman (security)
docker-compose run --rm web bundle exec brakeman

# Simplecov (coverage)
docker-compose run --rm web bundle exec rspec --format progress
```

---

## System Information Commands

```bash
# Docker disk usage
docker system df                         # Breakdown
docker system df --verbose               # Detailed

# Volume information
docker volume ls                         # List volumes
docker volume inspect postgres_data      # Inspect volume

# Container stats
docker stats                             # Real-time stats
docker ps                                # List containers
docker ps -a                             # All containers

# Image information
docker images                            # List images
docker image inspect rails:latest        # Inspect image
```

---

## Common Workflows

### Daily Development
```bash
make start          # Start services
make logs           # Watch logs
# Edit code in ./src/
make test           # Run tests periodically
make stop           # Stop at end of day
```

### Adding a Feature
```bash
# Create migration
docker-compose exec web rails generate migration CreatePosts title:string body:text

# Edit migration file in src/db/migrate/
# Then run it
make migrate

# Create model
docker-compose exec web rails generate model Post title:string body:text

# Write code
# Write tests
make test           # Run tests

# Add gems if needed
docker-compose run --rm bundler add gem_name
```

### Debugging
```bash
make console        # Open console
# Type: Post.all
# Or: User.find(1)
# Or: Ctrl+D to exit

make shell         # Get container shell
# Type: ps aux
# Or: ls -la
# Or: exit to close
```

### Before Deployment
```bash
make test           # Run all tests
make lint           # Check code style
make security       # Run security checks
make db-backup      # Backup database
docker-compose build # Build production images
docker-compose up -d # Deploy
```

---

## Command Tips & Tricks

### Search for Make Commands
```bash
make help | grep migrate    # Find migration commands
make help | grep db         # Find database commands
make help | grep gem        # Find gem commands
```

### View Specific Service Logs
```bash
docker-compose logs -f --tail=50 web     # Last 50 lines
docker-compose logs web | grep error     # Search logs
```

### Execute Commands in Container
```bash
docker-compose exec web bash -c "rails db:migrate && rails s"
```

### Check What's Listening
```bash
netstat -tulpn | grep 3000             # On Linux/Mac
netstat -ano | findstr :3000           # On Windows
lsof -i :3000                          # On Mac/Linux
```

---

## Most Used Commands (Cheat Sheet)

```bash
# Development
make start && make logs                 # Start and watch
make console                            # Rails console
make migrate                            # Run migrations
make test                               # Run tests
make stop                               # Stop services

# Cleaning
make clean                              # Weekly cleanup
make clean-medium                       # Monthly cleanup

# Help
make help                               # All commands
bash scripts/quick.sh help              # Quick commands
```

---

**Need more details?** Read:
- **06_MAKE_COMMANDS.md** - Detailed make command guide
- **04_TROUBLESHOOTING.md** - Problem solutions
- **02_COMPLETE_GUIDE.md** - Full reference
