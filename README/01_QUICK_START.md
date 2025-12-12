# 🚀 Quick Start Guide (5 Minutes)

Get your Rails Docker environment running in 5 minutes!

## Three Quick Setup Options

### Option 1: Automatic (Recommended)
```bash
bash scripts/setup.sh
```
- ✅ Checks Docker
- ✅ Creates Rails app
- ✅ Builds images
- ✅ Creates database
- ✅ Starts services
- **Time: 5-10 minutes**

### Option 2: Using Make
```bash
make setup
make start
make logs
```

### Option 3: Manual Docker
```bash
docker-compose build
docker-compose up -d
docker-compose run --rm rails_cli db:create
```

---

## Access Your App

After setup, visit: **http://localhost:3000**

---

## Important Before First Run

### 1. Change Database Password
```bash
nano env/postgres.env
# Change: POSTGRES_PASSWORD=secure_password_change_me
```

### 2. Generate Rails Secret
```bash
docker-compose run --rm rails_cli secret
# Copy the output, then update env/rails.env
```

### 3. Create Database
```bash
make migrate
# or: docker-compose run --rm rails_cli db:create
```

---

## After Setup

### View Logs
```bash
make logs
# or: docker-compose logs -f
```

### Open Rails Console
```bash
make console
# or: docker-compose exec web rails console
```

### Run Migrations
```bash
make migrate
# or: docker-compose exec web rails db:migrate
```

### Stop Services
```bash
make stop
# or: docker-compose stop
```

---

## Common Commands

```bash
make start              # Start all services
make stop               # Stop services
make logs               # View logs
make console            # Rails console
make migrate            # Run migrations
make test               # Run tests
make clean              # Safe cleanup
make help               # All 50+ commands
```

---

## Services Running

| Service | URL | Purpose |
|---------|-----|---------|
| Rails App | http://localhost:3000 | Your application |
| PostgreSQL | localhost:5432 | Database |
| Redis | localhost:6379 | Cache |
| Nginx | http://localhost:80 | Web server |

---

## Troubleshooting

### "Port 3000 already in use"
```bash
lsof -ti:3000 | xargs kill -9
make restart
```

### "Make command not found"
```bash
sudo apt-get install -y make
make help
```

### "Docker not running"
Start Docker Desktop or ensure Docker daemon is running.

---

## Need More Info?

- **Full reference:** Read `02_COMPLETE_GUIDE.md`
- **All commands:** Read `03_COMMANDS_REFERENCE.md`
- **Make commands:** Read `06_MAKE_COMMANDS.md`
- **Troubleshooting:** Read `04_TROUBLESHOOTING.md`

---

**Next:** Run `bash scripts/setup.sh` and visit http://localhost:3000
