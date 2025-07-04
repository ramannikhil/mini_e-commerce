defmodule MiniECommerceWeb.Component.InventoryTracker do
  use MiniECommerceWeb, :live_component

  @moduledoc """
  Reponisble for rendering the live updated quantity for the product, based on the inventory changes
  """

  def render(assigns) do
    ~H"""
    <div class="text-lg">
      Quantity: {@current_quantity}
    </div>
    """
  end
end
