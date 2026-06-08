defmodule OrderflowWeb.Api.QrMenuController do
  use OrderflowWeb, :controller

  alias Orderflow.QrMenus
  alias Orderflow.QrMenus.QrMenu

  def index(conn, _params) do
    qr_menus = QrMenus.list_qr_menus()
    render(conn, :index, qr_menus: qr_menus)
  end

  def create(conn, %{"table_id" => table_id}) do
    with {:ok, %QrMenu{} = qr_menu} <- QrMenus.create_qr_menu(table_id) do
      conn
      |> put_status(:created)
      |> render(:show, qr_menu: qr_menu)
    end
  end

  def show(conn, %{"id" => id}) do
    qr_menu = QrMenus.get_qr_menu!(id)
    render(conn, :show, qr_menu: qr_menu)
  end

  def svg(conn, %{"code" => code}) do
    svg = QrMenus.generate_qr_svg(code)

    conn
    |> put_resp_content_type("image/svg+xml")
    |> send_resp(200, svg)
  end
end

defmodule OrderflowWeb.Api.QrMenuJSON do
  alias Orderflow.QrMenus.QrMenu

  def index(%{qr_menus: qr_menus}) do
    %{data: for(qr <- qr_menus, do: data(qr))}
  end

  def show(%{qr_menu: qr_menu}) do
    %{data: data(qr_menu)}
  end

  defp data(%QrMenu{} = qr_menu) do
    %{
      id: qr_menu.id,
      code: qr_menu.code,
      table_id: qr_menu.table_id,
      url: qr_menu.url,
      active: qr_menu.active,
      scan_count: qr_menu.scan_count,
      expires_at: qr_menu.expires_at
    }
  end
end
