defmodule MiniECommerceWeb.Service.ProductTest do
  use ExUnit.Case, async: true
  use MiniECommerce.DataCase

  alias MiniECommerce.Repo
  alias MiniECommerce.Schema.Product
  alias MiniECommerce.Service.Product, as: ProductService

  @default_filters %{
    "category" => "",
    "sort_by" => "desc",
    "sort_column" => "updated_at",
    "page" => "1"
  }

  @limit 12

  setup context do
    product_params = %{
      "name" => "Baby cloths",
      "description" => "Product related to babies",
      "category" => :books,
      "price" => "49.99",
      "thumbnail" => "http://example.com/image.jpg"
    }

    product_id =
      case Map.get(context, :flag) do
        true -> create_product(product_params)
        nil -> nil
      end

    {:ok, %{product_params: product_params, product_id: product_id}}
  end

  test "creates a product using valid params", %{product_params: product_params} do
    {:ok,
     %Product{
       name: product_name,
       price: product_price,
       description: product_description,
       category: product_category
     }} =
      ProductService.create(product_params)

    assert product_name == "Baby cloths"
    assert product_price == Decimal.new("49.99")
    assert product_description == "Product related to babies"
    assert product_category == :books
  end

  describe "Create Product" do
    test "creating a product fails due to invalid price, string instead of decimal", %{
      product_params: product_params
    } do
      updated_params = product_params |> Map.merge(%{"price" => "invalid_price"})

      {:error, error_changeset} = ProductService.create(updated_params)

      assert error_changeset == [price: {"is invalid", [type: :decimal, validation: :cast]}]
    end

    test "creating a product fails due to invalid category, not part of the category_enum", %{
      product_params: product_params
    } do
      updated_params = product_params |> Map.merge(%{"category" => ":invalid_category"})

      {:error, error_changeset} = ProductService.create(updated_params)

      [category: {error, _}] = error_changeset

      assert error == "is invalid"
    end

    test "creating a product fails due to invalid params, not a valid name", %{
      product_params: product_params
    } do
      updated_params = product_params |> Map.merge(%{"name" => nil})
      assert {:error, :invalid_params} == ProductService.create(updated_params)
    end

    @tag flag: true
    test "creating a product fails due to same name unique constraint", %{
      product_params: product_params
    } do
      {:error, error_changeset} = ProductService.create(product_params)

      assert error_changeset == [
               name:
                 {"has already been taken",
                  [constraint: :unique, constraint_name: "product_name_has_to_be_unqiue"]}
             ]
    end
  end

  describe "Update Product" do
    @tag flag: true
    test "update the product price", %{product_id: product_id} do
      updated_name = "Baby product 2.0"

      updated_params = %{"id" => product_id, "name" => updated_name}

      {:ok, %Product{id: id, name: product_name}} = ProductService.update(updated_params)

      assert id == product_id
      assert updated_name == product_name
    end

    @tag flag: true
    test "update the product fails due to missing id" do
      updated_name = "Baby product 2.0"
      updated_params = %{"name" => updated_name}

      assert {:error, :invalid_params} == ProductService.update(updated_params)
    end

    @tag flag: true
    test "update the product fails due to invalid  category", %{product_id: product_id} do
      invalid_category = "invalid_category"
      updated_params = %{"id" => product_id, "category" => invalid_category}
      {:error, error_changeset} = ProductService.update(updated_params)

      [category: {error, _}] = error_changeset.errors
      assert error == "is invalid"
    end

    test "update the product fails due to invalid product_id" do
      invalid_product_id = "4092c0ae-7629-4ce4-b5e2-a8fe3d214aee"
      updated_params = %{"id" => invalid_product_id, "category" => :books}
      assert {:error, :product_not_found} = ProductService.update(updated_params)
    end
  end

  describe "Delete Product" do
    @tag flag: true
    test "delete a product with valid product_id", %{product_id: product_id} do
      {:ok, _deleted_product} = ProductService.delete(%{"id" => product_id})

      # product has been deleted
      refute Repo.get(Product, product_id)
    end

    @tag flag: true
    test "delete a product with in_valid product_id" do
      invalid_product_id = "4092c0ae-7629-4ce4-b5e2-a8fe3d214aee"
      assert {:error, :product_not_found} = ProductService.delete(%{"id" => invalid_product_id})
    end
  end

  @tag flag: true
  test "get product by id", %{product_id: product_id} do
    product_name = "Baby cloths"

    %{"name" => product_name_value, "id" => product_id_value} =
      ProductService.get_product_by_id(product_id)

    assert product_name == product_name_value
    assert product_id == product_id_value
  end

  test "list of products which include paginated records", %{product_params: product_params} do
    num_of_records = 20

    Enum.each(1..num_of_records, fn x ->
      updated_params = Map.merge(product_params, %{"name" => "Product #{x}"})
      create_product(updated_params)
    end)

    %{products: paginated_products_list, total_pages: total_pages} =
      ProductService.list(@default_filters)

    assert length(paginated_products_list) == @limit
    assert total_pages == ceil(num_of_records / @limit)
  end

  defp create_product(product_params) do
    {:ok, %Product{id: product_id}} = ProductService.create(product_params)

    product_id
  end
end
