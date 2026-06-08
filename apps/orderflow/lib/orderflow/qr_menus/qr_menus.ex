defmodule Orderflow.QrMenus do
  @moduledoc """
  Context for QR menu generation and management.
  """

  import Ecto.Query, warn: false
  alias Orderflow.Repo
  alias Orderflow.QrMenus.QrMenu

  def list_qr_menus do
    QrMenu |> preload(:table) |> order_by([q], desc: q.inserted_at) |> Repo.all()
  end

  def get_qr_menu!(id), do: Repo.get!(QrMenu, id) |> Repo.preload(:table)

  def get_qr_menu_by_code(code) do
    QrMenu
    |> where([q], q.code == ^code and q.active == true)
    |> preload(:table)
    |> Repo.one()
  end

  def create_qr_menu(table_id) do
    code = generate_code()
    url = "/menu/#{code}"

    %QrMenu{}
    |> QrMenu.changeset(%{
      code: code,
      table_id: table_id,
      url: url,
      active: true
    })
    |> Repo.insert()
  end

  def deactivate_qr_menu(%QrMenu{} = qr_menu) do
    qr_menu
    |> QrMenu.changeset(%{active: false})
    |> Repo.update()
  end

  def increment_scan(%QrMenu{} = qr_menu) do
    qr_menu
    |> QrMenu.changeset(%{scan_count: qr_menu.scan_count + 1})
    |> Repo.update()
  end

  def generate_qr_svg(code) do
    alias EQRCode

    code
    |> EQRCode.encode()
    |> EQRCode.svg()
  end

  defp generate_code do
    :crypto.strong_rand_bytes(6)
    |> Base.url_encode64(padding: false)
    |> String.replace(~r/[^A-Za-z0-9]/, "")
    |> String.slice(0, 8)
    |> String.upcase()
  end
end
