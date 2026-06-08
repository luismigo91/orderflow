defmodule Orderflow.Delivery.Zone do
  use Ecto.Schema
  import Ecto.Changeset

  schema "delivery_zones" do
    field :name, :string
    field :description, :string
    field :min_lat, :float
    field :max_lat, :float
    field :min_lng, :float
    field :max_lng, :float
    field :delivery_fee, :decimal
    field :estimated_time_minutes, :integer
    field :active, :boolean, default: true

    timestamps(type: :utc_datetime)
  end

  def changeset(zone, attrs) do
    zone
    |> cast(attrs, [
      :name,
      :description,
      :min_lat,
      :max_lat,
      :min_lng,
      :max_lng,
      :delivery_fee,
      :estimated_time_minutes,
      :active
    ])
    |> validate_required([:name, :min_lat, :max_lat, :min_lng, :max_lng])
    |> validate_number(:min_lat, greater_than_or_equal_to: -90, less_than_or_equal_to: 90)
    |> validate_number(:max_lat, greater_than_or_equal_to: -90, less_than_or_equal_to: 90)
    |> validate_number(:min_lng, greater_than_or_equal_to: -180, less_than_or_equal_to: 180)
    |> validate_number(:max_lng, greater_than_or_equal_to: -180, less_than_or_equal_to: 180)
  end
end
