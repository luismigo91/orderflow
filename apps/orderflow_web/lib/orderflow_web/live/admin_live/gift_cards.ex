defmodule OrderflowWeb.AdminLive.GiftCards do
  use OrderflowWeb, :live_view

  alias Orderflow.GiftCards

  @impl true
  def mount(_params, _session, socket) do
    gift_cards = GiftCards.list_gift_cards()
    {:ok, assign(socket, gift_cards: gift_cards, page_title: "Gift Cards")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-6">
      <h1 class="text-2xl font-bold mb-4">Gift Cards</h1>
      <div class="overflow-x-auto">
        <table class="w-full text-left">
          <thead class="bg-gray-100">
            <tr>
              <th class="p-2">Code</th>
              <th class="p-2">Balance</th>
              <th class="p-2">Initial</th>
              <th class="p-2">Status</th>
              <th class="p-2">Purchaser</th>
              <th class="p-2">Expires</th>
            </tr>
          </thead>
          <tbody>
            <%= for card <- @gift_cards do %>
              <tr class="border-b">
                <td class="p-2 font-mono text-sm">{card.code}</td>
                <td class="p-2">${card.balance}</td>
                <td class="p-2">${card.initial_amount}</td>
                <td class="p-2">
                  <span class={"px-2 py-1 rounded text-sm capitalize #{status_color(card.status)}"}>
                    {card.status}
                  </span>
                </td>
                <td class="p-2">{card.purchaser && card.purchaser.name}</td>
                <td class="p-2">{card.expires_at}</td>
              </tr>
            <% end %>
          </tbody>
        </table>
      </div>
    </div>
    """
  end

  defp status_color(:active), do: "bg-green-100 text-green-800"
  defp status_color(:redeemed), do: "bg-blue-100 text-blue-800"
  defp status_color(:expired), do: "bg-red-100 text-red-800"
  defp status_color(:cancelled), do: "bg-gray-100 text-gray-800"
  defp status_color(_), do: "bg-gray-100 text-gray-800"
end
