defmodule MiniECommerce.Schema.Product do
  import Ecto.Changeset
  use Ecto.Schema

  @moduledoc """
  Product Schema
  - Represents a product in the MiniECommerce system.
  """

  @category_enum ~w(books electronics clothing food sports baby)a

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "products" do
    field(:name, :string)
    field(:thumbnail, :string)
    field(:description, :string)
    field(:price, :decimal)
    field(:category, Ecto.Enum, values: @category_enum)

    timestamps()
  end

  def changeset(product, params \\ %{}) do
    product
    |> cast(params, [:id, :name, :description, :price, :category, :thumbnail])
    |> validate_required([:name, :price, :category])
    |> unique_constraint([:name], name: :product_name_has_to_be_unqiue)
  end

  def category_enum(), do: @category_enum
end
