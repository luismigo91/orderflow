# Design: scaffold-orderflow-domain

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    apps/orderflow/                           │
│                    (Domain Application)                        │
│                                                              │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │  Context: Accounts                                       │ │
│  │  • User schema (roles, auth)                             │ │
│  │  • Session management (simple token-based)               │ │
│  │  • Password hashing (bcrypt)                             │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                              │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │  Context: Catalog                                        │ │
│  │  • Category schema (name, description, sort_order)        │ │
│  │  • Product schema (name, description, price, stock, category)│ │
│  │  • Stock management (decrement/validate)                 │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                              │
│  Infrastructure:                                             │
│  • Orderflow.Repo (Ecto + PostgreSQL)                        │
│  • Orderflow.PubSub (Phoenix.PubSub)                          │
│  • Orderflow.Application (Supervisor)                        │
└─────────────────────────────────────────────────────────────┘
```

## Schema Designs

### User

```elixir
schema "users" do
  field :email, :string
  field :password_hash, :string
  field :name, :string
  field :role, Ecto.Enum, values: [:admin, :chef, :rider, :customer]
  field :phone, :string
  field :active, :boolean, default: true
  
  timestamps()
end
```

- `email` unique, required
- `password_hash` stored, never `password` plain
- `role` defines permissions across the system
- `active` soft-disable without deleting

### Category

```elixir
schema "categories" do
  field :name, :string
  field :description, :string
  field :sort_order, :integer, default: 0
  
  has_many :products, Orderflow.Catalog.Product
  
  timestamps()
end
```

### Product

```elixir
schema "products" do
  field :name, :string
  field :description, :string
  field :price, :decimal, precision: 10, scale: 2
  field :stock, :integer, default: 0
  field :active, :boolean, default: true
  
  belongs_to :category, Orderflow.Catalog.Category
  
  timestamps()
end
```

- `price` positive decimal
- `stock` non-negative integer
- `active` allows hiding without deleting

## Context APIs

### Accounts

```elixir
Accounts.list_users()
Accounts.get_user!(id)
Accounts.get_user_by_email(email)
Accounts.create_user(attrs)
Accounts.update_user(user, attrs)
Accounts.delete_user(user)
Accounts.register_user(attrs)          # with password hashing
Accounts.authenticate_user(email, password)
Accounts.change_user(user)
```

### Catalog

```elixir
Catalog.list_categories()
Catalog.get_category!(id)
Catalog.create_category(attrs)
Catalog.update_category(category, attrs)
Catalog.delete_category(category)

Catalog.list_products()
Catalog.list_products_by_category(category_id)
Catalog.get_product!(id)
Catalog.create_product(attrs)
Catalog.update_product(product, attrs)
Catalog.delete_product(product)
Catalog.decrement_stock(product, amount)
Catalog.restore_stock(product, amount)
```

## Migration Strategy

1. Create `users` table (with unique index on email)
2. Create `categories` table
3. Create `products` table (with FK to categories)
4. Seed data: 4 users, 4 categories, 12 products

## Testing Strategy

- **Unit tests**: Schema changesets (valid/invalid cases)
- **Context tests**: Full CRUD operations, edge cases (negative stock, duplicate email)
- **DataCase**: Use `Orderflow.DataCase` (already exists)

## Directory Structure

```
apps/orderflow/
├── lib/
│   ├── orderflow/
│   │   ├── application.ex
│   │   ├── repo.ex
│   │   ├── mailer.ex
│   │   ├── accounts/
│   │   │   ├── user.ex
│   │   │   └── accounts.ex
│   │   └── catalog/
│   │       ├── category.ex
│   │       ├── product.ex
│   │       └── catalog.ex
│   └── orderflow.ex
├── priv/
│   └── repo/
│       ├── migrations/
│       └── seeds.exs
└── test/
    ├── orderflow/
    │   ├── accounts_test.exs
    │   └── catalog_test.exs
    └── support/
        └── data_case.ex
```

## Renaming Strategy

The project is currently named `ElixirTest` / `elixir_test`. We rename to `OrderFlow` / `orderflow`:

- `apps/elixir_test/` → `apps/orderflow/`
- `apps/elixir_test_web/` → `apps/orderflow_web/`
- Module prefix: `ElixirTest` → `Orderflow`
- Module prefix: `ElixirTestWeb` → `OrderflowWeb`
- App atom: `:elixir_test` → `:orderflow`
- App atom: `:elixir_test_web` → `:orderflow_web`
- Database names: `elixir_test_dev` → `orderflow_dev`, `elixir_test_test` → `orderflow_test`
- Update `mix.exs` (umbrella and both apps)
- Update `config/*.exs` files
- Update `AGENTS.md` and `README.md`
- Update `docker-compose.yml`
- Update `.formatter.exs` if needed
- Update `lib/` namespaces in both apps

**Note**: Phoenix convention is lowercase for app names (`orderflow`), but the module namespace is `Orderflow` (CamelCase). The project name in docs is `OrderFlow` (with space).

## Dependencies to Add

In `apps/orderflow/mix.exs`:
- `{:bcrypt_elixir, "~> 3.0"}` (for password hashing)

## New Files to Create

- `apps/orderflow/lib/orderflow/accounts/user.ex`
- `apps/orderflow/lib/orderflow/accounts/accounts.ex`
- `apps/orderflow/lib/orderflow/catalog/category.ex`
- `apps/orderflow/lib/orderflow/catalog/product.ex`
- `apps/orderflow/lib/orderflow/catalog/catalog.ex`
- `apps/orderflow/priv/repo/migrations/..._create_users.exs`
- `apps/orderflow/priv/repo/migrations/..._create_categories.exs`
- `apps/orderflow/priv/repo/migrations/..._create_products.exs`
- `apps/orderflow/test/orderflow/accounts_test.exs`
- `apps/orderflow/test/orderflow/catalog_test.exs`
- `apps/orderflow/priv/repo/seeds.exs` (updated)

## Files to Modify

- `mix.exs` (umbrella root)
- `apps/orderflow/mix.exs` (renamed from `elixir_test`)
- `apps/orderflow_web/mix.exs` (renamed from `elixir_test_web`)
- `config/config.exs`
- `config/dev.exs`
- `config/test.exs`
- `config/runtime.exs` (if exists)
- `docker-compose.yml`
- `AGENTS.md`
- `README.md`
- All `.ex` files in both apps (namespace rename)
- All `.exs` test files (namespace rename)
