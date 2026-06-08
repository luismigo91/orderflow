defmodule Orderflow.Tables.Table do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tables" do
    field :number, :string
    field :capacity, :integer
    field :status, Ecto.Enum, values: [:free, :occupied, :reserved], default: :free
    field :location, :string
    field :active, :boolean, default: true

    has_many :reservations, Orderflow.Tables.Reservation
    has_many :qr_menus, Orderflow.QrMenus.QrMenu

    timestamps(type: :utc_datetime)
  end

  def changeset(table, attrs) do
    table
    |> cast(attrs, [:number, :capacity, :status, :location, :active])
    |> validate_required([:number, :capacity])
    |> validate_number(:capacity, greater_than: 0)
    |> unique_constraint(:number)
  end
end

defmodule Orderflow.Tables.Reservation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "reservations" do
    field :customer_name, :string
    field :customer_phone, :string
    field :party_size, :integer
    field :datetime, :utc_datetime

    field :status, Ecto.Enum,
      values: [:confirmed, :cancelled, :completed, :no_show],
      default: :confirmed

    field :notes, :string

    belongs_to :table, Orderflow.Tables.Table
    belongs_to :user, Orderflow.Accounts.User

    timestamps(type: :utc_datetime)
  end

  def changeset(reservation, attrs) do
    reservation
    |> cast(attrs, [
      :table_id,
      :customer_name,
      :customer_phone,
      :party_size,
      :datetime,
      :status,
      :notes,
      :user_id
    ])
    |> validate_required([:customer_name, :party_size, :datetime])
    |> validate_number(:party_size, greater_than: 0)
    |> foreign_key_constraint(:table_id)
    |> foreign_key_constraint(:user_id)
  end
end
