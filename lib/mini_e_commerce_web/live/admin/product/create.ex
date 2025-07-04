defmodule MiniECommerceWeb.Admin.Product.Create do
  use MiniECommerceWeb, :live_view
  import Phoenix.LiveComponent
  alias MiniECommerce.Schema.Product
  alias MiniECommerce.Service.Product, as: ProductService
  alias MiniECommerceWeb.Admin.BackToHomeButton

  @moduledoc """
  Liveview page for creating a Product
  """

  @product_form_fields %{
    "name" => "",
    "price" => "",
    "description" => "",
    "thumbnail" => "",
    "category" => ""
  }

  def mount(_params, _session, socket) do
    category_options = Product.category_enum() |> options_for_select()

    {:ok,
     assign(socket,
       form: @product_form_fields,
       category_options: category_options
     )}
  end

  def handle_event("handle_create_product", product_params, socket) do
    case ProductService.create(product_params) do
      {:ok, _product} ->
        socket = put_flash(socket, :info, "Product created successfully")

        {:noreply, push_navigate(socket, to: "/live/admin/home")}

      {:error, :invalid_params} ->
        socket = put_flash(socket, :error, "Please Enter required field. Name and Price details")
        {:noreply, socket}
    end
  end

  def handle_event("handle_back_to_list_page", _unsigned_params, socket) do
    {:noreply, push_navigate(socket, to: "/live/admin/home")}
  end

  def render(assigns) do
    ~H"""
    <BackToHomeButton.onclick />

    <div class="max-w-2xl mx-auto p-6 bg-white shadow-xl rounded-2xl space-y-6">
      <h2 class="text-2xl font-semibold text-gray-800">Create Product</h2>

      <.form for={@form} phx-submit="handle_create_product" id="product-create-form" class="space-y-5">
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
          <label for="description" class="block text-sm font-medium text-gray-700">Description</label>
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
          <label for="thumbnail" class="block text-sm font-medium text-gray-700">Thumbnail URL</label>
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
          <button class="w-[100px] mx-auto block bg-blue-600 hover:bg-blue-700 text-white font-medium py-2 px-4 rounded-md shadow-sm transition">
            Create
          </button>
        </div>
      </.form>
    </div>
    """
  end

  defp options_for_select(items) do
    Enum.map(items, &{to_string(&1) |> String.capitalize(), to_string(&1)})
  end
end
