defmodule ElixirTestWeb.PageController do
  use ElixirTestWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
