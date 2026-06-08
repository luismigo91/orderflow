# Agent Context: OrderFlow

Umbrella Phoenix 1.8 project with two apps:
- `apps/orderflow/` — domain logic, Ecto Repo, contexts
- `apps/orderflow_web/` — web interface, API, LiveView, assets

## Daily workflow

```bash
# Start PostgreSQL (required before mix setup)
docker compose up -d db

# One-time setup
mix setup          # umbrella alias: runs `cmd mix setup` in both apps

# Quality gate — always run before finishing work
mix precommit      # compile --warnings-as-errors, deps.unlock --unused, format, test
```

## Architecture & boundaries

- **App `:orderflow`** (domain): owns `Repo`, schemas, migrations, seeds. Depends on `ecto_sql`, `postgrex`, `req`.
- **App `:orderflow_web`** (web): owns controllers, LiveViews, router, endpoint, assets. Depends on `:orderflow` via `in_umbrella: true`.
- Router has three top-level scopes:
  - `scope "/"` → browser pipeline (public pages, tracker)
  - `scope "/admin"` → admin pipeline (dashboard, management)
  - `scope "/api"` → API pipeline (REST endpoints)
- Dev routes at `/dev/dashboard` and `/dev/mailbox` are gated by `dev_routes` config.

## Testing

- Tests live in `apps/<app>/test/`. Run single file: `mix test apps/orderflow_web/test/...`.
- The `:orderflow` app alias runs `ecto.create --quiet`, `ecto.migrate --quiet`, then `test`.
- Use `start_supervised!/1` for processes. Avoid `Process.sleep/1`; use `Process.monitor/1` + `assert_receive`.

## Database

- PostgreSQL via Docker (`docker-compose.yml`). Credentials: `postgres/postgres@localhost:5432`.
- Databases: `orderflow_dev`, `orderflow_test`.
- Generate migrations with: `mix ecto.gen.migration name_using_underscores`.

## Assets & CSS

- Tailwind CSS v4 — no `tailwind.config.js`. Import syntax in `app.css`:
  ```css
  @import "tailwindcss" source(none);
  @source "../css";
  @source "../js";
  @source "../../lib/orderflow_web";
  ```
- Never use `@apply` in raw CSS. Only `app.js` and `app.css` bundles are supported; vendor deps must be imported there.

## OpenSpec (spec-driven development)

Initialized at repo root. Use `openspec` CLI for change management:

```bash
openspec new change "<kebab-case-name>"   # scaffold a change
openspec status --change "<name>" --json  # check artifact readiness
openspec instructions <artifact> --change "<name>" --json
```

Slash commands registered in `.opencode/commands/`:
- `/opsx:propose` — create a change with proposal + design + tasks
- `/opsx:apply` — implement a change
- `/opsx:explore` — explore codebase context
- `/opsx:archive` — archive completed change

## HTTP client

Use the built-in `Req` library. Avoid `:httpoison`, `:tesla`, `:httpc`.

## Deployment container

`Dockerfile` + `docker-compose.yml` support full containerized deployment. Set `SECRET_KEY_BASE` env var (generate with `mix phx.gen.secret`).
