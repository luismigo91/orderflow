defmodule OrderflowWeb.Schema do
  use Absinthe.Schema

  alias Orderflow.Orders
  alias Orderflow.Catalog

  object :order do
    field(:id, :id)
    field(:customer_name, :string)
    field(:customer_phone, :string)
    field(:status, :string)
    field(:total, :float)
  end

  object :product do
    field(:id, :id)
    field(:name, :string)
    field(:description, :string)
    field(:price, :float)
    field(:stock, :integer)
  end

  query do
    field :orders, list_of(:order) do
      resolve(fn _, _, _ ->
        {:ok, Orders.list_orders()}
      end)
    end

    field :products, list_of(:product) do
      resolve(fn _, _, _ ->
        {:ok, Catalog.list_products()}
      end)
    end
  end
end
