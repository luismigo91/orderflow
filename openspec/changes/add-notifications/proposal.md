# Proposal: add-notifications

## Context

The system is fully functional. Now we add **background notifications** to keep customers and staff informed.

## Scope

### Included

1. **OrderNotifier GenServer**
   - Listens to `Phoenix.PubSub` for order state changes
   - Sends emails on key transitions:
     - `confirmed` → `cooking`: Email to customer "Your order is being prepared"
     - `ready` → `delivering`: Email to customer "Your order is on the way"
     - `delivering` → `delivered`: Email to customer "Your order has been delivered"
   - Sends internal alerts:
     - Order stuck in `cooking` > 30 min: Alert to admin
     - Order stuck in `pending` > 10 min: Alert to admin
2. **Email Templates** using Swoosh + HEEx
   - `OrderflowWeb.Emails.OrderEmail` module
   - Templates: `order_confirmed.html.heex`, `order_delivering.html.heex`, `order_delivered.html.heex`, `order_alert.html.heex`
   - Simple, responsive HTML emails
3. **Swoosh Configuration**
   - Dev: Local adapter (viewable at `/dev/mailbox`)
   - Test: Test adapter (capture emails in tests)
   - Prod: Configure via runtime (SMTP adapter)
4. **Alert Scheduler**
   - `Orderflow.Alerts.Scheduler` GenServer that checks every 5 minutes
   - Finds orders stuck in states for too long
   - Broadcasts alerts to admin dashboard via PubSub
5. **Tests**
   - GenServer tests (verify email is sent on state change)
   - Swoosh tests (assert email content)
   - Scheduler tests (verify alerts are triggered)

### Excluded

- SMS notifications (out of scope, could add later)
- Push notifications (requires external service)
- Webhook notifications (advanced feature)

## Success Criteria

- [ ] Email is sent when order reaches `cooking`
- [ ] Email is sent when order reaches `delivering`
- [ ] Email is sent when order reaches `delivered`
- [ ] Admin alert is triggered for stuck orders
- [ ] Emails are viewable in `/dev/mailbox` in dev
- [ ] All tests pass
- [ ] `mix precommit` passes

## Technical Notes

- `OrderNotifier` subscribes to PubSub topic `"orders:lobby"` in `init/1`
- Uses `Orderflow.Mailer.deliver/1` with `Swoosh.Adapters.Local`
- Email templates are in `OrderflowWeb.Emails/` directory
- Use `OrderflowWeb.Emails.OrderEmail.build/2` to construct emails
- `Orderflow.Alerts.Scheduler` uses `Process.send_after/3` for periodic checks
- Scheduler queries: `Orders.list_orders_by_status(:cooking, older_than: 30)`
- For testing, use `Swoosh.TestAssertions` to assert emails were sent
- Consider `{:gen_smtp, "~> 1.0"}` if we need SMTP support (add to deps)
