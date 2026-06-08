defmodule OrderflowWeb.AdminLive.Feedback do
  use OrderflowWeb, :live_view

  alias Orderflow.Feedback

  @impl true
  def mount(_params, _session, socket) do
    feedback = Feedback.list_feedback()
    nps = Feedback.nps_stats()
    ratings = Feedback.average_ratings()

    {:ok,
     assign(socket,
       feedback: feedback,
       nps: nps,
       ratings: ratings,
       page_title: "Customer Feedback"
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-6">
      <h1 class="text-2xl font-bold mb-4">Customer Feedback</h1>

      <div class="grid grid-cols-3 gap-4 mb-6">
        <div class="p-4 bg-blue-50 rounded-lg">
          <div class="text-3xl font-bold text-blue-600">{@nps.nps}</div>
          <div class="text-sm text-gray-600">NPS Score</div>
        </div>
        <div class="p-4 bg-green-50 rounded-lg">
          <div class="text-3xl font-bold text-green-600">{@nps.promoters}</div>
          <div class="text-sm text-gray-600">Promoters</div>
        </div>
        <div class="p-4 bg-red-50 rounded-lg">
          <div class="text-3xl font-bold text-red-600">{@nps.detractors}</div>
          <div class="text-sm text-gray-600">Detractors</div>
        </div>
      </div>

      <div class="mb-6">
        <h2 class="text-lg font-bold mb-2">Average Ratings</h2>
        <div class="flex gap-4">
          <div>Food: {Float.round(@ratings.food || 0.0, 1)}/5</div>
          <div>Service: {Float.round(@ratings.service || 0.0, 1)}/5</div>
          <div>Speed: {Float.round(@ratings.speed || 0.0, 1)}/5</div>
        </div>
      </div>

      <div class="overflow-x-auto">
        <table class="w-full text-left">
          <thead class="bg-gray-100">
            <tr>
              <th class="p-2">Order</th>
              <th class="p-2">NPS</th>
              <th class="p-2">Food</th>
              <th class="p-2">Service</th>
              <th class="p-2">Speed</th>
              <th class="p-2">Comments</th>
            </tr>
          </thead>
          <tbody>
            <%= for item <- @feedback do %>
              <tr class="border-b">
                <td class="p-2">#{item.order_id}</td>
                <td class="p-2">{item.nps_score}</td>
                <td class="p-2">{item.food_rating}</td>
                <td class="p-2">{item.service_rating}</td>
                <td class="p-2">{item.speed_rating}</td>
                <td class="p-2">{item.comments}</td>
              </tr>
            <% end %>
          </tbody>
        </table>
      </div>
    </div>
    """
  end
end
