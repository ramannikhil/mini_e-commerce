defmodule MiniECommerceWeb.Admin.Inventory.UpdateTest do
  use MiniECommerceWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  alias MiniECommerceWeb.Admin.Inventory
  alias MiniECommerce.Schema.{User, Product, Inventory}

  # import Ecto.Query
  alias MiniECommerce.Repo
  alias MiniECommerce.Service.Product, as: ProductSerivce
  alias MiniECommerce.Service.Inventory, as: InventorySerivce

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
    inventory_id = create_inventory(product_id)

    {:ok, view, html} = live(conn, "/live/admin/inventory/update")
    %{view: view, conn: conn, html: html, product_id: product_id, inventory_id: inventory_id}
  end

  describe "Update inventory" do
    test "renders the form fields", %{view: view} do
      html = render(view)

      assert html =~ "Update Inventory"
      assert html =~ "Product"
    end

    test "update the inventory current Quantity", %{
      view: view,
      product_id: product_id,
      inventory_id: inventory_id
    } do
      assert view |> element("#unique_id_inventory_product_change") |> has_element?()

      updated_html =
        view
        |> element("#unique_id_inventory_product_change")
        |> render_change(%{"_target" => ["id"], "product_id" => product_id})

      assert updated_html =~ "Current Quantity"

      # update the product details
      view
      |> form("#inventory-update-form", %{
        "product_id" => product_id,
        "current_quantity" => 22
      })
      |> render_submit()

      %Inventory{current_quantity: current_quantity} = Repo.get(Inventory, inventory_id)

      assert current_quantity == 22
      assert_redirect(view, "/live/admin/home")
    end

    test "update the inventory fails due to invalid current_quantity", %{
      view: view,
      product_id: product_id
    } do
      updated_html =
        view
        |> element("#unique_id_inventory_product_change")
        |> render_change(%{"_target" => ["id"], "product_id" => product_id})

      assert updated_html =~ "Current Quantity"

      # update the product details
      updated_html =
        view
        |> form("#inventory-update-form", %{
          "product_id" => product_id,
          "current_quantity" => ""
        })
        |> render_submit()

      assert updated_html =~ "Please Enter required fields. Product and Quantity details"
    end
  end

  test "visitor/user fails to create inventory due to missing admin access", %{conn: conn} do
    # delete the current_user from the session and try update the inventory throws an error
    conn = conn |> delete_session("current_user")

    assert {:error, {:redirect, %{to: "/login", flash: %{"error" => "Unauthorized access."}}}} ==
             live(conn, "/live/admin/inventory/update")
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

  defp create_inventory(product_id) do
    # inventory current quantity is set to '0' (default value)
    {:ok, %Inventory{id: inventory_id}} =
      InventorySerivce.create(%{"product_id" => product_id, "current_quantity" => 0})

    inventory_id
  end
end
