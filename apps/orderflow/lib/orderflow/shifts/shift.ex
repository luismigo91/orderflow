defmodule Orderflow.Shifts.Shift do
  use Ecto.Schema
  import Ecto.Changeset

  schema "shifts" do
    field :date, :date
    field :start_time, :time
    field :end_time, :time
    field :role, :string

    field :status, Ecto.Enum,
      values: [:scheduled, :confirmed, :completed, :cancelled],
      default: :scheduled

    field :notes, :string

    belongs_to :user, Orderflow.Accounts.User
    has_many :shift_requests, Orderflow.Shifts.ShiftRequest

    timestamps(type: :utc_datetime)
  end

  def changeset(shift, attrs) do
    shift
    |> cast(attrs, [:user_id, :date, :start_time, :end_time, :role, :status, :notes])
    |> validate_required([:user_id, :date, :start_time, :end_time, :role])
    |> foreign_key_constraint(:user_id)
  end
end

defmodule Orderflow.Shifts.ShiftRequest do
  use Ecto.Schema
  import Ecto.Changeset

  schema "shift_requests" do
    field :type, Ecto.Enum, values: [:swap, :time_off], default: :swap
    field :status, Ecto.Enum, values: [:pending, :approved, :rejected], default: :pending
    field :reason, :string

    belongs_to :shift, Orderflow.Shifts.Shift
    belongs_to :requester, Orderflow.Accounts.User
    belongs_to :target_shift, Orderflow.Shifts.Shift

    timestamps(type: :utc_datetime)
  end

  def changeset(request, attrs) do
    request
    |> cast(attrs, [:shift_id, :requester_id, :type, :status, :reason, :target_shift_id])
    |> validate_required([:shift_id, :requester_id, :type])
    |> foreign_key_constraint(:shift_id)
    |> foreign_key_constraint(:requester_id)
    |> foreign_key_constraint(:target_shift_id)
  end
end
