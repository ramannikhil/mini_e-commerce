defmodule MiniECommerceWeb.Admin.Inventory.Create do
  use MiniECommerceWeb, :live_view
  import Phoenix.LiveComponent
  alias MiniECommerce.Service.Inventory, as: InventoryService

  @moduledoc """
   Liveview page for creating Inventory
  """

  @inventory_form %{"product_id" => "", "current_quantity" => ""}

  def mount(_params, _session, socket) do
    available_products = InventoryService.available_products()
    product_options = [{"Select a Product", ""} | available_products]
    {:ok, assign(socket, products: product_options, inventory_form: @inventory_form)}
  end

  def handle_event(
        "handle_create_inventory",
        %{"product_id" => product_id, "current_quantity" => current_quantity} = params,
        socket
      )
      when product_id != "" and current_quantity != "" do
    case Integer.parse(current_quantity) do
      {quantity, ""} ->
        updated_params = Map.merge(params, %{"current_quantity" => quantity})
        InventoryService.create(updated_params)

        socket =
          put_flash(
            socket,
            :info,
            "Inventory created successfully for the product #{inspect(product_id)}"
          )

        {:noreply, push_navigate(socket, to: "/live/admin/home")}

      _ ->
        socket = put_flash(socket, :error, "Please Enter a valid Quantity.")
        {:noreply, socket}
    end
  end

  def handle_event("handle_create_inventory", _params, socket) do
    socket =
      put_flash(socket, :error, "Please Enter required fields. Product and Quantity details")

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="max-w-2xl mx-auto p-6 bg-white shadow-xl rounded-2xl space-y-6">
      <h2 class="text-2xl font-semibold text-gray-800">Create Inventory</h2>

      <.form
        for={@inventory_form}
        phx-submit="handle_create_inventory"
        id="inventory-create-form"
        class="space-y-5"
      >
        <div class="space-y-1">
          <label for="product_id" class="block text-sm font-medium text-gray-700">Product</label>
          <.input
            field={@inventory_form["product_id"]}
            name="product_id"
            type="select"
            placeholder="Select Product"
            options={@products}
            value={@inventory_form["product_id"]}
            class="w-full rounded-md border border-gray-300 px-4 py-2 focus:ring-blue-500 focus:border-blue-500"
          />
        </div>

        <div class="space-y-1">
          <label for="current_quantity" class="block text-sm font-medium text-gray-700">
            Current Quantity
          </label>
          <.input
            field={@inventory_form["current_quantity"]}
            name="current_quantity"
            type="number"
            value={@inventory_form["current_quantity"]}
            placeholder="Enter Quantity"
            class="w-full rounded-md border border-gray-300 px-4 py-2 focus:ring-blue-500 focus:border-blue-500"
          />
        </div>

        <div class="pt-4">
          <button
            type="submit"
            id="unique_id_for_submit_btn"
            class="w-[100px] mx-auto block bg-blue-600 hover:bg-blue-700 text-white font-medium py-2 px-4 rounded-md shadow-sm transition"
          >
            Create
          </button>
        </div>
      </.form>
    </div>
    """
  end
end
