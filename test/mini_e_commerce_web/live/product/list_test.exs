defmodule MiniECommerceWeb.Product.ListTest do
  use MiniECommerceWeb.ConnCase, async: true

  alias MiniECommerce.Service.Product, as: ProductSerivce
  alias MiniECommerce.Service.Inventory, as: InventorySerivce
  alias MiniECommerce.Schema.Product
  alias MiniECommerce.Repo
  import Phoenix.LiveViewTest
  import Ecto.Query

  @book_product_params %{
    "description" => "Product related to books",
    "category" => :books
  }

  @clothing_product_params %{
    "description" => "Product related to clothing",
    "category" => :clothing
  }
  @sports_product_params %{
    "description" => "Product related to sports",
    "category" => :sports
  }

  @default_page "1"

  @default_filters %{
    "category" => "",
    "sort_by" => "desc",
    "sort_column" => "updated_at",
    "page" => @default_page
  }

  @limit 12

  setup %{conn: conn} do
    create_products()
    {:ok, view, html} = live(conn, "/live/list")

    %{view: view, conn: conn, html: html}
  end

  describe "List page" do
    test "renders the forms fields", %{view: view} do
      html = render(view)
      assert html =~ "Category"
      assert html =~ "Column"
      assert html =~ "Apply Filters"
      assert html =~ "Sort By"
      assert html =~ "Clear filters"
      assert html =~ "Previous"
      assert html =~ "Next"
      assert html =~ "Page"
    end

    test "render list page with default params", %{view: view} do
      html = render(view)

      # check all the products are rendered using the @default_filters
      %{products: products, total_pages: total_pages} = ProductSerivce.list(@default_filters)

      assert length(products) == 12
      assert total_pages == ceil(30 / @limit)

      products
      |> Enum.each(fn %{
                        name: name,
                        description: description,
                        price: price,
                        category: category,
                        quantity: quantity
                      } ->
        assert html =~ "#{name}"
        assert html =~ "#{description}"
        assert html =~ "#{price}"
        assert html =~ "#{category}"
        assert html =~ "#{quantity}"
      end)
    end

    test "render list page with filter category type is books", %{view: view} do
      render(view)

      # currently there are 10 records in our test case for type books
      products_related_books =
        from(x in Product, where: x.category == :books, limit: @limit) |> Repo.all()

      assert view |> element("#unique_id_for_category_filters") |> has_element?()

      view
      |> element("form[phx-submit=handle_submit_filters]")
      |> render_submit(%{
        "category" => "books"
      })

      updated_html = render(view)

      products_related_books
      |> Enum.each(fn %Product{
                        name: name,
                        description: description,
                        price: price,
                        category: category
                      } ->
        assert updated_html =~ "#{name}"
        assert updated_html =~ "#{description}"
        assert updated_html =~ "#{price}"
        assert updated_html =~ "#{category}"
      end)
    end

    test "render list page with filter sort_column is price", %{view: view} do
      render(view)

      sort_products_by_price_desc =
        from(x in Product, order_by: [desc: x.price], limit: @limit) |> Repo.all()

      assert view |> element("#unique_id_for_sort_column_filters") |> has_element?()

      view
      |> element("form[phx-submit=handle_submit_filters]")
      |> render_submit(%{
        "sort_column" => "price"
      })

      updated_html = render(view)

      sort_products_by_price_desc
      |> Enum.each(fn %Product{
                        name: name,
                        description: description,
                        price: price,
                        category: category
                      } ->
        assert updated_html =~ "#{name}"
        assert updated_html =~ "#{description}"
        assert updated_html =~ "#{price}"
        assert updated_html =~ "#{category}"
      end)
    end

    test "render list page with filter sort_by ascending, sort_column is name", %{view: view} do
      render(view)

      sort_products_by_name_asc =
        from(x in Product, order_by: x.name, limit: @limit) |> Repo.all()

      assert view |> element("#unique_id_for_sort_by_filters") |> has_element?()

      view
      |> element("form[phx-submit=handle_submit_filters]")
      |> render_submit(%{
        "sort_by" => "asc",
        "sort_column" => "name"
      })

      updated_html = render(view)

      sort_products_by_name_asc
      |> Enum.each(fn %Product{
                        name: name,
                        description: description,
                        price: price,
                        category: category
                      } ->
        assert updated_html =~ "#{name}"
        assert updated_html =~ "#{description}"
        assert updated_html =~ "#{price}"
        assert updated_html =~ "#{category}"
      end)
    end

    test "render records based on pagination, for page 3 and price is descending", %{view: view} do
      render(view)

      page = 3
      # since we have 30 records in test DB, page 3 will have 6 records left,
      # check if the same products were rendered
      products =
        from(x in Product, limit: @limit, offset: (^page - 1) * @limit, order_by: [desc: :price])
        |> Repo.all()

      assert view |> element("#unqiue_id_for_previous_page") |> has_element?()
      assert view |> element("#unqiue_id_for_next_page") |> has_element?()

      # sort by price -> descending
      view
      |> element("form[phx-submit=handle_submit_filters]")
      |> render_submit(%{
        "sort_by" => "desc",
        "sort_column" => "price"
      })

      # click twice to reach last page
      view
      |> element("button#unqiue_id_for_next_page")
      |> render_click()

      view
      |> element("button#unqiue_id_for_next_page")
      |> render_click()

      updated_html = render(view)

      products
      |> Enum.each(fn %Product{
                        name: name,
                        description: description,
                        price: price,
                        category: category
                      } ->
        assert updated_html =~ "#{name}"
        assert updated_html =~ "#{description}"
        assert updated_html =~ "#{price}"
        assert updated_html =~ "#{category}"
      end)
    end

    test "check whether previous and next button clicks are working fine", %{view: view} do
      render(view)

      assert view |> element("#unqiue_id_for_previous_page") |> has_element?()
      assert view |> element("#unqiue_id_for_next_page") |> has_element?()

      # incase the pages are out of box, test case throws an error

      # click twice the Next button to reach last page
      view
      |> element("button#unqiue_id_for_next_page")
      |> render_click()

      view
      |> element("button#unqiue_id_for_next_page")
      |> render_click()

      # click twice the Previous button to reach first page
      view
      |> element("button#unqiue_id_for_previous_page")
      |> render_click()

      view
      |> element("button#unqiue_id_for_previous_page")
      |> render_click()
    end

    test "clear filters", %{conn: conn} do
      {:ok, view, html} =
        live(conn, "/live/list?category=sports&page=1&sort_by=desc&sort_column=updated_at")

      render(view)

      assert from(x in Product, where: x.category == :sports) |> Repo.all() |> length == 10

      # initially only 10 time Quantity: is rendered because of 10 products
      occurrences = (String.split(html, "Quantity:") |> length()) - 1
      assert occurrences == 10

      assert view |> element("#unique_id_for_clear_filters") |> has_element?()

      # on clearing the filters
      view
      |> element("#unique_id_for_clear_filters")
      |> render_click()

      updated_html = render(view)

      # once the filters are removed the products are rendered back with @limit 12
      occurrences = (String.split(updated_html, "Quantity:") |> length()) - 1
      assert occurrences == @limit
    end
  end

  describe "Broadcast event" do
    test "get the updates from the Pubsub when the inventory is updated for a product", %{
      conn: conn
    } do
      # pick 1 random product and create an inventory for that product
      # make sure this product is loaded in the first page
      %Product{id: product_id} =
        from(x in Product, order_by: [desc: x.updated_at], limit: 1) |> Repo.one()

      # set current_quantity to 1
      current_quantity = 1

      # subscribe to the event
      MiniECommerce.EventHandler.subscribe_event(
        MiniECommerce.PubSub,
        "inventory_updater:#{product_id}"
      )

      # create inventory
      create_inventory(product_id, current_quantity)

      %{
        "product_id" => product_id,
        "current_quantity" => updated_quantity
      } = InventorySerivce.get_product(product_id)

      assert updated_quantity == 1

      {:ok, view, html} = live(conn, "/live/list")

      assert html =~ "Quantity: #{updated_quantity}"

      modified_quantity = 123

      InventorySerivce.update(%{
        "product_id" => product_id,
        "current_quantity" => modified_quantity
      })

      # receives an updated from pubsub since subscribed for the events
      receive do
        {:updated_current_quantity, fetch_product_id, modified_quantity} ->
          assert modified_quantity == 123
          assert product_id == fetch_product_id
      after
        # cheky if the message is not received in 1 second this will fail the test case
        1000 ->
          assert 1 != 1
      end

      updated_html = render(view)

      assert updated_html =~ "Quantity: #{modified_quantity}"
    end
  end

  defp create_products() do
    # product of type :books
    Enum.each(1..10, fn index ->
      create_record(@book_product_params, "Book", index)
    end)

    # product of type :clothing
    Enum.each(1..10, fn index ->
      create_record(@clothing_product_params, "Clothing", index)
    end)

    # product of type :sports
    Enum.each(1..10, fn index ->
      create_record(@sports_product_params, "Sports", index)
    end)
  end

  defp create_record(product_params, type, index) do
    price = Enum.random(10..1000)

    updated_params =
      product_params
      |> Map.merge(%{"name" => "#{type} Product #{index}", "price" => price})

    ProductSerivce.create(updated_params)
  end

  defp create_inventory(product_id, current_quantity) do
    InventorySerivce.create(%{
      "product_id" => product_id,
      "current_quantity" => current_quantity
    })
  end
end
