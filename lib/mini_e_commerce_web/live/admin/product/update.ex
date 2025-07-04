defmodule MiniECommerceWeb.Admin.Product.Update do
  use MiniECommerceWeb, :live_view
  import Phoenix.LiveComponent
  alias MiniECommerce.Service.Product, as: ProductService
  alias MiniECommerce.Helpers
  alias MiniECommerceWeb.Admin.BackToHomeButton

  @moduledoc """
  Liveview page for Updating the Product
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
    if connected?(socket) do
      products = ProductService.list(%{})

      product_options = Helpers.fetch_product_options(products)
      category_options = Helpers.category_options()

      {:ok,
       assign(socket,
         form: @product_form_fields,
         product_options: product_options,
         category_options: category_options,
         is_product_selected?: false,
         is_loaded?: true
       )}
    else
      {:ok, assign(socket, is_loaded?: false)}
    end
  end

  def handle_event("handle_update_product", product_params, socket) do
    ProductService.update(product_params)
    |> case do
      {:ok, _updated_product} ->
        socket = put_flash(socket, :info, "Product updated successfully")
        {:noreply, push_navigate(socket, to: "/live/admin/home")}

      # rare scenario unless delete and update is done simultaneously
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

  # incase if the user has un-selected the product. i.e: "Select a Product" (default item)
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

    <div class="max-w-2xl mx-auto p-6 bg-white shadow-xl rounded-2xl space-y-6">
      <h2 class="text-2xl font-semibold text-gray-800">Update Product</h2>

      <%= if @is_loaded? do %>
        <.form
          for={@form}
          phx-submit="handle_update_product"
          id="product-update-form"
          class="space-y-5"
        >
          <div class="space-y-1">
            <label for="id" class="block text-sm font-medium text-gray-700">Product</label>
            <.input
              id="unique_id_for_update_product"
              field={@form["id"]}
              name="id"
              phx-change="handle_change_product_id"
              type="select"
              value={@form["id"]}
              options={@product_options}
              class="w-full rounded-md border border-gray-300 px-4 py-2 focus:ring-blue-500 focus:border-blue-500"
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
              />
            </div>

            <div class="space-y-1">
              <label for="category" class="block text-sm font-medium text-gray-700">Category</label>
              <.input
                field={@form["category"]}
                name="category"
                type="select"
                value={@form["category"]}
                options={@category_options}
                class="w-full rounded-md border border-gray-300 px-4 py-2 focus:ring-blue-500 focus:border-blue-500"
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
              />
            </div>

            <div class="space-y-1">
              <label for="thumbnail" class="block text-sm font-medium text-gray-700">
                Thumbnail URL
              </label>
              <.input
                field={@form["thumbnail"]}
                name="thumbnail"
                type="text"
                value={@form["thumbnail"]}
                placeholder="Enter thumbnail URL"
                class="w-full rounded-md border border-gray-300 px-4 py-2 focus:ring-blue-500 focus:border-blue-500"
              />
            </div>
            <div class="pt-4">
              <button
                type="handle_update_product"
                class="w-[100px] mx-auto block bg-blue-600 hover:bg-blue-700 text-white font-medium py-2 px-4 rounded-md shadow-sm transition"
              >
                Update
              </button>
            </div>
          <% end %>
        </.form>
      <% end %>
    </div>
    """
  end
end
