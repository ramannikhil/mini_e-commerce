defmodule MiniECommerceWeb.Admin.Product.CreateTest do
  use MiniECommerceWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  alias MiniECommerce.Schema.{User, Product}
  alias MiniECommerce.Repo
  import Ecto.Query

  @admin_creds %{
    "name" => "admin_user",
    "email" => "admin@example.com",
    "role" => :admin,
    "password" => "secret123"
  }

  setup %{conn: conn} do
    conn = insert_admin_and_update_conn(conn)
    {:ok, view, _html} = live(conn, "/live/admin/products/create")

    %{view: view, conn: conn}
  end

  describe "Create Product" do
    test "renders the form fields", %{view: view} do
      html = render(view)
      assert html =~ "Create Product"
      assert html =~ "Name"
      assert html =~ "Description"
      assert html =~ "Category"
      assert html =~ "Price"
      assert html =~ "Thumbnail URL"
    end

    test "submits valid product params and redirects", %{conn: conn} do
      valid_params = %{
        "name" => "Baby cloths",
        "description" => "Product related to babies",
        "category" => "books",
        "price" => "49.99",
        "thumbnail" => "http://example.com/image.jpg"
      }

      {:ok, view, _html} = live(conn, "/live/admin/products/create")

      form = element(view, "#product-create-form")
      render_submit(form, valid_params)

      assert_redirect(view, "/live/admin/home")

      # check whether the records exists in the DB
      assert from(x in Product, where: x.name == "Baby cloths") |> Repo.exists?()
    end

    test "submits invalid product params and shows flash error", %{conn: conn} do
      invalid_params = %{
        "name" => "",
        "price" => "",
        "description" => "",
        "category" => "",
        "thumbnail" => ""
      }

      {:ok, view, _html} = live(conn, "/live/admin/products/create")

      form = element(view, "#product-create-form")
      result_html = render_submit(form, invalid_params)

      assert result_html =~ "Please Enter required field. Name and Price details"
    end
  end

  test "visitor/user fails to create product due to missing admin access", %{conn: conn} do
    # delete the current_user from the session and try creating a product throws an error
    conn = conn |> delete_session("current_user")

    assert {:error, {:redirect, %{to: "/login", flash: %{"error" => "Unauthorized access."}}}} ==
             live(conn, "/live/admin/products/create")
  end

  defp insert_admin_and_update_conn(conn) do
    {:ok, %User{id: user_id, email: email, role: role}} =
      %User{}
      |> User.changeset(@admin_creds)
      |> Repo.insert()

    conn
    |> init_test_session(current_user: %{"id" => user_id, "email" => email, "role" => role})
  end
end
