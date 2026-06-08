defmodule Orderflow.Delivery.Zones do
  @moduledoc """
  Context for delivery zones and geofencing.
  """
  import Ecto.Query

  alias Orderflow.Delivery.Zone
  alias Orderflow.Repo

  def list_zones do
    Zone
    |> order_by([z], z.name)
    |> Repo.all()
  end

  def get_zone!(id), do: Repo.get!(Zone, id)

  def create_zone(attrs) do
    %Zone{}
    |> Zone.changeset(attrs)
    |> Repo.insert()
  end

  def update_zone(%Zone{} = zone, attrs) do
    zone
    |> Zone.changeset(attrs)
    |> Repo.update()
  end

  def delete_zone(%Zone{} = zone) do
    Repo.delete(zone)
  end

  @doc """
  Check if coordinates are within a zone.
  """
  def in_zone?(zone, lat, lng) do
    # Simple bounding box check
    lat >= zone.min_lat and lat <= zone.max_lat and
      lng >= zone.min_lng and lng <= zone.max_lng
  end

  @doc """
  Find zone for given coordinates.
  """
  def find_zone(lat, lng) do
    Zone
    |> where([z], z.min_lat <= ^lat and z.max_lat >= ^lat)
    |> where([z], z.min_lng <= ^lng and z.max_lng >= ^lng)
    |> where([z], z.active == true)
    |> Repo.one()
  end
end
