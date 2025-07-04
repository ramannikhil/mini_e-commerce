defmodule MiniECommerce.Service.ProductView do
  @moduledoc """
  service responsible for creating, updating the product views
  To determine the popularity for the products based on the user/ vistor views
  count is incremented based on the views that product received
  """

  import Ecto.Query
  require Logger
  alias MiniECommerce.Repo
  alias MiniECommerce.Schema.ProductView

  @doc """
  Creates a product_view

  After the product is created we created a record for product_view
  Used for tracking the product views count and displaying based on popularity

  Example:
  MiniECommerce.Service.ProductView.create(%{"product_id" => product_id})
  """
  @type product_id() :: String.t()

  @spec create(%{product_id() => binary()}) ::
          {:ok, %ProductView{}} | {:error, Ecto.Changeset.t()}
  def create(%{"product_id" => _product_id} = params) do
    %ProductView{}
    |> ProductView.changeset(params)
    |> Repo.insert()
    |> case do
      {:ok, created_product_view} ->
        Logger.info("Product view is created")
        {:ok, created_product_view}

      {:error, error_changeset} ->
        Logger.error("Error while creating product view, #{inspect(error_changeset)}")
        {:error, error_changeset}
    end
  end

  @spec update(product_id()) :: list(%ProductView{})
  def update(product_id) do
    from(v in ProductView, where: v.product_id == ^product_id)
    |> Repo.update_all(inc: [count: 1])
  end
end
