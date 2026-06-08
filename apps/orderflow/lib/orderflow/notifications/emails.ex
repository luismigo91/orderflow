defmodule Orderflow.Notifications.Emails do
  @moduledoc """
  Email builders for order notifications.
  """
  import Swoosh.Email

  def order_confirmed(order) do
    new()
    |> to({"Cliente", "customer@example.com"})
    |> from({"OrderFlow", "noreply@orderflow.com"})
    |> subject("Pedido ##{order.id} en preparación")
    |> text_body("""
    ¡Hola #{order.customer_name}!

    Tu pedido ##{order.id} está siendo preparado en este momento.

    Total: $#{order.total}

    Puedes seguir tu pedido en: http://localhost:4000/track/#{order.id}
    """)
  end

  def order_on_the_way(order) do
    new()
    |> to({"Cliente", "customer@example.com"})
    |> from({"OrderFlow", "noreply@orderflow.com"})
    |> subject("Pedido ##{order.id} en camino")
    |> text_body("""
    ¡Hola #{order.customer_name}!

    Tu pedido ##{order.id} ha salido para entrega.

    Tiempo estimado: 15-20 minutos.

    Puedes seguir tu pedido en: http://localhost:4000/track/#{order.id}
    """)
  end

  def order_delivered(order) do
    new()
    |> to({"Cliente", "customer@example.com"})
    |> from({"OrderFlow", "noreply@orderflow.com"})
    |> subject("Pedido ##{order.id} entregado")
    |> text_body("""
    ¡Hola #{order.customer_name}!

    Tu pedido ##{order.id} ha sido entregado.

    Total: $#{order.total}

    ¡Gracias por elegirnos!
    """)
  end

  def admin_alert(order, _type, threshold) do
    new()
    |> to({"Admin", "admin@orderflow.com"})
    |> from({"OrderFlow Alerts", "alerts@orderflow.com"})
    |> subject("⚠️ Pedido ##{order.id} atascado")
    |> text_body("""
    ALERTA: El pedido ##{order.id} lleva más de #{threshold} minutos en estado "#{order.status}".

    Cliente: #{order.customer_name}
    Teléfono: #{order.customer_phone}

    Ver en admin: http://localhost:4000/admin
    """)
  end
end
