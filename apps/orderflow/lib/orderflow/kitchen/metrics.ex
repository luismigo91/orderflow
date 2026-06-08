defmodule Orderflow.Kitchen.Metrics do
  use Ecto.Schema
  import Ecto.Changeset

  schema "kitchen_metrics" do
    field :prep_start, :utc_datetime
    field :prep_end, :utc_datetime
    field :stage_times, :map, default: %{}
    field :total_minutes, :integer
    field :items_count, :integer
    field :bottleneck_stage, :string

    belongs_to :order, Orderflow.Orders.Order

    timestamps(type: :utc_datetime)
  end

  def changeset(metrics, attrs) do
    metrics
    |> cast(attrs, [
      :order_id,
      :prep_start,
      :prep_end,
      :stage_times,
      :total_minutes,
      :items_count,
      :bottleneck_stage
    ])
    |> validate_required([:order_id])
    |> foreign_key_constraint(:order_id)
  end
end
