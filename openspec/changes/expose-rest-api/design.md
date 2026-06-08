# Design: expose-rest-api

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                         apps/orderflow_web/                          │
│                                                                      │
│  ┌─────────────────────────────────────────────────────────────────┐ │
│  │  API Layer:                                                      │ │
│  │  ┌──────────────────┐ ┌──────────────────┐ ┌──────────────────┐ │ │
│  │  │ Api.OrderController│ │ Api.ProductController│ │ Api.SessionController│ │
│  │  │ • index           │ │ • index           │ │ • create        │ │
│  │  │ • show            │ │ • show            │ │ • me            │ │
│  │  │ • create          │ │                   │ │                 │ │
│  │  │ • update_status   │ │                   │ │                 │ │
│  │  │ • delete          │ │                   │ │                 │ │
│  │  └──────────────────┘ └──────────────────┘ └──────────────────┘ │ │
│  │  ┌──────────────────┐ ┌──────────────────┐                      │ │
│  │  │ FallbackController │ │ ApiAuth Plug      │                      │ │
│  │  │ • handle errors   │ │ • Bearer token    │                      │ │
│  │  │ • JSON format     │ │ • User lookup     │                      │ │
│  │  └──────────────────┘ └──────────────────┘                      │ │
│  │  ┌──────────────────┐                                            │ │
│  │  │ RateLimit Plug     │                                            │ │
│  │  │ • 100 req/min     │                                            │ │
│  │  │ • In-memory       │                                            │ │
│  │  └──────────────────┘                                            │ │
│  └─────────────────────────────────────────────────────────────────┘ │
│                                                                      │
│  ┌─────────────────────────────────────────────────────────────────┐ │
│  │  JSON Views:                                                     │ │
│  │  • OrderJSON (index, show, order_with_items)                    │ │
│  │  • ProductJSON (index, show, with_category)                     │ │
│  │  • ErrorJSON (standard error format)                            │ │
│  │  • SessionJSON (token, user)                                    │ │
│  └─────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
```

## API Endpoints

### Authentication

```
POST /api/sessions
  Body: { email: "chef@example.com", password: "secret" }
  Response: { token: "abc123...", user: { id: 1, name: "Chef", role: "chef" } }

GET /api/me
  Headers: Authorization: Bearer <token>
  Response: { user: { id: 1, name: "Chef", role: "chef", email: "..." } }
```

### Orders

```
GET /api/orders
  Query: ?status=cooking&date=2024-01-01&page=1&per_page=20
  Response: {
    data: [
      { id: 1, customer_name: "Juan", status: "cooking", total: "27.00", ... }
    ],
    meta: { page: 1, per_page: 20, total: 100 }
  }

GET /api/orders/:id
  Response: {
    data: {
      id: 1, customer_name: "Juan", status: "cooking", total: "27.00",
      items: [
        { product_id: 1, name: "Pizza", quantity: 2, unit_price: "12.00", subtotal: "24.00" }
      ],
      status_logs: [
        { from: "pending", to: "confirmed", changed_at: "2024-01-01T10:00:00Z" }
      ]
    }
  }

POST /api/orders
  Headers: Authorization: Bearer <token>
  Body: {
    order: {
      customer_name: "Juan",
      customer_phone: "555-0123",
      notes: "Sin cebolla",
      items: [
        { product_id: 1, quantity: 2, notes: "Extra queso" }
      ]
    }
  }
  Response: { data: { id: 1025, ... } }

PATCH /api/orders/:id/status
  Headers: Authorization: Bearer <token>
  Body: { status: "cooking", reason: null }
  Response: { data: { id: 1, status: "cooking", ... } }

DELETE /api/orders/:id
  Headers: Authorization: Bearer <token>
  Body: { reason: "Cliente canceló" }
  Response: 204 No Content
```

### Products

```
GET /api/products
  Query: ?category_id=1&active=true
  Response: {
    data: [
      { id: 1, name: "Pizza", price: "12.00", stock: 24, category: { id: 1, name: "Platos" } }
    ]
  }

GET /api/products/:id
  Response: { data: { id: 1, name: "Pizza", ... } }
```

## Error Response Format

```json
{
  "error": {
    "code": "invalid_transition",
    "message": "Cannot transition from cooking to cancelled",
    "details": {
      "current_status": "cooking",
      "requested_status": "cancelled",
      "allowed": ["ready"]
    }
  }
}
```

### Error Codes

- `unauthorized` — 401, missing or invalid token
- `forbidden` — 403, valid token but insufficient permissions
- `not_found` — 404, resource doesn't exist
- `validation_error` — 422, invalid data (with field-level errors)
- `invalid_transition` — 422, FSM rejected transition
- `insufficient_stock` — 422, not enough stock for items
- `rate_limit` — 429, too many requests
- `internal_error` — 500, unexpected server error

## ApiAuth Plug

```elixir
defmodule OrderflowWeb.Plugs.ApiAuth do
  @moduledoc "Authenticates API requests via Bearer token"
  import Plug.Conn
  
  def init(opts), do: opts
  
  def call(conn, _opts) do
    case get_bearer_token(conn) do
      nil -> 
        conn |> send_resp(401, error_json("unauthorized", "Missing token")) |> halt()
      
      token ->
        case Orderflow.Accounts.get_user_by_api_token(token) do
          nil -> 
            conn |> send_resp(401, error_json("unauthorized", "Invalid token")) |> halt()
          
          user -> 
            assign(conn, :current_user, user)
        end
    end
  end
  
  defp get_bearer_token(conn) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] -> token
      _ -> nil
    end
  end
  
  defp error_json(code, message) do
    Jason.encode!(%{error: %{code: code, message: message}})
  end
end
```

## FallbackController

```elixir
defmodule OrderflowWeb.FallbackController do
  @moduledoc "Handles errors and returns consistent JSON"
  use OrderflowWeb, :controller
  
  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: OrderflowWeb.ErrorJSON)
    |> render("error.json", changeset: changeset)
  end
  
  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(json: OrderflowWeb.ErrorJSON)
    |> render("404.json")
  end
  
  def call(conn, {:error, :invalid_transition, reason}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: OrderflowWeb.ErrorJSON)
    |> render("invalid_transition.json", reason: reason)
  end
  
  def call(conn, {:error, :insufficient_stock, product_name}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: OrderflowWeb.ErrorJSON)
    |> render("insufficient_stock.json", product_name: product_name)
  end
  
  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(:unauthorized)
    |> put_view(json: OrderflowWeb.ErrorJSON)
    |> render("401.json")
  end
  
  def call(conn, {:error, :forbidden}) do
    conn
    |> put_status(:forbidden)
    |> put_view(json: OrderflowWeb.ErrorJSON)
    |> render("403.json")
  end
end
```

## RateLimit Plug

```elixir
defmodule OrderflowWeb.Plugs.RateLimit do
  @moduledoc "Simple in-memory rate limiter"
  import Plug.Conn
  
  @limit 100  # requests
  @window 60  # seconds
  
  def init(opts), do: opts
  
  def call(conn, _opts) do
    key = rate_limit_key(conn)
    
    case check_rate(key) do
      {:allow, count} ->
        conn |> put_resp_header("x-ratelimit-remaining", to_string(@limit - count))
      
      {:deny, _count} ->
        conn
        |> put_status(:too_many_requests)
        |> put_view(json: OrderflowWeb.ErrorJSON)
        |> render("429.json")
        |> halt()
    end
  end
  
  defp rate_limit_key(conn) do
    case conn.assigns[:current_user] do
      nil -> "ip:#{conn.remote_ip |> :inet.ntoa() |> to_string()}"
      user -> "user:#{user.id}"
    end
  end
  
  defp check_rate(key) do
    # Use ETS or Agent for in-memory tracking
    # Count requests in current window
    # Return {:allow, count} or {:deny, count}
  end
end
```

## JSON Views

### OrderJSON

```elixir
defmodule OrderflowWeb.Api.OrderJSON do
  def index(%{orders: orders, meta: meta}) do
    %{data: for(order <- orders, do: data(order)), meta: meta}
  end
  
  def show(%{order: order}) do
    %{data: data(order)}
  end
  
  defp data(order) do
    %{
      id: order.id,
      customer_name: order.customer_name,
      customer_phone: order.customer_phone,
      status: order.status,
      total: order.total,
      notes: order.notes,
      items: for(item <- order.order_items, do: item_data(item)),
      status_logs: for(log <- order.status_logs, do: log_data(log)),
      inserted_at: order.inserted_at,
      updated_at: order.updated_at
    }
  end
  
  defp item_data(item) do
    %{
      product_id: item.product_id,
      name: item.product.name,
      quantity: item.quantity,
      unit_price: item.unit_price,
      subtotal: item.subtotal,
      notes: item.notes
    }
  end
  
  defp log_data(log) do
    %{
      from_status: log.from_status,
      to_status: log.to_status,
      changed_by: log.changed_by,
      reason: log.reason,
      inserted_at: log.inserted_at
    }
  end
end
```

### ProductJSON

```elixir
defmodule OrderflowWeb.Api.ProductJSON do
  def index(%{products: products}) do
    %{data: for(product <- products, do: data(product))}
  end
  
  def show(%{product: product}) do
    %{data: data(product)}
  end
  
  defp data(product) do
    %{
      id: product.id,
      name: product.name,
      description: product.description,
      price: product.price,
      stock: product.stock,
      active: product.active,
      category: %{
        id: product.category.id,
        name: product.category.name
      }
    }
  end
end
```

### ErrorJSON

```elixir
defmodule OrderflowWeb.Api.ErrorJSON do
  def render("error.json", %{changeset: changeset}) do
    errors = Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
    
    %{error: %{code: "validation_error", message: "Invalid data", details: errors}}
  end
  
  def render("404.json", _assigns) do
    %{error: %{code: "not_found", message: "Resource not found"}}
  end
  
  def render("401.json", _assigns) do
    %{error: %{code: "unauthorized", message: "Authentication required"}}
  end
  
  def render("403.json", _assigns) do
    %{error: %{code: "forbidden", message: "Permission denied"}}
  end
  
  def render("429.json", _assigns) do
    %{error: %{code: "rate_limit", message: "Too many requests"}}
  end
  
  def render("invalid_transition.json", %{reason: reason}) do
    %{error: %{code: "invalid_transition", message: reason}}
  end
  
  def render("insufficient_stock.json", %{product_name: name}) do
    %{error: %{code: "insufficient_stock", message: "Not enough stock for #{name}"}}
  end
  
  def render(template, _assigns) do
    %{error: %{code: "internal_error", message: Phoenix.Controller.status_message_from_template(template)}}
  end
end
```

## Router Updates

```elixir
pipeline :api do
  plug :accepts, ["json"]
  plug OrderflowWeb.Plugs.ApiAuth
  plug OrderflowWeb.Plugs.RateLimit
end

pipeline :api_public do
  plug :accepts, ["json"]
  plug OrderflowWeb.Plugs.RateLimit
end

scope "/api", OrderflowWeb.Api do
  pipe_through :api_public
  
  post "/sessions", SessionController, :create
end

scope "/api", OrderflowWeb.Api do
  pipe_through :api
  
  get "/me", SessionController, :me
  
  get "/orders", OrderController, :index
  get "/orders/:id", OrderController, :show
  post "/orders", OrderController, :create
  patch "/orders/:id/status", OrderController, :update_status
  delete "/orders/:id", OrderController, :delete
  
  get "/products", ProductController, :index
  get "/products/:id", ProductController, :show
end
```

## Controller Implementation

### OrderController

```elixir
defmodule OrderflowWeb.Api.OrderController do
  use OrderflowWeb, :controller
  alias Orderflow.Orders
  
  action_fallback OrderflowWeb.FallbackController
  
  def index(conn, params) do
    status = params["status"] |> parse_status()
    date = params["date"] |> parse_date()
    page = params["page"] || "1" |> String.to_integer()
    per_page = params["per_page"] || "20" |> String.to_integer()
    
    orders = Orders.list_orders(status: status, date: date, page: page, per_page: per_page)
    total = Orders.count_orders(status: status, date: date)
    
    render(conn, :index, orders: orders, meta: %{page: page, per_page: per_page, total: total})
  end
  
  def show(conn, %{"id" => id}) do
    order = Orders.get_order_with_items!(id)
    render(conn, :show, order: order)
  end
  
  def create(conn, %{"order" => order_params}) do
    user = conn.assigns.current_user
    
    with {:ok, order} <- Orders.create_order(order_params, user.id) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/orders/#{order.id}")
      |> render(:show, order: order)
    end
  end
  
  def update_status(conn, %{"id" => id, "status" => status, "reason" => reason}) do
    order = Orders.get_order!(id)
    user = conn.assigns.current_user
    
    with {:ok, order} <- Orders.advance_status(order, String.to_atom(status), user.email, reason) do
      render(conn, :show, order: order)
    end
  end
  
  def delete(conn, %{"id" => id, "reason" => reason}) do
    order = Orders.get_order!(id)
    user = conn.assigns.current_user
    
    with {:ok, _order} <- Orders.cancel_order(order, reason, user.email) do
      send_resp(conn, :no_content, "")
    end
  end
  
  defp parse_status(nil), do: nil
  defp parse_status(status), do: String.to_atom(status)
  
  defp parse_date(nil), do: nil
  defp parse_date(date), do: Date.from_iso8601!(date)
end
```

## Testing Strategy

- **Controller tests**: All endpoints with valid/invalid data
- **Auth tests**: Missing token, invalid token, expired token (if applicable)
- **Rate limit tests**: Exceed limit, verify 429 response
- **Role tests**: Rider can only update delivering → delivered, admin can do everything
- **Integration tests**: Create order via API, verify in database
- **Error tests**: Verify consistent error format across all endpoints

## API Documentation

Create `API.md` in project root:
- Table of all endpoints
- Request/response examples
- Authentication instructions
- Error codes reference
- Rate limit information

## Dependencies

- `{:jason, "~> 1.2"}` — already present
- `{:bcrypt_elixir, "~> 3.0"}` — already present (from accounts)
- Optional: `{:open_api_spex, "~> 3.0"}` — for OpenAPI spec generation

## Notes

- API token stored in `users.api_token` (added in previous change)
- Token generation: `Base.url_encode64(:crypto.strong_rand_bytes(32))`
- No token expiration for simplicity (can add JWT later if needed)
- API uses same `Orderflow.Orders` context as web UI
- Reuse `FallbackController` for all API errors
