# preview_gate

A small, branded **preview environment gate** for Phoenix applications.

Use this to password-protect preview deployments (Fly.io, Railway, AWS, etc.) with a simple login page that sets a session cookie.

## Why
- Prevent accidental exposure of preview environments
- Provide a consistent, branded experience across apps
- Keep the solution portable (no provider-specific auth)

## Configuration
Set these environment variables in your preview environment:

- `PREVIEW_GATE_ENABLED=true`
- `PREVIEW_GATE_PASSWORD=...`
- `PREVIEW_GATE_PR=123` (optional)
- `PREVIEW_GATE_APP_NAME=...` (optional)
- `PREVIEW_GATE_BUILD_ID=...` (optional)

## Usage (high level)
1) Add the dependency to your Phoenix app.
2) Add the Plug to your browser pipeline.
3) Add `/__preview/login` routes.
4) Render the included login page (or your own).

## License
MIT
