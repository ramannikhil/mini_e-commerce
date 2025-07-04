defmodule MiniECommerce.Schema.User do
  import Ecto.Changeset
  use Ecto.Schema

  @moduledoc """
  User schema responsible for mainitaing the user details
  - Used for storing Admins & Visitors
  - In the current code use case this is used only for Admin
  """

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "users" do
    field(:name, :string)
    field(:email, :string)
    field(:password, :string, virtual: true)
    field(:hashed_password, :string)
    field(:role, Ecto.Enum, values: [:admin, :visitor], default: :visitor)

    timestamps()
  end

  def changeset(user, params \\ %{}) do
    user
    |> cast(params, [:id, :name, :email, :password, :role, :hashed_password])
    |> validate_required([:name, :email, :password])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must be a valid email address")
    |> unique_constraint([:email], name: :users_email_has_to_be_unqiue)
    |> put_password_hash()
  end

  defp put_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(changeset, :hashed_password, Bcrypt.hash_pwd_salt(password))

      _ ->
        changeset
    end
  end
end
