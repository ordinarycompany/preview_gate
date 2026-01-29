defmodule OrdinaryPreviewGate.Plug do
  @moduledoc """
  Branded preview environment gate for Phoenix apps.

  When enabled, blocks access until a visitor enters the shared preview password.

  ## Configuration (env)

  - `PREVIEW_GATE_ENABLED=true|false`
  - `PREVIEW_GATE_PASSWORD=...`
  - `PREVIEW_GATE_LOGIN_PATH=/__preview/login` (optional)
  - `PREVIEW_GATE_LOGOUT_PATH=/__preview/logout` (optional)

  ## Notes

  This Plug requires the host pipeline to include `plug :fetch_session`.
  """

  import Plug.Conn

  @session_key :preview_gate_ok

  def init(opts), do: opts

  def call(conn, opts) do
    if enabled?() do
      login_path =
        Keyword.get(opts, :login_path, env("PREVIEW_GATE_LOGIN_PATH", "/__preview/login"))

      logout_path =
        Keyword.get(opts, :logout_path, env("PREVIEW_GATE_LOGOUT_PATH", "/__preview/logout"))

      if allowlisted_path?(conn.request_path, login_path, logout_path) do
        conn
      else
        return_to = current_path_with_query(conn)

        case safe_get_session(conn, @session_key) do
          true ->
            conn

          _ ->
            conn
            |> safe_put_session(:preview_gate_return_to, return_to)
            |> Phoenix.Controller.redirect(to: login_path)
            |> halt()
        end
      end
    else
      conn
    end
  end

  defp enabled? do
    env("PREVIEW_GATE_ENABLED", "false") in ["1", "true", "TRUE", "yes", "YES"]
  end

  defp env(key, default) do
    case System.get_env(key) do
      nil -> default
      "" -> default
      v -> v
    end
  end

  defp allowlisted_path?(path, login_path, logout_path) do
    Enum.any?(
      [
        login_path,
        ensure_trailing_slash(login_path),
        logout_path,
        "/healthz",
        "/assets/"
      ],
      fn item ->
        if String.ends_with?(item, "/") do
          String.starts_with?(path, item)
        else
          path == item
        end
      end
    )
  end

  defp ensure_trailing_slash(path) do
    if String.ends_with?(path, "/"), do: path, else: path <> "/"
  end

  defp current_path_with_query(conn) do
    case conn.query_string do
      "" -> conn.request_path
      qs -> conn.request_path <> "?" <> qs
    end
  end

  defp safe_get_session(conn, key) do
    try do
      get_session(conn, key)
    rescue
      ArgumentError ->
        raise ArgumentError,
              "OrdinaryPreviewGate.Plug requires sessions. Add `plug :fetch_session` " <>
                "before this plug in your pipeline."
    end
  end

  defp safe_put_session(conn, key, value) do
    try do
      put_session(conn, key, value)
    rescue
      ArgumentError ->
        raise ArgumentError,
              "OrdinaryPreviewGate.Plug requires sessions. Add `plug :fetch_session` " <>
                "before this plug in your pipeline."
    end
  end
end
