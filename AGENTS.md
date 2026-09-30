# Agent instructions

Read `README.md` before changing or deploying this project.

This is only the deployment half of Michael's Gallery. The companion source repository is `drmichaelnguyen/ImmichbyMichaelGallery` on `gallery-v3.2.2-custom`. A remote agent that has only this checkout does not have the source, ignored `.env`, Docker daemon, database, or `/Volumes/photostorage`; state those limitations instead of guessing about local runtime state.

Keep the donor image version aligned with the source version. Never replace the custom image with stock Immich, never commit `.env`, and never modify photo or PostgreSQL storage as part of a code-only task. Use `./build-branding.sh` for local builds and verify the version, ping, container health, and featured endpoint after deployment.

Do not declare a web deployment successful from Docker health or `curl` alone. Load `https://gallery.drmichael.me/` and `/auth/login` in a clean browser context while recording page exceptions, error-level console messages, failed requests, and HTTP errors. All four error collections must be empty. A remote agent without both repositories and the local runtime must commit and push its source fix, identify its unperformed checks, and hand the commit back to the local deployment owner.
