defmodule MiniECommerceWeb.Component.Filters do
  use MiniECommerceWeb, :live_component
  alias MiniECommerce.Helpers

  @moduledoc """
  Renders the filters in the UI

  - sort_column: sorts the records based on the sort_column @allowed_sort_columns
  - sort_by: Sort using either Ascending or Descending, [:asc, :desc]
  - categorY_options: select item for choosing the category from the product category enum

  Reset the filters
  """

  @allowed_sort_columns [:name, :price, :popularity, :updated_at]
  @sort_by_options [:desc, :asc]

  def update(%{filters: filters}, socket) do
    category_options = Helpers.category_options()
    updated_options = [{"Select a category", ""} | category_options]
    sort_column_options = Helpers.fetch_select_options(@allowed_sort_columns)
    sort_by_options = Helpers.fetch_select_options(@sort_by_options)

    socket =
      assign(socket, :filters, filters)
      |> assign(
        category_options: updated_options,
        sort_column_options: sort_column_options,
        sort_by_options: sort_by_options
      )

    {:ok, socket}
  end

  def handle_event("handle_submit_filters", params, socket) do
    updated_filters = Map.merge(params, %{"page" => 1})
    socket = assign(socket, :filters, updated_filters)

    Process.send(self(), updated_filters, [:noconnect])
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="flex justify-center w-full mt-4">
      <div class="flex items-end gap-4">
        <.form
          for={@filters}
          phx-submit="handle_submit_filters"
          phx-target={@myself}
          class="flex flex-wrap items-end gap-4"
        >
          <div class="flex flex-col items-center min-w-[150px]">
            <label class="text-center"> Category</label>
            <.input
              id="unique_id_for_category_filters"
              field={@filters["category"]}
              name="category"
              type="select"
              options={@category_options}
              value={@filters["category"]}
              class="min-w-[200px]"
              placeholder="Select a Category"
            />
          </div>

          <div class="flex flex-col items-center min-w-[150px]">
            <label class="text-center"> Column</label>
            <.input
              id="unique_id_for_sort_column_filters"
              field={@filters["sort_column"]}
              name="sort_column"
              type="select"
              options={@sort_column_options}
              value={@filters["sort_column"]}
              class="min-w-[200px]"
            />
          </div>

          <div class="flex flex-col items-center min-w-[80px]">
            <label class="text-center"> Sort By</label>
            <.input
              id="unique_id_for_sort_by_filters"
              field={@filters["sort_by"]}
              name="sort_by"
              type="select"
              options={@sort_by_options}
              value={@filters["sort_by"]}
              class="min-w-[200px]"
            />
          </div>

          <div class="px-2">
            <button class="bg-blue-500 text-white font-semibold py-1 px-4 rounded h-10">
              Apply Filters
            </button>
          </div>
        </.form>

        <button
          phx-click="handle_clear_filters"
          id="unique_id_for_clear_filters"
          class="bg-gray-100 text-black font-medium py-1 px-4 rounded border border-gray-400 hover:bg-gray-300 h-10"
        >
          Clear filters
        </button>
      </div>
    </div>
    """
  end
end
