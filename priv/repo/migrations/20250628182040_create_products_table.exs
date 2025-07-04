defmodule MiniECommerce.Repo.Migrations.CreateProductsTable do
  use Ecto.Migration

  def change do
    execute(
      "CREATE TYPE category_enum AS ENUM ('books', 'electronics', 'clothing', 'food', 'sports', 'baby')"
    )

    create table("products", primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :thumbnail, :string
      add :description, :text
      add :category, :category_enum, null: false
      add :price, :decimal

      timestamps()
    end

    create unique_index("products", [:name], name: :product_name_has_to_be_unqiue)
  end
end
