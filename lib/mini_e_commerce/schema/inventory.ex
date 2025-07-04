defmodule MiniECommerce.Schema.Inventory do
  import Ecto.Changeset
  use Ecto.Schema
  alias MiniECommerce.Schema.Product

  @moduledoc """
  Inventory Schema
  - Represents a Inventory in the MiniECommerce system.
  """

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "inventories" do
    belongs_to(:product, Product, type: :binary_id)
    field(:current_quantity, :integer)

    timestamps()
  end

  def changeset(inventory, params \\ %{}) do
    inventory
    |> cast(params, [:id, :product_id, :current_quantity])
    |> validate_required([:product_id])
    |> check_constraint(:current_quantity, name: :current_quantity_must_be_positive)
    |> foreign_key_constraint(:product_id)
  end
end
