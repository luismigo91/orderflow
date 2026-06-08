# Design: Restaurant Operations v3

## Features Detail

### 1. Table Management & Reservations
- **Schema**: `tables` (number, capacity, status: :free/:occupied/:reserved, location), `reservations` (table_id, customer_name, party_size, datetime, status)
- **LiveView**: Admin mesas con grid visual (drag & drop), reservas calendar
- **Validation**: No overlapping reservations, capacity check
- **PubSub**: Real-time table status updates

### 2. Loyalty Tiers
- **Schema**: `loyalty_tiers` (name, min_points, multiplier, benefits[]), `user_loyalty` (user_id, current_tier, total_points, history)
- **Logic**: Auto-calculate tier on point change, benefits apply at checkout
- **LiveView**: Admin tier management, user loyalty dashboard
- **Business Rules**: Bronze (0pts, 1x), Silver (500pts, 1.5x), Gold (2000pts, 2x)

### 3. Order Scheduling
- **Schema**: `orders` add `scheduled_for` datetime, `schedule_status` (:immediate/:scheduled)
- **Oban Job**: `OrderScheduler` — runs every minute, processes pending scheduled orders
- **Validation**: Minimum 30 min in advance, max 7 days
- **LiveView**: Scheduling picker en order form

### 4. Split Bill
- **Schema**: `order_splits` (order_id, split_type: :equal/:percentage/:items, total_splits), `split_payments` (split_id, amount, status, paid_by)
- **Logic**: Calculate shares, track partial payments, mark complete when all paid
- **Validation**: Sum of splits must equal total
- **LiveView**: Split bill modal en checkout

### 5. Customer Feedback v2
- **Schema**: `feedback` (order_id, nps_score, food_rating, service_rating, speed_rating, comments, tags[])
- **Analysis**: NPS categorization (promoter/passive/detractor), average by product, sentiment tags
- **LiveView**: Feedback form post-order, admin feedback dashboard con charts
- **PubSub**: New feedback notification

### 6. Digital Menu QR
- **Schema**: `qr_menus` (code, url, table_id, active, expires_at)
- **Generation**: Unique code per mesa, URL `/menu/:code`
- **LiveView**: QR generator, QR scanner simulation, admin grid
- **Tech**: EQRCode library, SVG generation

### 7. Kitchen Efficiency Metrics
- **Schema**: `kitchen_metrics` (order_id, prep_start, prep_end, stage_times, total_minutes)
- **Calculation**: Auto-calculate desde status_logs, avg per product, per hour, per cook
- **LiveView**: Admin dashboard con métricas (avg prep time, throughput, bottleneck)
- **GenServer**: `KitchenMetricsCollector` — recopila métricas en tiempo real

### 8. Gift Cards
- **Schema**: `gift_cards` (code, balance, initial_amount, purchaser_id, recipient_email, status, expires_at)
- **Logic**: Generate unique code, validate on use, deduct balance, handle partial redemption
- **Validation**: Code format, expiration check, balance check
- **LiveView**: Admin gift card management, purchase form, redemption

### 9. Allergen Detection & Nutritional Info
- **Schema**: `products` add `allergens` (array), `nutritional_info` (JSONB: calories, protein, carbs, fat)
- **Logic**: Auto-flag orders con alergenos conflictivos, alertar en kitchen display
- **Validation**: Standard allergen list (gluten, dairy, nuts, shellfish, eggs, soy, fish, sesame)
- **LiveView**: Product form con allergen checkboxes, order allergen alert banner

### 10. Staff Scheduling & Shifts
- **Schema**: `shifts` (user_id, date, start_time, end_time, role, status), `shift_requests` (shift_id, type: :swap/:time_off, status)
- **Logic**: Validar no overlap, mínimo descanso 8h, coverage por role
- **Validation**: Conflict detection, hours limit
- **LiveView**: Admin calendar (weekly), staff shift view, request form

## Technical Decisions

- **EQRCode**: New dependency for QR generation
- **Oban cron**: `OrderScheduler` cada minuto para pedidos programados
- **GenServer**: `KitchenMetricsCollector` para métricas en tiempo real
- **PubSub**: Table updates, new feedback, schedule ready
- **Ecto**: Complex validations con `validate_number`, `validate_length`, custom constraints
- **JSONB**: Nutritional info flexible, benefits array en tiers
- **Array**: Allergens como array de strings, tags en feedback

## API Endpoints
- `POST /api/v1/tables` — CRUD mesas
- `POST /api/v1/reservations` — CRUD reservas
- `GET /api/v1/loyalty/tiers` — List tiers
- `GET /api/v1/loyalty/me` — My loyalty status
- `POST /api/v1/orders/:id/split` — Split bill
- `POST /api/v1/feedback` — Submit feedback
- `GET /api/v1/menu/:code` — Public menu QR
- `POST /api/v1/gift-cards` — Purchase gift card
- `POST /api/v1/gift-cards/redeem` — Redeem gift card
- `GET /api/v1/kitchen/metrics` — Efficiency metrics
- `GET /api/v1/staff/shifts` — Shift schedule

## Database Migrations
- `create_tables`: tables, reservations
- `create_loyalty_tiers`: loyalty_tiers, user_loyalty
- `add_order_scheduling`: scheduled_for, schedule_status to orders
- `create_order_splits`: order_splits, split_payments
- `create_feedback`: feedback con ratings
- `create_qr_menus`: qr_menus
- `create_kitchen_metrics`: kitchen_metrics
- `create_gift_cards`: gift_cards
- `add_allergens_to_products`: allergens, nutritional_info
- `create_shifts`: shifts, shift_requests

## LiveViews
- `Admin.TablesLive` — Grid de mesas
- `Admin.ReservationsLive` — Calendario de reservas
- `Admin.LoyaltyTiersLive` — Gestión de tiers
- `Admin.FeedbackLive` — Dashboard de feedback
- `Admin.KitchenMetricsLive` — Métricas de cocina
- `Admin.GiftCardsLive` — Gestión de gift cards
- `Admin.ShiftsLive` — Calendario de turnos
- `Menu.QrLive` — Menú digital público
- `Order.ScheduleLive` — Programar pedido
- `Order.SplitLive` — Dividir cuenta

## Testing Strategy
- Domain tests: validations, business logic, calculations
- Web tests: LiveView rendering, form submissions, API endpoints
- Integration tests: Oban jobs, PubSub, QR generation
- Fixtures: 10+ nuevos fixtures

## Quality Gate
- `mix precommit` must pass
- No warnings as errors
- 100+ tests total
