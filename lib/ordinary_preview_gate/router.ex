defmodule OrdinaryPreviewGate.Router do
  @moduledoc """
  Router helpers for mounting the preview gate.

  Minimal integration goal: **two lines** in the host router.

  1) Add the plug to your browser pipeline:

      plug OrdinaryPreviewGate.Plug

  2) Mount routes:

      import OrdinaryPreviewGate.Router
      preview_gate_routes(MyAppWeb)

  By default this mounts:
  - `GET /__preview/login`
  - `POST /__preview/login`
  - `DELETE /__preview/logout`

  Notes:
  - Routes are piped through `:browser` by default so they have sessions and CSRF.
  - You can change the mount path with `path:`.
  - You can change which pipeline is used with `pipe_through:`.
  """

  defmacro preview_gate_routes(web_module, opts \\ []) do
    path = Keyword.get(opts, :path, "/__preview")
    pipe = Keyword.get(opts, :pipe_through, :browser)

    quote do
      scope unquote(path), unquote(web_module) do
        pipe_through(unquote(pipe))

        get("/login", OrdinaryPreviewGate.LoginController, :new)
        post("/login", OrdinaryPreviewGate.LoginController, :create)
        delete("/logout", OrdinaryPreviewGate.LoginController, :logout)
      end
    end
  end
end
