defmodule MiniECommerce.Service.Inventory do
  @moduledoc """
  Responsible for creating and updating inventory records
  """

  import Ecto.Query
  require Logger
  alias MiniECommerce.Service.Inventory
  alias MiniECommerce.Repo
  alias MiniECommerce.Schema.{Inventory, Product}
  alias MiniECommerce.EventHandler

  @doc """
  create an inventory record

  Example:
   %Inventory{
   "product_id" => product_id,
   "current_quantity" => current_quantity
   }
  """
  @type product_id() :: String.t()
  @type current_quantity() :: String.t()

  @spec create(%{product_id() => binary(), current_quantity() => integer()}) ::
          {:ok, %Product{}} | {:error, :invalid_params} | {:error, :unable_to_create_inventory}
  def create(%{"product_id" => product_id, "current_quantity" => current_quantity} = params)
      when product_id not in ["", " ", nil] do
    %Inventory{}
    |> Inventory.changeset(params)
    |> Repo.insert()
    |> case do
      {:ok, created_inventory} ->
        Logger.info(
          "Inventory created for the product_id #{product_id} with quantity #{current_quantity}"
        )

        {:ok, created_inventory}

      {:error, error_changeset} ->
        Logger.error(
          "Error while creating Inventory, check the changeset errors #{inspect(error_changeset.errors)}"
        )

        {:error, :unable_to_create_inventory}
    end
  end

  def create(invalid_params) do
    Logger.error(
      "Error while creating Inventory due to Invalid params, #{inspect(invalid_params)}"
    )

    {:error, :invalid_params}
  end

  @doc """
  update an inventory record

  Example:
   %Inventory{"current_quantity" => current_quantity}
  """

  @spec update(%{product_id() => binary(), current_quantity() => integer()}) ::
          {:ok, %Inventory{}}
          | {:error, :invalid_params}
          | {:error, Ecto.Changeset.t()}
          | {:error, :product_doesnot_exist}
  def update(%{"product_id" => product_id, "current_quantity" => current_quantity} = params) do
    case check_inventory_for_product_exists?(product_id) do
      nil ->
        Logger.error(
          "Error while Updating Inventory, the product_id doesnot eixits, #{inspect(product_id)}"
        )

        {:error, :product_doesnot_exist}

      inventory_entity ->
        Inventory.changeset(inventory_entity, params)
        |> Repo.update()
        |> case do
          {:ok, %Inventory{current_quantity: updated_quantity} = updated_inventory} ->
            EventHandler.broadcast_event(
              MiniECommerce.PubSub,
              "inventory_updater:#{product_id}",
              {:updated_current_quantity, product_id, updated_quantity}
            )

            Logger.info(
              "Inventory Updated for the product_id #{product_id} with quantity #{current_quantity}"
            )

            {:ok, updated_inventory}

          {:error, error_changeset} ->
            Logger.error(
              "Error while updating Inventory, check the changeset errors #{inspect(error_changeset.errors)}"
            )

            {:error, error_changeset}
        end
    end
  end

  def update(invalid_params) do
    Logger.error(
      "Error while updating Inventory due to Invalid params, #{inspect(invalid_params)}"
    )

    {:error, :invalid_params}
  end

  defp check_inventory_for_product_exists?(product_id) do
    Repo.get_by(Inventory, %{product_id: product_id})
  end

  @doc """
  fetch list of products for which Inventory doesn't exist
  """

  @spec available_products() :: list(%Product{}) | []
  def available_products() do
    from(p in Product,
      left_join: i in Inventory,
      on: p.id == i.product_id,
      where: is_nil(i.product_id),
      select: {p.name, p.id}
    )
    |> Repo.all()
  end

  @doc """
  fetch product for the related Inventory
  """

  @spec get_product(binary()) :: %Inventory{} | nil
  def get_product(product_id) do
    from(x in Inventory,
      where: x.product_id == ^product_id,
      select: %{
        "product_id" => x.product_id,
        "current_quantity" => x.current_quantity
      }
    )
    |> Repo.one()
  end
end
