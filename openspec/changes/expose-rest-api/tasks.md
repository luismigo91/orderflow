# Tasks: expose-rest-api

## 1. Add API Token to Users
- [ ] Ensure `users.api_token` migration exists (from previous change)
- [ ] Add `generate_api_token/1` to `Orderflow.Accounts`
  - [ ] Generate random token using `:crypto.strong_rand_bytes/1`
  - [ ] Base64 URL-safe encoding
  - [ ] Update user in database
- [ ] Add `get_user_by_api_token/1` to `Orderflow.Accounts`
  - [ ] Query by api_token
  - [ ] Return user or nil
- [ ] Add `api_token` to User schema changeset (optional, nullable)
- [ ] Update seeds to generate API tokens for all users
- [ ] Test: `generate_api_token/1` creates unique token
- [ ] Test: `get_user_by_api_token/1` returns correct user
- [ ] Test: `get_user_by_api_token/1` with invalid token returns nil

## 2. Create ApiAuth Plug
- [ ] Create `apps/orderflow_web/lib/orderflow_web/plugs/api_auth.ex`
  - [ ] Extract Bearer token from Authorization header
  - [ ] Handle missing token → 401
  - [ ] Handle invalid token → 401
  - [ ] Lookup user by token via `Accounts.get_user_by_api_token/1`
  - [ ] Assign user to conn on success
  - [ ] Add `init/1` and `call/2`
  - [ ] Add `@moduledoc`
- [ ] Test: Passes with valid token
- [ ] Test: Returns 401 with missing token
- [ ] Test: Returns 401 with invalid token
- [ ] Test: Returns 401 with malformed header

## 3. Create RateLimit Plug
- [ ] Create `apps/orderflow_web/lib/orderflow_web/plugs/rate_limit.ex`
  - [ ] Use ETS or Agent for in-memory tracking
  - [ ] Key by user ID (if authenticated) or IP address
  - [ ] Track request timestamps in sliding window
  - [ ] Limit: 100 requests per 60 seconds
  - [ ] Return 429 with `Retry-After` header when exceeded
  - [ ] Add `x-ratelimit-remaining` header on success
  - [ ] Add `init/1` and `call/2`
  - [ ] Add `@moduledoc`
- [ ] Test: Allows requests under limit
- [ ] Test: Denies requests over limit
- [ ] Test: Resets after window expires
- [ ] Test: Different keys for different users/IPs
- [ ] Test: Rate limit headers present

## 4. Create FallbackController
- [ ] Create `apps/orderflow_web/lib/orderflow_web/controllers/fallback_controller.ex`
  - [ ] Handle `{:error, %Ecto.Changeset{}}` → 422 with validation errors
  - [ ] Handle `{:error, :not_found}` → 404
  - [ ] Handle `{:error, :invalid_transition, reason}` → 422
  - [ ] Handle `{:error, :insufficient_stock, product_name}` → 422
  - [ ] Handle `{:error, :unauthorized}` → 401
  - [ ] Handle `{:error, :forbidden}` → 403
  - [ ] Handle generic errors → 500
  - [ ] Use `action_fallback` in controllers
  - [ ] Add `@moduledoc`
- [ ] Test: Each error case returns correct status and JSON format
- [ ] Test: Changeset errors include field-level details
- [ ] Test: All errors follow consistent format

## 5. Create JSON Views
- [ ] Create `apps/orderflow_web/lib/orderflow_web/controllers/api/order_json.ex`
  - [ ] `index/1` renders list with meta
  - [ ] `show/1` renders single order with items and logs
  - [ ] `data/1` helper for order serialization
  - [ ] `item_data/1` helper for order item serialization
  - [ ] `log_data/1` helper for status log serialization
  - [ ] Test: JSON structure matches spec
- [ ] Create `apps/orderflow_web/lib/orderflow_web/controllers/api/product_json.ex`
  - [ ] `index/1` renders list
  - [ ] `show/1` renders single product with category
  - [ ] `data/1` helper for product serialization
  - [ ] Test: JSON structure matches spec
- [ ] Create `apps/orderflow_web/lib/orderflow_web/controllers/api/session_json.ex`
  - [ ] `create/1` renders token and user
  - [ ] `me/1` renders user
  - [ ] `data/1` helper for user serialization
  - [ ] Test: JSON structure matches spec
- [ ] Create `apps/orderflow_web/lib/orderflow_web/controllers/api/error_json.ex`
  - [ ] `render/2` for "error.json" with changeset
  - [ ] `render/2` for "404.json"
  - [ ] `render/2` for "401.json"
  - [ ] `render/2` for "403.json"
  - [ ] `render/2` for "429.json"
  - [ ] `render/2` for "invalid_transition.json"
  - [ ] `render/2` for "insufficient_stock.json"
  - [ ] `render/2` for default template (500)
  - [ ] Test: All error templates render correct JSON
  - [ ] Test: Changeset errors include field-level details

## 6. Implement SessionController
- [ ] Create `apps/orderflow_web/lib/orderflow_web/controllers/api/session_controller.ex`
  - [ ] `create/2` — authenticate user, generate token, return JSON
  - [ ] `me/2` — return current user from conn assigns
  - [ ] Use `action_fallback OrderflowWeb.FallbackController`
  - [ ] Test: Valid credentials return token and user
  - [ ] Test: Invalid credentials return 401
  - [ ] Test: `me` returns current user when authenticated
  - [ ] Test: `me` returns 401 when not authenticated

## 7. Implement OrderController
- [ ] Create `apps/orderflow_web/lib/orderflow_web/controllers/api/order_controller.ex`
  - [ ] `index/2` — list orders with filters (status, date, pagination)
  - [ ] `show/2` — get single order with items and logs
  - [ ] `create/2` — create order with nested items
  - [ ] `update_status/2` — advance order status (FSM validation)
  - [ ] `delete/2` — cancel order with reason
  - [ ] Use `action_fallback OrderflowWeb.FallbackController`
  - [ ] Parse query params (status atom, date, pagination)
  - [ ] Add `Orderflow.Orders.list_orders/1` with opts support
  - [ ] Add `Orderflow.Orders.count_orders/1` with opts support
  - [ ] Test: `index` returns paginated list
  - [ ] Test: `index` filters by status
  - [ ] Test: `index` filters by date
  - [ ] Test: `show` returns order with items
  - [ ] Test: `show` returns 404 for missing order
  - [ ] Test: `create` with valid data returns 201
  - [ ] Test: `create` with invalid data returns 422
  - [ ] Test: `update_status` advances status
  - [ ] Test: `update_status` with invalid transition returns 422
  - [ ] Test: `delete` cancels order
  - [ ] Test: `delete` with missing order returns 404
  - [ ] Test: All endpoints require authentication
  - [ ] Test: Role-based access (rider can only update delivering)

## 8. Implement ProductController
- [ ] Create `apps/orderflow_web/lib/orderflow_web/controllers/api/product_controller.ex`
  - [ ] `index/2` — list products with optional category filter
  - [ ] `show/2` — get single product with category
  - [ ] Use `action_fallback OrderflowWeb.FallbackController`
  - [ ] Add `Orderflow.Catalog.list_products/1` with opts support
  - [ ] Test: `index` returns all products
  - [ ] Test: `index` filters by category
  - [ ] Test: `show` returns product with category
  - [ ] Test: `show` returns 404 for missing product
  - [ ] Test: Public access (no auth required for products)

## 9. Update Router
- [ ] Add `:api` pipeline with `:accepts_json`, `ApiAuth`, `RateLimit`
- [ ] Add `:api_public` pipeline with `:accepts_json`, `RateLimit` (no auth)
- [ ] Add public API scope:
  - [ ] `post "/api/sessions", SessionController, :create`
- [ ] Add authenticated API scope:
  - [ ] `get "/api/me", SessionController, :me`
  - [ ] `get "/api/orders", OrderController, :index`
  - [ ] `get "/api/orders/:id", OrderController, :show`
  - [ ] `post "/api/orders", OrderController, :create`
  - [ ] `patch "/api/orders/:id/status", OrderController, :update_status`
  - [ ] `delete "/api/orders/:id", OrderController, :delete`
  - [ ] `get "/api/products", ProductController, :index`
  - [ ] `get "/api/products/:id", ProductController, :show`
- [ ] Test: All routes are accessible
- [ ] Test: Auth routes protected
- [ ] Test: Public routes accessible without auth

## 10. Add API Documentation
- [ ] Create `API.md` in project root
  - [ ] Authentication section (Bearer token)
  - [ ] Endpoint table (method, path, description, auth required)
  - [ ] Request/response examples for each endpoint
  - [ ] Error codes reference
  - [ ] Rate limit information
  - [ ] Example cURL commands
- [ ] Add API docs to `README.md`

## 11. Update Orders Context for API
- [ ] Add `list_orders/1` with opts support:
  - [ ] `:status` — filter by status
  - [ ] `:date` — filter by date
  - [ ] `:page` — pagination offset
  - [ ] `:per_page` — pagination limit
  - [ ] Preload: order_items, products, status_logs
- [ ] Add `count_orders/1` with opts support:
  - [ ] `:status` — filter by status
  - [ ] `:date` — filter by date
- [ ] Test: `list_orders/1` with all filter combinations
- [ ] Test: `count_orders/1` with all filter combinations
- [ ] Test: Pagination returns correct page
- [ ] Test: Preloads are included

## 12. Update Catalog Context for API
- [ ] Add `list_products/1` with opts support:
  - [ ] `:category_id` — filter by category
  - [ ] `:active` — filter by active status
  - [ ] Preload: category
- [ ] Test: `list_products/1` with all filter combinations
- [ ] Test: Preloads are included

## 13. Quality Gate
- [ ] Run `mix compile --warnings-as-errors`
- [ ] Run `mix deps.unlock --unused`
- [ ] Run `mix format`
- [ ] Run `mix test` (all pass)
- [ ] Run `mix precommit` (all pass)
- [ ] Manual test: `curl -X POST http://localhost:4000/api/sessions` with valid credentials
- [ ] Manual test: `curl -H "Authorization: Bearer <token>" http://localhost:4000/api/me`
- [ ] Manual test: `curl -H "Authorization: Bearer <token>" http://localhost:4000/api/orders`
- [ ] Manual test: `curl -H "Authorization: Bearer <token>" http://localhost:4000/api/products`
- [ ] Manual test: Rate limit triggers after 100 requests
- [ ] Manual test: Error responses are consistent JSON

## 14. Documentation
- [ ] Add `@moduledoc` to all API controllers
- [ ] Add `@moduledoc` to all Plugs
- [ ] Add `@moduledoc` to all JSON views
- [ ] Add `@moduledoc` to FallbackController
- [ ] Update `apps/orderflow_web/README.md` with API description
- [ ] Update `README.md` with API section and link to `API.md`
- [ ] Add API documentation to `AGENTS.md` if relevant
