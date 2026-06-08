defmodule Orderflow.Shifts do
  @moduledoc """
  Context for staff scheduling and shifts.
  """

  import Ecto.Query, warn: false
  alias Orderflow.Repo
  alias Orderflow.Shifts.{Shift, ShiftRequest}

  def list_shifts do
    Shift
    |> preload(:user)
    |> order_by([s], desc: s.date)
    |> Repo.all()
  end

  def list_shifts_for_date(date) do
    Shift
    |> where([s], s.date == ^date)
    |> preload(:user)
    |> order_by([s], s.start_time)
    |> Repo.all()
  end

  def list_shifts_for_user(user_id) do
    Shift
    |> where([s], s.user_id == ^user_id)
    |> order_by([s], desc: s.date)
    |> Repo.all()
  end

  def get_shift!(id), do: Repo.get!(Shift, id) |> Repo.preload(:user)

  def create_shift(attrs) do
    %Shift{}
    |> Shift.changeset(attrs)
    |> Repo.insert()
  end

  def update_shift(%Shift{} = shift, attrs) do
    shift
    |> Shift.changeset(attrs)
    |> Repo.update()
  end

  def change_shift(%Shift{} = shift, attrs \\ %{}), do: Shift.changeset(shift, attrs)

  # Shift Requests

  def list_shift_requests do
    ShiftRequest
    |> preload([:shift, :requester, :target_shift])
    |> order_by([r], desc: r.inserted_at)
    |> Repo.all()
  end

  def create_shift_request(attrs) do
    %ShiftRequest{}
    |> ShiftRequest.changeset(attrs)
    |> Repo.insert()
  end

  def approve_request(%ShiftRequest{} = request) do
    request
    |> ShiftRequest.changeset(%{status: :approved})
    |> Repo.update()
  end

  def reject_request(%ShiftRequest{} = request) do
    request
    |> ShiftRequest.changeset(%{status: :rejected})
    |> Repo.update()
  end
end
