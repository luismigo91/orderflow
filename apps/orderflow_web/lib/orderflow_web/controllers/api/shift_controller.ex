defmodule OrderflowWeb.Api.ShiftController do
  use OrderflowWeb, :controller

  alias Orderflow.Shifts
  alias Orderflow.Shifts.Shift

  def index(conn, %{"date" => date}) do
    parsed_date = Date.from_iso8601!(date)
    shifts = Shifts.list_shifts_for_date(parsed_date)
    render(conn, :index, shifts: shifts)
  end

  def index(conn, _params) do
    shifts = Shifts.list_shifts()
    render(conn, :index, shifts: shifts)
  end

  def create(conn, %{"shift" => shift_params}) do
    with {:ok, %Shift{} = shift} <- Shifts.create_shift(shift_params) do
      conn
      |> put_status(:created)
      |> render(:show, shift: shift)
    end
  end

  def show(conn, %{"id" => id}) do
    shift = Shifts.get_shift!(id)
    render(conn, :show, shift: shift)
  end

  def update(conn, %{"id" => id, "shift" => shift_params}) do
    shift = Shifts.get_shift!(id)

    with {:ok, %Shift{} = shift} <- Shifts.update_shift(shift, shift_params) do
      render(conn, :show, shift: shift)
    end
  end
end

defmodule OrderflowWeb.Api.ShiftJSON do
  alias Orderflow.Shifts.Shift

  def index(%{shifts: shifts}) do
    %{data: for(shift <- shifts, do: data(shift))}
  end

  def show(%{shift: shift}) do
    %{data: data(shift)}
  end

  defp data(%Shift{} = shift) do
    %{
      id: shift.id,
      user_id: shift.user_id,
      date: shift.date,
      start_time: shift.start_time,
      end_time: shift.end_time,
      role: shift.role,
      status: shift.status,
      notes: shift.notes,
      inserted_at: shift.inserted_at
    }
  end
end
