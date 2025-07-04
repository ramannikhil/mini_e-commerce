defmodule MiniECommerceWeb.Admin.Product.UpdateTest do
  use MiniECommerceWeb.ConnCase, async: true

  alias MiniECommerce.Service.Product, as: ProductSerivce
  alias MiniECommerce.Schema.{User, Product}
  alias MiniECommerce.Repo
  import Phoenix.LiveViewTest

  @admin_creds %{
    "name" => "admin_user",
    "email" => "admin@example.com",
    "role" => :admin,
    "password" => "secret123"
  }

  @product_params %{
    "name" => "Baby cloths",
    "description" => "Product related to babies",
    "category" => "books",
    "price" => "49.99",
    "thumbnail" => "http://example.com/image.jpg"
  }

  setup %{conn: conn} do
    conn = insert_admin_and_update_conn(conn)
    product_id = create_product()
    {:ok, view, html} = live(conn, "/live/admin/products/update")

    %{view: view, conn: conn, html: html, product_id: product_id}
  end

  describe "Update Product form" do
    test "renders the forms fields", %{view: view} do
      html = render(view)
      assert html =~ "Update Product"
      assert html =~ "Product"
    end

    test "renders the whole form on selecting the product from dropdown", %{
      view: view,
      product_id: product_id
    } do
      assert view |> element("#unique_id_for_update_product") |> has_element?()

      # selects the product_id from the form,
      #  will display all the form fields on product  selection change
      updated_html =
        view
        |> element("#unique_id_for_update_product")
        |> render_change(%{"_target" => ["id"], "id" => product_id})

      assert updated_html =~ "Name"
      assert updated_html =~ "Description"
      assert updated_html =~ "Price"
      assert updated_html =~ "Thumbnail URL"
    end

    test "update the product", %{view: view, product_id: product_id} do
      view
      |> element("#unique_id_for_update_product")
      |> render_change(%{"_target" => ["id"], "id" => product_id})

      # update the product details
      view
      |> form("#product-update-form", %{
        "id" => product_id,
        "name" => "Baby Cloth 2.0",
        "description" => "Updated Description for baby products",
        "price" => "99.99"
      })
      |> render_submit()

      %Product{
        description: updated_description,
        price: updated_price,
        name: updated_name
      } = Repo.get(Product, product_id)

      assert updated_name == "Baby Cloth 2.0"
      assert updated_price == Decimal.new("99.99")
      assert updated_description == "Updated Description for baby products"

      assert_redirect(view, "/live/admin/home")
    end

    test "update the product fails due to invalid price", %{view: view, product_id: product_id} do
      view
      |> element("#unique_id_for_update_product")
      |> render_change(%{"_target" => ["id"], "id" => product_id})

      # update the product details
      html =
        view
        |> form("#product-update-form", %{
          "id" => product_id,
          "name" => "Baby Cloth 2.0",
          "description" => "Updated Description for baby products",
          "price" => "invalid_price"
        })
        |> render_submit()

      assert html =~ "Error while updating the product"
      assert html =~ "is invalid"
    end

    test "update the product fails due to missing field", %{view: view, product_id: product_id} do
      view
      |> element("#unique_id_for_update_product")
      |> render_change(%{"_target" => ["id"], "id" => product_id})

      html =
        view
        |> form("#product-update-form", %{
          "id" => product_id,
          "name" => "",
          "description" => "",
          "price" => ""
        })
        |> render_submit()

      assert html =~ "Error while updating the product"
    end
  end

  test "visitor/user fails to updating product due to missing admin access", %{conn: conn} do
    # delete the current_user from the session and try creating a product throws an error
    conn = conn |> delete_session("current_user")

    assert {:error, {:redirect, %{to: "/login", flash: %{"error" => "Unauthorized access."}}}} ==
             live(conn, "/live/admin/products/update")
  end

  defp insert_admin_and_update_conn(conn) do
    {:ok, %User{id: user_id, email: email, role: role}} =
      %User{}
      |> User.changeset(@admin_creds)
      |> Repo.insert()

    conn
    |> init_test_session(current_user: %{"id" => user_id, "email" => email, "role" => role})
  end

  defp create_product() do
    {:ok, %Product{id: product_id}} = ProductSerivce.create(@product_params)
    product_id
  end
end
