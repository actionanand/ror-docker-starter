# Rails Docker Setup Guide

A complete Docker setup for Ruby on Rails development with PostgreSQL, Redis, Nginx, and Sidekiq. All application files and volumes are stored outside the container for easy management.

## Table of Contents

1. [Project Overview](#project-overview)
2. [Prerequisites](#prerequisites)
3. [Project Structure](#project-structure)
4. [Technologies & Services](#technologies--services)
5. [Initial Setup](#initial-setup)
6. [Running the Application](#running-the-application)
7. [Common Commands](#common-commands)
8. [Development Workflow](#development-workflow)
9. [Memory & Disk Management](#memory--disk-management)
10. [Troubleshooting](#troubleshooting)
11. [Production Deployment](#production-deployment)

---

## Project Overview

This Docker setup provides a complete Rails development environment with:
- **Rails 7.1** with PostgreSQL 15
- **Redis** for caching and Sidekiq job processing
- **Nginx** as reverse proxy and web server
- **Sidekiq** for background job processing
- **PostgreSQL** as primary database
- All volumes and source code located outside containers for easier management

### Why Files are Outside Containers?

- **Easy source code editing** in your IDE without copying
- **Persistent data** survives container deletion
- **Better performance** with delegated volumes
- **Version control friendly** - only commit what matters
- **Memory efficient** - shared volumes across containers

---

## Prerequisites

- Docker Desktop (or Docker + Docker Compose)
  - macOS: [Docker Desktop](https://www.docker.com/products/docker-desktop)
  - Windows: [Docker Desktop](https://www.docker.com/products/docker-desktop)
  - Linux: Install [Docker](https://docs.docker.com/engine/install/) and [Docker Compose](https://docs.docker.com/compose/install/)
- At least 4GB RAM available for Docker
- Git (for version control)

### Verify Installation

```bash
docker --version
docker-compose --version
```

---

## Project Structure

```
ror/
├── docker-compose.yaml      # Main orchestration file
├── .gitignore              # Git ignore patterns
├── README.md               # This file
├── Dockerfile              # Rails application Dockerfile
│
├── dockerfiles/            # Container configuration files
│   ├── rails.dockerfile    # Rails/Ruby application container
│   └── nginx.dockerfile    # Nginx web server configuration
│
├── nginx/                  # Nginx configuration (outside container)
│   ├── nginx.conf          # Main nginx configuration
│   └── ssl/                # SSL certificates directory
│
├── env/                    # Environment configuration files
│   ├── postgres.env        # PostgreSQL environment variables
│   ├── rails.env           # Rails environment variables
│   └── .env.production.example  # Production example
│
├── src/                    # Rails application source code (OUTSIDE container)
│   ├── Gemfile            # Ruby gems dependencies
│   ├── Gemfile.lock       # Locked gem versions
│   ├── app/               # Rails app directory
│   ├── config/            # Rails configuration
│   ├── db/                # Database migrations
│   ├── public/            # Static files
│   ├── Rakefile           # Rails tasks
│   └── ... (standard Rails structure)
│
└── scripts/               # Utility scripts
    ├── setup.sh           # Initial setup script
    ├── cleanup.sh         # Cleanup script
    └── docker-cleanup.sh  # Docker image/volume cleanup
```

---

## Technologies & Services

### Services Running in Docker Compose

| Service | Image/Build | Port | Purpose |
|---------|-----------|------|---------|
| `web` | rails.dockerfile | 3000 | Rails Puma web server |
| `db` | postgres:15-alpine | 5432 | PostgreSQL database |
| `redis` | redis:7-alpine | 6379 | Cache & Sidekiq queue |
| `sidekiq` | rails.dockerfile | - | Background job worker |
| `nginx` | nginx:1.25-alpine | 80, 443 | Reverse proxy & static files |
| `bundler` | rails.dockerfile | - | Gem dependency manager |
| `rails_cli` | rails.dockerfile | - | Rails console/generators |
| `npm` | node:18-alpine | - | JavaScript dependency manager |

### External Volumes

| Volume Name | Mount Point | Purpose |
|-------------|-------------|---------|
| `postgres_data` | `/var/lib/postgresql/data` | PostgreSQL data persistence |
| `redis_data` | `/data` | Redis persistence |
| `./src` | `/app` | Rails source code (delegated) |
| `/app/vendor` | Named volume | Gem cache |
| `/app/node_modules` | Named volume | JavaScript dependencies |

---

## Initial Setup

### 1. Clone or Create the Project

```bash
cd /path/to/ror
```

### 2. Create a New Rails Application (if starting from scratch)

```bash
# Create Rails app skeleton
docker-compose run --rm rails_cli new . --database=postgresql --skip-test

# Or generate with specific features
docker-compose run --rm rails_cli new . \
  --database=postgresql \
  --skip-test \
  --webpack=webpack \
  --css=sass
```

### 3. Configure Environment Variables

Update the environment files with your settings:

```bash
# Edit database credentials
nano env/postgres.env
nano env/rails.env
```

**Important:** Change the default passwords!

```bash
# Generate Rails secret key
docker-compose run --rm rails_cli secret
```

Update `env/rails.env` with the generated secret:
```bash
SECRET_KEY_BASE=your_generated_secret_here
```

### 4. Build Docker Images

```bash
# Build all custom images (rails, nginx)
docker-compose build

# Or build specific service
docker-compose build web
docker-compose build nginx
```

### 5. Create and Setup Database

```bash
# Create database
docker-compose run --rm rails_cli db:create

# Run migrations
docker-compose run --rm rails_cli db:migrate

# Seed database (if seeds exist)
docker-compose run --rm rails_cli db:seed
```

---

## Running the Application

### Start All Services

```bash
# Start in foreground (see logs)
docker-compose up

# Start in background (detached mode)
docker-compose up -d

# Start specific services
docker-compose up web db nginx
```

### Access the Application

- **Rails App**: http://localhost:3000
- **Nginx Proxy**: http://localhost:80
- **PostgreSQL**: localhost:5432
- **Redis**: localhost:6379

### View Logs

```bash
# All services logs
docker-compose logs -f

# Specific service
docker-compose logs -f web
docker-compose logs -f db
docker-compose logs -f sidekiq

# Last 50 lines
docker-compose logs --tail=50 web

# Follow only web and sidekiq
docker-compose logs -f web sidekiq
```

### Stop Services

```bash
# Stop running containers
docker-compose stop

# Stop and remove containers (data persists in volumes)
docker-compose down

# Stop, remove containers AND volumes (⚠️ data loss)
docker-compose down -v
```

---

## Common Commands

### Rails Commands

```bash
# Rails console
docker-compose exec web rails console

# Generate migration
docker-compose exec web rails generate migration CreateUsers

# Run migrations
docker-compose exec web rails db:migrate

# Rollback migration
docker-compose exec web rails db:rollback

# Seed database
docker-compose exec web rails db:seed

# Check database status
docker-compose exec web rails db:check

# Create new controller
docker-compose exec web rails generate controller Pages home about

# Create new model
docker-compose exec web rails generate model User email:string name:string
```

### Bundler Commands

```bash
# Install gems
docker-compose run --rm bundler install

# Add new gem and install
docker-compose run --rm bundler add devise

# Update gems
docker-compose run --rm bundler update

# Show installed gems
docker-compose run --rm bundler list
```

### Database Commands

```bash
# Connect to PostgreSQL
docker-compose exec db psql -U rails_user -d rails_development

# Backup database
docker-compose exec db pg_dump -U rails_user rails_development > backup.sql

# Restore database
docker-compose exec db psql -U rails_user rails_development < backup.sql

# Drop database
docker-compose exec web rails db:drop
```

### Sidekiq (Background Jobs)

```bash
# View Sidekiq logs
docker-compose logs -f sidekiq

# Check Sidekiq status
docker-compose ps sidekiq
```

### Node/NPM Commands

```bash
# Install dependencies
docker-compose run --rm npm install

# Add package
docker-compose run --rm npm install --save lodash

# Build JavaScript
docker-compose run --rm npm run build

# Watch for changes
docker-compose run --rm npm run watch
```

### Container Management

```bash
# List running containers
docker-compose ps

# Execute command in container
docker-compose exec web bash

# Get interactive shell in container
docker-compose run --rm web bash

# Restart service
docker-compose restart web

# Recreate containers
docker-compose up --force-recreate
```

---

## Development Workflow

### 1. Starting Fresh Development Session

```bash
# Start all services
docker-compose up -d

# Check services are running
docker-compose ps

# View logs
docker-compose logs -f
```

### 2. Making Code Changes

Since files are in `./src` (outside container), you can:
- Edit files directly in your IDE
- Changes are automatically reflected (with delegated volumes)
- No need to rebuild containers

### 3. Adding Dependencies

```bash
# Add Ruby gem
docker-compose run --rm bundler add devise

# Add JavaScript package
docker-compose run --rm npm install axios

# The files update on disk, changes reflected immediately
```

### 4. Running Tests

```bash
# Setup test database
docker-compose run --rm rails_cli db:test:load

# Run all tests
docker-compose run --rm web bundle exec rspec

# Run specific test file
docker-compose run --rm web bundle exec rspec spec/models/user_spec.rb

# Run with coverage
docker-compose run --rm web bundle exec rspec --format progress --require rails_helper --out tmp/rspec.txt
```

### 5. Code Quality Tools

```bash
# RuboCop (linter)
docker-compose run --rm web bundle exec rubocop

# Brakeman (security scanner)
docker-compose run --rm web bundle exec brakeman

# Fix RuboCop issues automatically
docker-compose run --rm web bundle exec rubocop -a
```

### 6. Debugging

```bash
# Using byebug in code
# Add 'byebug' in your code, then:
docker-compose attach web
# Will drop into debugger

# View running processes
docker-compose exec web ps aux

# Check memory usage
docker stats

# Monitor database connections
docker-compose exec db psql -U rails_user -d rails_development -c "SELECT * FROM pg_stat_activity;"
```

---

## Memory & Disk Management

### Checking Disk Usage

```bash
# See all Docker disk usage
docker system df

# Detailed breakdown
docker system df --verbose

# See volume sizes
docker volume ls
docker volume inspect postgres_data redis_data

# Check host disk usage
du -sh /var/lib/docker/
du -sh ./src
```

### Memory Management

```bash
# Monitor container memory usage
docker stats

# Set memory limits in docker-compose.yaml
# Add to services:
# deploy:
#   resources:
#     limits:
#       memory: 1G
#     reservations:
#       memory: 512M
```

### Cleanup Strategies

#### 1. **Clean Database Data Only** (keep containers running)
```bash
# Remove all data but keep schema
docker-compose exec web rails db:reset

# Or drop and recreate
docker-compose exec web rails db:drop
docker-compose exec web rails db:create
```

#### 2. **Remove Stopped Containers** (~100MB-500MB freed)
```bash
# Remove stopped containers
docker container prune

# Remove with confirmation
docker container prune -f
```

#### 3. **Remove Unused Images** (~500MB-2GB freed)
```bash
# Remove dangling images
docker image prune

# Remove all unused images
docker image prune -a

# Remove all images except latest
docker image prune -a --filter "until=24h"
```

#### 4. **Remove Unused Volumes** (~100MB-1GB freed)
```bash
# WARNING: This removes data!
# Remove unused volumes
docker volume prune

# Remove with confirmation
docker volume prune -f

# Remove specific volume
docker volume rm postgres_data redis_data
```

#### 5. **Full System Cleanup** (⚠️ DELETES DATA)
```bash
# Remove everything: containers, images, volumes, networks
docker system prune -a --volumes

# This removes:
# - All stopped containers
# - All images not in use
# - All volumes not in use
# - All networks not in use
```

#### 6. **Cleanup Build Cache**
```bash
# Remove build cache
docker builder prune

# Remove all build cache
docker builder prune -a
```

### Recommended Cleanup Schedule

```bash
# Weekly
docker system prune -f              # Remove stopped containers & dangling images

# Monthly
docker image prune -a -f            # Remove unused images

# When low on disk space
docker system prune -a --volumes -f # DANGER: removes data volumes too
```

### Safe Cleanup Script

Create `scripts/cleanup.sh`:
```bash
#!/bin/bash
set -e

echo "=== Docker Cleanup Script ==="
echo

echo "1. Stopping containers..."
docker-compose down

echo "2. Removing stopped containers..."
docker container prune -f

echo "3. Removing dangling images..."
docker image prune -f

echo "4. Removing unused volumes (except data)..."
docker volume prune -f

echo "5. Removing build cache..."
docker builder prune -f

echo
echo "=== Cleanup Complete ==="
docker system df
```

Run it:
```bash
bash scripts/cleanup.sh
```

### Database Specific Cleanup

```bash
# Backup before cleanup
docker-compose exec db pg_dump -U rails_user rails_development > backup.sql

# Clean database
docker-compose exec web rails db:drop
docker-compose exec web rails db:create
docker-compose exec web rails db:migrate

# Vacuum to reclaim disk space
docker-compose exec db vacuumdb -U rails_user -d rails_development -z
```

---

## Troubleshooting

### Container Won't Start

```bash
# Check logs
docker-compose logs web

# Rebuild container
docker-compose down
docker-compose build --no-cache web
docker-compose up

# Check for port conflicts
netstat -tulpn | grep 3000  # macOS/Linux
netstat -ano | findstr :3000 # Windows

# Kill process on port
lsof -ti:3000 | xargs kill -9  # macOS/Linux
netstat -ano | findstr :3000   # Windows
```

### Database Connection Issues

```bash
# Test database connection
docker-compose exec web rails dbconsole

# Check if db is healthy
docker-compose exec db pg_isready -U rails_user

# View db container logs
docker-compose logs db

# Check environment variables
docker-compose exec web env | grep DATABASE
```

### Gem Installation Issues

```bash
# Clear gem cache
docker-compose down
docker volume rm ror_postgres_data ror_redis_data

# Rebuild with no cache
docker-compose build --no-cache

# Reinstall gems
docker-compose run --rm bundler install
```

### Memory Issues

```bash
# Check memory usage
docker stats

# Reduce Sidekiq concurrency in env/rails.env
SIDEKIQ_CONCURRENCY=2

# Restart with new settings
docker-compose restart sidekiq

# Clear Redis cache
docker-compose exec redis redis-cli FLUSHALL
```

### Redis Connection Issues

```bash
# Check Redis is running
docker-compose ps redis

# Test Redis connection
docker-compose exec redis redis-cli ping

# Check Redis logs
docker-compose logs redis

# Clear Redis data
docker-compose exec redis redis-cli FLUSHALL
```

### File Permission Issues

```bash
# Fix permissions on src folder
sudo chown -R $USER:$USER ./src

# Fix in container
docker-compose exec web chown -R www:www /app

# On host (Linux)
chmod 755 ./src
chmod 644 ./src/**/*.rb
```

### Nginx Issues

```bash
# Test nginx configuration
docker-compose exec nginx nginx -t

# View nginx logs
docker-compose logs nginx

# Check what's listening on port 80
netstat -tulpn | grep 80

# Restart nginx
docker-compose restart nginx
```

---

## Production Deployment

### Before Deployment

1. **Update environment files**
   ```bash
   cp env/.env.production.example env/.env.production
   # Edit with production values
   ```

2. **Set strong credentials**
   ```bash
   # Generate new secret
   docker-compose run --rm rails_cli secret
   ```

3. **Review docker-compose.yaml**
   - Set `RAILS_ENV=production`
   - Reduce Sidekiq concurrency if needed
   - Add resource limits

### Deployment Steps

```bash
# Pull latest code
git pull origin main

# Build images
docker-compose build

# Run migrations
docker-compose run --rm rails_cli db:migrate

# Precompile assets
docker-compose run --rm rails_cli assets:precompile

# Start services
docker-compose up -d

# Check status
docker-compose ps
docker system df
```

### Production Monitoring

```bash
# Monitor memory
watch docker stats

# Check logs for errors
docker-compose logs -f web | grep -i error

# Database monitoring
docker-compose exec db psql -U rails_user -d rails_production -c "SELECT count(*) FROM users;"
```

### Backup Strategy

```bash
# Daily database backup
docker-compose exec db pg_dump -U rails_user rails_production > \
  backups/db_$(date +%Y%m%d_%H%M%S).sql

# Backup to S3
docker-compose exec db pg_dump -U rails_user rails_production | \
  gzip | \
  aws s3 cp - s3://my-bucket/backups/db_$(date +%Y%m%d).sql.gz
```

---

## Quick Reference

```bash
# Start development
docker-compose up -d && docker-compose logs -f

# Run migration
docker-compose exec web rails db:migrate

# Open console
docker-compose exec web rails console

# Add gem
docker-compose run --rm bundler add gem_name

# Run tests
docker-compose run --rm web bundle exec rspec

# Cleanup volumes
docker volume prune -f

# Full reset (⚠️ data loss)
docker-compose down -v && docker-compose up -d
```

---

## Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Rails Guides](https://guides.rubyonrails.org/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Redis Documentation](https://redis.io/documentation)
- [Sidekiq Documentation](https://sidekiq.org/)
- [Nginx Documentation](https://nginx.org/en/docs/)

---

## License

This Docker setup is provided as-is for development purposes.

## Support

For issues or questions:
1. Check the Troubleshooting section
2. Review Docker logs
3. Consult the official documentation
4. Check container status with `docker-compose ps`

---

**Last Updated:** December 2024
**Rails Version:** 7.1
**Ruby Version:** 3.2
**PostgreSQL Version:** 15
**Nginx Version:** 1.25
