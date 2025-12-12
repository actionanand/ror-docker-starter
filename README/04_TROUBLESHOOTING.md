# 🆘 Troubleshooting Guide

Solutions for common problems.

## Make Command Issues

### Problem: "make: command not found"

**Cause:** Make is not installed in WSL/Linux.

**Solution:**
```bash
sudo apt-get update
sudo apt-get install -y make
make --version    # Verify installation
```

### Problem: "make: *** No rule to make target ..."

**Cause:** Typo in make command or Makefile issue.

**Solution:**
```bash
make help         # Show all valid commands
# Check spelling of command
make start        # Not "make start-services"
```

---

## Docker Issues

### Problem: "Docker daemon is not running"

**Cause:** Docker service is not started.

**Solution:**
```bash
# On WSL2
wsl.exe -d Docker-Desktop service docker status

# Or start Docker Desktop manually
# Then retry your command
```

### Problem: "docker-compose: command not found"

**Cause:** Docker Compose is not installed or not in PATH.

**Solution:**
```bash
docker-compose --version      # Check if installed
docker compose --version      # Newer version syntax

# If not installed
sudo apt-get install -y docker-compose
```

### Problem: "Cannot connect to Docker daemon"

**Cause:** Docker service not running or permission issue.

**Solution:**
```bash
# Check if Docker is running
sudo systemctl status docker

# Start Docker
sudo systemctl start docker

# Add your user to docker group
sudo usermod -aG docker $USER
newgrp docker
```

---

## Port Issues

### Problem: "Port 3000 already in use"

**Cause:** Another application is using port 3000.

**Solution:**
```bash
# Find what's using the port
lsof -ti:3000                # macOS/Linux
netstat -ano | findstr :3000 # Windows

# Kill the process
lsof -ti:3000 | xargs kill -9

# Then restart
make restart
```

### Problem: "Bind for 0.0.0.0:3000 failed: port is allocated"

**Solution:**
```bash
# Same as above - kill the process on port 3000
lsof -ti:3000 | xargs kill -9

# Or change port in docker-compose.yaml
# Change: ports: - "3000:3000"
# To: ports: - "3001:3000"
```

---

## Database Issues

### Problem: "Database connection refused"

**Cause:** PostgreSQL container not running or not ready.

**Solution:**
```bash
# Check if DB is running
docker-compose ps db

# Check logs
docker-compose logs db

# Restart database
docker-compose restart db

# Wait a few seconds, then try again
sleep 5
make migrate
```

### Problem: "FATAL: password authentication failed"

**Cause:** Wrong password in environment file.

**Solution:**
```bash
# Check credentials
cat env/postgres.env
cat env/rails.env

# Make sure they match
# Then recreate database
docker-compose restart db
docker-compose run --rm rails_cli db:create
```

### Problem: "database does not exist"

**Cause:** Database hasn't been created yet.

**Solution:**
```bash
# Create database
docker-compose run --rm rails_cli db:create

# Run migrations
docker-compose run --rm rails_cli db:migrate

# Seed if needed
docker-compose run --rm rails_cli db:seed
```

### Problem: "PG::DuplicateDatabase: ERROR: database already exists"

**Cause:** Database already exists when trying to create.

**Solution:**
```bash
# This is safe - just means database exists
# You can ignore this error
# Or check migrations
docker-compose exec web rails db:migrate:status
```

---

## Gem/Dependency Issues

### Problem: "Could not find gem ..."

**Cause:** Gem not installed or version mismatch.

**Solution:**
```bash
# Reinstall gems
docker-compose run --rm bundler install

# Update gems
docker-compose run --rm bundler update

# Check Gemfile.lock
cat src/Gemfile.lock | grep gem_name
```

### Problem: "compilation failed for ... native extension"

**Cause:** Missing build tools for native extension.

**Solution:**
```bash
# Rebuild image with additional tools
docker-compose build --no-cache web

# Then install gems
docker-compose run --rm bundler install
```

---

## File Permission Issues

### Problem: "Permission denied when editing src/ files"

**Cause:** File ownership issue in mounted volume.

**Solution:**
```bash
# Fix permissions
sudo chown -R $USER:$USER ./src

# Or change file mode
chmod 644 src/app/models/user.rb
chmod 755 src/app
```

### Problem: "Cannot write to file in container"

**Cause:** File permissions in container don't match host.

**Solution:**
```bash
# Recreate the file
docker-compose exec web rm problematic_file.rb
# Re-edit and recreate

# Or fix permissions in container
docker-compose exec web chown -R www:www /app
```

---

## Memory & Disk Issues

### Problem: "No space left on device"

**Cause:** Disk is full.

**Solution:**
```bash
# Check disk usage
docker system df

# Light cleanup
make clean

# Medium cleanup if needed
make clean-medium

# See what's using space
du -sh ./src
du -sh ~/.docker
```

### Problem: "Out of memory" or services crashing

**Cause:** Not enough RAM allocated to Docker.

**Solution:**
```bash
# Check memory usage
docker stats

# Increase Docker memory allocation:
# - Docker Desktop: Settings → Resources → Memory
# Or reduce Sidekiq concurrency:
nano env/rails.env
# Change: SIDEKIQ_CONCURRENCY=5
# To: SIDEKIQ_CONCURRENCY=2
docker-compose restart sidekiq
```

---

## Service Start Issues

### Problem: "service failed to start" or "unhealthy"

**Cause:** Various issues - check logs.

**Solution:**
```bash
# View detailed logs
docker-compose logs web

# Common issues in logs:
# - Port already in use
# - Database connection failed
# - Missing dependencies
# - Configuration error

# After fixing, rebuild
docker-compose build --no-cache web

# Then restart
docker-compose up -d
```

### Problem: "Container exits immediately"

**Cause:** Application error on startup.

**Solution:**
```bash
# View the logs
docker-compose logs web

# Look for errors like:
# - Bundler error
# - Database error
# - Configuration error

# Fix the issue, then retry
docker-compose down
docker-compose build
docker-compose up -d
```

---

## Rails-Specific Issues

### Problem: "ActionView::Template::Error" or "NameError"

**Cause:** Code error in your application.

**Solution:**
```bash
# Check logs for detailed error
docker-compose logs web

# Open Rails console to debug
make console

# Try the problematic code interactively
# Then fix in src/
```

### Problem: "Could not find ... in Gemfile"

**Cause:** Gem not added to Gemfile.

**Solution:**
```bash
# Add the gem
docker-compose run --rm bundler add gem_name

# Or edit Gemfile manually
nano src/Gemfile
# Add: gem 'gem_name'

# Reinstall
docker-compose run --rm bundler install
```

### Problem: "Migration pending" - site won't load

**Cause:** Database migrations not run.

**Solution:**
```bash
# Run migrations
make migrate

# Check status
make migrate-status

# Reload browser
```

---

## Redis Issues

### Problem: "Redis connection refused"

**Cause:** Redis container not running.

**Solution:**
```bash
# Check if Redis is running
docker-compose ps redis

# View logs
docker-compose logs redis

# Restart Redis
docker-compose restart redis
```

### Problem: "Could not connect to Redis at 127.0.0.1:6379"

**Cause:** Wrong Redis URL or connection issue.

**Solution:**
```bash
# Check environment variable
cat env/rails.env | grep REDIS

# Should be: redis://redis:6379/1

# If local testing needed
docker-compose exec redis redis-cli ping
# Should return: PONG
```

---

## Nginx Issues

### Problem: "502 Bad Gateway"

**Cause:** Nginx can't connect to Rails.

**Solution:**
```bash
# Check if Rails is running
docker-compose ps web

# View Nginx logs
docker-compose logs nginx

# Restart Nginx
docker-compose restart nginx
```

### Problem: "Connection refused" when accessing localhost

**Cause:** Nginx not running or port not exposed.

**Solution:**
```bash
# Check Nginx status
docker-compose ps nginx

# Check port mapping
docker-compose ps | grep nginx
# Should show: 0.0.0.0:80->80

# Restart
docker-compose restart nginx
```

---

## Build Issues

### Problem: "Dockerfile build failed"

**Cause:** Error in Dockerfile during build.

**Solution:**
```bash
# View full build logs
docker-compose build --no-cache web

# Look for error in build output

# Common errors:
# - Missing file (check COPY commands)
# - Package not found (update apt-get)
# - Permission denied (check chmod)

# Fix and rebuild
```

### Problem: "base image ... not found"

**Cause:** Docker image doesn't exist or network issue.

**Solution:**
```bash
# Pull the image first
docker pull ruby:3.2-alpine
docker pull postgres:15-alpine
docker pull redis:7-alpine
docker pull nginx:1.25-alpine

# Then build
docker-compose build
```

---

## Network Issues

### Problem: "Cannot reach localhost:3000"

**Cause:** Service not running or port not mapped.

**Solution:**
```bash
# Check if service is running
docker-compose ps web

# Check port mapping
docker-compose port web 3000
# Should show: 0.0.0.0:3000

# Check if service is healthy
docker-compose ps | grep web
# Should show: Up (healthy)

# Try accessing different ways
curl http://localhost:3000
curl http://127.0.0.1:3000
```

### Problem: "Network timeout" on WSL2

**Cause:** WSL networking issue.

**Solution:**
```bash
# WSL2 sometimes needs network reset
# In PowerShell (Windows, Admin):
Get-NetAdapter | Where-Object {$_.InterfaceDescription -Match "Hyper-V"} | Restart-NetAdapter

# Or restart WSL
wsl --shutdown

# Wait a few seconds
# Then start again and retry
```

---

## Last Resort Fixes

### Nuclear Option: Complete Reset

```bash
# Stop everything
docker-compose down

# Remove volumes (⚠️ DATA LOSS)
docker-compose down -v

# Remove images
docker system prune -a

# Rebuild from scratch
docker-compose build

# Start fresh
docker-compose up -d
docker-compose run --rm rails_cli db:create
docker-compose run --rm rails_cli db:migrate
```

### Deep Dive Debugging

```bash
# Get interactive shell in container
docker-compose exec web bash

# Inside container:
ps aux                      # See processes
df -h                       # Disk usage
env | grep RAILS            # Environment variables
ls -la /app                 # View app directory
```

---

## Getting Help

If you can't find the solution:

1. **Check logs:**
   ```bash
   docker-compose logs -f
   docker-compose logs web
   docker-compose logs db
   ```

2. **Check status:**
   ```bash
   make status
   docker-compose ps
   docker system df
   ```

3. **Review configuration:**
   ```bash
   cat docker-compose.yaml
   cat env/rails.env
   cat env/postgres.env
   ```

4. **Consult documentation:**
   - Read: `02_COMPLETE_GUIDE.md`
   - Read: `03_COMMANDS_REFERENCE.md`

---

**Can't solve it?** Try the "Complete Reset" section above.
