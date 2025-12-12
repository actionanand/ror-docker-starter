# 💾 Memory & Disk Management

Managing Docker storage and memory efficiently.

## Check Disk Usage

### See What's Using Space

```bash
# Overall Docker usage
docker system df

# Detailed breakdown
docker system df --verbose

# Check your project
du -sh .
du -sh src/
du -sh ./README
du -sh env/
```

### Sample Output
```
TYPE                TOTAL     ACTIVE    SIZE      RECLAIMABLE
Images              5         2         1.2GB     800MB
Containers          8         1         500MB     450MB
Local Volumes       2         2         2.5GB     0B
Build Cache         -         -         320MB     320MB
```

---

## Cleanup Levels

Choose the appropriate level based on your needs:

### Level 1: Light Cleanup (Safe) ✅
**When:** Weekly
**Command:** `make clean`
**What's deleted:**
- Stopped containers
- Dangling images
**Space freed:** 100-500MB
**Risk:** None
**Recovery:** None needed

```bash
make clean
# or
bash scripts/cleanup.sh light
```

### Level 2: Medium Cleanup (Moderate) ⚠️
**When:** Monthly
**Command:** `make clean-medium`
**What's deleted:**
- Unused images (not currently in use)
- Build cache
**Space freed:** 500MB-2GB
**Risk:** Low (images rebuild on `docker-compose build`)
**Recovery:** Run `docker-compose build`

```bash
make clean-medium
# or
bash scripts/cleanup.sh medium
```

### Level 3: Deep Cleanup (High Risk) 🔴
**When:** When very low on disk
**Command:** `make clean-full`
**What's deleted:**
- Unused volumes
- Stopped containers
- Unused images
- Build cache
**Space freed:** 1-5GB
**Risk:** Medium (may delete temporary data)
**Recovery:** May need database restore

```bash
make clean-full
# or
bash scripts/cleanup.sh deep
```

### Level 4: Full Reset (DANGER) ⚠️⚠️⚠️
**When:** Emergency only
**Command:** `docker-compose down -v`
**What's deleted:**
- Everything (containers, images, volumes)
**Space freed:** 5-20GB
**Risk:** EXTREME (⚠️ DATABASE DATA LOST)
**Recovery:** Complex (need database backup)

```bash
docker-compose down -v    # ⚠️ DATA LOSS
# Not recommended!
```

---

## Safe Cleanup Strategy

### Daily
Nothing needed - let Docker manage

### Weekly
```bash
make clean                  # Takes ~30 seconds
docker system df            # Check results
```

### Monthly
```bash
make clean                  # Light cleanup first
make clean-medium           # Then medium cleanup
docker system df            # Verify results
```

### When Low on Space
```bash
# Step 1: Backup
make db-backup              # Backup database first!

# Step 2: Light clean
make clean

# Step 3: Check space
docker system df

# Step 4: If still low, medium clean
make clean-medium

# Step 5: Final resort
make clean-full             # Only if still low
```

---

## Database Specific Cleanup

### Backup Before Any Cleanup
```bash
make db-backup
# Creates: backups/db_backup_YYYYMMDD_HHMMSS.sql
```

### Reset Database (⚠️ Data Loss)
```bash
make migrate-reset
# or
docker-compose exec web rails db:drop --force
docker-compose run --rm rails_cli db:create
docker-compose run --rm rails_cli db:migrate
```

### Vacuum PostgreSQL (Reclaim Space)
```bash
docker-compose exec db vacuumdb -U rails_user rails_development -z
```

---

## Volume Management

### List All Volumes
```bash
docker volume ls
```

### Inspect a Volume
```bash
docker volume inspect postgres_data
docker volume inspect redis_data
```

### Remove Unused Volumes
```bash
docker volume prune                 # Interactive
docker volume prune -f              # Force (no confirmation)
```

### Remove Specific Volume (⚠️ Data Loss)
```bash
docker volume rm postgres_data      # ⚠️ DELETES DATABASE
docker volume rm redis_data         # ⚠️ DELETES CACHE DATA
```

---

## Image Management

### List Images
```bash
docker images
docker images -a                    # All images including intermediate
```

### Remove Unused Images
```bash
docker image prune                  # Interactive
docker image prune -f               # Force
docker image prune -a               # Remove all unused
```

### Remove Specific Image
```bash
docker image rm image_name
docker image rm image_id
```

---

## Container Management

### List Containers
```bash
docker ps                           # Running
docker ps -a                        # All
```

### Remove Containers
```bash
docker container prune              # Interactive
docker container prune -f           # Force
docker rm container_id              # Specific container
```

---

## Build Cache Management

### View Build Cache
```bash
docker builder ls
docker builder du
```

### Clear Build Cache
```bash
docker builder prune                # Interactive
docker builder prune -f             # Force
docker builder prune -a             # All cache
```

---

## Memory Management

### Monitor Memory Usage

```bash
# Real-time stats
docker stats

# Specific container
docker stats web
docker stats db

# With limits
docker stats --no-stream web
```

### Sample Output
```
CONTAINER ID    NAME      CPU %     MEM USAGE / LIMIT     MEM %
abc12345def6    ror_web   0.5%      256MiB / 2GiB         12%
def67890abc1    ror_db    1.2%      512MiB / 2GiB         25%
```

### Set Memory Limits

Edit `docker-compose.yaml`:
```yaml
services:
  web:
    deploy:
      resources:
        limits:
          memory: 1G          # Max 1GB
        reservations:
          memory: 512M        # Reserve 512MB
```

### Reduce Sidekiq Memory

Edit `env/rails.env`:
```
SIDEKIQ_CONCURRENCY=5      # Default
SIDEKIQ_CONCURRENCY=2      # Reduced
```

Then restart:
```bash
docker-compose restart sidekiq
```

---

## Space By Component

### Typical Sizes

| Component | Size | Notes |
|-----------|------|-------|
| Rails image | 300-400MB | Built from Gemfile |
| Nginx image | 20-30MB | Lightweight |
| PostgreSQL image | 200-250MB | Base image |
| Redis image | 30-50MB | Lightweight |
| PostgreSQL data | 50MB-5GB | Depends on usage |
| Redis data | 10MB-500MB | Depends on caching |
| Gem cache | 200-800MB | Ruby dependencies |
| npm cache | 100-500MB | Node packages |
| Build cache | 100-500MB | Docker build layers |

---

## Storage Examples

### Small Project (Dev)
- Code: ~50MB
- Database: ~100MB
- Total: ~200MB
- Cleanup: `make clean` (weekly)

### Medium Project (Dev+Test)
- Code: ~200MB
- Database: ~500MB
- Caches: ~300MB
- Total: ~1GB
- Cleanup: `make clean` (weekly), `make clean-medium` (monthly)

### Large Project (Prod)
- Code: ~500MB
- Database: ~5GB+
- Caches: ~1GB+
- Total: ~10GB+
- Cleanup: Daily `make clean`, weekly backup, monthly `make clean-medium`

---

## Optimization Tips

### Reduce Database Size
```bash
# Delete old logs
docker-compose exec db psql -U rails_user rails_development -c "DELETE FROM logs WHERE created_at < NOW() - INTERVAL '30 days';"

# Vacuum to reclaim space
docker-compose exec db vacuumdb -U rails_user rails_development -z
```

### Clean Docker Buildkit Cache
```bash
docker buildx prune -a
```

### Regular Maintenance Schedule

```bash
# Daily
docker system df        # Just check

# Weekly
make clean              # Light cleanup

# Monthly  
make clean-medium       # Medium cleanup
make db-backup          # Backup database

# Quarterly
make clean-full         # If needed
# Clean old backups
find backups -mtime +90 -delete   # Delete backups older than 90 days
```

---

## Emergency Cleanup

If you're critically low on disk space:

### Step-by-Step
```bash
# 1. Backup immediately
make db-backup

# 2. Stop services to free memory
make stop

# 3. Light cleanup
make clean

# 4. Check space
docker system df

# 5. If still low, medium cleanup
make clean-medium

# 6. Check again
docker system df

# 7. Restart services
make start
```

---

## What NOT to Delete

❌ **Don't delete:** `postgres_data` volume (unless you want to lose database)
❌ **Don't delete:** `redis_data` volume (unless you want to lose cache)
❌ **Don't delete:** `./src/` directory (your application code)
❌ **Don't delete:** `./env/` directory (your configuration)
❌ **Don't delete:** `backups/` directory (your backups)

✅ **Safe to delete:**
- Stopped containers
- Dangling images
- Unused volumes (check first!)
- Build cache
- Old backups (keep recent ones)

---

## Monitoring Script

Create a daily cleanup reminder:

```bash
# Add to crontab (runs daily at 2 AM)
crontab -e

# Add this line:
0 2 * * * cd /mnt/c/repos/ar_files/code/ror && make clean >> /tmp/docker_cleanup.log 2>&1
```

---

## Reference Table

| Problem | Solution | Space Freed |
|---------|----------|------------|
| Stopped containers | `make clean` | 100-300MB |
| Dangling images | `make clean` | 50-200MB |
| Unused images | `make clean-medium` | 500MB-2GB |
| Build cache | `make clean-medium` | 100-300MB |
| Unused volumes | `make clean-full` | Varies |
| Database bloat | Vacuum + prune | 100MB-1GB |

---

**Next:** Read `06_MAKE_COMMANDS.md` for command details.
