#!/bin/bash
# rebuild.sh — Builds and runs the all-in-one podman container.
# Contains: MariaDB + FastAPI + Vite React + CSV watcher
# All inside one container — zero residue on host Ubuntu 24.
# MariaDB data persists in named volume across restarts.
# podman volume rm ecomm_mariadb_data  — wipes DB data cleanly.
set -euo pipefail

PROJ_DIR="/home/ftpadmin/mypoc_ecommerce"
CONTAINER_NAME="ecomm_watcher"
IMAGE_NAME="mypoc_ecommerce"
VOLUME_NAME="ecomm_mariadb_data"
# PINPOINTED ADDITION: named volume for node_modules
# Persists across rebuilds — npm ci skips unchanged packages on reuse
VOLUME_NODEMODULES="ecomm_node_modules"
# Source .env to load all variables
source "$PROJ_DIR/.env"

# Declare explicitly at top for consistency and readability
# Value comes from .env — real filename never hardcoded here
GCP_JSON_PATH="${GCP_JSON_PATH:-}"

# ADD this check before podman run
# note later if this will be removed as it may not be necessary
#if [ ! -f "$PROJ_DIR/subxXxj-xXx.json" ]; then
#    echo "❌ Service account JSON not found in $PROJ_DIR"
#    exit 1
#fi

# ── Host-side directories ─────────────────────────────────────────────────────
# Only logs and CSV drop/finished dirs live on host
# Everything else (MariaDB, Python, Node) is inside container
mkdir -p "$PROJ_DIR/logs"
mkdir -p /home/ftpadmin/Usenet_Factory/2_Processing
mkdir -p /home/ftpadmin/Usenet_Factory/1_ProcessedDrops
chmod 777 "$PROJ_DIR/logs"

# GCP_JSON_PATH lives in .env — never hardcoded here
# .env is gitignored — collaborators never see the real filename

if [ -z "$GCP_JSON_PATH" ]; then
    echo "❌ GCP_JSON_PATH is not set in .env"
    echo "   Add this line to $PROJ_DIR/.env:"
    echo "   GCP_JSON_PATH=/home/ftpadmin/mypoc_ecommerce/yourProject-577xxxxxxx.json"
    exit 1
fi

if [ ! -f "$GCP_JSON_PATH" ]; then
    echo "❌ Service account JSON not found: $GCP_JSON_PATH"
    echo "   Verify the file exists:"
    echo "   ls -la $GCP_JSON_PATH"
    exit 1
fi

cp "$GCP_JSON_PATH" "$PROJ_DIR/gcp_service_account.json"

# No residue of the copy left after build completes
trap 'rm -f "$PROJ_DIR/gcp_service_account.json"' EXIT


# ── Named volume for MariaDB data ─────────────────────────────────────────────
# Survives container stop/start but NOT podman volume rm
# To fully wipe: podman volume rm ecomm_mariadb_data
if ! podman volume exists "$VOLUME_NAME" 2>/dev/null; then
    echo "📦 Creating named volume: $VOLUME_NAME"
    podman volume create "$VOLUME_NAME"
fi

# PINPOINTED ADDITION: node_modules named volume
# Created once — reused across all subsequent rebuilds
# Wipe with: podman volume rm ecomm_node_modules
if ! podman volume exists "$VOLUME_NODEMODULES" 2>/dev/null; then
    echo "📦 Creating named volume: $VOLUME_NODEMODULES"
    podman volume create "$VOLUME_NODEMODULES"
fi

# ── Build fresh image ─────────────────────────────────────────────────────────
echo "🔨 Building image: $IMAGE_NAME..."
podman build -t "$IMAGE_NAME" "$PROJ_DIR"

# ── Run container ─────────────────────────────────────────────────────────────
echo "🚀 Starting container: $CONTAINER_NAME..."
podman run -d \
    --name "$CONTAINER_NAME" \
    --replace \
    --restart unless-stopped \
    \
    `# Expose FastAPI and Vite React to host browser` \
    -p 8000:8000 \
    -p 3001:3000 \
    \
    `# MariaDB data volume — persists across restarts, clean on volume rm` \
    -v "$VOLUME_NAME":/var/lib/mysql:Z \
    \
    `# PINPOINTED ADDITION: node_modules volume` \
    `# Mounted at exact path npm expects inside container` \
    `# Host frontend/node_modules directory never created` \
    -v "$VOLUME_NODEMODULES":/app/frontend/node_modules:Z \
    \
    `# Frontend source — live mount so src changes reflect on rebuild` \
    -v "$PROJ_DIR/frontend/src":/app/frontend/src:Z \
    -v "$PROJ_DIR/frontend/index.html":/app/frontend/index.html:Z \
    -v "$PROJ_DIR/frontend/package.json":/app/frontend/package.json:Z \
    -v "$PROJ_DIR/frontend/tsconfig.json":/app/frontend/tsconfig.json:Z \
    -v "$PROJ_DIR/frontend/vite.config.ts":/app/frontend/vite.config.ts:Z \
    \
    `# CSV drop directory — host drops files here, watcher picks them up` \
    -v /home/ftpadmin/Usenet_Factory/2_Processing:/app/drop_here:Z \
    \
    `# Finished/processed output directory on host` \
    -v /home/ftpadmin/Usenet_Factory/1_ProcessedDrops:/app/finished:Z \
    \
    `# Logs directory on host for easy tail/grep without exec` \
    -v "$PROJ_DIR/logs":/app/logs:Z \
    \
    `# Live-mount backend for development iteration without rebuild` \
    -v "$PROJ_DIR/backend":/app/backend:Z \
    \
    `# Environment variables` \
    --env-file "$PROJ_DIR/.env" \
    \
    "$IMAGE_NAME"

echo ""
echo "✅ Container started: $CONTAINER_NAME"
echo ""
echo "📡 FastAPI backend:   http://localhost:8000"
echo "🌐 React frontend:    http://localhost:3000"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "   Test: anything_products.csv or anything_shippers.csv"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
