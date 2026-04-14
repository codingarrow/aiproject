#!/bin/bash
# start.sh — Container entrypoint.
# 1. Initializes MariaDB data directory if first run
# 2. Starts MariaDB and waits until ready
# 3. Creates database and user if not exists
# 4. Hands off to supervisord which manages all processes

set -euo pipefail

mkdir -p /app/logs

echo "🔧 Checking MariaDB data directory..."

echo "🔧 Creating MariaDB socket directory..."
mkdir -p /run/mysqld
chown root:root /run/mysqld
chmod 755 /run/mysqld

# Initialize MariaDB data directory on first run only
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "📦 First run — initializing MariaDB data directory..."
    mysql_install_db \
        --user=root \
        --datadir=/var/lib/mysql \
        --skip-test-db \
        > /app/logs/mysql_init.log 2>&1
    echo "✅ MariaDB data directory initialized."
fi

echo "🚀 Starting MariaDB..."
#mysqld_safe --datadir=/var/lib/mysql &
/usr/sbin/mysqld \
    --user=root \
    --datadir=/var/lib/mysql \
    --skip-networking=0 \
    --bind-address=127.0.0.1 \
    --console &
MARIADB_PID=$!

# Wait until MariaDB is accepting connections
echo "⏳ Waiting for MariaDB to be ready..."
MAX_TRIES=30
COUNT=0
until mysqladmin ping --silent 2>/dev/null; do
    COUNT=$((COUNT + 1))
    if [ $COUNT -ge $MAX_TRIES ]; then
        echo "❌ MariaDB did not start in time. Check /app/logs/mariadb_err.log"
        exit 1
    fi
    sleep 1
done
echo "✅ MariaDB is ready."

# Create database and user on first run
echo "🔧 Ensuring database and user exist..."
mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS mypoc_ecommerce
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

-- Create app user with password from env or default
CREATE USER IF NOT EXISTS 'ecomm_user'@'localhost'
    IDENTIFIED BY '${DB_PASSWORD:-ec0mx_!xXs}';

GRANT ALL PRIVILEGES ON mypoc_ecommerce.*
    TO 'ecomm_user'@'localhost';

FLUSH PRIVILEGES;
EOF

# Load schema.sql only on first run — guard prevents re-running on restarts
# Checks for existence of 'orders' table as a reliable first-run sentinel
# If table exists = schema already loaded = skip safely
TABLE_CHECK=$(mysql -u ecomm_user -p"${DB_PASSWORD:-ec0mx_!xXs}" \
    mypoc_ecommerce \
    -sse "SELECT COUNT(*) FROM information_schema.tables \
          WHERE table_schema='mypoc_ecommerce' \
          AND table_name='orders';" 2>/dev/null || echo "0")

if [ "$TABLE_CHECK" = "0" ]; then
    echo "📦 First run — loading schema.sql into MariaDB..."
    mysql -u ecomm_user -p"${DB_PASSWORD:-ec0mx_!xXs}" \
        mypoc_ecommerce < /app/schema.sql
    echo "✅ Schema and seed data loaded successfully."
else
    echo "✅ Schema already loaded — skipping."
fi

echo "✅ Database and user ready."


# Kill the background MariaDB — supervisord will manage it from here
kill $MARIADB_PID 2>/dev/null || true
sleep 2

#podman logs ecomm_watcher 2>&1 | tail -50

# ── PINPOINTED ADDITION: npm install inside container against named volume ────
# node_modules lives in named volume ecomm_node_modules mounted at
# /app/frontend/node_modules — never on host filesystem
# npm ci is used instead of npm install:
#   • ci = clean install, respects package-lock.json exactly
#   • faster than npm install on subsequent runs (cache-aware)
#   • deterministic — same packages every time
#   • if node_modules volume already populated, npm ci skips unchanged pkgs
echo "📦 Checking frontend node_modules..."
cd /app/frontend

#npm install --package-lock-only 
# Generate package-lock.json only if it does not exist
# --package-lock-only writes lock file without creating node_modules
# Runs once ever — subsequent starts skip this entirely
if [ ! -f "package-lock.json" ]; then
    echo "📦 Generating package-lock.json (first run only)..."
    npm install --package-lock-only
    echo "✅ package-lock.json generated."
fi

if [ ! -f "node_modules/.package-lock.json" ]; then
    echo "📦 First run — installing npm packages into volume..."
    npm ci
    echo "✅ npm packages installed."
else
    #echo "✅ node_modules already populated — skipping npm ci."
    echo "✅ node_modules exists — checking for new packages..."
    npm install --prefer-offline
    echo "✅ npm packages verified."
fi

# Build frontend static files into /app/frontend/dist inside container
# dist/ is rebuilt on every container start to pick up any src/ changes
echo "🔨 Building Vite React frontend..."
npm run build
echo "✅ Frontend built."

cd /app
echo "🤖 Handing off to supervisord..."
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
