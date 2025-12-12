# 🚀 Rails Docker Setup - START HERE!

Welcome! This folder contains all documentation for your Rails Docker project.

## 📂 Documentation Files in This Folder

| File | Purpose | Read When |
|------|---------|-----------|
| **01_QUICK_START.md** | 5-minute setup | You're in a hurry |
| **02_COMPLETE_GUIDE.md** | Full reference (2000+ lines) | You need detailed info |
| **03_COMMANDS_REFERENCE.md** | All available commands | You need command help |
| **04_TROUBLESHOOTING.md** | Problem solutions | Something isn't working |
| **05_MEMORY_MANAGEMENT.md** | Cleanup & storage info | Managing disk space |
| **06_MAKE_COMMANDS.md** | Make command guide | Using `make` commands |

---

## ⚡ Quick Summary

You have a complete Rails Docker setup with:
- **Rails 7.1** + **Ruby 3.2**
- **PostgreSQL 15** + **Redis 7**
- **Nginx** + **Sidekiq**
- All code outside containers (easy editing!)
- 50+ Make commands
- Automated setup script

---

## 🎯 Recommended Reading Order

### If You Have 5 Minutes
1. Read this file (you're reading it now!)
2. Read: **01_QUICK_START.md**
3. Run: `bash scripts/setup.sh`

### If You Have 15 Minutes
1. This file
2. **01_QUICK_START.md**
3. **06_MAKE_COMMANDS.md** (to understand the commands)
4. Run setup

### If You Have 30 Minutes
1. This file
2. **01_QUICK_START.md**
3. **02_COMPLETE_GUIDE.md** (overview section)
4. **06_MAKE_COMMANDS.md**
5. Run setup

### If You Want Complete Understanding
1. Read all files in order: 01 → 02 → 03 → 04 → 05 → 06
2. Then run: `bash scripts/setup.sh`

---

## 🚀 Three Ways to Get Started

### Option 1: Fastest (Recommended)
```bash
bash scripts/setup.sh
# Automatic setup - 5-10 minutes
# Everything done for you!
```

### Option 2: Using Make Commands
```bash
make help           # See all available commands
make setup          # Run setup
make start          # Start services
make logs           # View logs
```

### Option 3: Manual Docker
```bash
docker-compose build
docker-compose up -d
docker-compose exec web rails db:create
```

---

## 📖 Which File Should I Read?

### "I just want to get it running"
→ Read: **01_QUICK_START.md**

### "What commands are available?"
→ Read: **03_COMMANDS_REFERENCE.md** or **06_MAKE_COMMANDS.md**

### "How do I use the `make` command?"
→ Read: **06_MAKE_COMMANDS.md**

### "I need detailed documentation"
→ Read: **02_COMPLETE_GUIDE.md**

### "Something isn't working"
→ Read: **04_TROUBLESHOOTING.md**

### "I'm running out of disk space"
→ Read: **05_MEMORY_MANAGEMENT.md**

---

## ⚠️ IMPORTANT Before First Run

1. **Change Database Password**
   ```bash
   nano ../env/postgres.env
   # Change: POSTGRES_PASSWORD=secure_password_change_me
   ```

2. **Generate Rails Secret**
   ```bash
   docker-compose run --rm rails_cli secret
   # Copy the output
   # Update: ../env/rails.env (SECRET_KEY_BASE=)
   ```

3. **Create Database**
   ```bash
   make migrate
   # Or: docker-compose run --rm rails_cli db:create
   ```

---

## 🎯 Most Common Commands

```bash
# Start/Stop
make start              # Start all services
make stop               # Stop services
make logs               # View logs

# Development
make console            # Open Rails console
make migrate            # Run database migrations
make test               # Run tests

# Cleanup
make clean              # Safe cleanup (weekly)
make clean-medium       # Medium cleanup (monthly)
```

**Need more?** Run: `make help` to see all 50+ commands!

---

## 📂 Project Structure

```
ror/
├── README/                    ← You are here!
│   ├── 00_START_HERE.md      ← This file
│   ├── 01_QUICK_START.md     ← 5-min setup
│   ├── 02_COMPLETE_GUIDE.md  ← Full reference
│   ├── 03_COMMANDS_REFERENCE.md ← All commands
│   ├── 04_TROUBLESHOOTING.md ← Problem fixes
│   ├── 05_MEMORY_MANAGEMENT.md ← Storage info
│   └── 06_MAKE_COMMANDS.md   ← Make guide
│
├── docker-compose.yaml       ← Services config
├── Makefile                  ← Command definitions
├── .gitignore               ← Git config
│
├── dockerfiles/             ← Container definitions
├── nginx/                   ← Web server config
├── env/                     ← Environment files
├── scripts/                 ← Utility scripts
└── src/                     ← YOUR RAILS APP
```

---

## 💡 Key Features

✅ **Code Outside Containers**
- Edit `./src/` directly in your IDE
- Changes reflect immediately
- No permission issues

✅ **50+ Make Commands**
- Easy shortcuts for common tasks
- No need to remember Docker syntax
- `make help` shows all commands

✅ **Automated Setup**
- `bash scripts/setup.sh` does everything
- Checks Docker installation
- Creates database
- Installs dependencies

✅ **Complete Documentation**
- 6 comprehensive guide files
- Troubleshooting included
- Command reference included
- Memory management guide

---

## 🔧 What Is "Make"?

`make` is a command that runs shortcuts defined in the `Makefile`.

Instead of typing:
```bash
docker-compose exec web rails console
```

You can just type:
```bash
make console
```

**To see all available make commands:**
```bash
make help
```

---

## 🚨 Make Command Didn't Work?

If you see: `make: command not found`

**Solution: Install make**
```bash
sudo apt-get update
sudo apt-get install -y make
```

Then try again:
```bash
make help
```

---

## 🎓 Learning Path

### Beginner
1. Read: **01_QUICK_START.md**
2. Run: `bash scripts/setup.sh`
3. Visit: http://localhost:3000
4. Edit code in: `./src/`

### Intermediate
1. Read: **06_MAKE_COMMANDS.md**
2. Learn common commands: `make start`, `make logs`, `make console`
3. Read: **03_COMMANDS_REFERENCE.md**
4. Try different commands

### Advanced
1. Read: **02_COMPLETE_GUIDE.md**
2. Review: `docker-compose.yaml`
3. Customize: Dockerfiles, configuration
4. Deploy: To production

---

## 📞 Need Help?

### Quick Help
```bash
make help               # Show all make commands
bash scripts/quick.sh help    # Quick command help
```

### Find Answers
| Question | Read |
|----------|------|
| How do I get started quickly? | **01_QUICK_START.md** |
| What make commands exist? | **06_MAKE_COMMANDS.md** |
| Something isn't working | **04_TROUBLESHOOTING.md** |
| Running out of disk space? | **05_MEMORY_MANAGEMENT.md** |
| Need detailed info? | **02_COMPLETE_GUIDE.md** |

---

## ✅ Quick Checklist

Before you start:
- [ ] Read this file (you're doing it!)
- [ ] Choose a reading file from the list above
- [ ] Install make if needed: `sudo apt-get install -y make`
- [ ] Change passwords in `../env/postgres.env`
- [ ] Run `bash scripts/setup.sh`
- [ ] Visit http://localhost:3000

---

## 🎉 You're Ready!

Everything is set up. Now:

1. **Read one of these files** based on what you need
2. **Run the setup**: `bash scripts/setup.sh`
3. **Start developing** in `./src/`
4. **Use make commands**: `make help` to see all

---

## 📊 File Overview

| File | Size | Time | Content |
|------|------|------|---------|
| 01_QUICK_START.md | 3 KB | 5 min | Fast setup instructions |
| 02_COMPLETE_GUIDE.md | 18 KB | 20 min | Full detailed reference |
| 03_COMMANDS_REFERENCE.md | 8 KB | 10 min | All available commands |
| 04_TROUBLESHOOTING.md | 12 KB | Reference | Problem solutions |
| 05_MEMORY_MANAGEMENT.md | 6 KB | Reference | Storage & cleanup |
| 06_MAKE_COMMANDS.md | 5 KB | 10 min | Understanding make |

**Total: 52 KB of documentation**

---

## 🚀 Get Started Now!

```bash
# If in a hurry
bash scripts/setup.sh

# If want to understand first
cat 01_QUICK_START.md

# If need all commands
make help

# If need specific help
cat 06_MAKE_COMMANDS.md
```

---

**Next Step:** Read **01_QUICK_START.md** or run `bash scripts/setup.sh`
