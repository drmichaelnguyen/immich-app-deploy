#!/usr/bin/env bash
set -euo pipefail

# Purge Cloudflare cache after deploying a new Immich web build.
# Old hashed JS files are cached as immutable for up to 1 year; without a purge,
# browsers can load mismatched bundles and crash with:
#   Cannot read properties of undefined (reading 'env')
#
# Usage:
#   export CLOUDFLARE_API_TOKEN="..."
#   export CLOUDFLARE_ZONE_ID="..."   # zone for drmichael.me
#   ./purge-cloudflare-cache.sh
#
# Find zone ID: Cloudflare dashboard → drmichael.me → Overview (right sidebar)

ZONE_ID="${CLOUDFLARE_ZONE_ID:-}"
TOKEN="${CLOUDFLARE_API_TOKEN:-}"
HOST="${CLOUDFLARE_PURGE_HOST:-gallery.drmichael.me}"

if [[ -z "$TOKEN" || -z "$ZONE_ID" ]]; then
  echo "Set CLOUDFLARE_API_TOKEN and CLOUDFLARE_ZONE_ID, or purge manually:" >&2
  echo "  Cloudflare → drmichael.me → Caching → Configuration → Purge Everything" >&2
  exit 1
fi

echo "Purging Cloudflare cache for zone $ZONE_ID (host: $HOST)..."
curl -fsS -X POST "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/purge_cache" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  --data "{\"hosts\":[\"${HOST}\"]}" \
  | python3 -c "import sys,json; r=json.load(sys.stdin); print('OK' if r.get('success') else r); sys.exit(0 if r.get('success') else 1)"

echo "Done. Hard-refresh https://${HOST}/ (Cmd+Shift+R)."
