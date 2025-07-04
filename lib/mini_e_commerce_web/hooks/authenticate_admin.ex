defmodule MiniECommerceWeb.Hooks.AuthenticateAdmin do
  use MiniECommerceWeb, :live_view
  import Phoenix.Component

  @moduledoc """
  Provides LiveView `on_mount/4` hooks for enforcing admin authentication.

  This module defines an `:admin_auth` mount hook that checks whether the current
  user stored in the session has an admin role. If the user is an admin, they are
  assigned to the LiveView socket. Otherwise, the LiveView mounting is halted, an
  error flash message is set, and the user is redirected to the login page.
  """

  def on_mount(:admin_auth, _params, session, socket) do
    case session["current_user"] do
      %{"role" => :admin} = user ->
        {:cont, assign(socket, :current_user, user)}

      _ ->
        {:halt,
         socket
         |> put_flash(:error, "Unauthorized access.")
         |> redirect(to: "/login")}
    end
  end
end
