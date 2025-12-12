#!/bin/bash

###############################################################################
# Directory Structure Guide
# Visual overview of the Rails Docker project
###############################################################################

cat << 'EOF'

╔════════════════════════════════════════════════════════════════════════════╗
║                    RAILS DOCKER PROJECT STRUCTURE                          ║
╚════════════════════════════════════════════════════════════════════════════╝

ror/
│
├── 📄 QUICKSTART.md                 ← START HERE! (5-minute setup)
├── 📄 SETUP_SUMMARY.md              ← Overview of the project
├── 📄 README.md                     ← Complete documentation (2000+ lines)
│
├── 📋 docker-compose.yaml           ← Main orchestration file
├── 🛠️  Makefile                     ← Easy commands (make help)
│
├── 📁 dockerfiles/                  ← Container configurations
│   ├── rails.dockerfile             ← Rails/Ruby container
│   └── nginx.dockerfile             ← Nginx web server
│
├── 📁 nginx/                        ← Nginx configuration (outside container)
│   ├── nginx.conf                   ← Reverse proxy config
│   └── ssl/                         ← SSL certificates directory
│       └── .gitkeep
│
├── 📁 env/                          ← Environment configurations
│   ├── postgres.env                 ← PostgreSQL variables
│   ├── rails.env                    ← Rails variables
│   └── .env.production.example      ← Production template
│
├── 📁 src/                          ← YOUR RAILS APPLICATION (OUTSIDE)
│   ├── Gemfile                      ← Ruby dependencies template
│   ├── Gemfile.lock                 ← Locked gem versions
│   ├── app/                         ← Application code
│   ├── config/                      ← Configuration
│   ├── db/                          ← Migrations & seeds
│   ├── public/                      ← Static files
│   ├── Rakefile                     ← Rails tasks
│   └── ... (standard Rails structure)
│
├── 📁 scripts/                      ← Utility scripts
│   ├── setup.sh                     ← Automated setup (bash scripts/setup.sh)
│   ├── quick.sh                     ← Daily commands (bash scripts/quick.sh)
│   ├── cleanup.sh                   ← Docker cleanup (bash scripts/cleanup.sh)
│   └── README.sh (this file)        ← Visual structure guide
│
└── 📁 backups/                      ← Database backups (auto-created)
    └── db_backup_*.sql              ← Backup files


╔════════════════════════════════════════════════════════════════════════════╗
║                           SERVICES & PORTS                                 ║
╚════════════════════════════════════════════════════════════════════════════╝

Service         Container    Port      Purpose
─────────────────────────────────────────────────────────────────────────────
web             ror_rails    3000      Rails Puma server
db              ror_postgres 5432      PostgreSQL database
redis           ror_redis    6379      Cache & Sidekiq queue
sidekiq         ror_sidekiq  -         Background job worker
nginx           ror_nginx    80/443    Reverse proxy & static files
bundler         -            -         Gem dependency manager
rails_cli       -            -         Rails commands/generators
npm             -            -         Node package manager


╔════════════════════════════════════════════════════════════════════════════╗
║                          VOLUMES & PERSISTENCE                             ║
╚════════════════════════════════════════════════════════════════════════════╝

Volume Name         Mount Point                    Storage Location
─────────────────────────────────────────────────────────────────────────────
./src              /app                           Host: ./src (YOUR CODE)
postgres_data      /var/lib/postgresql/data       Named volume (persistent)
redis_data         /data                          Named volume (persistent)
/app/vendor        -                              Named volume (gems cache)
/app/node_modules  -                              Named volume (npm cache)


╔════════════════════════════════════════════════════════════════════════════╗
║                         QUICK START COMMANDS                               ║
╚════════════════════════════════════════════════════════════════════════════╝

📌 Using Make (Recommended):

    make help               Show all make commands
    make setup             Complete automated setup
    make start             Start all services
    make logs              View service logs
    make console           Open Rails console
    make migrate           Run database migrations
    make stop              Stop all services
    make clean             Safe cleanup (removes stopped containers)


📌 Using Scripts:

    bash scripts/setup.sh               Automated setup
    bash scripts/quick.sh start         Start services
    bash scripts/quick.sh logs -f       View logs
    bash scripts/quick.sh console       Rails console
    bash scripts/cleanup.sh light       Light cleanup
    bash scripts/cleanup.sh medium      Medium cleanup


📌 Using Docker Compose:

    docker-compose up -d                Start services
    docker-compose down                 Stop services
    docker-compose logs -f              View logs
    docker-compose exec web rails c     Rails console
    docker-compose ps                   Show status


╔════════════════════════════════════════════════════════════════════════════╗
║                         FILE MODIFICATION GUIDE                            ║
╚════════════════════════════════════════════════════════════════════════════╝

What to Edit                          Location                When
─────────────────────────────────────────────────────────────────────────────
Rails Code                            src/app/                Always
Database Migrations                   src/db/migrate/         Feature work
Rails Config                          src/config/             Setup/config
CSS/JavaScript                        src/app/assets/         Design work
PostgreSQL Password                   env/postgres.env        Before first run
Rails Secrets                         env/rails.env           Before first run
Nginx Config                          nginx/nginx.conf        Domain/SSL changes
Gems/Dependencies                     src/Gemfile             Add packages
Node Dependencies                     src/package.json        Add npm packages
Docker Image                          dockerfiles/*.dockerfile Need new tools
⚠️ NEVER edit container internals    Inside container        Bad idea!


╔════════════════════════════════════════════════════════════════════════════╗
║                        TYPICAL DEVELOPMENT WORKFLOW                        ║
╚════════════════════════════════════════════════════════════════════════════╝

1️⃣  START OF DAY:
    make start          # Start all services
    make logs           # Watch logs


2️⃣  DEVELOPMENT:
    # Edit files in ./src/  (outside container)
    # Changes reflect automatically!


3️⃣  DATABASE CHANGES:
    docker-compose exec web rails generate migration CreateUsers
    # Edit db/migrate/xxx_create_users.rb
    make migrate        # Run the migration


4️⃣  ADD DEPENDENCIES:
    docker-compose run --rm bundler add devise
    # Or
    docker-compose run --rm npm install axios


5️⃣  RUN TESTS:
    make test           # Run all tests
    make lint           # Check code style


6️⃣  DEBUGGING:
    make console        # Open Rails console
    make shell          # Get container shell access
    docker-compose logs -f web  # Watch logs


7️⃣  END OF DAY:
    make stop           # Stop services


📊 MEMORY MANAGEMENT:

    Weekly:
    make clean          # Light cleanup (safe)

    Monthly:
    make clean-medium   # Medium cleanup
    make status         # Check disk usage

    When low on space:
    docker system df    # See what's using space
    make clean-full     # Deep cleanup (careful!)


╔════════════════════════════════════════════════════════════════════════════╗
║                            FILE DESCRIPTIONS                               ║
╚════════════════════════════════════════════════════════════════════════════╝

DOCUMENTATION:
  QUICKSTART.md           5-minute setup guide (READ THIS FIRST!)
  SETUP_SUMMARY.md        Overview and checklist
  README.md               Complete documentation (2000+ lines)
  Makefile                50+ useful commands

DOCKER CONFIGURATION:
  docker-compose.yaml     Main orchestration (defines all services)
  dockerfiles/rails.dockerfile    Rails container definition
  dockerfiles/nginx.dockerfile    Nginx container definition

APPLICATION:
  src/                    Your Rails application (edit directly)
  src/Gemfile             Ruby dependencies
  src/Gemfile.lock        Locked gem versions

CONFIGURATION:
  env/postgres.env        PostgreSQL environment variables
  env/rails.env           Rails environment variables
  env/.env.production.example    Production template
  nginx/nginx.conf        Nginx configuration
  nginx/ssl/              SSL certificates directory

SCRIPTS:
  scripts/setup.sh        Automated setup (bash scripts/setup.sh)
  scripts/quick.sh        Daily command shortcuts
  scripts/cleanup.sh      Docker cleanup utilities

OTHERS:
  .gitignore              Git ignore patterns
  backups/                Database backups (auto-created)


╔════════════════════════════════════════════════════════════════════════════╗
║                          IMPORTANT REMINDERS                               ║
╚════════════════════════════════════════════════════════════════════════════╝

⚠️  CHANGE PASSWORDS
    Before first run, update:
    env/postgres.env       (POSTGRES_PASSWORD)
    env/rails.env          (DATABASE credentials)

⚠️  GENERATE SECRETS
    Run: docker-compose run --rm rails_cli secret
    Update: env/rails.env (SECRET_KEY_BASE)

✅  DATA PERSISTENCE
    Database: postgres_data volume (survives container deletion)
    Redis: redis_data volume (survives container deletion)
    Code: ./src directory (always editable)

✅  SAFE CLEANUP
    docker-compose stop    (stops, keeps data)
    docker-compose down    (removes containers, keeps data)
    docker-compose down -v ⚠️  (removes containers AND data)

✅  VOLUMES ARE OUTSIDE
    Edit code directly in ./src/
    Changes reflect immediately
    No need to rebuild containers for code changes

🚀  QUICK ACCESS
    make help              See all commands
    make start             Start services
    make logs              Watch logs


╔════════════════════════════════════════════════════════════════════════════╗
║                          GETTING STARTED NOW                               ║
╚════════════════════════════════════════════════════════════════════════════╝

Option 1: QUICKEST (Recommended)
─────────────────────────────────
  1. bash scripts/setup.sh        ← Run this!
  2. Wait for completion
  3. Visit http://localhost:3000

Option 2: Using Make
──────────────────
  1. make setup
  2. make start
  3. make logs
  4. Visit http://localhost:3000

Option 3: Manual Setup
────────────────────
  1. docker-compose build
  2. docker-compose run --rm rails_cli db:create
  3. docker-compose up -d
  4. Visit http://localhost:3000

Option 4: Skip Everything
─────────────────────────
  1. Read QUICKSTART.md
  2. Read SETUP_SUMMARY.md
  3. Read README.md


═══════════════════════════════════════════════════════════════════════════════
Ready to start? Run: make setup
Need help? Run: make help
Want details? Read: QUICKSTART.md
═══════════════════════════════════════════════════════════════════════════════

EOF

echo ""
echo "This structure guide is also available at: scripts/README.sh"
echo ""
