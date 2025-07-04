defmodule MiniECommerce.Repo.Migrations.CreateUsersTable do
  use Ecto.Migration

  def change do
    execute("CREATE TYPE role_enum AS ENUM ('admin', 'visitor')")

    create table("users", primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :email, :string
      add :hashed_password, :text
      add :role, :role_enum, null: false, default: "visitor"

      timestamps()
    end

    create unique_index("users", [:email], name: :users_email_has_to_be_unqiue)
  end
end
