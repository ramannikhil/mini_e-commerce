defmodule MiniECommerce.Service.Product do
  @moduledoc """
  Fetch the list of Products, Get Product by Id
  Create, Update and delete product
  """

  import Ecto.Query
  require Logger
  alias MiniECommerce.Repo
  alias MiniECommerce.Schema.{Product, ProductView, Inventory}
  alias MiniECommerce.Service.ProductView, as: ProductViewService

  @limit 12

  @doc """
  create a Product

  Example:

  Product.create(%{
   "name" => "Product_name",
    "price" => 12.12,
    "thumbnail" => "thumbnail url",
    "description" => "relavant description",
    "category" => "books"
  })
  """

  @spec create(map()) ::
          {:ok, Ecto.Schema.t()} | {:error, :invalid_params} | {:error, Ecto.Changeset.t()}
  def create(%{"name" => name, "price" => price} = product_params)
      when name not in ["", " ", nil] and not is_nil(price) and price not in ["", nil] do
    Product.changeset(%Product{}, product_params)
    |> Repo.insert()
    |> case do
      {:ok, %Product{id: product_id} = created_product} ->
        # once the product is created, we create a product_view record in DB for the product_id
        ProductViewService.create(%{"product_id" => product_id})

        Logger.info("Successfully create the Product")
        {:ok, created_product}

      {:error, error_changeset} ->
        Logger.error(
          "Error while creating product, check the changeset errors #{inspect(error_changeset.errors)}"
        )

        {:error, error_changeset.errors}
    end
  end

  def create(invalid_params) do
    Logger.error("Error while creating a product, #{inspect(invalid_params)}")
    {:error, :invalid_params}
  end

  @doc """
  update the product

  Example:

  Product.update(%{"id" => "73ff528e-c43d-422f-9826-a1109bfb75e0"})
  """
  @spec update(map()) ::
          {:ok, Ecto.Schema.t()}
          | {:error, :product_not_found}
          | {:error, :invalid_params}
          | {:error, Ecto.Changeset.t()}
  def update(%{"id" => product_id} = product_params) when product_id not in ["", " ", nil] do
    with product_entity when not is_nil(product_entity) <- fetch_product(product_id),
         product_changeset = Product.changeset(product_entity, product_params),
         {:ok, updated_product} <- Repo.update(product_changeset) do
      Logger.info("Product details updated successfully. #{inspect(updated_product)}")
      {:ok, updated_product}
    else
      nil ->
        Logger.error("Error while fetching the Product by id. Product Id: #{inspect(product_id)}")
        {:error, :product_not_found}

      {:error, error_changset} ->
        Logger.error(
          "Error while updating the Product, Changeset errors: #{inspect(error_changset.errors)}"
        )

        {:error, error_changset}
    end
  end

  def update(invalid_params) do
    Logger.error("Error while updating the  product, #{inspect(invalid_params)}")
    {:error, :invalid_params}
  end

  @doc """
  delete the product

  Example:
  Product.delete(%{"id" => "73ff528e-c43d-422f-9826-a1109bfb75e0"})
  """
  # @spec create(%{String.t() => String.t()}) ::
  # {:ok, %Product{}} | {:error, :invalid_params} | {:error, map()} |  {:error, :product_not_found}
  @type id() :: String.t()
  @spec delete(%{id() => binary()} | map()) ::
          {:ok, Ecto.Schema.t()}
          | {:error, :product_not_found}
          | {:error, :invalid_params}
          | {:error, Ecto.Changeset.t()}
  def delete(%{"id" => product_id}) when product_id not in ["", " ", nil] do
    with product_entity when not is_nil(product_entity) <- fetch_product(product_id),
         {:ok, deleted_product} <- Repo.delete(product_entity) do
      Logger.info(
        "Successfully Deleted the product. For Product Id: #{inspect(product_id)}, #{inspect(deleted_product)}"
      )

      {:ok, deleted_product}
    else
      nil ->
        Logger.error("Error while fetching the Product by id. Product Id: #{inspect(product_id)}")
        {:error, :product_not_found}

      {:error, error_changset} ->
        Logger.error("Error while deleting the product. #{inspect(error_changset)}")
        {:error, error_changset}
    end
  end

  def delete(invalid_params) do
    Logger.error("Error while deleting the  product, #{inspect(invalid_params)}")
    {:error, :invalid_params}
  end

  @doc """
    fetch list of products based on filters
  """
  @type product() :: Ecto.Schema.t()
  @spec list(map()) ::
          %{products: list(), total_pages: integer()}
          | {:error, :invalid_params}
          | list(product())
  def list(
        %{
          "category" => category,
          "sort_by" => sort_by,
          "sort_column" => sort_column,
          "page" => page
        } = _params
      )
      when category != " " do
    {page, _} = Integer.parse(page)

    base_query = from(x in Product)
    sorted_query = sorted_query(base_query, sort_column, sort_by)
    category_query = category_query(sorted_query, category)
    product_query = products_include_inventory(category_query, sort_column)

    products = paginated_query(product_query, page)
    total_records = from(x in subquery(category_query)) |> Repo.aggregate(:count)

    %{
      products: products,
      total_pages: ceil(total_records / @limit)
    }
  end

  def list(%{}) do
    base_query()
    |> Repo.all()
  end

  def list(invalid_params) do
    Logger.error(
      "Error while fetching products due to invalid params, #{inspect(invalid_params)}"
    )

    {:error, :invalid_params}
  end

  defp base_query() do
    from(x in Product,
      select: %{
        "id" => x.id,
        "name" => x.name,
        "thumbnail" => x.thumbnail,
        "description" => x.description,
        "price" => x.price,
        "category" => x.category
      }
    )
  end

  defp sorted_query(base_query, sort_column, sort_by) do
    sort_column = String.to_atom(sort_column)

    case sort_column do
      :popularity ->
        fetch_product_query_based_on_popularity(sort_by)

      _ ->
        case sort_by do
          "asc" ->
            from(x in base_query, order_by: ^sort_column)

          "desc" ->
            from(x in base_query, order_by: [desc: ^sort_column])
        end
    end
  end

  defp fetch_product_query_based_on_popularity(sort_by) do
    case sort_by do
      "desc" ->
        from(p in Product,
          left_join: v in ProductView,
          on: v.product_id == p.id,
          left_join: i in Inventory,
          on: i.product_id == p.id,
          group_by: [p.id, v.count, i.id],
          order_by: [desc: v.count],
          select: %{
            quantity: i.current_quantity
          }
        )

      "asc" ->
        from(p in Product,
          left_join: v in ProductView,
          on: v.product_id == p.id,
          left_join: i in Inventory,
          on: i.product_id == p.id,
          group_by: [p.id, v.count, i.id],
          order_by: v.count,
          select: %{
            quantity: i.current_quantity
          }
        )
    end
  end

  defp category_query(sorted_query, category) do
    case category do
      category when category in ["", nil] ->
        sorted_query

      _ ->
        category = String.to_atom(category)

        from(x in sorted_query, where: x.category == ^category)
    end
  end

  defp paginated_query(category_query, page) do
    category_query
    |> limit(^@limit)
    |> offset(^((page - 1) * @limit))
    |> Repo.all()
  end

  defp products_include_inventory(category_query, sort_column) do
    case sort_column do
      "popularity" ->
        from(x in category_query,
          select_merge: %{
            id: x.id,
            name: x.name,
            thumbnail: x.thumbnail,
            description: x.description,
            price: x.price,
            category: x.category
          }
        )

      _ ->
        from(x in category_query,
          left_join: i in Inventory,
          on: x.id == i.product_id,
          select: %{
            id: x.id,
            name: x.name,
            thumbnail: x.thumbnail,
            description: x.description,
            price: x.price,
            category: x.category,
            quantity: i.current_quantity
          }
        )
    end
  end

  defp fetch_product(product_id) do
    from(x in Product,
      where: x.id == ^product_id
    )
    |> Repo.one()
  end

  @doc """
  Get product by Id, includes, Inventory
  """

  @spec get_product_with_inventory(binary()) :: map() | nil
  def get_product_with_inventory(product_id) do
    from(p in Product,
      join: i in Inventory,
      on: p.id == i.product_id,
      where: p.id == ^product_id,
      select: %{
        "id" => p.id,
        "name" => p.name,
        "thumbnail" => p.thumbnail,
        "description" => p.description,
        "price" => p.price,
        "category" => p.category,
        "quantity" => i.current_quantity
      }
    )
    |> Repo.one()
  end

  @doc """
  Get product by Id
  """
  @spec get_product_with_inventory(binary()) :: map() | nil
  def get_product_by_id(product_id) do
    from(p in Product,
      where: p.id == ^product_id,
      select: %{
        "id" => p.id,
        "name" => p.name,
        "thumbnail" => p.thumbnail,
        "description" => p.description,
        "price" => p.price,
        "category" => p.category
      }
    )
    |> Repo.one()
  end
end
