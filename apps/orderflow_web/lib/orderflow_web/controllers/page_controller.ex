defmodule OrderflowWeb.PageController do
  use OrderflowWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
