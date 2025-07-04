defmodule MiniECommerceWeb.Admin.Inventory.Update do
  use MiniECommerceWeb, :live_view
  import Phoenix.LiveComponent
  alias MiniECommerce.Service.Inventory, as: InventoryService
  alias MiniECommerce.Service.Product, as: ProductService
  alias MiniECommerce.Helpers

  @moduledoc """
   Liveview page for updating Inventory
  """
  @inventory_form %{"product_id" => "", "current_quantity" => ""}

  def mount(_params, _session, socket) do
    products = ProductService.list(%{})
    product_options = Helpers.fetch_product_options(products)

    {:ok,
     assign(socket,
       inventory_form: @inventory_form,
       product_options: product_options,
       is_product_selected?: false
     )}
  end

  def handle_event(
        "handle_update_inventory",
        %{"product_id" => product_id, "current_quantity" => current_quantity} = params,
        socket
      )
      when product_id != "" and current_quantity != "" do
    case Integer.parse(current_quantity) do
      {quantity, ""} ->
        updated_params = Map.merge(params, %{"current_quantity" => quantity})

        InventoryService.update(updated_params)
        |> case do
          {:ok, _updated_inventory} ->
            socket = put_flash(socket, :info, "Inventory updated successfully")
            {:noreply, push_navigate(socket, to: "/live/admin/home")}

          # scenario where the product is being deleteed
          # and the user is trying to update the inventory is done simultaneously
          {:error, :product_doesnot_exist} ->
            {:noreply, put_flash(socket, :error, "Product not found")}

          {:error, error_changset} ->
            changset_errors = Helpers.transform_errors(error_changset)

            {:noreply,
             put_flash(
               socket,
               :error,
               "Error while updating the product, #{inspect(changset_errors)}"
             )}
        end

      _ ->
        socket = put_flash(socket, :error, "Please Enter a valid Quantity.")
        {:noreply, socket}
    end
  end

  def handle_event("handle_update_inventory", _params, socket) do
    socket =
      put_flash(socket, :error, "Please Enter required fields. Product and Quantity details")

    {:noreply, socket}
  end

  # incase if the user has un-selected the product. i.e: "Select a Product" (default item)
  def handle_event("handle_change_product_id", %{"product_id" => ""}, socket) do
    {:noreply, assign(socket, is_product_selected?: false)}
  end

  def handle_event("handle_change_product_id", %{"product_id" => product_id}, socket) do
    inventory_product = InventoryService.get_product(product_id)
    {:noreply, assign(socket, is_product_selected?: true, inventory_form: inventory_product)}
  end

  def render(assigns) do
    ~H"""
    <div class="max-w-2xl mx-auto p-6 bg-white shadow-xl rounded-2xl space-y-6">
      <h2 class="text-2xl font-semibold text-gray-800">Update Inventory</h2>

      <.form
        for={@inventory_form}
        phx-submit="handle_update_inventory"
        id="inventory-update-form"
        class="space-y-5"
      >
        <div class="space-y-1">
          <label for="product_id" class="block text-sm font-medium text-gray-700">Category</label>
          <.input
            id="unique_id_inventory_product_change"
            field={@inventory_form["product_id"]}
            name="product_id"
            phx-change="handle_change_product_id"
            type="select"
            value={@inventory_form["product_id"]}
            options={@product_options}
            class="w-full rounded-md border border-gray-300 px-4 py-2 focus:ring-blue-500 focus:border-blue-500"
          />
        </div>

        <%= if @is_product_selected? do %>
          <div class="space-y-1">
            <label for="current_quantity" class="block text-sm font-medium text-gray-700">
              Current Quantity
            </label>
            <.input
              field={@inventory_form["current_quantity"]}
              name="current_quantity"
              type="number"
              placeholder="Enter product name"
              value={@inventory_form["current_quantity"]}
              class="w-full rounded-md border border-gray-300 px-4 py-2 focus:ring-blue-500 focus:border-blue-500"
            />
          </div>

          <div class="pt-4">
            <button class="w-[100px] mx-auto block bg-blue-600 hover:bg-blue-700 text-white font-medium py-2 px-4 rounded-md shadow-sm transition">
              Update
            </button>
          </div>
        <% end %>
      </.form>
    </div>
    """
  end
end
