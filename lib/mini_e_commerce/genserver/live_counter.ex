defmodule MiniECommerce.Genserver.LiveCounter do
  use GenServer
  alias MiniECommerce.EventHandler

  @moduledoc """
  Genserver responsible for tracking the live user_views count for a product
  Incrment: If a user visits a product page, increments to +1 per tab
  Decrement: If the user tab/browser is closed, it will decrement count by -1 per tab
  """

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(state), do: {:ok, state}

  def handle_cast({:increment, product_id}, state) do
    new_count = Map.get(state, product_id, 0) + 1

    EventHandler.broadcast_event(
      MiniECommerce.PubSub,
      "product_views:#{product_id}",
      {:product_view_updated, new_count}
    )

    new_state = Map.put(state, product_id, new_count)
    {:noreply, new_state}
  end

  # Handled terminate session in the detail.ex, if the user terminates/ closes the tab for better accuracy
  def handle_cast({:decrement, product_id}, state) do
    new_count = max(Map.get(state, product_id, 1) - 1, 0)

    EventHandler.broadcast_event(
      MiniECommerce.PubSub,
      "product_views:#{product_id}",
      {:product_view_updated, new_count}
    )

    new_state = Map.put(state, product_id, new_count)
    {:noreply, new_state}
  end
end
