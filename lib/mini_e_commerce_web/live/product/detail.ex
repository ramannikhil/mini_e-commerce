defmodule MiniECommerceWeb.Product.Detail do
  alias MiniECommerce.Service.Product, as: ProductService
  alias MiniECommerce.Service.ProductView, as: ProductViewService
  use MiniECommerceWeb, :live_view
  alias MiniECommerce.Genserver.LiveCounter
  alias MiniECommerceWeb.Component.{CurrentCounter, InventoryTracker}
  alias MiniECommerce.EventHandler

  @moduledoc """
  Renders Ui for the Product detail page
  subscribe to the topic for getting the current viewers count and quantity updates
  Updates the product views using Genserver
  """

  def mount(%{"id" => product_id} = _params, _session, socket) do
    if connected?(socket) do
      product = ProductService.get_product_with_inventory(product_id)
      GenServer.cast(LiveCounter, {:increment, product_id})

      subscribe_to_events(product_id)
      # update product views count
      ProductViewService.update(product_id)

      socket =
        assign(socket, product: product)
        |> assign(product_id: product_id)
        |> assign(current_count: 0)
        |> assign(current_quantity: nil)

      {:ok, socket}
    else
      {:ok, socket}
    end
  end

  def handle_event("handle_back_to_list_page", _unsigned_params, socket) do
    {:noreply, push_navigate(socket, to: "/live/list")}
  end

  def handle_event("handle_add_to_cart", %{"name" => name} = _unsigned_params, socket) do
    socket = put_flash(socket, :info, "Item #{name} Added to cart")
    {:noreply, socket}
  end

  def handle_info({:product_view_updated, new_count} = _msg, socket) do
    send_update(CurrentCounter, id: "current_counter_value", current_count: new_count)
    {:noreply, socket}
  end

  def handle_info({:updated_current_quantity, _product_id, updated_quantity} = _msg, socket) do
    send_update(InventoryTracker,
      id: "current_current_quantity",
      current_quantity: updated_quantity
    )

    {:noreply, socket}
  end

  def handle_info(_msg, socket) do
    {:noreply, socket}
  end

  # on closing the page/ tab decrement the current count
  def terminate(_reason, socket) do
    product_id = Map.get(socket.assigns, :product_id)
    GenServer.cast(LiveCounter, {:decrement, product_id})
    {:noreply, socket}
  end

  def render(%{product_id: _product_id} = assigns) do
    ~H"""
    <div>
      <.live_component
        module={CurrentCounter}
        id="current_counter_value"
        product_id={@product_id}
        current_count={@current_count}
      />
    </div>

    <div class="flex justify-start">
      <button
        phx-click="handle_back_to_list_page"
        class="bg-blue-500 text-white font-bold py-2 px-4 rounded h-12 ml-auto mr-[15%]"
      >
        Back to List Page
      </button>
    </div>

    <div class="max-w-7xl mx-auto p-12">
      <h1 class="text-4xl font-bold text-gray-800 mb-10">Product Details</h1>

      <div class="bg-white shadow-2xl rounded-2xl overflow-hidden grid grid-cols-1 md:grid-cols-2 gap-12 min-h-[36rem]">
        <div class="flex items-center justify-center bg-gray-100 p-8">
          <img
            src={@product["thumbnail"]}
            alt="Product image"
            class="max-h-[30rem] w-full object-contain rounded-xl"
          />
        </div>

        <div class="p-10 space-y-6">
          <h2 class="text-2xl font-semibold text-gray-900">{@product["name"]}</h2>

          <p class="text-lg text-gray-700">
            <span class="font-medium">Price:</span> €{@product["price"]}
          </p>

          <p class="text-md text-gray-600">
            <span class="font-medium text-gray-800 capitalize">Category:</span>
            <span class="text-base capitalize">{@product["category"]}</span>
          </p>

          <div>
            <h3 class="text-lg font-medium text-gray-800 mb-2">Product Description</h3>
            <p class="text-gray-700 leading-relaxed">
              {@product["description"]}
            </p>
          </div>

          <div>
            <.live_component
              module={InventoryTracker}
              id="current_current_quantity"
              current_quantity={@current_quantity || @product["quantity"]}
            />
            <%= if (@current_quantity || @product["quantity"]) <= 20 do %>
              <span>
              Hurry, stock is running out
              </span>

          <% end %>

          </div>

          <div class="pt-10 m-10">
            <button
              phx-value-name={@product["name"]}
              phx-click="handle_add_to_cart"
              class="w-[200px] bg-black px-4 py-2 text-white rounded h-12"
            >
              Add to Cart
            </button>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def render(assigns) do
    ~H"""
    Loading...
    """
  end

  defp subscribe_to_events(product_id) do
    EventHandler.subscribe_event(MiniECommerce.PubSub, "product_views:#{product_id}")
    EventHandler.subscribe_event(MiniECommerce.PubSub, "inventory_updater:#{product_id}")
  end
end
