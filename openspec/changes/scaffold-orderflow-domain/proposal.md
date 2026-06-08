# Proposal: scaffold-orderflow-domain

## Context

El proyecto actual es un umbrella Phoenix 1.8 (`ElixirTest`) con una estructura base pero sin dominio de negocio. Se desea convertir este repositorio en un **ejemplo de producto completo** con enfoque de arquitectura y demostración de capacidades técnicas avanzadas de Phoenix/Elixir para un artículo técnico.

El producto elegido es **OrderFlow**: un sistema de gestión de pedidos para delivery/restaurantes que demuestra:
- Arquitectura umbrella con separación domain/web
- Contextos de Ecto con relaciones complejas
- FSM (Finite State Machine) para ciclo de vida de pedidos
- Real-time con PubSub y Presence
- LiveView para dashboards interactivos
- API REST para integración externa
- Background jobs con GenServer
- Testing completo (unit, integration, feature)

## Scope

Este primer change establece la **base del dominio** sobre la cual se construirán todas las demás features.

### Included

1. **Renombrar proyecto** de `ElixirTest` a `OrderFlow` (apps, módulos, configs, docs)
2. **Schema `User`** con roles (`admin`, `chef`, `rider`, `customer`) y autenticación básica
3. **Schema `Category`** para clasificación de productos
4. **Schema `Product`** con stock, precio, categoría
5. **Context `Accounts`** (gestión de usuarios, roles, sesiones)
6. **Context `Catalog`** (gestión de categorías y productos)
7. **Seed data** para desarrollo (usuarios de cada rol, categorías, productos de ejemplo)
8. **Tests** para todos los schemas y contexts
9. **Documentación** del dominio en el README del app `:orderflow`

### Excluded (para futuros changes)

- Orders y OrderItems (Change: `implement-order-lifecycle`)
- Kitchen Display LiveView (Change: `add-realtime-kitchen-display`)
- Admin Dashboard (Change: `build-admin-dashboard`)
- API REST (Change: `expose-rest-api`)
- Notifications (Change: `add-notifications`)
- PubSub/Presence (Change: `add-realtime-kitchen-display`)

## Success Criteria

- [ ] `mix setup` ejecuta sin errores creando la base de datos con seeds
- [ ] `mix test` pasa 100% (contexts + schemas)
- [ ] `mix precommit` pasa sin warnings
- [ ] Se puede consultar usuarios, categorías y productos desde `iex -S mix`
- [ ] El proyecto se llama `OrderFlow` en todos los archivos relevantes

## Technical Notes

- Usar `Ecto.Enum` para roles de usuario y estados de pedidos (preparando el FSM)
- Usar `bcrypt_elixir` para hash de passwords (no incluido en deps actuales, se añade en `Accounts`)
- Las relaciones: `Product belongs_to Category`, `Category has_many Products`
- Seeds: 4 usuarios (uno por rol), 4 categorías, ~12 productos
- Mantener la estructura umbrella: `apps/orderflow/` (domain) y `apps/orderflow_web/` (web)
- Los `mix.exs` existentes usan `elixir_test` y `elixir_test_web` — estos serán renombrados
- El `mix.exs` del umbrella también debe actualizarse
- No renombrar los archivos de `AGENTS.md` y `README.md` del root si no es necesario, pero sí actualizar las referencias

## Risks

- Renombrar un umbrella Phoenix es tedioso y propenso a errores. Se debe hacer con cuidado y verificar compilación después de cada paso.
- La estructura de `apps/elixir_test` → `apps/orderflow` requiere cambios en paths, namespaces, y aliases.
