defmodule MiniECommerceWeb.Component.CurrentCounter do
  use MiniECommerceWeb, :live_component

  @moduledoc """
  Responsible for rendering the live product views count
  """

  def render(assigns) do
    ~H"""
    <div class="text-xl">
      Watching Now: {@current_count}
    </div>
    """
  end
end
