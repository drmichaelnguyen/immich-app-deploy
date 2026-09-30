#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
IMMICH_APP="${IMMICH_APP:-$SCRIPT_DIR}"
IMMICH_SOURCE="${IMMICH_SOURCE:-${IMMICH_V300:-$(dirname "$IMMICH_APP")/immich-v300-branding}}"

if [[ ! -f "$IMMICH_SOURCE/package.json" || ! -d "$IMMICH_SOURCE/web" || ! -d "$IMMICH_SOURCE/server" ]]; then
  echo "Missing Immich source checkout at $IMMICH_SOURCE" >&2
  exit 1
fi

export PATH="/opt/homebrew/opt/node@22/bin:$PATH"

echo "Building web (Michael's Gallery editor + presets)..."
cd "$IMMICH_SOURCE"
rm -rf "$IMMICH_SOURCE/web/build" "$IMMICH_SOURCE/server/dist"
pnpm --filter @immich/sdk --filter immich-web build

echo "Building server (color adjust + edits)..."
pnpm --filter @immich/sdk --filter @immich/plugin-sdk --filter immich build

echo "Staging server dist..."
rm -rf "$IMMICH_APP/server-dist"
cp -R "$IMMICH_SOURCE/server/dist" "$IMMICH_APP/server-dist"

echo "Staging web build..."
rm -rf "$IMMICH_APP/www-build"
cp -R "$IMMICH_SOURCE/web/build" "$IMMICH_APP/www-build"

echo "Building gallery server image (custom server + web)..."
cd "$IMMICH_APP"
docker compose -f docker-compose.yml -f docker-compose.gallery.yml pull immich-machine-learning redis database
docker compose -f docker-compose.yml -f docker-compose.gallery.yml build --pull immich-server
docker compose -f docker-compose.yml -f docker-compose.gallery.yml up -d

echo "Done. Open http://localhost:2283 → open a photo → Editor → Adjust."
