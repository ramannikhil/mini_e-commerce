defmodule MiniECommerce.Repo.Migrations.CreateProductViewsTable do
  use Ecto.Migration

  def change do
    create table("product_views", primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :product_id, references("products", on_delete: :delete_all, type: :binary_id),
        null: false

      add :count, :integer, default: 0

      timestamps()
    end
  end
end
