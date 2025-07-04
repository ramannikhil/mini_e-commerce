defmodule MiniECommerceWeb.Product.List do
  use MiniECommerceWeb, :live_view
  alias MiniECommerce.Service.Product, as: ProductService
  alias MiniECommerceWeb.Component.{Filters, InventoryTracker}
  # alias MiniECommerce.Schema.Product
  alias MiniECommerce.EventHandler
  alias MiniECommerceWeb.Component.Pagination

  @moduledoc """
  Responsible for Displaying the List of products
  Receives the updates for the Inventory quantity changes for the product (InventoryTracker)
  Handles product click to naviagte to Detail page
  Clear Filters
  """

  @default_page "1"

  @default_filters %{
    "category" => "",
    "sort_by" => "desc",
    "sort_column" => "updated_at",
    "page" => @default_page
  }

  def mount(_params, _session, socket) do
    if connected?(socket) do
      socket =
        assign(socket, product_list: [])
        # |> assign(:current_filters, @default_filters)
        |> assign(:current_quantity, nil)
        |> assign(loaded: true)

      {:ok, socket}
    else
      {:ok, assign(socket, loaded: false, current_filters: @default_filters)}
    end
  end

  def handle_params(params, _uri, socket) do
    if connected?(socket) do
      updated_params = @default_filters |> Map.merge(params)

      %{products: product_list, total_pages: total_pages} = ProductService.list(updated_params)

      # subscribe for the product events for getting live updates for the inventory changes
      subscribe_product_events(product_list)

      socket =
        assign(socket,
          product_list: product_list,
          total_pages: total_pages,
          current_filters: updated_params
        )

      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  # responible to receiving the live updates based on the Inventory current quantity updates
  def handle_info({:updated_current_quantity, product_id, updated_quantity} = _msg, socket) do
    send_update(InventoryTracker,
      id: "current_quantity_list#{product_id}",
      current_quantity: updated_quantity
    )

    {:noreply, socket}
  end

  def handle_info(filter_params, socket) do
    socket =
      assign(socket, current_filters: filter_params)

    url = "/live/list?" <> URI.encode_query(filter_params)
    {:noreply, push_patch(socket, to: url)}
  end

  # navigates to detail page of the specific product_id
  def handle_event("handle_product", %{"product_id" => product_id} = _params, socket) do
    url = URI.encode("/live/detail/" <> product_id)
    {:noreply, push_navigate(socket, to: url)}
  end

  # reset the filters
  def handle_event(
        "handle_clear_filters",
        _params,
        %{assigns: %{current_filters: current_filters}} = socket
      ) do
    updated_filters = Map.merge(current_filters, %{"page" => @default_page})

    {:noreply, push_patch(assign(socket, current_filters: updated_filters), to: ~p"/live/list")}
  end

  def handle_event(
        "handle_previous_page",
        _params,
        %{
          assigns: %{
            current_filters: %{"page" => current_page} = current_filters
          }
        } = socket
      ) do
    {curr_page, _} = Integer.parse(current_page)
    new_page = max(curr_page - 1, 1)

    handle_page_event_update(current_filters, to_string(new_page), socket)
  end

  def handle_event(
        "handle_next_page",
        _params,
        %{
          assigns: %{
            total_pages: total_pages,
            current_filters: %{"page" => current_page} = current_filters
          }
        } = socket
      ) do
    {curr_page, _} = Integer.parse(current_page)

    new_page = min(curr_page + 1, total_pages)

    handle_page_event_update(current_filters, to_string(new_page), socket)
  end

  defp handle_page_event_update(current_filters, new_page, socket) do
    updated_filters = Map.merge(current_filters, %{"page" => new_page})
    url = "/live/list?" <> URI.encode_query(updated_filters)
    {:noreply, push_patch(assign(socket, current_filters: updated_filters), to: url)}
  end

  defp subscribe_product_events(product_list) do
    product_list
    |> Enum.each(fn %{id: product_id} ->
      EventHandler.subscribe_event(MiniECommerce.PubSub, "inventory_updater:#{product_id}")
    end)
  end

  def render(%{product_list: product_list} = assigns) when length(product_list) != 0 do
    ~H"""
    <div>
      <div class="pb-10">
        <.live_component module={Filters} id="filters_values" filters={@current_filters} />
      </div>
      <%= if @product_list != [] do %>
        <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6 p-6">
          <%= for product <- @product_list do %>
            <button
              phx-click="handle_product"
              phx-value-product_id={product.id}
              class="bg-white rounded-xl shadow-md hover:shadow-lg transition-shadow duration-300 overflow-hidden text-left"
            >
              <div class="w-full h-52 bg-gray-100 flex items-center justify-center">
                <img
                  src={product.thumbnail}
                  alt={product.name}
                  class="max-h-full max-w-full object-contain"
                />
              </div>

              <div class="p-4 space-y-2">
                <div class="text-lg font-semibold text-gray-800 truncate">{product.name}</div>
                <div class="text-sm text-gray-600 h-12 overflow-hidden">{product.description}</div>
                <div class="text-md font-medium text-blue-600">€{product.price}</div>
              </div>

              <div class="p-5 text-lg">
                <.live_component
                  module={InventoryTracker}
                  id={"current_quantity_list#{product.id}"}
                  current_quantity={@current_quantity || product.quantity}
                />
              </div>
            </button>
          <% end %>
        </div>

        <Pagination.show
          page={String.to_integer(@current_filters["page"])}
          total_pages={@total_pages}
        />
      <% end %>
    </div>
    """
  end

  def render(assigns) do
    ~H"""
    Loading Products...
    """
  end
end
