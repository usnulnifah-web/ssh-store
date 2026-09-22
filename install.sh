#!/usr/bin/env bash
set -Eeuo pipefail

if [[ "${EUID}" -ne 0 ]]; then echo "Jalankan sebagai root: sudo bash install.sh" >&2; exit 1; fi

DOMAIN="${DOMAIN:-_}"
APP_DIR="${APP_DIR:-/var/www/ssh-store}"
API_PORT="${API_PORT:-8788}"
AGENT_URL="${AGENT_URL:-http://127.0.0.1:8787}"
AGENT_SHARED_SECRET="${AGENT_SHARED_SECRET:-}"

usage(){
  cat <<'HELP'
SSH Store Website Installer

Penggunaan:
  sudo DOMAIN=www.domain-anda.com bash install.sh

Environment:
  DOMAIN                 domain website, default _
  APP_DIR                direktori aplikasi, default /var/www/ssh-store
  API_PORT               port API internal, default 8788
  AGENT_URL              URL VPS Agent, default http://127.0.0.1:8787
  AGENT_SHARED_SECRET    secret HMAC yang sama dengan VPS Agent
HELP
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --domain) DOMAIN="${2:?domain belum diisi}"; shift 2;;
    --app-dir) APP_DIR="${2:?direktori belum diisi}"; shift 2;;
    --api-port) API_PORT="${2:?port belum diisi}"; shift 2;;
    --agent-url) AGENT_URL="${2:?URL agent belum diisi}"; shift 2;;
    --secret) AGENT_SHARED_SECRET="${2:?secret belum diisi}"; shift 2;;
    --help) usage; exit 0;;
    *) echo "Opsi tidak dikenal: $1" >&2; usage; exit 1;;
  esac
done

[[ "$API_PORT" =~ ^[0-9]+$ ]] || { echo "API_PORT tidak valid" >&2; exit 1; }
if [[ -z "$AGENT_SHARED_SECRET" && -r /etc/ssh-store-agent/agent.env ]]; then
  AGENT_SHARED_SECRET="$(sed -n 's/^AGENT_SHARED_SECRET=//p' /etc/ssh-store-agent/agent.env | head -n 1)"
fi
if [[ -z "$AGENT_SHARED_SECRET" ]]; then
  AGENT_SHARED_SECRET="$(openssl rand -hex 32)"
  echo "PERINGATAN: secret baru dibuat. Harus sama dengan secret pada VPS Agent." >&2
fi

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y ca-certificates curl git nginx openssl
if ! command -v node >/dev/null 2>&1 || [[ "$(node -p 'process.versions.node.split(".")[0]')" -lt 20 ]]; then
  curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
  apt-get install -y nodejs
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
install -d -m 0755 "$APP_DIR"
cp -a "$SCRIPT_DIR"/. "$APP_DIR"/
rm -rf "$APP_DIR/.git" "$APP_DIR/backend/node_modules"
install -d -m 0750 /etc/ssh-store
cat > /etc/ssh-store/website.env <<EOF
NODE_ENV=production
API_PORT=${API_PORT}
AGENT_URL=${AGENT_URL}
AGENT_SHARED_SECRET=${AGENT_SHARED_SECRET}
AGENT_PORT=8787
AGENT_DATA_FILE=/var/lib/ssh-store-agent/accounts.json
AGENT_MAX_SKEW_SECONDS=60
EOF
chmod 0600 /etc/ssh-store/website.env

cd "$APP_DIR/backend"
npm install --omit=dev --no-audit --no-fund

cat > /etc/systemd/system/ssh-store-api.service <<EOF
[Unit]
Description=SSH Store Website API
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
WorkingDirectory=${APP_DIR}/backend
EnvironmentFile=/etc/ssh-store/website.env
ExecStart=$(command -v node) src/api.js
Restart=always
RestartSec=5
User=www-data
Group=www-data
NoNewPrivileges=true
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF
chown -R root:root "$APP_DIR"
chown -R www-data:www-data "$APP_DIR/backend/node_modules"

cat > /etc/nginx/sites-available/ssh-store <<EOF
server {
    listen 80;
    listen [::]:80;
    server_name ${DOMAIN};
    root ${APP_DIR};
    index index.html;

    location /v1/ {
        proxy_pass http://127.0.0.1:${API_PORT};
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    location /health {
        proxy_pass http://127.0.0.1:${API_PORT};
    }

    location = /admin {
        try_files /admin.html =404;
    }

    location = /member {
        try_files /member.html =404;
    }

    location / {
        try_files \$uri \$uri/ /index.html;
    }
}
EOF
ln -sfn /etc/nginx/sites-available/ssh-store /etc/nginx/sites-enabled/ssh-store
rm -f /etc/nginx/sites-enabled/default
nginx -t
systemctl daemon-reload
systemctl enable --now ssh-store-api
systemctl enable --now nginx
curl -fsS --max-time 5 "http://127.0.0.1:${API_PORT}/health"
echo
echo "Website terpasang di: http://${DOMAIN}"
echo "Panel admin: http://${DOMAIN}/admin"
echo "Direktori aplikasi: ${APP_DIR}"
echo "API service: systemctl status ssh-store-api"
echo "HTTPS dapat diaktifkan setelah DNS domain mengarah ke server dengan certbot."
