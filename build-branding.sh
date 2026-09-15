#!/usr/bin/env bash
set -euo pipefail

IMMICH_V300="${IMMICH_V300:-/Users/mikeserver/immich-v300-branding}"
IMMICH_APP="${IMMICH_APP:-/Users/mikeserver/immich-app}"

if [[ ! -d "$IMMICH_V300/web" ]]; then
  echo "Missing v3.0.0 worktree at $IMMICH_V300" >&2
  exit 1
fi

export PATH="/opt/homebrew/opt/node@22/bin:$PATH"

echo "Building web (Michael's Gallery editor + presets)..."
cd "$IMMICH_V300"
pnpm --filter @immich/sdk --filter immich-web build

echo "Building server (color adjust + edits)..."
pnpm --filter @immich/sdk --filter @immich/plugin-sdk --filter immich build

echo "Staging server dist..."
rm -rf "$IMMICH_APP/server-dist"
cp -R "$IMMICH_V300/server/dist" "$IMMICH_APP/server-dist"

echo "Staging web build..."
rm -rf "$IMMICH_APP/www-build"
cp -R "$IMMICH_V300/web/build" "$IMMICH_APP/www-build"

echo "Building gallery server image (custom server + web)..."
cd "$IMMICH_APP"
docker compose -f docker-compose.yml -f docker-compose.gallery.yml build immich-server
docker compose -f docker-compose.yml -f docker-compose.gallery.yml up -d immich-server

echo "Done. Open http://localhost:2283 → open a photo → Editor → Adjust."
