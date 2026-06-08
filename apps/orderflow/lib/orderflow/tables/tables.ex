defmodule Orderflow.Tables do
  @moduledoc """
  Context for table management and reservations.
  """

  import Ecto.Query, warn: false
  alias Orderflow.Repo
  alias Orderflow.Tables.{Table, Reservation}

  # Tables

  def list_tables do
    Table |> where([t], t.active == true) |> order_by([t], t.number) |> Repo.all()
  end

  def list_tables_by_status(status) do
    Table |> where([t], t.status == ^status and t.active == true) |> Repo.all()
  end

  def get_table!(id), do: Repo.get!(Table, id)

  def create_table(attrs) do
    %Table{}
    |> Table.changeset(attrs)
    |> Repo.insert()
  end

  def update_table(%Table{} = table, attrs) do
    table
    |> Table.changeset(attrs)
    |> Repo.update()
  end

  def change_table(%Table{} = table, attrs \\ %{}), do: Table.changeset(table, attrs)

  # Reservations

  def list_reservations do
    Reservation
    |> preload(:table)
    |> order_by([r], desc: r.datetime)
    |> Repo.all()
  end

  def list_reservations_for_date(date) do
    start = DateTime.new!(date, ~T[00:00:00])
    end_ = DateTime.new!(date, ~T[23:59:59])

    Reservation
    |> where([r], r.datetime >= ^start and r.datetime <= ^end_)
    |> preload(:table)
    |> order_by([r], r.datetime)
    |> Repo.all()
  end

  def create_reservation(attrs) do
    %Reservation{}
    |> Reservation.changeset(attrs)
    |> Repo.insert()
  end

  def update_reservation(%Reservation{} = reservation, attrs) do
    reservation
    |> Reservation.changeset(attrs)
    |> Repo.update()
  end

  def cancel_reservation(%Reservation{} = reservation) do
    update_reservation(reservation, %{status: :cancelled})
  end

  def change_reservation(%Reservation{} = reservation, attrs \\ %{}),
    do: Reservation.changeset(reservation, attrs)

  def get_reservation!(id) do
    Reservation
    |> preload(:table)
    |> Repo.get!(id)
  end
end
