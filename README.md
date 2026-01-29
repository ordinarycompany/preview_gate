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

## Usage

### 1) Add the dependency

```elixir
{:ordinary_preview_gate, github: "ordinarycompany/preview_gate", tag: "v0.1.1"}
```

### 2) Add the Plug to your browser pipeline

```elixir
pipeline :browser do
  plug :accepts, ["html"]
  plug :fetch_session
  plug :fetch_live_flash
  plug OrdinaryPreviewGate.Plug
  plug :put_root_layout, html: {MyAppWeb.Layouts, :root}
  plug :protect_from_forgery
  plug :put_secure_browser_headers
end
```

### 3) Provide a minimal preview layout

Create `MyAppWeb.Layouts.preview_gate.html.heex` with a minimal white page layout.

### 4) Add a preview pipeline (recommended)

```elixir
pipeline :preview do
  plug :accepts, ["html"]
  plug :fetch_session
  plug :fetch_live_flash
  plug :put_root_layout, html: {MyAppWeb.Layouts, :preview_gate}
  plug :protect_from_forgery
  plug :put_secure_browser_headers
end
```

### 5) Mount routes via macro

```elixir
import OrdinaryPreviewGate.Router
preview_gate_routes(MyAppWeb)
```

By default this creates:
- `GET /__preview/login`
- `POST /__preview/login`
- `DELETE /__preview/logout`

You can customize the mount path:

```elixir
preview_gate_routes(MyAppWeb, path: "/_preview")
```

## License
MIT
