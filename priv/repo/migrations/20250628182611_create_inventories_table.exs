defmodule MiniECommerce.Repo.Migrations.CreateInventoriesTable do
  use Ecto.Migration

  def change do
    create table("inventories", primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :product_id, references("products", on_delete: :delete_all, type: :binary_id),
        null: false

      add :current_quantity, :integer

      timestamps()
    end

    create constraint("inventories", :current_quantity_must_be_positive,
             check: "current_quantity >= 0"
           )
  end
end
