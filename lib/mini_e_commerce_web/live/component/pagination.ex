defmodule MiniECommerceWeb.Component.Pagination do
  use MiniECommerceWeb, :html

  @moduledoc """
  functional component resposible for supporting pagination
  """

  def show(assigns) do
    ~H"""
    <div class="flex justify-between pt-10">
      <button
        id="unqiue_id_for_previous_page"
        phx-click="handle_previous_page"
        class="bg-white border border-black-700 text-gray-700 hover:bg-gray-100 font-medium py-2 px-4 rounded-md shadow-sm transition"
        disabled={@page == 1}
      >
        Previous
      </button>

      <div class="text-lg">
        Page: {@page} of {@total_pages}
      </div>

      <button
        id="unqiue_id_for_next_page"
        phx-click="handle_next_page"
        class="bg-white border border-gray-300 text-gray-700 hover:bg-gray-100 font-medium py-2 px-4 rounded-md shadow-sm transition"
        disabled={@total_pages <= @page}
      >
        Next
      </button>
    </div>
    """
  end
end
