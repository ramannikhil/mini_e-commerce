defmodule MiniECommerceWeb.Admin.Product.DeleteTest do
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
    {:ok, view, html} = live(conn, "/live/admin/products/delete")

    %{view: view, conn: conn, html: html, product_id: product_id}
  end

  describe "Delete Product" do
    test "renders the forms fields", %{view: view} do
      html = render(view)

      assert html =~ "Delete Product"
      assert html =~ "Product"
    end

    test "renders the whole form on selecting the product from dropdown", %{
      view: view,
      product_id: product_id
    } do
      assert view |> element("#unique_id_for_delete_product") |> has_element?()

      # selects the product_id from the form, which will display all the form fields on change
      updated_html =
        view
        |> element("#unique_id_for_delete_product")
        |> render_change(%{"_target" => ["id"], "id" => product_id})

      assert updated_html =~ "Name"
      assert updated_html =~ "Description"
      assert updated_html =~ "Price"
      assert updated_html =~ "Category"
    end

    test "delete the product", %{view: view, product_id: product_id} do
      view
      |> element("#unique_id_for_delete_product")
      |> render_change(%{"_target" => ["id"], "id" => product_id})

      # delete the product details
      view
      |> form("#product-delete-form", %{"id" => product_id})
      |> render_submit()

      assert_redirect(view, "/live/admin/home")

      # product is deleted
      refute Repo.get(Product, product_id)
    end

    test "delete the product for unselecting the product", %{view: view, product_id: product_id} do
      view
      |> element("#unique_id_for_delete_product")
      |> render_change(%{"_target" => ["id"], "id" => product_id})

      view
      |> element("#unique_id_for_delete_product")
      |> render_change(%{"_target" => ["id"], "id" => ""})

      # update the product details
      html =
        view
        |> form("#product-delete-form", %{
          "id" => ""
        })
        |> render_submit()

      assert html =~ "Please choose the product"
      # assert html =~ "is invalid"
    end
  end

  test "visitor/user fails to deleting product due to missing admin access", %{conn: conn} do
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
