# Proposal: expose-rest-api

## Context

The system has a full web UI. Now we need a **REST API** for external integrations (mobile apps, POS systems, delivery partner apps).

## Scope

### Included

1. **API Authentication** — token-based
   - `POST /api/sessions` (email/password → token)
   - `GET /api/me` (current user)
   - `OrderflowWeb.Plugs.ApiAuth` verifies `Authorization: Bearer <token>`
2. **OrderController** (`OrderflowWeb.Api.OrderController`)
   - `GET /api/orders` — list orders (filter by status, date)
   - `GET /api/orders/:id` — show order with items
   - `POST /api/orders` — create order with items
   - `PATCH /api/orders/:id/status` — advance status (rider only: `delivering → delivered`)
   - `DELETE /api/orders/:id` — cancel order (only if allowed by FSM)
3. **ProductController** (`OrderflowWeb.Api.ProductController`)
   - `GET /api/products` — list products with categories
   - `GET /api/products/:id` — show product
4. **Error Handling**
   - Consistent JSON error format: `{error: {code: "...", message: "...", details: {...}}}`
   - 401 Unauthorized, 403 Forbidden, 422 Validation, 404 Not Found, 500 Server Error
5. **Rate Limiting** (optional)
   - Simple in-memory rate limit using `Plug` for API endpoints
   - 100 requests per minute per token
6. **Tests** — Controller tests using `OrderflowWeb.ConnCase`
7. **API Documentation** — `OrderflowWeb.ApiSpec` or README section describing endpoints

### Excluded

- Real-time features (Change: `add-realtime-kitchen-display`)
- Email notifications (Change: `add-notifications`)
- Dashboard (Change: `build-admin-dashboard`)

## Success Criteria

- [ ] API accepts Bearer token authentication
- [ ] All endpoints return consistent JSON
- [ ] Order creation accepts nested items
- [ ] Order status updates respect FSM rules
- [ ] Error responses are informative
- [ ] All API tests pass
- [ ] `mix precommit` passes

## Technical Notes

- Token generation: simple random string stored in `User.api_token` field (added in this change)
- `OrderflowWeb.Plugs.ApiAuth` decodes token and assigns current user to conn
- `OrderflowWeb.Plugs.RequireRole` validates role for API endpoints
- Order creation uses `Ecto.Multi` (reuse from Orders context)
- JSON views: `OrderflowWeb.Api.OrderJSON` and `OrderflowWeb.Api.ProductJSON`
- Use `OrderflowWeb.FallbackController` for consistent error handling
- Add `{:jason, "~> 1.2"}` is already present (used by Phoenix)
- Consider adding `{:open_api_spex, "~> 3.0"}` for OpenAPI spec generation (optional)
