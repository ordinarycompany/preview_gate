defmodule OrdinaryPreviewGate.Router do
  @moduledoc """
  Router helpers for mounting the preview gate.

  Minimal integration goal: **two lines** in the host router.

      plug OrdinaryPreviewGate.Plug

      import OrdinaryPreviewGate.Router
      preview_gate_routes(MyAppWeb)

  Notes:
  - Uses `:browser` pipeline by default.
  - `path:` and `pipe_through:` are customizable.

  This macro intentionally mounts routes in a scope **without** a web namespace
  to avoid any module aliasing surprises in host apps.
  """

  defmacro preview_gate_routes(_web_module, opts \\ []) do
    path = Keyword.get(opts, :path, "/__preview")
    pipe = Keyword.get(opts, :pipe_through, :browser)

    plug_module = Macro.escape(:"Elixir.OrdinaryPreviewGate.LoginPlug")

    quote do
      scope unquote(path) do
        pipe_through(unquote(pipe))

        get("/login", unquote(plug_module), :new)
        post("/login", unquote(plug_module), :create)
        delete("/logout", unquote(plug_module), :logout)
      end
    end
  end
end
