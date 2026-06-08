defmodule OrderflowWeb.FallbackController do
  @moduledoc """
  Handles errors and returns consistent JSON responses.
  """
  use OrderflowWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: OrderflowWeb.Api.ErrorJSON)
    |> render("error.json", changeset: changeset)
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(json: OrderflowWeb.Api.ErrorJSON)
    |> render("404.json")
  end

  def call(conn, {:error, :invalid_transition, reason}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: OrderflowWeb.Api.ErrorJSON)
    |> render("error.json", message: reason)
  end

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(:unauthorized)
    |> put_view(json: OrderflowWeb.Api.ErrorJSON)
    |> render("401.json")
  end

  def call(conn, {:error, :forbidden}) do
    conn
    |> put_status(:forbidden)
    |> put_view(json: OrderflowWeb.Api.ErrorJSON)
    |> render("403.json")
  end
end
