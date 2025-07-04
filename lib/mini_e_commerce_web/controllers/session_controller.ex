defmodule MiniECommerceWeb.SessionController do
  use MiniECommerceWeb, :controller
  alias MiniECommerce.Service.User, as: UserService
  alias MiniECommerce.Schema.User

  @moduledoc """
  Reponsible for authenticating the Admin User and updating the user session
  """

  def new(conn, _params) do
    render(conn, :login)
  end

  @doc """
  configures a admin user session
  """
  def create(conn, user_params) do
    case UserService.authenticate_user(user_params) do
      {:ok, %User{role: :admin} = user} ->
        conn
        |> put_session(:current_user, %{
          "id" => user.id,
          "email" => user.email,
          "role" => user.role
        })
        |> configure_session(renew: true)
        |> put_flash(:info, "Login Successful.")
        |> redirect(to: "/live/admin/home")

      # If the user doesn't exist or the credentials passed were incorrect
      # throwing a common error, to avoid Email enumeration attacks
      _ ->
        conn
        |> put_flash(:error, "Invalid credentials.")
        |> redirect(to: "/login")
    end
  end

  def delete(conn, _params) do
    conn
    |> delete_session("current_user")
    |> configure_session(drop: true)
    |> redirect(to: "/login")
  end
end
