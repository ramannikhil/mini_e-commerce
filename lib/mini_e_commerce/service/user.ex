defmodule MiniECommerce.Service.User do
  @moduledoc """
   Service responsibe for register and login
  """
  alias MiniECommerce.Schema.User
  alias MiniECommerce.Repo
  require Logger

  @doc """
   Register the user
  """
  def register_user(user_params) do
    user_changeset = User.changeset(%User{}, user_params)

    case Repo.insert(user_changeset) do
      {:ok, created_user} ->
        Logger.info("Successfully registered the user")
        {:ok, created_user}

      {:error, error_changeset} ->
        Logger.error(
          "Failed while registering the user. Check error #{inspect(error_changeset.errors)}"
        )

        {:error, :unable_to_register}
    end
  end

  @doc """
    validates the password, if successfull proceeds to login
  """
  @type email() :: String.t()
  @type password() :: String.t()

  @spec authenticate_user(%{email() => String.t(), password() => String.t()}) ::
          {:ok, %User{}} | {:error, :unauthorized | :not_found}

  def authenticate_user(%{"email" => email, "password" => password} = _user_params) do
    user = validate_user(email)

    cond do
      user && Bcrypt.verify_pass(password, user.hashed_password) ->
        {:ok, user}

      user ->
        {:error, :unauthorized}

      true ->
        {:error, :not_found}
    end
  end

  defp validate_user(email) do
    Repo.get_by(User, email: email)
  end
end
