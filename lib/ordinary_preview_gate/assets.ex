defmodule OrdinaryPreviewGate.Assets do
  @moduledoc """
  Static assets shipped with the preview gate.
  """

  @svg_path Path.join(:code.priv_dir(:ordinary_preview_gate), "static/ordinary-wordmark.svg")
  @external_resource @svg_path

  @doc """
  Returns the black-on-white Ordinary. wordmark SVG as a string.
  """
  def ordinary_wordmark_svg do
    File.read!(@svg_path)
  end
end
