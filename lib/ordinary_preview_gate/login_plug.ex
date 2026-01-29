defmodule OrdinaryPreviewGate.LoginPlug do
  @moduledoc false

  import Plug.Conn

  @session_ok :preview_gate_ok

  def init(action), do: action

  def call(conn, action) do
    case action do
      :new -> new(conn)
      :create -> create(conn)
      :logout -> logout(conn)
      _ -> send_resp(conn, 404, "not found")
    end
  end

  defp new(conn) do
    html = render_html(conn)

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, html)
  end

  defp create(conn) do
    params = conn.params || %{}
    password = Map.get(params, "password", "")
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
      |> Phoenix.Controller.redirect(to: login_path())
    end
  end

  defp logout(conn) do
    conn
    |> delete_session(@session_ok)
    |> Phoenix.Controller.redirect(to: login_path())
  end

  defp login_path do
    System.get_env("PREVIEW_GATE_LOGIN_PATH", "/__preview/login")
  end

  defp render_html(conn) do
    app_name = System.get_env("PREVIEW_GATE_APP_NAME", "(app)")
    pr_number = System.get_env("PREVIEW_GATE_PR", "(local)")
    build_id = System.get_env("PREVIEW_GATE_BUILD_ID", "(unknown)")

    csrf = Plug.CSRFProtection.get_csrf_token()
    error = Phoenix.Flash.get(conn.assigns[:flash] || %{}, :error)

    svg = OrdinaryPreviewGate.Assets.ordinary_wordmark_svg() |> strip_xml_decl()

    form_action = login_path()

    """
    <!doctype html>
    <html lang=\"en\">
      <head>
        <meta charset=\"utf-8\" />
        <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\" />
        <meta name=\"color-scheme\" content=\"light\" />
        <title>Preview environment</title>
        <style>
          html, body { height: 100%; }
          body { margin: 0; background: #fff; color: #000; font-family: ui-sans-serif, system-ui, -apple-system, \"system-ui\", \"Segoe UI\", Roboto, \"Helvetica Neue\", Arial, \"Noto Sans\", sans-serif; }
          .wrap { min-height: 100vh; display: flex; align-items: center; justify-content: center; padding: 48px 20px; }
          .card { width: 100%; max-width: 720px; border: 1px solid #e5e7eb; border-radius: 20px; padding: 28px; background: #fff; }
          .mark { display: block; line-height: 0; }
          .mark svg { display: block; height: 22px; width: auto; }
          .title { margin: 18px 0 6px; font-size: 28px; font-weight: 600; letter-spacing: -0.02em; }
          .desc { margin: 0 0 18px; color: #111; opacity: 0.75; }
          .meta { display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 12px; margin: 18px 0 20px; }
          .meta dt { font-size: 11px; color: #111; opacity: 0.55; }
          .meta dd { margin: 4px 0 0; font-size: 13px; font-weight: 600; }
          .meta .mono { font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, \"Liberation Mono\", \"Courier New\", monospace; font-size: 12px; font-weight: 500; }
          label { display: block; font-size: 13px; font-weight: 600; margin-bottom: 8px; }
          input { width: 100%; border: 1px solid #d1d5db; border-radius: 14px; padding: 12px 14px; font-size: 16px; }
          .actions { display: flex; align-items: center; justify-content: space-between; margin-top: 14px; gap: 12px; }
          .hint { font-size: 12px; color: #111; opacity: 0.6; }
          .error { font-size: 13px; font-weight: 600; color: #b91c1c; }
          button { border: 0; border-radius: 14px; padding: 10px 14px; font-size: 13px; font-weight: 700; background: #111; color: #fff; cursor: pointer; }
          button:hover { opacity: 0.9; }
          @media (max-width: 640px) { .meta { grid-template-columns: 1fr; } }
        </style>
      </head>
      <body>
        <main class=\"wrap\">
          <div class=\"card\">
            <div class=\"mark\">#{svg}</div>
            <h1 class=\"title\">Preview environment</h1>
            <p class=\"desc\">Enter the preview password to continue.</p>

            <dl class=\"meta\">
              <div>
                <dt>App</dt>
                <dd>#{escape(app_name)}</dd>
              </div>
              <div>
                <dt>PR</dt>
                <dd>#{escape(pr_number)}</dd>
              </div>
              <div>
                <dt>Build</dt>
                <dd class=\"mono\">#{escape(build_id)}</dd>
              </div>
            </dl>

            <form method=\"post\" action=\"#{escape(form_action)}\">
              <input type=\"hidden\" name=\"_csrf_token\" value=\"#{csrf}\" />

              <label for=\"password\">Password</label>
              <input id=\"password\" name=\"password\" type=\"password\" autofocus />

              <div class=\"actions\">
                #{error_block(error)}
                <button type=\"submit\">Continue</button>
              </div>
            </form>
          </div>
        </main>
      </body>
    </html>
    """
  end

  defp error_block(nil), do: ~s(<div class="hint">Not production. Not indexed.</div>)
  defp error_block(msg), do: ~s(<div class="error">#{escape(msg)}</div>)

  defp strip_xml_decl(svg), do: String.replace(svg, ~r/^<\?xml[^>]*>\s*/m, "")

  defp escape(nil), do: ""

  defp escape(value) do
    value
    |> to_string()
    |> String.replace("&", "&amp;")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
    |> String.replace("\"", "&quot;")
  end
end
