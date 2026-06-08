defmodule Orderflow.Orders.OrderFSM do
  @moduledoc """
  Finite State Machine para el ciclo de vida de un pedido.

  Estados permitidos:
  - pending → confirmed → cooking → ready → delivering → delivered
  - pending → cancelled
  - confirmed → cancelled
  - cooking → cancelled (requiere admin override)
  - delivering → cancelled (raro, requiere admin override)

  Estados terminales: delivered, cancelled
  """

  @transitions %{
    pending: [:confirmed, :cancelled],
    confirmed: [:cooking, :cancelled],
    cooking: [:ready, :cancelled],
    ready: [:delivering],
    delivering: [:delivered, :cancelled],
    delivered: [],
    cancelled: []
  }

  def allowed_transitions(status) do
    Map.get(@transitions, status, [])
  end

  def transition_allowed?(from, to) do
    to in allowed_transitions(from)
  end

  def validate_transition!(from, to) do
    if transition_allowed?(from, to) do
      :ok
    else
      {:error, :invalid_transition, "Cannot transition from #{from} to #{to}"}
    end
  end
end
