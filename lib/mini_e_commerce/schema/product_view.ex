defmodule MiniECommerce.Schema.ProductView do
  import Ecto.Changeset
  use Ecto.Schema
  alias MiniECommerce.Schema.Product

  @moduledoc """
   ProductView Schema
  - Represents a ProductView in the MiniECommerce system.
  """

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "product_views" do
    belongs_to(:product, Product, type: :binary_id)
    field(:count, :integer, default: 0)

    timestamps()
  end

  def changeset(product_view, params \\ %{}) do
    product_view
    |> cast(params, [:id, :product_id, :count])
    |> validate_required([:product_id, :count])
    |> foreign_key_constraint(:product_id)
  end
end
