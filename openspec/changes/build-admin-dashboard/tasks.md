# Tasks: build-admin-dashboard

## 1. Create MetricsCollector GenServer
- [ ] Create `apps/orderflow/lib/orderflow/metrics/collector.ex`
  - [ ] Implement `start_link/1` with GenServer
  - [ ] Implement `init/1` to create ETS table
  - [ ] Implement `handle_info(:tick, state)` to recalculate metrics
  - [ ] Implement `calculate_metrics/0` with all queries
  - [ ] Implement `get_dashboard_metrics/0` to read from ETS
  - [ ] Implement `refresh_metrics/0` to trigger recalculation
  - [ ] Schedule periodic ticks (every 5 minutes)
  - [ ] Add `child_spec` to `Orderflow.Application` supervisor
- [ ] Test: GenServer starts and calculates metrics
- [ ] Test: ETS cache is populated
- [ ] Test: `get_dashboard_metrics/0` returns data
- [ ] Test: `refresh_metrics/0` triggers recalculation

## 2. Add Metrics Queries to Orders Context
- [ ] Implement `count_orders_by_date/1` in `Orderflow.Orders`
- [ ] Implement `sum_revenue_by_date/1`
- [ ] Implement `count_orders_by_week/1`
- [ ] Implement `sum_revenue_by_week/1`
- [ ] Implement `count_by_status/1`
- [ ] Implement `avg_order_time/1`
- [ ] Implement `count_active_orders/0`
- [ ] Implement `list_active_orders/0`
- [ ] Test all query functions with seeded data
- [ ] Test edge cases: empty results, null totals

## 3. Create Admin Layout
- [ ] Create `apps/orderflow_web/lib/orderflow_web/components/layouts/admin.html.heex`
  - [ ] Sidebar with navigation links
  - [ ] Active link highlighting
  - [ ] Top bar with logo and user menu
  - [ ] Responsive: collapsible on mobile
  - [ ] Dark mode support
- [ ] Create `apps/orderflow_web/lib/orderflow_web/components/admin_components.ex`
  - [ ] `metric_card/1` — card with icon, value, label
  - [ ] `status_bar/1` — horizontal bar chart
  - [ ] `data_table/1` — sortable table with header
  - [ ] `filter_bar/1` — filter inputs row
  - [ ] `modal/1` — modal container
  - [ ] `badge/1` — colored badge
  - [ ] `pagination/1` — page controls
  - [ ] `empty_state/1` — no data display
- [ ] Add `use OrderflowWeb, :admin_layout` macro (if needed)
- [ ] Update `OrderflowWeb` module to add `admin_layout` helper

## 4. Implement AdminDashboard LiveView
- [ ] Create `apps/orderflow_web/lib/orderflow_web/live/admin_live/dashboard.ex`
  - [ ] `mount/3`: subscribe to PubSub, load metrics
  - [ ] `handle_info/2`: handle order changes, refresh metrics
  - [ ] `render/1`: assign to `admin/dashboard.html.heex`
- [ ] Create `apps/orderflow_web/lib/orderflow_web/live/admin_live/dashboard.html.heex`
  - [ ] Metrics grid (4 cards)
  - [ ] Status bar chart (CSS-based)
  - [ ] Weekly activity chart (CSS-based)
  - [ ] Active orders table (top 10)
  - [ ] Auto-refresh indicator (last updated)
- [ ] Test: Dashboard renders metrics
- [ ] Test: Dashboard updates when order changes
- [ ] Test: Unauthorized access redirected

## 5. Implement UserManagement LiveView
- [ ] Create `apps/orderflow_web/lib/orderflow_web/live/admin_live/user_management.ex`
  - [ ] `mount/3`: load users with pagination
  - [ ] `handle_event/3`: handle search, filter, sort, pagination
  - [ ] `handle_event/3`: handle inline role edit
  - [ ] `handle_event/3`: handle toggle active
  - [ ] `handle_event/3`: handle create new user (modal)
  - [ ] `render/1`: assign to `admin/user_management.html.heex`
- [ ] Create `apps/orderflow_web/lib/orderflow_web/live/admin_live/user_management.html.heex`
  - [ ] Search input
  - [ ] Role filter dropdown
  - [ ] New user button (opens modal)
  - [ ] Users table with inline editing
  - [ ] Pagination controls
  - [ ] Modal form for new user
- [ ] Test: List users with pagination
- [ ] Test: Search filters by name
- [ ] Test: Filter by role
- [ ] Test: Inline role edit updates user
- [ ] Test: Toggle active status
- [ ] Test: Create new user with modal
- [ ] Test: Unauthorized access redirected

## 6. Implement ProductManagement LiveView
- [ ] Create `apps/orderflow_web/lib/orderflow_web/live/admin_live/product_management.ex`
  - [ ] `mount/3`: load products with pagination
  - [ ] `handle_event/3`: handle search, category filter, sort
  - [ ] `handle_event/3`: handle inline stock edit
  - [ ] `handle_event/3`: handle toggle active
  - [ ] `handle_event/3`: handle create new product (modal)
  - [ ] `render/1`: assign to `admin/product_management.html.heex`
- [ ] Create `apps/orderflow_web/lib/orderflow_web/live/admin_live/product_management.html.heex`
  - [ ] Search input
  - [ ] Category filter dropdown
  - [ ] New product button (opens modal)
  - [ ] Products table with inline stock editing
  - [ ] Stock color indicator (green/yellow/red)
  - [ ] Pagination controls
  - [ ] Modal form for new product
- [ ] Test: List products with pagination
- [ ] Test: Filter by category
- [ ] Test: Inline stock edit updates product
- [ ] Test: Toggle active status
- [ ] Test: Create new product with modal
- [ ] Test: Unauthorized access redirected

## 7. Implement OrderHistory LiveView
- [ ] Create `apps/orderflow_web/lib/orderflow_web/live/admin_live/order_history.ex`
  - [ ] `mount/3`: load orders with pagination
  - [ ] `handle_event/3`: handle search, status filter, date filter
  - [ ] `handle_event/3`: handle sort by column
  - [ ] `handle_event/3`: handle pagination
  - [ ] `handle_event/3`: handle show order details (modal)
  - [ ] `render/1`: assign to `admin/order_history.html.heex`
- [ ] Create `apps/orderflow_web/lib/orderflow_web/live/admin_live/order_history.html.heex`
  - [ ] Search input (by order number or customer name)
  - [ ] Status filter (multi-select checkboxes)
  - [ ] Date range filter (today/week/month/custom)
  - [ ] Sort dropdown (date, total, status)
  - [ ] Orders table
  - [ ] Pagination controls
  - [ ] Modal with order details
  - [ ] Export to CSV button (optional)
- [ ] Test: List orders with pagination
- [ ] Test: Filter by status
- [ ] Test: Filter by date range
- [ ] Test: Sort by different columns
- [ ] Test: Search by order number
- [ ] Test: Show order details modal
- [ ] Test: Unauthorized access redirected

## 8. Update Router
- [ ] Add `:admin` pipeline with `:browser` + `RequireRole, :admin`
- [ ] Add admin scope:
  - [ ] `live "/admin", AdminLive.Dashboard, :index`
  - [ ] `live "/admin/users", AdminLive.UserManagement, :index`
  - [ ] `live "/admin/users/new", AdminLive.UserManagement, :new`
  - [ ] `live "/admin/users/:id/edit", AdminLive.UserManagement, :edit`
  - [ ] `live "/admin/products", AdminLive.ProductManagement, :index`
  - [ ] `live "/admin/products/new", AdminLive.ProductManagement, :new`
  - [ ] `live "/admin/products/:id/edit", AdminLive.ProductManagement, :edit`
  - [ ] `live "/admin/history", AdminLive.OrderHistory, :index`
- [ ] Update root layout navigation to include admin links for admin users

## 9. Update Navigation
- [ ] Update `root.html.heex` to show role-based navigation
  - [ ] Admin: Dashboard, Users, Products, History, Kitchen (link)
  - [ ] Chef: Kitchen (direct link), Tracker
  - [ ] Rider: (placeholder for future)
  - [ ] Customer: Tracker
  - [ ] Active page highlighting
- [ ] Add mobile hamburger menu
- [ ] Add user dropdown with name, role, logout

## 10. Write Tests
- [ ] Create `apps/orderflow_web/test/orderflow_web/live/admin_live/dashboard_test.exs`
  - [ ] Test renders metrics
  - [ ] Test updates on order change
  - [ ] Test unauthorized access
- [ ] Create `apps/orderflow_web/test/orderflow_web/live/admin_live/user_management_test.exs`
  - [ ] Test list users
  - [ ] Test pagination
  - [ ] Test search/filter
  - [ ] Test edit role
  - [ ] Test toggle active
  - [ ] Test create user
  - [ ] Test unauthorized access
- [ ] Create `apps/orderflow_web/test/orderflow_web/live/admin_live/product_management_test.exs`
  - [ ] Test list products
  - [ ] Test pagination
  - [ ] Test filter by category
  - [ ] Test edit stock
  - [ ] Test toggle active
  - [ ] Test create product
  - [ ] Test unauthorized access
- [ ] Create `apps/orderflow_web/test/orderflow_web/live/admin_live/order_history_test.exs`
  - [ ] Test list orders
  - [ ] Test pagination
  - [ ] Test filter by status
  - [ ] Test filter by date
  - [ ] Test sort by column
  - [ ] Test search
  - [ ] Test unauthorized access
- [ ] Create `apps/orderflow/test/orderflow/metrics/collector_test.exs`
  - [ ] Test GenServer starts
  - [ ] Test calculates metrics
  - [ ] Test caches in ETS
  - [ ] Test periodic updates
  - [ ] Test manual refresh

## 11. Quality Gate
- [ ] Run `mix compile --warnings-as-errors`
- [ ] Run `mix deps.unlock --unused`
- [ ] Run `mix format`
- [ ] Run `mix test` (all pass)
- [ ] Run `mix precommit` (all pass)
- [ ] Manual test: Dashboard shows metrics
- [ ] Manual test: Dashboard updates when order changes
- [ ] Manual test: User management CRUD works
- [ ] Manual test: Product management CRUD works
- [ ] Manual test: Order history filters work
- [ ] Manual test: Admin routes protected by role
- [ ] Manual test: Mobile responsive layout

## 12. Documentation
- [ ] Add `@moduledoc` to all Admin LiveViews
- [ ] Add `@moduledoc` to MetricsCollector
- [ ] Add `@moduledoc` to AdminComponents
- [ ] Update `apps/orderflow_web/README.md` with admin features
- [ ] Add metrics calculation logic comments in Orders context
