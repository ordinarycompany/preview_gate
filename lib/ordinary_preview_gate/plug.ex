defmodule OrdinaryPreviewGate.Plug do
  @moduledoc """
  Branded preview environment gate for Phoenix apps.

  When enabled, blocks access until a visitor enters the shared preview password.

  ## Configuration

  Enable with env vars (recommended for preview deploys):

    PREVIEW_GATE_ENABLED=true
    PREVIEW_GATE_PASSWORD=...
    PREVIEW_GATE_PR=123

  Optional display vars:

    PREVIEW_GATE_APP_NAME=... (or app derives from host config)
    PREVIEW_GATE_BUILD_ID=... (or host passes build_id via assigns)

  Host apps should add routes and a controller action to render the login page.
  This repo provides a minimal layout + HEEx template for that page.

  This is intentionally simple and portable (Fly/AWS/etc).
  """

  import Plug.Conn

  @session_key :preview_gate_ok

  def init(opts), do: opts

  def call(conn, _opts) do
    if enabled?() do
      if allowlisted_path?(conn.request_path) do
        conn
      else
        case get_session(conn, @session_key) do
          true ->
            conn

          _ ->
            return_to = current_path_with_query(conn)

            conn
            |> put_session(:preview_gate_return_to, return_to)
            |> Phoenix.Controller.redirect(to: "/__preview/login")
            |> halt()
        end
      end
    else
      conn
    end
  end

  defp enabled? do
    System.get_env("PREVIEW_GATE_ENABLED") in ["1", "true", "TRUE", "yes", "YES"]
  end

  defp allowlisted_path?(path) do
    # Login/logout and assets/health endpoints should remain reachable.
    Enum.any?([
      "/__preview/login",
      "/__preview/login/",
      "/__preview/logout",
      "/healthz",
      "/assets/"
    ], fn item ->
      if String.ends_with?(item, "/") do
        String.starts_with?(path, item)
      else
        path == item
      end
    end)
  end

  defp current_path_with_query(conn) do
    case conn.query_string do
      "" -> conn.request_path
      qs -> conn.request_path <> "?" <> qs
    end
  end
end
