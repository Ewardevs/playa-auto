#!/usr/bin/env bash
# Deploy de una versión nueva: pull + migraciones + precompile + restart.
# Uso (como usuario ewardevs, NO con sudo):
#   bash /var/www/playa/deploy/deploy.sh
# El único paso con sudo es el restart, y lo pide el propio script.
set -euo pipefail

cd /var/www/playa

export PATH="$HOME/.rbenv/shims:$HOME/.rbenv/bin:/usr/local/bin:/usr/bin:/bin"
set -a
source shared/playa.env
set +a

echo "== [1/4] pull =="
git pull --ff-only

echo "== [2/4] migraciones =="
RAILS_ENV=production bin/rails db:migrate

echo "== [3/4] precompile =="
RAILS_ENV=production bin/rails assets:precompile

echo "== [4/4] restart =="
sudo systemctl restart playa
sleep 5
systemctl is-active playa

echo "=== deploy OK ==="
