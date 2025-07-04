defmodule MiniECommerceWeb.Service.InventoryTest do
  use ExUnit.Case, async: true
  use MiniECommerce.DataCase

  alias MiniECommerce.Schema.{Inventory, Product}
  alias MiniECommerce.Service.Product, as: ProductService
  alias MiniECommerce.Service.Inventory, as: InventoryService

  # current_quantity set to 1
  @current_quantity 1

  setup context do
    product_params = %{
      "name" => "Baby cloths",
      "description" => "Product related to babies",
      "category" => :books,
      "price" => "49.99",
      "thumbnail" => "http://example.com/image.jpg"
    }

    product_id = create_product(product_params)

    inventory_params = %{"product_id" => product_id, "current_quantity" => @current_quantity}

    inventory_id =
      case Map.get(context, :flag) do
        true -> create_inventory(inventory_params)
        nil -> nil
      end

    {:ok,
     %{
       product_params: product_params,
       product_id: product_id,
       inventory_id: inventory_id,
       inventory_params: inventory_params
     }}
  end

  describe "Create Inventory" do
    test "create inventory with valid params", %{
      inventory_params: inventory_params,
      product_id: product_id
    } do
      {:ok,
       %Inventory{
         product_id: product_id_from_db,
         current_quantity: current_quantity_from_db
       }} = InventoryService.create(inventory_params)

      assert product_id == product_id_from_db
      assert @current_quantity == current_quantity_from_db
    end

    test "create inventory fails due to invalid product_id", %{inventory_params: inventory_params} do
      updated_params = inventory_params |> Map.merge(%{"product_id" => ""})
      assert {:error, :invalid_params} == InventoryService.create(updated_params)
    end

    test "create inventory fails due to invalid quantity", %{inventory_params: inventory_params} do
      updated_params = inventory_params |> Map.merge(%{"current_quantity" => "invalid_quantity"})
      assert {:error, :unable_to_create_inventory} == InventoryService.create(updated_params)
    end
  end

  describe "Update Inventory" do
    @tag flag: true
    test "updated inventory with valid params", %{inventory_params: inventory_params} do
      quantity = 88
      updated_params = inventory_params |> Map.merge(%{"current_quantity" => quantity})

      {:ok, %Inventory{current_quantity: updated_quantity}} =
        InventoryService.update(updated_params)

      assert updated_quantity == quantity
    end

    @tag flag: true
    test "updated inventory fails due to invalid qunatity", %{inventory_params: inventory_params} do
      updated_params = inventory_params |> Map.merge(%{"current_quantity" => "invalid_qunatity"})

      {:error, error_changeset} = InventoryService.update(updated_params)

      assert [
               current_quantity: {"is invalid", [type: :integer, validation: :cast]}
             ] == error_changeset.errors
    end
  end

  defp create_product(product_params) do
    {:ok, %Product{id: product_id}} = ProductService.create(product_params)

    product_id
  end

  defp create_inventory(inventory_params) do
    {:ok, %Inventory{id: inventory_id}} = InventoryService.create(inventory_params)
    inventory_id
  end
end
