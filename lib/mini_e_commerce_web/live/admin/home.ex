defmodule MiniECommerceWeb.Admin.Home do
  use MiniECommerceWeb, :live_view

  @moduledoc """
  Admin home page responsible for
  - Create, Update and Delete Products
  - Create and Update  Inventory
  """

  def mount(_params, _session, socket), do: {:ok, socket}

  def render(assigns) do
    ~H"""
    <div class="  flex items-center justify-center px-4">
      <div class="grid grid-cols-1 md:grid-cols-2 gap-6 w-full max-w-5xl">
        
    <!-- Product section -->
        <div class="bg-white p-8 rounded-2xl shadow-lg text-center">
          <h1 class="text-3xl font-bold text-gray-800 mb-6">Product</h1>
          <div class="space-y-4">
            <.link
              navigate={~p"/live/admin/products/create"}
              class="block w-full bg-blue-500 text-white py-2 px-4 rounded-xl hover:bg-blue-600 transition"
            >
              Create Product
            </.link>
            <.link
              navigate={~p"/live/admin/products/update"}
              class="block w-full bg-yellow-500 text-white py-2 px-4 rounded-xl hover:bg-yellow-600 transition"
            >
              Update Product
            </.link>
            <.link
              navigate={~p"/live/admin/products/delete"}
              class="block w-full bg-red-500 text-white py-2 px-4 rounded-xl hover:bg-red-600 transition"
            >
              Delete Product
            </.link>
          </div>
        </div>
        
    <!-- Inventory section -->
        <div class="bg-white p-8 rounded-2xl shadow-lg text-center">
          <h1 class="text-2xl font-semibold text-gray-800 mb-6">Inventory</h1>
          <div class="space-y-4">
            <.link
              navigate={~p"/live/admin/inventory/create"}
              class="block w-full bg-blue-500 text-white py-2 px-4 rounded-xl hover:bg-blue-600 transition"
            >
              Create Inventory
            </.link>
            <.link
              navigate={~p"/live/admin/inventory/update"}
              class="block w-full bg-yellow-500 text-white py-2 px-4 rounded-xl hover:bg-yellow-600 transition"
            >
              Update Inventory
            </.link>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
