defmodule MiniECommerceWeb.Admin.Product.Delete do
  alias MiniECommerce.Schema.Product
  use MiniECommerceWeb, :live_view
  import Phoenix.LiveComponent
  alias MiniECommerce.Service.Product, as: ProductService
  alias MiniECommerce.Helpers
  alias MiniECommerceWeb.Admin.BackToHomeButton

  @moduledoc """
  Liveview page for Deleting the Product
  """

  @product_form_fields %{
    "id" => "",
    "name" => "",
    "price" => "",
    "description" => "",
    "thumbnail" => "",
    "category" => ""
  }

  def mount(_params, _session, socket) do
    products = ProductService.list(%{})
    product_options = Helpers.fetch_product_options(products)

    {:ok,
     assign(socket,
       product_options: product_options,
       form: @product_form_fields,
       show_delete?: false,
       is_product_selected?: false
     )}
  end

  def handle_event("handle_show_delete_display", _params, socket) do
    {:noreply, assign(socket, show_delete?: true)}
  end

  def handle_event("handle_cancel_delete_display", _params, socket) do
    {:noreply, assign(socket, show_delete?: false)}
  end

  def handle_event("handle_confirm_delete", %{"id" => _product_id} = params, socket) do
    ProductService.delete(params)
    |> case do
      {:ok, %Product{name: product_name} = _deleted_product} ->
        socket =
          put_flash(socket, :info, "Product deleted successfully, #{inspect(product_name)}")

        {:noreply, push_navigate(socket, to: "/live/admin/home")}

      {:error, :invalid_params} ->
        {:noreply, put_flash(socket, :error, "Please choose the product")}

      # rare scenario where the product has already deleted in the DB
      # and another user is trying the same action from the UI simultaneously
      {:error, :product_not_found} ->
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
  end

  def handle_event("handle_change_product_id", %{"id" => ""}, socket) do
    {:noreply, assign(socket, is_product_selected?: false)}
  end

  def handle_event("handle_change_product_id", %{"id" => product_id}, socket) do
    product = ProductService.get_product_by_id(product_id)
    {:noreply, assign(socket, is_product_selected?: true, form: product)}
  end

  def handle_event("handle_back_to_list_page", _unsigned_params, socket) do
    {:noreply, push_navigate(socket, to: "/live/admin/home")}
  end

  def render(assigns) do
    ~H"""
    <BackToHomeButton.onclick />

    <div class="max-w-xl mx-auto p-6 bg-white shadow-xl rounded-2xl space-y-6">
      <h2 class="text-2xl font-semibold text-gray-800">Delete Product</h2>
      <.form for={@form} phx-submit="handle_confirm_delete" id="product-delete-form" class="space-y-5">
        <div class="space-y-1">
          <label for="id" class="block text-sm font-medium text-gray-700">Product</label>
          <.input
            field={@form["id"]}
            name="id"
            id="unique_id_for_delete_product"
            type="select"
            phx-change="handle_change_product_id"
            value={@form["id"]}
            options={@product_options}
            class="w-full rounded-md bg-red-600 border border-gray-300 px-4 py-2 focus:ring-blue-500 focus:border-blue-500"
          />
        </div>

        <%= if @is_product_selected? do %>
          <div class="space-y-1">
            <label for="name" class="block text-sm font-medium text-gray-700">Name</label>
            <.input
              field={@form["name"]}
              name="name"
              type="text"
              placeholder="Enter product name"
              value={@form["name"]}
              class="w-full rounded-md border border-gray-300 px-4 py-2 focus:ring-blue-500 focus:border-blue-500"
              readonly
            />
          </div>

          <div class=" h-52 flex items-center justify-center">
            <img
              src={@form["thumbnail"]}
              alt={@form["name"]}
              class="max-h-full max-w-full object-contain"
            />
          </div>
          <div class="space-y-1">
            <label for="description" class="block text-sm font-medium text-gray-700">
              Description
            </label>
            <.input
              field={@form["description"]}
              name="description"
              type="textarea"
              placeholder="Enter product description"
              value={@form["description"]}
              class="w-full rounded-md border border-gray-300 px-4 py-2 focus:ring-blue-500 focus:border-blue-500"
              readonly
            />
          </div>

          <div class="space-y-1">
            <label for="category" class="block text-sm font-medium text-gray-700">Category</label>
            <.input
              field={@form["category"]}
              name="category"
              type="text"
              value={@form["category"]}
              class="w-full rounded-md border border-gray-300 px-4 py-2 focus:ring-blue-500 focus:border-blue-500"
              readonly
            />
          </div>

          <div class="space-y-1">
            <label for="price" class="block text-sm font-medium text-gray-700">Price</label>
            <.input
              field={@form["price"]}
              name="price"
              type="number"
              step="0.01"
              value={@form["price"]}
              placeholder="Enter price"
              class="w-full rounded-md border border-gray-300 px-4 py-2 focus:ring-blue-500 focus:border-blue-500"
              readonly
            />
          </div>

          <div class="pt-4">
            <button
              type="button"
              phx-click="handle_show_delete_display"
              class="w-[100px] mx-auto block bg-red-600 hover:bg-red-700 text-white font-medium py-2 px-4 rounded-md shadow-sm transition"
            >
              Delete
            </button>
          </div>
        <% end %>

        <%= if @show_delete? do %>
          <div class="fixed inset-0 bg-black bg-opacity-30 flex items-center justify-center z-50">
            <div class="bg-white rounded-lg shadow-xl p-6 space-y-4 max-w-sm w-full">
              <h3 class="text-lg font-semibold text-gray-800">Confirm Deletion</h3>
              <p class="text-gray-600">Are you sure you want to delete this product?</p>
              <div class="flex justify-end gap-4">
                <button
                  phx-click="handle_cancel_delete_display"
                  class="px-4 py-2 rounded bg-gray-300 hover:bg-gray-400 text-gray-800"
                >
                  Cancel
                </button>
                <button class="px-4 py-2 rounded bg-red-600 hover:bg-red-700 text-white">
                  <%!-- phx-value-id={@form["name"]} --%> Confirm
                </button>
              </div>
            </div>
          </div>
        <% end %>
      </.form>
    </div>
    """
  end
end
