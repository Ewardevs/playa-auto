#!/usr/bin/env bash
# Instalación de playa-autos en el server contabo (requiere sudo).
# Patrón idéntico a apiV2 / asdf: systemd + puma + nginx + certbot.
set -euo pipefail

APP=playa
APP_DIR=/var/www/playa
PORT=3002
DOMAIN=playa-auto.ewardevs.site
ENV_FILE="$APP_DIR/shared/playa.env"

echo "== [1/4] Paquetes (ImageMagick para variantes de imagen) =="
apt-get update -y
apt-get install -y imagemagick

echo "== [2/4] Servicio systemd =="
cat > /etc/systemd/system/$APP.service <<UNIT
[Unit]
Description=playa-autos (Rails 8 / Puma) - demo automotora
After=network-online.target docker.service
Wants=network-online.target
Requires=docker.service

[Service]
Type=simple
User=ewardevs
Group=ewardevs
WorkingDirectory=$APP_DIR
EnvironmentFile=$ENV_FILE
Environment="PATH=/home/ewardevs/.rbenv/shims:/home/ewardevs/.rbenv/bin:/usr/local/bin:/usr/bin:/bin"
ExecStart=/home/ewardevs/.rbenv/shims/bundle exec puma -C config/puma.rb -b tcp://127.0.0.1:$PORT
Restart=always
RestartSec=5
StandardOutput=journal
StandardError=journal
SyslogIdentifier=$APP

[Install]
WantedBy=multi-user.target
UNIT
systemctl daemon-reload
systemctl enable --now $APP
echo "servicio activo: $(systemctl is-active $APP)"

echo "== [3/4] nginx =="
cat > /etc/nginx/conf.d/$APP.conf <<NGINX
upstream $APP {
    server 127.0.0.1:$PORT;
    keepalive 16;
}

server {
    server_name $DOMAIN;

    access_log /var/log/nginx/$APP.access.log;
    error_log  /var/log/nginx/$APP.error.log;

    client_max_body_size 100M;

    root $APP_DIR/public;

    location /assets/ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        access_log off;
    }

    location / {
        try_files \$uri @app;
    }

    location @app {
        proxy_pass http://$APP;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
        proxy_set_header Host              \$host;
        proxy_set_header X-Real-IP         \$remote_addr;
        proxy_set_header X-Forwarded-For   \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_read_timeout 60s;
    }

    gzip on;
    gzip_types text/plain text/css application/javascript application/json image/svg+xml;
    gzip_min_length 1024;

    listen 80;
    listen [::]:80;
}
NGINX
nginx -t
systemctl reload nginx
echo "nginx recargado"

echo "== [4/4] Certificado TLS =="
certbot --nginx -d $DOMAIN --redirect --agree-tos -n --register-unsafely-without-email

echo "=== ¡Listo! ==="
