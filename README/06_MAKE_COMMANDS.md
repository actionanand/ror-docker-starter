# 🔨 Understanding Make Commands

Complete guide to using `make` commands in this project.

## What is Make?

`make` is a utility that runs shortcuts defined in a `Makefile`.

**Why use it?**
- Shorter commands (typing `make start` instead of `docker-compose up -d`)
- Consistency (same commands on all machines)
- Less error-prone (no typos in long Docker commands)
- Built-in help (run `make help` to see all commands)

## First Time Setup

### Install Make (If Not Already Done)
```bash
# Check if make is installed
which make
make --version

# If not installed
sudo apt-get update
sudo apt-get install -y make

# Verify installation
make --version
```

### View All Available Commands
```bash
make help
```

This shows you all 50+ available commands with descriptions.

---

## How Make Works

### The Makefile
Located at: `/mnt/c/repos/ar_files/code/ror/Makefile`

It contains targets (commands) that execute shell commands:

```makefile
start:
    docker-compose up -d
    echo "Services started"
```

When you run:
```bash
make start
```

It executes:
```bash
docker-compose up -d
echo "Services started"
```

### Command Syntax
```bash
make <target>       # Run a specific command
make help          # Show all commands
make -n <target>   # Dry-run (show what would execute, don't run)
```

---

## Essential Commands to Know

### Starting & Stopping

**Start Services**
```bash
make start
# Equivalent to: docker-compose up -d
# Starts all services in background
```

**Stop Services**
```bash
make stop
# Equivalent to: docker-compose stop
# Stops services gracefully
```

**Restart Services**
```bash
make restart
# Stops and restarts all services
```

**Check Status**
```bash
make ps
# Shows running containers

make status
# Shows detailed status + disk usage
```

---

### Viewing Logs

**View All Logs**
```bash
make logs
# Shows logs from all services
# Press Ctrl+C to stop
```

**View Specific Service**
```bash
make logs-web       # Rails web server
make logs-db        # PostgreSQL database
make logs-sidekiq   # Sidekiq worker
make logs-nginx     # Nginx web server
```

**Real-time Memory Stats**
```bash
make docker-stats
# Shows CPU and memory usage
# Press Ctrl+C to stop
```

---

### Rails Development

**Open Rails Console**
```bash
make console
# Interactive Ruby/Rails console
# Type: User.all
# Type: Post.find(1)
# Type: exit (Ctrl+D) to quit
```

**Get Container Shell**
```bash
make shell
# Direct shell access to web container
# Type: ls -la
# Type: pwd
# Type: exit to quit
```

**Run Tests**
```bash
make test
# Run all RSpec tests

make test-watch
# Watch for changes and re-run tests
```

**Code Quality**
```bash
make lint
# Run RuboCop code linter

make lint-fix
# Auto-fix RuboCop issues

make security
# Run Brakeman security scanner
```

---

### Database Management

**Run Migrations**
```bash
make migrate
# Run pending database migrations
```

**Check Migration Status**
```bash
make migrate-status
# Shows which migrations are run/pending
```

**Seed Database**
```bash
make seed
# Run database seeds (db/seeds.rb)
```

**Backup Database**
```bash
make db-backup
# Creates: backups/db_backup_YYYYMMDD_HHMMSS.sql
```

**Reset Database (⚠️ Data Loss)**
```bash
make migrate-reset
# Drops and recreates database
# ⚠️ ALL DATA WILL BE LOST
# Use db-backup first!
```

---

### Dependencies & Assets

**Gem Management**
```bash
make gem-list       # Show installed gems
make gem-update     # Update all gems
```

**Node.js Packages**
```bash
make npm-install    # Install npm packages
make npm-build      # Build JavaScript assets
make npm-watch      # Watch and rebuild
```

**Assets**
```bash
make assets         # Precompile assets
make assets-clean   # Clean compiled assets
```

---

### Cleanup

**Light Cleanup (Safe) - Weekly**
```bash
make clean
# Removes: stopped containers, dangling images
# Frees: 100-500MB
# Risk: None
```

**Medium Cleanup (Moderate) - Monthly**
```bash
make clean-medium
# Removes: unused images
# Frees: 500MB-2GB
# Risk: Low (images rebuild on docker-compose build)
```

**Database Cleanup**
```bash
make clean-db
# Interactive menu for database cleanup
```

---

### Docker Building

**Build Images**
```bash
make build
# Builds custom Docker images (rails, nginx)
```

**Start with Build**
```bash
make up
# Builds and starts services

make up --force-recreate
# Forces rebuild even if images exist
```

**Completely Remove**
```bash
make down
# Stops and removes containers (keeps volumes)

make down-full
# Stops and removes everything including volumes ⚠️
```

---

## Common Workflows

### Daily Development

**Morning**
```bash
make start          # Start services
make logs           # Watch logs (Ctrl+C to stop watching)
# Now edit code in ./src/
```

**During Development**
```bash
make test           # Run tests after making changes
make lint           # Check code quality
```

**Evening**
```bash
make stop           # Stop services at end of day
```

### Adding a Feature

```bash
# 1. Create migration
docker-compose exec web rails generate migration CreatePosts title:string

# 2. Run migration
make migrate

# 3. Create model
docker-compose exec web rails generate model Post title:string

# 4. Write code in ./src/app/models/post.rb

# 5. Write tests in ./src/spec/models/post_spec.rb

# 6. Run tests
make test

# 7. Add gem if needed
docker-compose run --rm bundler add gem_name

# 8. Repeat from step 4 until tests pass
```

### Before Deployment

```bash
make test           # Run all tests
make lint           # Check code style
make security       # Security scan
make db-backup      # Backup database
make build          # Build production images
```

---

## Advanced Usage

### Dry-Run (Preview Without Executing)
```bash
make -n start
# Shows what would be executed, but doesn't run it
```

### Search for Commands
```bash
make help | grep migrate
# Shows all commands containing "migrate"

make help | grep clean
# Shows all cleanup commands

make help | grep db
# Shows all database commands
```

### View Makefile
```bash
cat Makefile
# Shows the full Makefile content
# See all commands and what they do
```

---

## Makefile Structure

### Target Parts

```makefile
target:              # This is the command name
    command          # This is what gets executed
    @echo "Done"     # The @ suppresses output of the command itself
```

### Example: make start

```makefile
start:
    @docker-compose up -d
    @echo "$(GREEN)✓ Services started$(NC)"
    @echo "$(BLUE)Access: http://localhost:3000$(NC)"
```

This is why you see the green checkmark and blue URL when running `make start`.

---

## Tips & Tricks

### Quick Shortcuts

```bash
# Chain commands
make start && make logs      # Start then view logs

# Use in scripts
if make test; then
  echo "Tests passed!"
else
  echo "Tests failed!"
fi
```

### View Specific Help

```bash
# Create an alias for quick access
alias mh="make help"
mh

# Or search
make help | grep -i "your_search"
```

### Customize for Your Needs

Edit the Makefile to add your own commands:

```makefile
# Add at the end of Makefile
my-custom-command:
    @echo "Running custom command..."
    docker-compose exec web your_command_here
    @echo "Done!"
```

Then use:
```bash
make my-custom-command
```

---

## Troubleshooting Make

### "make: command not found"
```bash
# Install make
sudo apt-get install -y make
```

### "make: *** No rule to make target ..."
```bash
# Typo in command name - check with make help
make help | grep similar_name

# Or run make help to see all valid commands
make help
```

### "Permission denied"
```bash
# Make sure scripts are executable
chmod +x scripts/*.sh

# Or use docker-compose directly
docker-compose start
```

### Makefile Syntax Error

```bash
# Check Makefile syntax
make -n start

# View Makefile
cat Makefile

# Make sure indentation is TABS not spaces
# (This is a common issue in Makefiles)
```

---

## Comparison: Make vs Docker Compose

### Using Make (Recommended for Beginners)
```bash
make start
make console
make migrate
make test
make stop
```

### Equivalent Docker Compose
```bash
docker-compose up -d
docker-compose exec web rails console
docker-compose exec web rails db:migrate
docker-compose run --rm web bundle exec rspec
docker-compose stop
```

As you can see, make is much shorter and easier!

---

## Learning More

### View Full Help
```bash
make help
# Shows all 50+ commands with descriptions
```

### View Makefile
```bash
cat Makefile
# Shows exactly what each command does
```

### Practice

```bash
# Try these one by one
make help           # See all commands
make ps             # Check status
make start          # Start services
make logs           # View logs (Ctrl+C to stop)
make console        # Open Rails console (exit to quit)
make migrate        # Run migrations
make test           # Run tests
make stop           # Stop services
```

---

## Command Reference Cheat Sheet

| Command | Purpose | Time |
|---------|---------|------|
| `make help` | Show all commands | Instant |
| `make start` | Start all services | 5-10s |
| `make stop` | Stop services | 2-5s |
| `make logs` | View logs | Continuous |
| `make console` | Rails console | 3-5s |
| `make migrate` | Run migrations | 5-30s |
| `make test` | Run tests | 10-60s |
| `make clean` | Cleanup | 30-60s |

---

## The Golden Rule of Make

**When in doubt, run `make help`**

This shows you everything available and what each command does.

---

**Next Steps:**
1. Install make: `sudo apt-get install -y make`
2. Run: `make help`
3. Try: `make start && make logs`
4. Read: `03_COMMANDS_REFERENCE.md` for all available commands

