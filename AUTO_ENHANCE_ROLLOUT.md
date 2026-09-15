# Immich Auto-Enhance Rollout (Local)

This setup uses a local source build with a compose override, so rollback is one command away.

## Enable auto-enhance build

```bash
cd /Users/mikeserver/immich-app
docker compose -f docker-compose.yml -f docker-compose.auto-enhance.yml up -d --build immich-server
```

## Regenerate derivatives (optional, recommended)

In the Immich UI:
- Administration -> Jobs
- Run **Thumbnail Generation** (all)

This backfills enhanced derivatives for existing assets.

## Rollback to official image

```bash
cd /Users/mikeserver/immich-app
docker compose -f docker-compose.yml up -d immich-server
```

If you also want to remove the local built image:

```bash
docker image rm immich-server:auto-enhance
```

## Runtime toggle behavior

- Default behavior serves enhanced preview/thumbnail when available.
- Append `unenhanced=true` to thumbnail requests to force standard derivatives.
- In web settings, "Use standard previews and thumbnails" maps to this request parameter.
