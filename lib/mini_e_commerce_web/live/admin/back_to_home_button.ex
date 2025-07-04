defmodule MiniECommerceWeb.Admin.BackToHomeButton do
  use MiniECommerceWeb, :html

  def onclick(assigns) do
    ~H"""
    <div class="pt-6 flex justify-center">
      <button
        phx-click="handle_back_to_list_page"
        class="inline-flex items-center justify-center gap-2 px-5 py-2.5 bg-blue-600 hover:bg-blue-700 text-white text-sm font-semibold rounded-lg shadow transition duration-200 focus:outline-none focus:ring-2 focus:ring-blue-400 focus:ring-offset-2"
      >
        <svg class="w-4 h-4" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" d="M15 19l-7-7 7-7" />
        </svg>
        Back to Home
      </button>
    </div>
    """
  end
end
