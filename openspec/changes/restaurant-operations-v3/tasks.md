# Tasks: Restaurant Operations v3

## Migrations
- [x] Create tables migration (tables, reservations)
- [x] Create loyalty tiers migration (loyalty_tiers, user_loyalty)
- [x] Add order scheduling fields to orders
- [x] Create order splits migration (order_splits, split_payments)
- [x] Create feedback migration (feedback table)
- [x] Create QR menus migration (qr_menus)
- [x] Create kitchen metrics migration (kitchen_metrics)
- [x] Create gift cards migration (gift_cards)
- [x] Add allergens to products (allergens[], nutritional_info)
- [x] Create shifts migration (shifts, shift_requests)

## Domain Logic
- [x] Table Management context + schema + validations
- [x] Reservation context + schema + validations
- [x] Loyalty Tiers context + schema + auto-calculation
- [x] Order Scheduling logic + Oban job
- [x] Split Bill context + calculations + validations
- [x] Customer Feedback v2 context + NPS logic
- [x] QR Menu generation context + unique codes
- [x] Kitchen Metrics context + GenServer collector
- [x] Gift Cards context + balance logic
- [x] Allergen Detection context + conflict detection
- [x] Staff Scheduling context + conflict validation

## Web Layer
- [x] Admin Tables LiveView (grid visual)
- [x] Admin Reservations LiveView (calendar)
- [x] Admin Loyalty Tiers LiveView
- [x] Admin Feedback Dashboard LiveView
- [x] Admin Kitchen Metrics LiveView
- [x] Admin Gift Cards LiveView
- [x] Admin Shifts LiveView (calendar)
- [x] Public QR Menu LiveView (customer-facing)
- [x] Order Scheduling form LiveView
- [x] Order Split Bill LiveView
- [x] API controllers for all features
- [x] Router updates for all routes
- [x] Navbar updates for admin menu

## Tests
- [x] Domain tests for all 10 contexts
- [x] Web tests for all LiveViews
- [x] API tests for new endpoints
- [x] Integration tests (Oban, PubSub, QR)
- [x] Fixtures for all new schemas

## Infrastructure
- [x] Add EQRCode dependency
- [x] Add Oban cron job for OrderScheduler
- [x] Add GenServer to supervision tree
- [x] Add PubSub topics for real-time updates
- [x] Update seeds with demo data
- [x] Update README with new features
- [x] Run mix precommit
- [x] Verify all 120 tests pass
