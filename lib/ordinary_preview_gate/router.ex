defmodule OrdinaryPreviewGate.Router do
  @moduledoc """
  Router helpers for mounting the preview gate.

  Usage:

      defmodule MyAppWeb.Router do
        use MyAppWeb, :router

        pipeline :browser do
          # ...
          plug OrdinaryPreviewGate.Plug
        end

        pipeline :preview do
          plug :accepts, ["html"]
          plug :fetch_session
          plug :fetch_live_flash
          plug :put_root_layout, html: {MyAppWeb.Layouts, :preview_gate}
          plug :protect_from_forgery
          plug :put_secure_browser_headers
        end

        scope "/", MyAppWeb do
          pipe_through :browser
          # ...your app routes...
        end

        import OrdinaryPreviewGate.Router

        preview_gate_routes(MyAppWeb)
      end

  The macro keeps host apps explicit while avoiding copy/paste boilerplate.
  """

  defmacro preview_gate_routes(web_module, opts \\ []) do
    path = Keyword.get(opts, :path, "/__preview")

    quote do
      scope unquote(path), unquote(web_module) do
        pipe_through(:preview)

        get("/login", PreviewGateController, :new)
        post("/login", PreviewGateController, :create)
        delete("/logout", PreviewGateController, :logout)
      end
    end
  end
end
