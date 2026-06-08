# Tasks: scaffold-orderflow-domain

## 1. Project Rename
- [ ] Rename `apps/elixir_test/` directory to `apps/orderflow/`
- [ ] Rename `apps/elixir_test_web/` directory to `apps/orderflow_web/`
- [ ] Update umbrella `mix.exs` (app paths, references)
- [ ] Update `apps/orderflow/mix.exs` (app name, module name, deps, aliases)
- [ ] Update `apps/orderflow_web/mix.exs` (app name, module name, deps, references)
- [ ] Update all `config/*.exs` files (app names, database names, PubSub names)
- [ ] Update `docker-compose.yml` (container names, database names, env vars)
- [ ] Update `AGENTS.md` (project references)
- [ ] Update `README.md` (project references, commands)
- [ ] Rename all module namespaces in `lib/` files: `ElixirTest` → `Orderflow`, `ElixirTestWeb` → `OrderflowWeb`
- [ ] Rename all module namespaces in test files
- [ ] Update `priv/repo/seeds.exs` namespace
- [ ] Verify `mix compile` works after rename
- [ ] Run `mix format` to catch any missed references

## 2. Add Dependencies
- [ ] Add `{:bcrypt_elixir, "~> 3.0"}` to `apps/orderflow/mix.exs`
- [ ] Run `mix deps.get` to update lockfile
- [ ] Verify compilation

## 3. Create Migrations
- [ ] Create migration: `create_users` (email, password_hash, name, role, phone, active, timestamps)
- [ ] Create migration: `create_categories` (name, description, sort_order, timestamps)
- [ ] Create migration: `create_products` (name, description, price, stock, active, category_id FK, timestamps)
- [ ] Add unique index on `users.email`
- [ ] Add index on `products.category_id`
- [ ] Run `mix ecto.migrate` to verify

## 4. Implement Accounts Context
- [ ] Create `apps/orderflow/lib/orderflow/accounts/user.ex` (schema, changeset, password hashing)
- [ ] Create `apps/orderflow/lib/orderflow/accounts/accounts.ex` (CRUD + auth functions)
- [ ] Implement `register_user/1` with `Bcrypt.hash_pwd_salt/1`
- [ ] Implement `authenticate_user/2` with `Bcrypt.verify_pass/2`
- [ ] Implement `change_user/1` for forms
- [ ] Add validation: email format, password min length (6), role in enum
- [ ] Add validation: unique email
- [ ] Add `User.changeset/2` with `cast` and `validate_required`

## 5. Implement Catalog Context
- [ ] Create `apps/orderflow/lib/orderflow/catalog/category.ex` (schema, changeset)
- [ ] Create `apps/orderflow/lib/orderflow/catalog/product.ex` (schema, changeset)
- [ ] Create `apps/orderflow/lib/orderflow/catalog/catalog.ex` (CRUD functions)
- [ ] Implement `list_products_by_category/1`
- [ ] Implement `decrement_stock/2` (with non-negative guard)
- [ ] Implement `restore_stock/2`
- [ ] Add validation: price > 0, stock >= 0
- [ ] Add `Product.changeset/2` with `cast` and `validate_required`

## 6. Create Seed Data
- [ ] Update `apps/orderflow/priv/repo/seeds.exs`
- [ ] Create 4 users: 1 admin, 1 chef, 1 rider, 1 customer (with known passwords)
- [ ] Create 4 categories: "Bebidas", "Entradas", "Platos Principales", "Postres"
- [ ] Create ~12 products across categories with realistic data
- [ ] Verify seeds run with `mix ecto.reset` or `mix run priv/repo/seeds.exs`

## 7. Write Tests
- [ ] Create `apps/orderflow/test/orderflow/accounts_test.exs`
  - [ ] Test `list_users/0` returns all users
  - [ ] Test `get_user!/1` returns user or raises
  - [ ] Test `get_user_by_email/1` returns user or nil
  - [ ] Test `create_user/1` with valid data
  - [ ] Test `create_user/1` with invalid data (missing email, invalid role)
  - [ ] Test `update_user/2` changes name
  - [ ] Test `register_user/1` hashes password
  - [ ] Test `authenticate_user/2` with valid credentials
  - [ ] Test `authenticate_user/2` with invalid credentials
  - [ ] Test `delete_user/1` removes user
  - [ ] Test `change_user/1` returns changeset
- [ ] Create `apps/orderflow/test/orderflow/catalog_test.exs`
  - [ ] Test `list_categories/0` returns categories
  - [ ] Test `create_category/1` with valid data
  - [ ] Test `create_category/1` with invalid data
  - [ ] Test `list_products/0` returns products
  - [ ] Test `list_products_by_category/1` filters correctly
  - [ ] Test `create_product/1` with valid data
  - [ ] Test `create_product/1` with invalid data (negative price, negative stock)
  - [ ] Test `update_product/2` updates stock
  - [ ] Test `decrement_stock/2` reduces stock
  - [ ] Test `decrement_stock/2` fails when insufficient stock
  - [ ] Test `delete_product/1` removes product
  - [ ] Test `delete_category/1` with products (behavior? prevent or cascade)

## 8. Quality Gate
- [ ] Run `mix compile --warnings-as-errors`
- [ ] Run `mix deps.unlock --unused`
- [ ] Run `mix format`
- [ ] Run `mix test` (all pass)
- [ ] Run `mix precommit` (all pass)
- [ ] Manual verification: `iex -S mix` → `Orderflow.Accounts.list_users()` → returns users
- [ ] Manual verification: `Orderflow.Catalog.list_products()` → returns products

## 9. Documentation
- [ ] Update `apps/orderflow/README.md` with domain description
- [ ] Add module documentation to `Accounts` and `Catalog` contexts
- [ ] Add `@moduledoc` to `User`, `Category`, `Product` schemas
- [ ] Update `openspec/changes/scaffold-orderflow-domain/proposal.md` status if needed

## 10. Rename Verification
- [ ] Search for any remaining `ElixirTest` references in codebase
- [ ] Search for any remaining `elixir_test` references in config
- [ ] Verify Docker compose builds and starts
- [ ] Verify all test files compile with correct namespaces
