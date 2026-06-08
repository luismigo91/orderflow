defmodule OrderflowWeb.Api.ReservationController do
  use OrderflowWeb, :controller

  alias Orderflow.Tables
  alias Orderflow.Tables.Reservation

  def index(conn, %{"date" => date}) do
    parsed_date = Date.from_iso8601!(date)
    reservations = Tables.list_reservations_for_date(parsed_date)
    render(conn, :index, reservations: reservations)
  end

  def index(conn, _params) do
    reservations = Tables.list_reservations()
    render(conn, :index, reservations: reservations)
  end

  def create(conn, %{"reservation" => reservation_params}) do
    with {:ok, %Reservation{} = reservation} <- Tables.create_reservation(reservation_params) do
      conn
      |> put_status(:created)
      |> render(:show, reservation: reservation)
    end
  end

  def show(conn, %{"id" => id}) do
    reservation = Tables.get_reservation!(id)
    render(conn, :show, reservation: reservation)
  end

  def update(conn, %{"id" => id, "reservation" => reservation_params}) do
    reservation = Tables.get_reservation!(id)

    with {:ok, %Reservation{} = reservation} <-
           Tables.update_reservation(reservation, reservation_params) do
      render(conn, :show, reservation: reservation)
    end
  end

  def cancel(conn, %{"id" => id}) do
    reservation = Tables.get_reservation!(id)

    with {:ok, %Reservation{}} <- Tables.cancel_reservation(reservation) do
      send_resp(conn, :no_content, "")
    end
  end
end

defmodule OrderflowWeb.Api.ReservationJSON do
  alias Orderflow.Tables.Reservation

  def index(%{reservations: reservations}) do
    %{data: for(reservation <- reservations, do: data(reservation))}
  end

  def show(%{reservation: reservation}) do
    %{data: data(reservation)}
  end

  defp data(%Reservation{} = reservation) do
    %{
      id: reservation.id,
      customer_name: reservation.customer_name,
      customer_phone: reservation.customer_phone,
      party_size: reservation.party_size,
      datetime: reservation.datetime,
      status: reservation.status,
      notes: reservation.notes,
      table_id: reservation.table_id,
      inserted_at: reservation.inserted_at,
      updated_at: reservation.updated_at
    }
  end
end
