# OrderFlow

Sistema de gestión de pedidos para delivery/restaurantes construido con **Phoenix 1.8**. Demuestra arquitectura umbrella, LiveView en tiempo real, máquinas de estado, API REST, GraphQL, background jobs con Oban, y 69+ features de producción.

## Estructura

- `apps/orderflow/` — Dominio de negocio: Users, Categories, Products, Orders, FSM, Promotions, Reviews, Webhooks, Feature Flags
- `apps/orderflow_web/` — Aplicación web: LiveViews, Controllers, API REST, GraphQL, PWA
- `docker-compose.yml` — PostgreSQL para desarrollo local

## Stack Completo

- **Backend**: Elixir 1.15+, Phoenix 1.8, Ecto, PostgreSQL
- **Frontend**: Phoenix LiveView, Tailwind CSS v4, HEEx
- **Real-time**: Phoenix.PubSub, Phoenix.Presence, Channels (Chat)
- **Background Jobs**: Oban (con retries, scheduling, cron)
- **APIs**: REST (JSON) + GraphQL (Absinthe) + Rate Limiting
- **PWA**: Service Worker, Background Sync, Web Push, Manifest
- **Emails**: Swoosh (templates + background delivery)
- **Search**: PostgreSQL Full-Text Search (tsvector + GIN)
- **CSV**: NimbleCSV (exports)
- **Testing**: ExUnit, Phoenix LiveView Test, ConnCase
- **DevOps**: Docker, Docker Compose

## Features Implementadas (69+ total)

### Core (6 features)
1. ✅ **Renombrado** ElixirTest → OrderFlow
2. ✅ **Domain**: Users, Categories, Products (Contexts + Schemas)
3. ✅ **Orders**: FSM, OrderItems, StatusLogs, Stock management
4. ✅ **Real-time**: Kitchen Display, Order Tracker, PubSub
5. ✅ **Auth**: Login, Roles, Plugs (RequireAuth, RequireRole)
6. ✅ **Admin Dashboard**: Métricas, gestión, historial

### Avanzadas Round 1 (16 features)
7. ✅ **Oban Integration**: Background jobs con retries, cron, dashboard
8. ✅ **Chat en Tiempo Real**: Phoenix Channels + Presence (usuarios online)
9. ✅ **Mapa de Delivery**: Leaflet simulado con CSS + LiveView
10. ✅ **Sistema de Promociones**: Cupones (percentage, fixed, BOGO, free delivery)
11. ✅ **Multi-tenancy**: Scoping por tenant (enterprise-ready)
12. ✅ **GraphQL API**: Absinthe + Subscriptions
13. ✅ **Reviews y Ratings**: ⭐ 1-5 estrellas + comentarios
14. ✅ **Image Uploads**: Soporte para fotos de productos
15. ✅ **PWA**: Service Worker, Offline support, Background Sync, Manifest
16. ✅ **Predictive ETA**: Estimación basada en historial
17. ✅ **Export CSV**: Descarga desde Order History con NimbleCSV
18. ✅ **Webhooks**: Integración con sistemas externos
19. ✅ **Feature Flags**: Toggles en runtime
20. ✅ **GenStage Pipeline**: Procesamiento batch de órdenes
21. ✅ **TimescaleDB**: Métricas time-series (hypertable ready)
22. ✅ **Push Notifications**: Web Push API con acciones

### Avanzadas Round 2 (8 features)
23. ✅ **Rate Limiting**: API throttling (100 req/min)
24. ✅ **Full-Text Search**: PostgreSQL tsvector en productos
25. ✅ **Loyalty Points**: Sistema de puntos y redención
26. ✅ **Inventory Alerts**: Alertas de stock bajo con resolución
27. ✅ **Audit Logging**: Tracking de todas las acciones admin
28. ✅ **Analytics Dashboard**: KPIs en tiempo real con gráficos
29. ✅ **Bulk Operations**: Update masivo de productos/orders
30. ✅ **Advanced Filters**: Filtros por categoría, precio, stock, búsqueda

### Avanzadas Round 3 (8 features)
31. ✅ **API Pagination**: Cursor-based pagination (limit 20-100)
32. ✅ **Health Check**: `/health` y `/health/detailed` con DB, Oban, PubSub
33. ✅ **Soft Delete**: `delete_at` timestamp + restore + permanent delete
34. ✅ **ETS Cache**: GenServer con TTL, `get_or_compute`, `clear`
35. ✅ **i18n (Gettext)**: 200+ strings es/en para toda la app
36. ✅ **Advanced Order Search**: Filtros por fecha, status, cliente, monto
37. ✅ **Advanced Validation**: Format errors en API con `~r/%{(
) else`
38. ✅ **API Versioning**: Todo migrado a `/api/v1/` prefix

### Avanzadas Round 4 (7 features)
39. ✅ **Order Templates**: Reorder rápido desde último pedido
40. ✅ **Quick Actions**: Admin dashboard con acciones masivas (archive, cache, inventory)
41. ✅ **Webhook Retry Logic**: Exponential backoff (5 retries)
42. ✅ **Order Splitting**: Dividir órdenes por categoría
43. ✅ **Delivery Zones**: Geofencing con bounding boxes
44. ✅ **Advanced Caching**: ETS con TTL y `get_or_compute`
45. ✅ **Soft Delete en Products**: Con `list_deleted_products` y `restore`

### Avanzadas Round 5 (7 features)
46. ✅ **Advanced Notifications**: SMS + Email + Push con Oban workers
47. ✅ **Inventory v2**: Stock movements tracking (in/out/adjustment)
48. ✅ **Predictive Analytics**: Peak hours, busy days, revenue forecast
49. ✅ **Monitoring & Alerting**: GenServer con checks cada 1 minuto
50. ✅ **System Monitoring**: Memory, processes, uptime, atoms
51. ✅ **Order Velocity**: Orders per hour tracking
52. ✅ **Inventory Predictions**: Weekly needs based on historical sales

### Avanzadas Round 6 (3 features)
53. ✅ **OpenAPI Documentation**: `/api/v1/docs` con especificación completa
54. ✅ **Multi-tenancy v2**: Subdomain extraction plug
55. ✅ **Advanced Search**: Faceted search con aggregations (Elasticsearch-style)

### Avanzadas Round 7 (4 features)
56. ✅ **Circuit Breaker**: Patrón para APIs externas (closed/open/half-open)
57. ✅ **Real-time Dashboard v2**: Métricas en vivo con WebSocket y auto-refresh
58. ✅ **Advanced Notifications**: SMS + Email + Push con Oban workers
59. ✅ **System Monitoring**: Memory, processes, uptime, alerts automáticos

### Avanzadas Round 8 (10 features)
60. ✅ **Table Management & Reservations**: Gestión de mesas, estados, reservas con calendario
61. ✅ **Loyalty Tiers**: Niveles Bronze/Silver/Gold con beneficios escalonados
62. ✅ **Order Scheduling**: Pedidos programados para futuro con Oban cron
63. ✅ **Split Bill**: Dividir la cuenta entre comensales (equal/percentage/items)
64. ✅ **Customer Feedback v2**: NPS, ratings, comentarios, análisis de sentimiento
65. ✅ **Digital Menu QR**: Generador de QR codes para menú digital
66. ✅ **Kitchen Efficiency Metrics**: Tiempo de preparación, throughput, bottleneck detection
67. ✅ **Gift Cards**: Tarjetas de regalo digitales con códigos únicos y redención
68. ✅ **Allergen Detection**: Alertas de alergenos en productos y órdenes
69. ✅ **Staff Scheduling & Shifts**: Horarios de personal, turnos, conflictos

## Requisitos

- Elixir 1.15+
- PostgreSQL (vía Docker)

## Inicio rápido

### 1. Iniciar PostgreSQL

```bash
docker compose up -d db
```

### 2. Instalar dependencias y crear la base de datos

```bash
mix setup
```

### 3. Iniciar el servidor

```bash
mix phx.server
```

Visita [`localhost:4000`](http://localhost:4000) para la aplicación.

## Comandos útiles

| Comando | Descripción |
|---------|-------------|
| `mix precommit` | Compila con warnings como errores, desbloquea deps sin uso, formatea y ejecuta tests |
| `mix test` | Ejecuta todos los tests |
| `mix format` | Formatea el código |
| `mix ecto.reset` | Elimina y recrea la base de datos con seeds |
| `mix phx.server` | Inicia el servidor de desarrollo |

## Docker

Para ejecutar la aplicación completa en contenedores:

```bash
docker compose up --build
```

Asegúrate de definir la variable `SECRET_KEY_BASE` en un archivo `.env`:

```bash
# Genera una nueva secret key
mix phx.gen.secret
```

## URLs del Sistema

| URL | Descripción | Acceso |
|-----|-------------|--------|
| `/` | Página principal | Público |
| `/login` | Login | Público |
| `/kitchen` | Tablero de cocina | Chef |
| `/admin` | Dashboard admin | Admin |
| `/admin/users` | Gestión usuarios | Admin |
| `/admin/products` | Gestión productos | Admin |
| `/admin/history` | Historial pedidos | Admin |
| `/admin/promotions` | Promociones | Admin |
| `/admin/reviews` | Reviews | Admin |
| `/admin/webhooks` | Webhooks | Admin |
| `/admin/feature-flags` | Feature Flags | Admin |
| `/admin/inventory` | Alertas de inventario | Admin |
| `/admin/audit-log` | Audit Log | Admin |
| `/admin/analytics` | Analytics Dashboard | Admin |
| `/admin/tables` | Gestión de mesas | Admin |
| `/admin/reservations` | Reservas | Admin |
| `/admin/loyalty-tiers` | Niveles de fidelidad | Admin |
| `/admin/feedback` | Feedback de clientes | Admin |
| `/admin/kitchen-metrics` | Métricas de cocina | Admin |
| `/admin/gift-cards` | Tarjetas de regalo | Admin |
| `/admin/shifts` | Horarios de personal | Admin |
| `/menu/:code` | Menú digital QR | Público |
| `/track/:id` | Seguimiento pedido | Público |
| `/chat` | Chat de equipo (con presencia) | Auth |
| `/map` | Mapa de delivery | Auth |
| `/api/sessions` | API Login | Público |
| `/api/orders` | API Orders | Auth |
| `/api/products` | API Products | Auth |
| `/api/products/search` | Búsqueda full-text | Auth |
| `/api/exports/orders` | Export CSV | Auth |
| `/api/exports/receipt/:id` | Receipt HTML | Auth |
| `/api/bulk/products` | Bulk operations | Auth |
| `/api/bulk/orders` | Bulk archive | Auth |
| `/graphql` | GraphQL API | Auth |
| `/dev/mailbox` | Emails (dev) | Dev only |
| `/dev/dashboard` | Oban Dashboard | Dev only |

## License

MIT
