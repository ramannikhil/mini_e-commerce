defmodule MiniECommerceWeb.InitAssigns do
  import Phoenix.Component
  use MiniECommerceWeb, :live_view

  @moduledoc """
  Livesession for Product endpoints
  - List
  - Detail
  """

  def on_mount(:default, _params, _session, socket) do
    {:cont, assign(socket, :page_title, "Mini E-Commerce")}
  end
end
