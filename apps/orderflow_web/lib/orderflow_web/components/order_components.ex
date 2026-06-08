defmodule OrderflowWeb.OrderComponents do
  use Phoenix.Component

  def status_card_class(status) do
    case status do
      :cooking -> "bg-yellow-900 border-yellow-500"
      :ready -> "bg-green-900 border-green-500"
      :pending -> "bg-gray-800 border-gray-500"
      :confirmed -> "bg-blue-900 border-blue-500"
      :delivering -> "bg-purple-900 border-purple-500"
      :delivered -> "bg-green-800 border-green-400"
      :cancelled -> "bg-red-900 border-red-500"
      _ -> "bg-gray-800 border-gray-500"
    end
  end

  def status_badge_class(status) do
    case status do
      :cooking -> "bg-yellow-500 text-yellow-900"
      :ready -> "bg-green-500 text-green-900"
      :pending -> "bg-gray-500 text-gray-900"
      :confirmed -> "bg-blue-500 text-blue-900"
      :delivering -> "bg-purple-500 text-purple-900"
      :delivered -> "bg-green-400 text-green-900"
      :cancelled -> "bg-red-500 text-red-900"
      _ -> "bg-gray-500 text-gray-900"
    end
  end

  def status_label(status) do
    case status do
      :pending -> "⏳ Pendiente"
      :confirmed -> "✅ Confirmado"
      :cooking -> "🍳 En cocina"
      :ready -> "📦 Listo"
      :delivering -> "🚲 En camino"
      :delivered -> "✅ Entregado"
      :cancelled -> "❌ Cancelado"
      _ -> "Desconocido"
    end
  end

  def tracker_status_class(current_status, status) do
    order = [:pending, :confirmed, :cooking, :ready, :delivering, :delivered]
    current_index = Enum.find_index(order, &(&1 == current_status)) || -1
    status_index = Enum.find_index(order, &(&1 == status)) || -1

    cond do
      status == current_status -> "bg-blue-600 text-white"
      status_index < current_index -> "bg-green-500 text-white"
      true -> "bg-gray-300 text-gray-600"
    end
  end

  def tracker_status_icon(status) do
    case status do
      :pending -> "⏳"
      :confirmed -> "✅"
      :cooking -> "🍳"
      :ready -> "📦"
      :delivering -> "🚲"
      :delivered -> "✅"
      _ -> "•"
    end
  end

  def tracker_progress(status) do
    case status do
      :pending -> 0
      :confirmed -> 20
      :cooking -> 40
      :ready -> 60
      :delivering -> 80
      :delivered -> 100
      _ -> 0
    end
  end

  def role_badge_class(role) do
    case role do
      :admin -> "bg-red-500 text-white"
      :chef -> "bg-orange-500 text-white"
      :rider -> "bg-blue-500 text-white"
      :customer -> "bg-green-500 text-white"
      _ -> "bg-gray-500 text-white"
    end
  end

  def role_label(role) do
    case role do
      :admin -> "🔴 Admin"
      :chef -> "🟠 Chef"
      :rider -> "🔵 Rider"
      :customer -> "🟢 Cliente"
      _ -> "Desconocido"
    end
  end

  def stock_color_class(stock) do
    cond do
      stock > 10 -> "text-green-600"
      stock >= 5 -> "text-yellow-600"
      true -> "text-red-600"
    end
  end
end
