defmodule Orderflow.QrMenus.QrMenu do
  use Ecto.Schema
  import Ecto.Changeset

  schema "qr_menus" do
    field :code, :string
    field :url, :string
    field :active, :boolean, default: true
    field :expires_at, :utc_datetime
    field :scan_count, :integer, default: 0

    belongs_to :table, Orderflow.Tables.Table

    timestamps(type: :utc_datetime)
  end

  def changeset(qr_menu, attrs) do
    qr_menu
    |> cast(attrs, [:code, :table_id, :url, :active, :expires_at, :scan_count])
    |> validate_required([:code, :url])
    |> unique_constraint(:code)
    |> foreign_key_constraint(:table_id)
  end
end
