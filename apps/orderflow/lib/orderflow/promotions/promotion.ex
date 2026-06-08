defmodule Orderflow.Promotions.Promotion do
  use Ecto.Schema
  import Ecto.Changeset

  schema "promotions" do
    field :code, :string
    field :name, :string
    field :description, :string
    field :type, Ecto.Enum, values: [:percentage, :fixed_amount, :buy_one_get_one, :free_delivery]
    field :value, :decimal
    field :min_order_amount, :decimal, default: Decimal.new("0")
    field :max_uses, :integer
    field :uses_count, :integer, default: 0
    field :active, :boolean, default: true
    field :expires_at, :naive_datetime

    timestamps()
  end

  def changeset(promotion, attrs) do
    promotion
    |> cast(attrs, [
      :code,
      :name,
      :description,
      :type,
      :value,
      :min_order_amount,
      :max_uses,
      :uses_count,
      :active,
      :expires_at
    ])
    |> validate_required([:code, :name, :type, :value])
    |> validate_length(:code, min: 3, max: 20)
    |> unique_constraint(:code)
  end
end
