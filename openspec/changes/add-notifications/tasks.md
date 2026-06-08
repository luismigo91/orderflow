# Tasks: add-notifications

## 1. Create OrderNotifier GenServer
- [ ] Create `apps/orderflow/lib/orderflow/notifications/order_notifier.ex`
  - [ ] Implement `start_link/1` with GenServer
  - [ ] Implement `init/1` to subscribe to `"orders:lobby"` PubSub topic
  - [ ] Implement `handle_info/2` for order change broadcasts
  - [ ] Implement `send_notification/1` to dispatch emails based on status
  - [ ] Handle `:cooking` → send order confirmed email
  - [ ] Handle `:delivering` → send order on the way email
  - [ ] Handle `:delivered` → send order delivered email
  - [ ] Ignore other statuses
  - [ ] Add `child_spec` to `Orderflow.Application` supervisor
  - [ ] Add `@moduledoc` with description and behavior
- [ ] Test: GenServer starts successfully
- [ ] Test: Subscribes to PubSub topic
- [ ] Test: Receives and handles order update broadcasts
- [ ] Test: Sends correct email for each status
- [ ] Test: Does not send email for ignored statuses
- [ ] Test: Handles errors gracefully (does not crash)

## 2. Create Alert Scheduler GenServer
- [ ] Create `apps/orderflow/lib/orderflow/alerts/scheduler.ex`
  - [ ] Implement `start_link/1` with GenServer
  - [ ] Implement `init/1` to schedule first check
  - [ ] Implement `handle_info(:check, state)` to check stuck orders
  - [ ] Check orders in `:cooking` > 30 minutes
  - [ ] Check orders in `:pending` > 10 minutes
  - [ ] Broadcast alert to `"admin:alerts"` PubSub topic
  - [ ] Schedule next check every 5 minutes
  - [ ] Add `child_spec` to `Orderflow.Application` supervisor
  - [ ] Add `@moduledoc`
- [ ] Test: GenServer starts and schedules checks
- [ ] Test: Detects stuck orders in cooking
- [ ] Test: Detects stuck orders in pending
- [ ] Test: Broadcasts alert to admin topic
- [ ] Test: Does not alert for non-stuck orders
- [ ] Test: Reschedules after each check

## 3. Create Email Templates
- [ ] Create `apps/orderflow_web/lib/orderflow_web/emails/order_confirmed.html.heex`
  - [ ] Order header with green color
  - [ ] Customer greeting
  - [ ] Order summary with items list
  - [ ] Total amount
  - [ ] Estimated time
  - [ ] Tracker link
  - [ ] Inline CSS for email compatibility
- [ ] Create `apps/orderflow_web/lib/orderflow_web/emails/order_on_the_way.html.heex`
  - [ ] Order header with blue color
  - [ ] Delivery notification message
  - [ ] Estimated arrival time
  - [ ] Tracker link
  - [ ] Inline CSS
- [ ] Create `apps/orderflow_web/lib/orderflow_web/emails/order_delivered.html.heex`
  - [ ] Order header with green color
  - [ ] Delivery confirmation message
  - [ ] Order summary
  - [ ] Thank you message
  - [ ] Inline CSS
- [ ] Create `apps/orderflow_web/lib/orderflow_web/emails/admin_alert.html.heex`
  - [ ] Alert header with red color
  - [ ] Order details (number, status, duration)
  - [ ] Customer info (name, phone)
  - [ ] Items list
  - [ ] Admin dashboard link
  - [ ] Inline CSS
- [ ] Test: All templates render correctly
- [ ] Test: Templates include order data correctly
- [ ] Test: Templates are responsive (mobile-friendly)

## 4. Create Emails Module
- [ ] Create `apps/orderflow/lib/orderflow/notifications/emails.ex`
  - [ ] Implement `order_confirmed/1` — builds email with template
  - [ ] Implement `order_on_the_way/1` — builds email with template
  - [ ] Implement `order_delivered/1` — builds email with template
  - [ ] Implement `admin_alert/3` — builds alert email with template
  - [ ] Use `Swoosh.Email` functions
  - [ ] Set from/to/subject correctly
  - [ ] Use `render_body/2` for HEEx templates
  - [ ] Add `@moduledoc`
- [ ] Test: `order_confirmed/1` returns correct email structure
- [ ] Test: `order_on_the_way/1` returns correct email structure
- [ ] Test: `order_delivered/1` returns correct email structure
- [ ] Test: `admin_alert/3` returns correct email structure
- [ ] Test: All emails have correct subject lines
- [ ] Test: All emails have correct recipients

## 5. Update Application Supervisor
- [ ] Add `Orderflow.Notifications.OrderNotifier` to `Orderflow.Application` children
- [ ] Add `Orderflow.Alerts.Scheduler` to `Orderflow.Application` children
- [ ] Ensure correct startup order (after Repo and PubSub)
- [ ] Test: Application starts successfully with new children
- [ ] Test: Both GenServers start on application boot
- [ ] Test: Supervisor restarts GenServers if they crash

## 6. Update Admin Dashboard for Alerts
- [ ] Update `OrderflowWeb.AdminLive.Dashboard` to subscribe to `"admin:alerts"`
  - [ ] Add `Orderflow.PubSub.subscribe("admin:alerts")` in `mount/3`
  - [ ] Add `handle_info/2` for alert messages
  - [ ] Add alert banner to UI
  - [ ] Auto-dismiss alerts after 30 seconds
- [ ] Create `apps/orderflow_web/lib/orderflow_web/components/alert_components.ex`
  - [ ] `alert_banner/1` — colored alert banner
  - [ ] `alert_list/1` — list of active alerts
  - [ ] Add `@moduledoc`
- [ ] Test: Dashboard receives alert broadcasts
- [ ] Test: Alert appears in UI
- [ ] Test: Alert auto-dismisses after timeout
- [ ] Test: Multiple alerts are displayed

## 7. Configure Mailer
- [ ] Verify `Swoosh.Adapters.Local` in `config/config.exs`
- [ ] Verify `Swoosh.Adapters.Test` in `config/test.exs`
- [ ] Add SMTP configuration to `config/runtime.exs` (commented out)
  - [ ] `SMTP_HOST` env var
  - [ ] `SMTP_USER` env var
  - [ ] `SMTP_PASS` env var
  - [ ] `SMTP_PORT` env var (default 587)
- [ ] Add `{:gen_smtp, "~> 1.0"}` to `apps/orderflow/mix.exs` (optional, for production)
- [ ] Test: `Orderflow.Mailer` is configured correctly
- [ ] Test: Dev mailbox accessible at `/dev/mailbox`
- [ ] Test: Test adapter captures emails in tests

## 8. Write Tests
- [ ] Create `apps/orderflow/test/orderflow/notifications/order_notifier_test.exs`
  - [ ] Test GenServer starts
  - [ ] Test handles order update broadcast
  - [ ] Test sends email on cooking transition
  - [ ] Test sends email on delivering transition
  - [ ] Test sends email on delivered transition
  - [ ] Test ignores other transitions
  - [ ] Test handles errors gracefully
- [ ] Create `apps/orderflow/test/orderflow/alerts/scheduler_test.exs`
  - [ ] Test GenServer starts
  - [ ] Test detects stuck cooking orders
  - [ ] Test detects stuck pending orders
  - [ ] Test broadcasts alert
  - [ ] Test does not alert normal orders
  - [ ] Test reschedules after check
- [ ] Create `apps/orderflow/test/orderflow/notifications/emails_test.exs`
  - [ ] Test `order_confirmed/1` builds email
  - [ ] Test `order_on_the_way/1` builds email
  - [ ] Test `order_delivered/1` builds email
  - [ ] Test `admin_alert/3` builds email
  - [ ] Test email subjects are correct
  - [ ] Test email recipients are correct
- [ ] Create `apps/orderflow_web/test/orderflow_web/live/admin_live/dashboard_alert_test.exs`
  - [ ] Test alert appears in dashboard
  - [ ] Test alert auto-dismisses
  - [ ] Test multiple alerts display
- [ ] Create integration test: `apps/orderflow/test/orderflow/notifications_integration_test.exs`
  - [ ] Test: Create order → advance to cooking → assert email sent
  - [ ] Test: Create order → advance to delivering → assert email sent
  - [ ] Test: Create order → advance to delivered → assert email sent
  - [ ] Test: Stuck order → assert alert broadcast

## 9. Quality Gate
- [ ] Run `mix compile --warnings-as-errors`
- [ ] Run `mix deps.unlock --unused`
- [ ] Run `mix format`
- [ ] Run `mix test` (all pass)
- [ ] Run `mix precommit` (all pass)
- [ ] Manual test: Create order via UI → advance to cooking → check `/dev/mailbox` for email
- [ ] Manual test: Advance to delivering → check `/dev/mailbox`
- [ ] Manual test: Advance to delivered → check `/dev/mailbox`
- [ ] Manual test: Leave order in cooking for > 30 min → check alert in dashboard
- [ ] Manual test: Verify emails have correct order details

## 10. Documentation
- [ ] Add `@moduledoc` to `OrderNotifier`
- [ ] Add `@moduledoc` to `AlertScheduler`
- [ ] Add `@moduledoc` to `Emails`
- [ ] Add `@moduledoc` to `AlertComponents`
- [ ] Update `apps/orderflow/README.md` with notifications description
- [ ] Update `apps/orderflow_web/README.md` with email templates description
- [ ] Add notification architecture to `design.md`
- [ ] Update `AGENTS.md` if needed
- [ ] Add email delivery instructions to `README.md`

## 11. Optional Enhancements
- [ ] Add `customer_email` field to `orders` table (if not present)
- [ ] Update `Order` schema to include `customer_email`
- [ ] Update `Emails` module to use actual customer email
- [ ] Add email validation for `customer_email`
- [ ] Add SMS notification placeholder (Twilio integration)
- [ ] Add webhook notification placeholder (for external systems)
- [ ] Add email preference settings per user
- [ ] Add digest email (daily summary of orders)
- [ ] Add failed email retry mechanism
