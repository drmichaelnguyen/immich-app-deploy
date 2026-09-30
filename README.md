# Michael's Gallery deployment

This repository builds and runs the customized Immich server used by PhotoStorage. It is the deployment half of a two-repository system.

## Repository layout

- Source: `https://github.com/drmichaelnguyen/ImmichbyMichaelGallery`, branch `gallery-v3.2.2-custom`
- Deployment: `https://github.com/drmichaelnguyen/immich-app-deploy`, branch `main`
- Default local source checkout: sibling directory `../immich-v300-branding`
- Default local deployment checkout: this repository
- Local media and PostgreSQL data: configured only in the ignored `.env`

The source repository supplies `server/dist` and `web/build`. This repository stages those outputs, overlays them onto the matching official Immich image, and starts Docker Compose.

## Why a remote agent has incomplete context

A remote or cloud agent normally receives only the Git checkout assigned to it. It cannot automatically see:

- the companion repository;
- this Mac's ignored `.env` and secrets;
- `/Volumes/photostorage`;
- Docker Desktop, running containers, local images, or container logs;
- the PostgreSQL data volume and its applied migration ledger;
- uncommitted local fixes.

Consequently, a remote agent can review and change repository code, but it cannot truthfully validate the local deployment unless both repositories and an equivalent Docker/database environment are explicitly provided. Local fixes must be committed and pushed before a remote agent can see them.

## Build and deploy

Requirements: Node 22, pnpm, Docker Desktop, both repositories, and a local `.env` copied from `.env.example`.

```bash
git -C ../immich-v300-branding switch gallery-v3.2.2-custom
git -C ../immich-v300-branding pull --ff-only
git pull --ff-only
./build-branding.sh
```

Override checkout locations when necessary:

```bash
IMMICH_SOURCE=/path/to/source IMMICH_APP=/path/to/deployment ./build-branding.sh
```

The build script cleans generated source output before compilation, stages fresh server and web artifacts, pulls dependency images, rebuilds the custom server image, and reconciles the complete Compose stack.

Verify after deployment:

```bash
docker compose -f docker-compose.yml -f docker-compose.gallery.yml ps
curl -fsS http://127.0.0.1:2283/api/server/version
curl -fsS http://127.0.0.1:2283/api/server/ping
curl -fsS http://127.0.0.1:2283/api/featured/assets
```

## Version and migration rules

- Keep `IMMICH_VERSION` pinned to the same version as the custom source. Do not use floating `v3` with a 3.2.2 server overlay.
- `Dockerfile.gallery` deletes donor `server/dist` and `/build/www` before copying custom output. Docker `COPY` otherwise merges directories and can retain deleted migrations.
- Never insert or rename a migration before an already-applied migration without reconciling the database ledger and the migration `ORDER` file.
- On 2026-09-30, the local 99-row Kysely migration ledger was normalized to ISO timestamps derived from each numeric migration-name prefix. This was a one-time repair for mixed legacy timestamp formats; do not repeat or alter it casually.

## Upgrade fixes made on 2026-09-30

- Removed a duplicate `downloadBlob` export that broke the web build.
- Updated the custom Sharp `sharpen` call to the options-object API.
- Preserved the custom shared-link migration order and moved the unexecuted live-photo migration after it.
- Cleared donor build artifacts before applying the custom Docker overlay.
- Added the missing `Featured` API tag description required by the server build.
- Added deterministic cleaning and full-stack reconciliation to `build-branding.sh`.

Do not commit `.env`, passwords, database dumps, media, or generated `server-dist`/`www-build` directories.
