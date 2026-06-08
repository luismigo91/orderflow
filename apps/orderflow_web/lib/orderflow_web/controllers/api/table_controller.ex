defmodule OrderflowWeb.Api.TableController do
  use OrderflowWeb, :controller

  alias Orderflow.Tables
  alias Orderflow.Tables.Table

  def index(conn, _params) do
    tables = Tables.list_tables()
    render(conn, :index, tables: tables)
  end

  def create(conn, %{"table" => table_params}) do
    with {:ok, %Table{} = table} <- Tables.create_table(table_params) do
      conn
      |> put_status(:created)
      |> render(:show, table: table)
    end
  end

  def show(conn, %{"id" => id}) do
    table = Tables.get_table!(id)
    render(conn, :show, table: table)
  end

  def update(conn, %{"id" => id, "table" => table_params}) do
    table = Tables.get_table!(id)

    with {:ok, %Table{} = table} <- Tables.update_table(table, table_params) do
      render(conn, :show, table: table)
    end
  end
end

defmodule OrderflowWeb.Api.TableJSON do
  alias Orderflow.Tables.Table

  def index(%{tables: tables}) do
    %{data: for(table <- tables, do: data(table))}
  end

  def show(%{table: table}) do
    %{data: data(table)}
  end

  defp data(%Table{} = table) do
    %{
      id: table.id,
      number: table.number,
      capacity: table.capacity,
      status: table.status,
      location: table.location,
      active: table.active,
      inserted_at: table.inserted_at,
      updated_at: table.updated_at
    }
  end
end
