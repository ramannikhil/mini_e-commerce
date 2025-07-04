defmodule MiniECommerceWeb.Admin.Inventory.CreateTest do
  use MiniECommerceWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  alias MiniECommerceWeb.Admin.Inventory
  alias MiniECommerce.Schema.{User, Product, Inventory}
  import Ecto.Query
  alias MiniECommerce.Repo
  alias MiniECommerce.Service.Product, as: ProductSerivce

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

    {:ok, view, html} = live(conn, "/live/admin/inventory/create")
    %{view: view, conn: conn, html: html, product_id: product_id}
  end

  describe "Create Inventory" do
    test "renders the form fields", %{view: view} do
      html = render(view)

      assert html =~ "Create Inventory"
      assert html =~ "Product"
      assert html =~ "Current Quantity"
    end

    test "submits valid product params and redirects", %{conn: conn, product_id: product_id} do
      valid_params = %{
        "product_id" => product_id,
        "current_quantity" => 10
      }

      {:ok, view, _html} = live(conn, "/live/admin/inventory/create")

      form = element(view, "#inventory-create-form")
      render_submit(form, valid_params)

      # check whether the Db record is updated
      %Inventory{current_quantity: current_quantity} =
        from(x in Inventory, where: x.product_id == ^product_id) |> Repo.one()

      assert current_quantity == 10
      assert_redirect(view, "/live/admin/home")
    end

    test "error while creating a product due to invalid quantity", %{
      conn: conn,
      product_id: product_id
    } do
      {:ok, view, _html} = live(conn, "/live/admin/inventory/create")

      invalid_params = %{
        "product_id" => product_id,
        "current_quantity" => ""
      }

      view
      |> form("#inventory-create-form", invalid_params)
      |> render_submit()

      assert has_element?(
               view,
               "div",
               "Please Enter required fields. Product and Quantity details"
             )
    end
  end

  test "visitor/user fails to create inventory due to missing admin access", %{conn: conn} do
    # delete the current_user from the session and try creating a inventory throws an error
    conn = conn |> delete_session("current_user")

    assert {:error, {:redirect, %{to: "/login", flash: %{"error" => "Unauthorized access."}}}} ==
             live(conn, "/live/admin/inventory/create")
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
