FROM python:3.11-slim

# ── System packages ───────────────────────────────────────────────────────────
# mariadb-server    : database engine inside container
# curl              : healthcheck and download
# nodejs + npm      : Vite React frontend build
# inotify-tools     : CSV watcher fallback (watchdog preferred)
# supervisor        : process manager for multiple services in one container
RUN apt-get update && apt-get install -y \
    mariadb-server \
    curl \
    nodejs \
    npm \
    inotify-tools \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# ── Python dependencies ───────────────────────────────────────────────────────
WORKDIR /app
COPY requirements.txt /app/requirements.txt

RUN pip install --no-cache-dir -r requirements.txt

# ── Frontend scaffold ─────────────────────────────────────────────────────────
# PINPOINTED CHANGE: Do NOT copy node_modules from host (never exists on host)
# Do NOT run npm install here — it runs in start.sh against named volume mount
# Only copy source files that you author and maintain
COPY frontend/index.html      /app/frontend/index.html
COPY frontend/package.json    /app/frontend/package.json
COPY frontend/tsconfig.json   /app/frontend/tsconfig.json
COPY frontend/vite.config.ts  /app/frontend/vite.config.ts
COPY frontend/src/            /app/frontend/src/

# Must exist before MariaDB ever starts
# chown root ensures MariaDB running as root can write to it
RUN mkdir -p /run/mysqld && chown root:root /run/mysqld && chmod 755 /run/mysqld

# node_modules directory is created here as empty mountpoint
# Named volume ecomm_node_modules will be mounted here at runtime
# This prevents the volume mount from being blocked by a missing directory
RUN mkdir -p /app/frontend/node_modules

#COPY suXxxxxXxx97.json /app/suXxxxxXxx97.json
COPY gcp_service_account.json /app/gcp_service_account.json

# ── Frontend build ────────────────────────────────────────────────────────────
# Copy frontend source and build static files
# Built once at image build time — served by uvicorn StaticFiles mount
COPY frontend/ /app/frontend/
WORKDIR /app/frontend
RUN npm install && npm run build

RUN cd /app/frontend && npm install express http-proxy-middleware --save

# ── Backend source ────────────────────────────────────────────────────────────
WORKDIR /app
COPY backend/ /app/backend/

# ── MariaDB init script ───────────────────────────────────────────────────────
# Copied into container — run manually via podman exec after first start
COPY schema.sql /app/schema.sql

# ── Supervisor config ─────────────────────────────────────────────────────────
# Manages MariaDB + FastAPI + CSV watcher as one container process tree
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# ── Startup script ────────────────────────────────────────────────────────────
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

# ── Drop directory for CSV watcher ───────────────────────────────────────────
RUN mkdir -p /app/drop_here /app/finished

# Expose FastAPI and Vite preview ports
EXPOSE 8000 3000

CMD ["/app/start.sh"]
