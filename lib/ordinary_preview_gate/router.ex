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
  """

  defmacro preview_gate_routes(web_module, opts \\ []) do
    path = Keyword.get(opts, :path, "/__preview")
    pipe = Keyword.get(opts, :pipe_through, :browser)

    controller = Macro.escape(:"Elixir.OrdinaryPreviewGate.LoginController")

    quote do
      scope unquote(path), unquote(web_module) do
        pipe_through(unquote(pipe))

        get("/login", unquote(controller), :new)
        post("/login", unquote(controller), :create)
        delete("/logout", unquote(controller), :logout)
      end
    end
  end
end
