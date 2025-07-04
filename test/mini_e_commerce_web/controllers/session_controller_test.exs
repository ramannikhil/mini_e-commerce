defmodule MiniECommerceWeb.SessionControllerTest do
  use MiniECommerceWeb.ConnCase, async: true
  alias MiniECommerce.Schema.User
  alias MiniECommerce.Repo

  describe "POST /session" do
    test "logs in admin successfully and redirects to home page", %{conn: conn} do
      admin_user =
        insert_admin_record(%{
          name: "admin123",
          email: "admin@example.com",
          password: "secret123",
          role: :admin
        })

      conn =
        post(conn, ~p"/session", %{"email" => admin_user.email, "password" => "secret123"})

      assert redirected_to(conn) == "/live/admin/home"
      assert get_session(conn, :current_user)["email"] == admin_user.email
      assert Phoenix.Flash.get(conn.assigns[:flash], :info) == "Login Successful."
    end

    test "fails login with invalid credentials", %{conn: conn} do
      insert_admin_record(%{
        name: "random_user",
        email: "admin@example.com",
        password: "secret123",
        role: :admin
      })

      conn =
        post(conn, ~p"/session", %{
          "email" => "admin@example.com",
          "password" => "incorrect_password"
        })

      assert redirected_to(conn) == "/login"
      assert Phoenix.Flash.get(conn.assigns[:flash], :error) == "Invalid credentials."
    end
  end

  describe "DELETE /logout" do
    test "clears session and redirects to login page", %{conn: conn} do
      conn =
        conn
        |> init_test_session(
          current_user: %{"id" => 1, "email" => "admin@example.com", "role" => :admin}
        )
        |> delete(~p"/logout")

      assert redirected_to(conn) == "/login"
      refute get_session(conn, :current_user)
    end
  end

  defp insert_admin_record(user_params) do
    {:ok, user} =
      %User{}
      |> User.changeset(user_params)
      |> Repo.insert()

    user
  end
end
