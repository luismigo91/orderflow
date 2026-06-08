# Proposal: build-admin-dashboard

## Context

With the order system and real-time displays working, we need an **admin dashboard** for analytics and management.

## Scope

### Included

1. **LiveView `AdminDashboard`** — overview metrics
   - Total orders today / this week / this month
   - Revenue today / this week / this month
   - Average order time (from `cooking` to `ready`)
   - Orders by status (pie chart or bar using CSS/SVG)
   - Active orders table (real-time updates)
2. **LiveView `UserManagement`** — CRUD for users
   - List users with role badges
   - Create/edit users inline
   - Deactivate/activate users
3. **LiveView `ProductManagement`** — CRUD for products
   - List products with stock indicators
   - Quick stock edit
   - Toggle active/inactive
   - Filter by category
4. **LiveView `OrderHistory`** — searchable list of past orders
   - Filter by status, date range
   - Sort by created_at
   - Pagination (manual or Flop)
   - Export to CSV (optional)
5. **MetricsCollector** — `GenServer` that recalculates dashboard metrics periodically
   - Runs every 5 minutes or on demand
   - Caches results in ETS for fast dashboard loads
   - Triggers on PubSub events
6. **Router guards** — `RequireAdmin` plug ensures only admins access these routes
7. **Tests** — LiveView and GenServer tests

### Excluded

- API endpoints (Change: `expose-rest-api`)
- Email notifications (Change: `add-notifications`)
- Kitchen display (Change: `add-realtime-kitchen-display`)

## Success Criteria

- [ ] Admin dashboard shows live metrics
- [ ] User management allows CRUD operations
- [ ] Product management allows stock updates
- [ ] Order history supports filtering
- [ ] MetricsCollector updates on order changes
- [ ] All tests pass
- [ ] `mix precommit` passes

## Technical Notes

- Dashboard uses `Phoenix.PubSub` to listen for order changes
- MetricsCollector stores in `Orderflow.Metrics.Cache` (ETS table)
- Dashboard queries cache first, falls back to DB
- User/Product management uses `form` + `submit` patterns in LiveView
- Order history uses `stream` or `assign` with pagination
- Use `Flop` library if pagination is complex, otherwise manual offset/limit
- Role-based access: `OrderflowWeb.Plugs.RequireRole` with `:admin` role
