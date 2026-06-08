# ElixirTest

Umbrella project con **Phoenix 1.8** que incluye una aplicación web y una API REST, con PostgreSQL como base de datos.

## Estructura

- `apps/elixir_test/` — Dominio de negocio, Ecto Repo y contextos
- `apps/elixir_test_web/` — Aplicación web: controllers, LiveView, endpoints, router y assets
- `docker-compose.yml` — PostgreSQL para desarrollo local

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

Visita [`localhost:4000`](http://localhost:4000) para la web y [`localhost:4000/api/health`](http://localhost:4000/api/health) para la API.

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

## License

MIT
