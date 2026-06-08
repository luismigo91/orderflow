# Tasks: add-realtime-kitchen-display

## 1. Update PubSub in Orders Context
- [ ] Add `broadcast_order_change/2` private function in `Orderflow.Orders`
- [ ] Broadcast to `"orders:lobby"` after every successful status transition
- [ ] Broadcast to `"order:#{order.id}"` after every successful status transition
- [ ] Add `subscribe_to_orders/0` helper function
- [ ] Add `subscribe_to_order/1` helper function
- [ ] Test that broadcast is sent on order update

## 2. Create Presence Module
- [ ] Create `apps/orderflow_web/lib/orderflow_web/presence.ex`
- [ ] Use `Phoenix.Presence` with `:orderflow_web` otp_app
- [ ] Configure pubsub_server as `Orderflow.PubSub`
- [ ] Add `list_users/1` helper
- [ ] Add `track_user/3` helper
- [ ] Test Presence module initialization

## 3. Create Plugs
- [ ] Create `apps/orderflow_web/lib/orderflow_web/plugs/require_auth.ex`
  - [ ] Check for `current_user` in conn assigns
  - [ ] Redirect to login if not authenticated
  - [ ] Add `init/1` and `call/2`
- [ ] Create `apps/orderflow_web/lib/orderflow_web/plugs/require_role.ex`
  - [ ] Accept role parameter in `init/1`
  - [ ] Check user role matches
  - [ ] Redirect with error if not authorized
  - [ ] Support multiple roles (optional: `[:admin, :chef]`)
- [ ] Create `apps/orderflow_web/lib/orderflow_web/plugs/fetch_current_user.ex`
  - [ ] Fetch user from session token
  - [ ] Assign `current_user` to conn
  - [ ] Handle invalid/missing token gracefully

## 4. Implement KitchenDisplay LiveView
- [ ] Create `apps/orderflow_web/lib/orderflow_web/live/kitchen_live/index.ex`
  - [ ] `mount/3`: subscribe to PubSub, track presence, load orders
  - [ ] `handle_info/2`: handle `order_updated` broadcast, refresh orders
  - [ ] `handle_event/3`: handle "advance_status" button clicks
  - [ ] `render/1`: assign to `kitchen/index.html.heex` template
- [ ] Create `apps/orderflow_web/lib/orderflow_web/live/kitchen_live/index.html.heex`
  - [ ] Grid layout for order cards
  - [ ] Timer display for each order
  - [ ] Status badge with color
  - [ ] Action buttons (conditional on status)
  - [ ] Alert banner for stuck orders
  - [ ] Online users counter
- [ ] Add `kitchen.html.heex` layout (full-screen, minimal)
  - [ ] No navigation bar
  - [ ] Large font sizes
  - [ ] Optimized for tablets (min 768px width)
  - [ ] Dark mode support

## 5. Implement OrderTracker LiveView
- [ ] Create `apps/orderflow_web/lib/orderflow_web/live/order_tracker_live/index.ex`
  - [ ] Public access (no auth required)
  - [ ] Accept order ID or phone as parameter
  - [ ] Subscribe to `"order:#{id}"` topic
  - [ ] Display current status with visual progress
  - [ ] Show estimated delivery time
  - [ ] Handle not found gracefully
- [ ] Create `apps/orderflow_web/lib/orderflow_web/live/order_tracker_live/index.html.heex`
  - [ ] Progress bar/timeline visualization
  - [ ] Order details (items, total)
  - [ ] Status with icon and color
  - [ ] ETA countdown
  - [ ] Mobile-optimized layout
- [ ] Add `public.html.heex` layout (minimal)

## 6. Implement OrderForm LiveView
- [ ] Create `apps/orderflow_web/lib/orderflow_web/live/order_live/index.ex` (new order)
  - [ ] Use `OrderFormComponent` for the form
  - [ ] Handle "save" event
  - [ ] Redirect to order tracker on success
- [ ] Create `apps/orderflow_web/lib/orderflow_web/live/order_live/form_component.ex`
  - [ ] Dynamic line items (add/remove rows)
  - [ ] Product selector with categories
  - [ ] Live quantity updates
  - [ ] Live total calculation
  - [ ] Stock validation (error if insufficient)
  - [ ] Use `Orderflow.Catalog.list_products/0` for dropdown
  - [ ] Handle `cast_assoc` for nested order_items
- [ ] Create `apps/orderflow_web/lib/orderflow_web/live/order_live/form_component.html.heex`
  - [ ] Customer info fields
  - [ ] Dynamic line items table
  - [ ] Product dropdown per row
  - [ ] Quantity input per row
  - [ ] Remove button per row
  - [ ] Add item button
  - [ ] Total display
  - [ ] Submit button

## 7. Create Reusable Components
- [ ] Create `apps/orderflow_web/lib/orderflow_web/components/order_components.ex`
  - [ ] `order_card/1` — card with timer, status, items, buttons
  - [ ] `status_badge/1` — colored badge for status
  - [ ] `timer_display/1` — elapsed time with color coding
  - [ ] `order_items_list/1` — list of items with quantities
  - [ ] `progress_bar/1` — visual progress for tracker
  - [ ] `online_users_badge/1` — presence indicator
- [ ] Add `@moduledoc` to `OrderComponents`
- [ ] Use `OrderComponents` in Kitchen and Tracker views

## 8. Update Router
- [ ] Add `OrderflowWeb.Plugs.FetchCurrentUser` to `:browser` pipeline
- [ ] Create `:kitchen` pipeline with `:browser` + `RequireRole, :chef`
- [ ] Create `:admin` pipeline with `:browser` + `RequireRole, :admin`
- [ ] Add public routes (no auth):
  - [ ] `get "/track", OrderTrackerController, :index`
  - [ ] `live "/track/:id", OrderTrackerLive.Index`
- [ ] Add kitchen routes (chef only):
  - [ ] `live "/kitchen", KitchenLive.Index`
- [ ] Add admin routes (admin only):
  - [ ] `live "/admin/orders/new", OrderLive.Index, :new`
- [ ] Add login route:
  - [ ] `live "/login", SessionLive.New`
- [ ] Update `PageController` to redirect based on role
  - [ ] Admin → admin dashboard
  - [ ] Chef → kitchen display
  - [ ] Rider → (placeholder for future)
  - [ ] Customer → tracker page

## 9. Create Session Management
- [ ] Create `apps/orderflow_web/lib/orderflow_web/live/session_live/new.ex`
  - [ ] Login form with email/password
  - [ ] Authenticate via `Orderflow.Accounts`
  - [ ] Set session token on success
  - [ ] Show error on invalid credentials
- [ ] Create `apps/orderflow_web/lib/orderflow_web/live/session_live/new.html.heex`
  - [ ] Simple centered form
  - [ ] Email input
  - [ ] Password input
  - [ ] Submit button
  - [ ] Error display
- [ ] Create `apps/orderflow_web/lib/orderflow_web/controllers/session_controller.ex`
  - [ ] `create/2` — authenticate and set session
  - [ ] `delete/2` — clear session (logout)
- [ ] Add logout route: `delete "/logout", SessionController, :delete`

## 10. Update Layouts
- [ ] Update `root.html.heex` to show navigation
  - [ ] Logo/brand link
  - [ ] Role-based navigation links
  - [ ] User name and role badge
  - [ ] Logout button
  - [ ] Responsive mobile menu
- [ ] Create `apps/orderflow_web/lib/orderflow_web/components/layouts/kitchen.html.heex`
  - [ ] Full-screen layout (no padding)
  - [ ] Top bar with order count and online users
  - [ ] Large font sizes
  - [ ] No sidebar navigation
- [ ] Create `apps/orderflow_web/lib/orderflow_web/components/layouts/public.html.heex`
  - [ ] Minimal layout (centered content)
  - [ ] Small header with logo
  - [ ] No navigation
  - [ ] Mobile-first design

## 11. Write Tests
- [ ] Create `apps/orderflow_web/test/orderflow_web/live/kitchen_live_test.exs`
  - [ ] Test mount renders orders
  - [ ] Test "advance_status" event updates order
  - [ ] Test order card appears after broadcast
  - [ ] Test unauthorized access is redirected
- [ ] Create `apps/orderflow_web/test/orderflow_web/live/order_tracker_live_test.exs`
  - [ ] Test mount renders order details
  - [ ] Test status updates after broadcast
  - [ ] Test not found shows error
  - [ ] Test public access (no auth required)
- [ ] Create `apps/orderflow_web/test/orderflow_web/live/order_live_test.exs`
  - [ ] Test create order with items
  - [ ] Test form validation (missing customer)
  - [ ] Test live total updates on item changes
  - [ ] Test add/remove line items
- [ ] Create `apps/orderflow_web/test/orderflow_web/plugs/require_auth_test.exs`
  - [ ] Test redirects when not authenticated
  - [ ] Test passes when authenticated
- [ ] Create `apps/orderflow_web/test/orderflow_web/plugs/require_role_test.exs`
  - [ ] Test redirects when wrong role
  - [ ] Test passes when correct role
- [ ] Create `apps/orderflow_web/test/orderflow_web/presence_test.exs`
  - [ ] Test tracks users
  - [ ] Test lists online users
- [ ] Test PubSub broadcast in integration
  - [ ] Two LiveViews receive same update

## 12. Quality Gate
- [ ] Run `mix compile --warnings-as-errors`
- [ ] Run `mix deps.unlock --unused`
- [ ] Run `mix format`
- [ ] Run `mix test` (all pass)
- [ ] Run `mix precommit` (all pass)
- [ ] Manual test: Open two browser tabs, create order in one, see it appear in kitchen
- [ ] Manual test: Open kitchen and tracker, advance status, see both update
- [ ] Manual test: Login as admin, access admin routes
- [ ] Manual test: Login as chef, access kitchen routes
- [ ] Manual test: Login as customer, access tracker routes
- [ ] Manual test: Unauthenticated user redirected to login

## 13. Documentation
- [ ] Add `@moduledoc` to all LiveViews
- [ ] Add `@moduledoc` to all Plugs
- [ ] Add `@moduledoc` to Presence module
- [ ] Add `@moduledoc` to OrderComponents
- [ ] Update `apps/orderflow_web/README.md` with live views description
- [ ] Add screenshots description (for article) in a `docs/` folder (optional)
