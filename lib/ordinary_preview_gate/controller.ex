defmodule OrdinaryPreviewGate.Controller do
  @moduledoc """
  Controller helpers for the preview gate.

  Host app typically defines its own controller that delegates to these helpers,
  so the host can choose layout, app name, build id, etc.

  Example host controller:

      defmodule MyAppWeb.PreviewGateController do
        use MyAppWeb, :controller

        def new(conn, _), do: OrdinaryPreviewGate.Controller.render_login(conn, MyAppWeb.PreviewGateHTML)
        def create(conn, params), do: OrdinaryPreviewGate.Controller.handle_login(conn, params)
        def logout(conn, _), do: OrdinaryPreviewGate.Controller.logout(conn)
      end
  """

  import Plug.Conn

  @session_ok :preview_gate_ok

  def render_login(conn, view_module, assigns \\ %{}) do
    default_assigns = %{
      app_name: System.get_env("PREVIEW_GATE_APP_NAME", "(app)"),
      pr_number: System.get_env("PREVIEW_GATE_PR", "(local)"),
      build_id: System.get_env("PREVIEW_GATE_BUILD_ID", "(unknown)")
    }

    Phoenix.Controller.render(conn, view_module, :new, Map.merge(default_assigns, assigns))
  end

  def handle_login(conn, %{"password" => password}) do
    expected = System.get_env("PREVIEW_GATE_PASSWORD", "")

    if expected != "" and Plug.Crypto.secure_compare(password, expected) do
      return_to = get_session(conn, :preview_gate_return_to) || "/"

      conn
      |> put_session(@session_ok, true)
      |> delete_session(:preview_gate_return_to)
      |> Phoenix.Controller.redirect(to: return_to)
    else
      conn
      |> Phoenix.Controller.put_flash(:error, "Incorrect password")
      |> Phoenix.Controller.redirect(to: "/__preview/login")
    end
  end

  def logout(conn) do
    conn
    |> delete_session(@session_ok)
    |> Phoenix.Controller.redirect(to: "/__preview/login")
  end
end
