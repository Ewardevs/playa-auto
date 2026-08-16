#!/usr/bin/env bash
# Deploy de una versión nueva de playa-autos (requiere sudo al final).
# Uso: sudo bash deploy/deploy.sh
set -euo pipefail

APP_DIR=/var/www/playa
cd "$APP_DIR"

export PATH="$HOME/.rbenv/shims:$HOME/.rbenv/bin:/usr/local/bin:/usr/bin:/bin"
set -a
source shared/playa.env
set +a

echo "== pull =="
git pull --ff-only

echo "== bundle =="
bundle install --quiet

echo "== DB (migraciones) =="
RAILS_ENV=production bin/rails db:prepare

echo "== schemas secundarios (solo si faltan) =="
for db in queue cache cable; do
  table="solid_queue_jobs"; [ "$db" = "cache" ] && table="solid_cache_entries"
  [ "$db" = "cable" ] && table="solid_cable_messages"
  ok=$(docker exec pg16 psql -U playa_autos -d "playa_autos_production_$db" -tAc "SELECT to_regclass('public.$table') IS NOT NULL")
  if [ "$ok" != "t" ]; then
    echo "  cargando schema:$db"
    DISABLE_DATABASE_ENVIRONMENT_CHECK=1 SCHEMA_FORMAT=ruby RAILS_ENV=production bin/rails "db:schema:load:$db"
  fi
done

echo "== assets =="
RAILS_ENV=production bin/rails assets:precompile

echo "== restart =="
sudo systemctl restart playa
sleep 5
systemctl is-active playa

echo "=== deploy OK ==="
