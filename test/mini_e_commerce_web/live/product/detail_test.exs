defmodule MiniECommerceWeb.Product.DetailTest do
  use MiniECommerceWeb.ConnCase, async: true

  alias MiniECommerce.Service.Product, as: ProductSerivce
  alias MiniECommerce.Service.Inventory, as: InventorySerivce
  alias MiniECommerce.Schema.Product
  import Phoenix.LiveViewTest
  alias MiniECommerce.EventHandler

  @product_params %{
    "name" => "Baby cloths",
    "description" => "Product related to babies",
    "category" => "books",
    "price" => "49.99",
    "thumbnail" => "http://example.com/image.jpg"
  }
  setup %{conn: conn} do
    product = create_product()

    %{conn: conn, product: product}
  end

  test "render detail page UI", %{conn: conn, product: product} do
    {:ok, _view, html} = live(conn, "/live/detail/#{product.id}")

    assert html =~ "Watching Now"
    assert html =~ "Product Details"
    assert html =~ "Price"
    assert html =~ "Category"
    assert html =~ "Product Description"
    assert html =~ "Quantity"
  end

  test "render the Product detail page", %{conn: conn, product: product} do
    # subscribe for this event to receive the live count updates
    EventHandler.subscribe_event(MiniECommerce.PubSub, "product_views:#{product.id}")

    {:ok, view, _html} = live(conn, "/live/detail/#{product.id}")
    invoke_mutilple_product_visit(conn, product.id)

    # since we invoked the detail endpoint 10 times,
    # checking the messages whether we have received 10 updates based on the count
    Enum.each(1..10, fn count ->
      receive do
        {:product_view_updated, new_count} ->
          assert count == new_count
      after
        # cheky if the message is not received in 1 second this will fail the test case
        1000 ->
          assert 1 != 1
      end
    end)

    updated_html = render(view)
    assert updated_html =~ "Watching Now: 10"
  end

  test "renders the updated inventory quantity for a given product", %{
    conn: conn,
    product: %Product{id: product_id} = _product
  } do
    # subscribe for this event to receive the live inventory updates
    EventHandler.subscribe_event(MiniECommerce.PubSub, "inventory_updater:#{product_id}")

    current_quantity = 1

    # create inventory
    create_inventory(product_id, current_quantity)

    {:ok, view, html} = live(conn, "/live/detail/#{product_id}")

    assert html =~ "Quantity: #{current_quantity}"

    modified_quantity = 66

    InventorySerivce.update(%{
      "product_id" => product_id,
      "current_quantity" => modified_quantity
    })

    # receives an updated from pubsub since subscribed for the events
    receive do
      {:updated_current_quantity, fetch_product_id, modified_quantity} ->
        assert modified_quantity == 66
        assert product_id == fetch_product_id
    after
      1000 ->
        assert 1 != 1
    end

    updated_html = render(view)
    assert updated_html =~ "Quantity: #{modified_quantity}"
  end

  defp invoke_mutilple_product_visit(conn, product_id) do
    # total renders 10
    Enum.each(1..9, fn _ ->
      live(conn, "/live/detail/#{product_id}")
    end)
  end

  defp create_product() do
    {:ok, product} = ProductSerivce.create(@product_params)
    product
  end

  defp create_inventory(product_id, current_quantity) do
    InventorySerivce.create(%{
      "product_id" => product_id,
      "current_quantity" => current_quantity
    })
  end
end
