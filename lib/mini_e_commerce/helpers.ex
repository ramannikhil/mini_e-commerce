defmodule MiniECommerce.Helpers do
  alias MiniECommerce.Schema.Product

  @moduledoc """
  Common helper funtions, transform errors

  Fetching the options for select component
  """

  def category_options() do
    Product.category_enum()
    |> fetch_select_options()
  end

  def fetch_product_options(products) do
    product_options =
      products
      # |> Enum.map(fn %Product{"id" => product_id, "name" => product_name} ->
      |> Enum.map(fn %{"id" => product_id, "name" => product_name} ->
        {product_name, product_id}
      end)

    [{"Select a Product", ""} | product_options]
  end

  def fetch_select_options(items) do
    Enum.map(items, &{to_string(&1) |> String.capitalize(), to_string(&1)})
  end

  @doc """
  Convert changeset errors into an Array to display as Flash messages in the UI
  """
  def transform_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
    |> Enum.map(fn {field, messages} ->
      {field, Enum.join(messages, ", ")}
    end)
  end
end
