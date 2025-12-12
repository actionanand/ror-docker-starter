# 📖 Complete Guide (Full Reference)

Complete Rails Docker setup documentation.

## Project Overview

You have a production-ready Rails Docker environment with:
- **Rails 7.1** + **Ruby 3.2**
- **PostgreSQL 15** database
- **Redis 7** for caching and Sidekiq
- **Nginx 1.25** reverse proxy
- **Sidekiq** background job worker
- **All code outside containers** (easy editing)

## Services & Ports

| Service | Port | Purpose |
|---------|------|---------|
| Rails Puma | 3000 | Web application |
| PostgreSQL | 5432 | Database |
| Redis | 6379 | Cache & job queue |
| Nginx | 80, 443 | Reverse proxy |
| Sidekiq | - | Background jobs |

## Directory Structure

```
ror/
├── README/              ← Documentation (you are here)
├── docker-compose.yaml  ← Service configuration
├── Makefile            ← Command shortcuts
├── .gitignore          ← Git configuration
│
├── dockerfiles/        ← Container definitions
│   ├── rails.dockerfile
│   └── nginx.dockerfile
│
├── nginx/              ← Web server config
│   ├── nginx.conf
│   └── ssl/            ← SSL certificates
│
├── env/                ← Environment configs
│   ├── postgres.env    ← Database settings
│   ├── rails.env       ← Rails settings
│   └── .env.production.example
│
├── scripts/            ← Utility scripts
│   ├── setup.sh        ← Automated setup
│   ├── quick.sh        ← Quick commands
│   ├── cleanup.sh      ← Docker cleanup
│   └── README.sh       ← Structure guide
│
└── src/                ← YOUR Rails Application
    ├── Gemfile         ← Ruby dependencies
    ├── app/            ← Application code
    ├── config/         ← Configuration
    ├── db/             ← Migrations
    └── ... (standard Rails structure)
```

## Volumes & Persistence

### Named Volumes
- `postgres_data` → PostgreSQL database files
- `redis_data` → Redis cache files

### Host Directories
- `./src/` → Rails application code (edit directly!)
- `./env/` → Environment configuration files
- `./nginx/` → Nginx configuration

## Initial Setup

### Step 1: Change Passwords
```bash
nano env/postgres.env
# Change POSTGRES_PASSWORD from default value
```

### Step 2: Generate Rails Secret
```bash
docker-compose run --rm rails_cli secret
# Copy output and paste into env/rails.env (SECRET_KEY_BASE=)
```

### Step 3: Build & Create Database
```bash
docker-compose build
docker-compose run --rm rails_cli db:create
docker-compose run --rm rails_cli db:migrate
```

### Step 4: Start Services
```bash
docker-compose up -d
# Visit: http://localhost:3000
```

## Configuration Files

### env/postgres.env
PostgreSQL database settings:
```
POSTGRES_USER=rails_user
POSTGRES_PASSWORD=secure_password_change_me
POSTGRES_DB=rails_development
```

### env/rails.env
Rails environment variables:
```
RAILS_ENV=development
DATABASE_URL=postgresql://rails_user:password@db:5432/rails_development
REDIS_URL=redis://redis:6379/1
SECRET_KEY_BASE=your_generated_secret_here
```

### docker-compose.yaml
Defines all services:
- Ports and volume mappings
- Environment variables
- Health checks
- Service dependencies

### nginx/nginx.conf
Reverse proxy configuration:
- Port forwarding to Rails
- Static file serving
- Security headers
- Gzip compression

## Development Workflow

### Daily Start
```bash
make start              # Start all services
make logs               # Watch logs
# Open IDE, edit code in ./src/
```

### Running Migrations
```bash
# Create migration
docker-compose exec web rails generate migration CreateUsers

# Edit the migration file in src/db/migrate/

# Run migration
make migrate
```

### Adding Dependencies

**Ruby Gems:**
```bash
docker-compose run --rm bundler add devise
```

**Node Packages:**
```bash
docker-compose run --rm npm install axios
```

### Running Tests
```bash
make test               # Run all tests
make lint               # Check code style
```

### Opening Rails Console
```bash
make console            # Interactive Rails console
```

### Daily End
```bash
make stop               # Stop all services
```

## Database Management

### Create Database
```bash
docker-compose run --rm rails_cli db:create
```

### Run Migrations
```bash
docker-compose exec web rails db:migrate
```

### Check Migration Status
```bash
docker-compose exec web rails db:migrate:status
```

### Seed Database
```bash
docker-compose exec web rails db:seed
```

### Backup Database
```bash
docker-compose exec db pg_dump -U rails_user rails_development > backup.sql
```

### Reset Database (⚠️ Data Loss)
```bash
docker-compose exec web rails db:drop --force
docker-compose run --rm rails_cli db:create
docker-compose run --rm rails_cli db:migrate
```

## Cleanup & Maintenance

### Light Cleanup (Weekly)
```bash
make clean
# Removes: stopped containers, dangling images
# Frees: 100-500MB
```

### Medium Cleanup (Monthly)
```bash
make clean-medium
# Removes: unused images
# Frees: 500MB-2GB
```

### Deep Cleanup (When Needed)
```bash
make clean-full
# Removes: unused volumes
# Frees: 1-5GB
```

### Check Disk Usage
```bash
make status             # Service status + disk usage
docker system df        # Detailed breakdown
```

## Production Deployment

### Prepare for Production

1. **Change All Passwords**
   ```bash
   cp env/.env.production.example env/.env.production
   nano env/.env.production
   ```

2. **Generate New Secrets**
   ```bash
   docker-compose run --rm rails_cli secret
   ```

3. **Update Nginx Config**
   - Edit: `nginx/nginx.conf`
   - Update server_name with your domain

4. **Add SSL Certificates**
   - Place certificates in: `nginx/ssl/`

5. **Configure Resource Limits**
   - Edit: `docker-compose.yaml`
   - Set memory and CPU limits

### Deploy
```bash
docker-compose build
docker-compose up -d
docker-compose exec web rails db:migrate
```

## Troubleshooting

### Container Won't Start
```bash
docker-compose logs web           # View error logs
docker-compose build --no-cache   # Rebuild
docker-compose up -d              # Try again
```

### Port Already in Use
```bash
lsof -ti:3000 | xargs kill -9
make restart
```

### Database Connection Failed
```bash
docker-compose logs db            # Check DB logs
docker-compose restart db         # Restart DB
```

### Out of Disk Space
```bash
docker system df                  # Check usage
make clean                        # Light cleanup
make clean-medium                 # Medium cleanup if needed
```

## Useful Docker Commands

```bash
# Service management
docker-compose ps                 # List services
docker-compose logs -f            # View logs
docker-compose exec web bash      # Get shell access
docker-compose restart            # Restart services

# Information
docker system df                  # Disk usage
docker stats                      # Memory usage
docker ps                         # List containers
docker images                     # List images

# Cleanup
docker container prune -f         # Remove stopped containers
docker image prune -f             # Remove dangling images
docker volume prune -f            # Remove unused volumes
```

## Security Notes

- ✅ Change default passwords before first run
- ✅ Generate new SECRET_KEY_BASE for each environment
- ✅ Use strong passwords in production
- ✅ Keep environment files out of version control
- ✅ Use SSL/TLS in production
- ✅ Regular database backups

## Performance Tips

- Use delegated volumes for faster file syncing
- Monitor resource usage: `docker stats`
- Clean up regularly: `make clean`
- Use proper database indexes
- Cache frequently accessed data in Redis

---

**Need specific help?** Read one of these:
- **03_COMMANDS_REFERENCE.md** - All available commands
- **04_TROUBLESHOOTING.md** - Problem solutions
- **05_MEMORY_MANAGEMENT.md** - Storage management
- **06_MAKE_COMMANDS.md** - Understanding make
