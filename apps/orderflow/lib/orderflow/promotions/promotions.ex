defmodule Orderflow.Promotions do
  @moduledoc """
  Contexto de gestión de promociones y cupones.
  """

  import Ecto.Query, warn: false
  alias Orderflow.Repo
  alias Orderflow.Promotions.Promotion

  def list_promotions do
    Repo.all(Promotion)
  end

  def get_promotion!(id), do: Repo.get!(Promotion, id)

  def get_promotion_by_code(code) do
    Repo.get_by(Promotion, code: code, active: true)
  end

  def create_promotion(attrs \\ %{}) do
    %Promotion{}
    |> Promotion.changeset(attrs)
    |> Repo.insert()
  end

  def update_promotion(%Promotion{} = promotion, attrs) do
    promotion
    |> Promotion.changeset(attrs)
    |> Repo.update()
  end

  def delete_promotion(%Promotion{} = promotion) do
    Repo.delete(promotion)
  end

  def apply_promotion(code, order_total) do
    case get_promotion_by_code(code) do
      nil ->
        {:error, :not_found}

      promotion ->
        if valid_promotion?(promotion) do
          discount = calculate_discount(promotion, order_total)
          {:ok, discount, promotion}
        else
          {:error, :invalid}
        end
    end
  end

  defp valid_promotion?(promotion) do
    cond do
      !promotion.active ->
        false

      promotion.expires_at &&
          NaiveDateTime.compare(promotion.expires_at, NaiveDateTime.utc_now()) == :lt ->
        false

      promotion.max_uses && promotion.uses_count >= promotion.max_uses ->
        false

      true ->
        true
    end
  end

  defp calculate_discount(%{type: :percentage, value: value}, total) do
    Decimal.mult(total, Decimal.div(value, Decimal.new("100")))
  end

  defp calculate_discount(%{type: :fixed_amount, value: value}, _total) do
    value
  end

  defp calculate_discount(%{type: :free_delivery}, _total) do
    Decimal.new("5.00")
  end

  defp calculate_discount(%{type: :buy_one_get_one}, _total) do
    Decimal.new("0")
  end
end
