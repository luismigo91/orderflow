# Elixir + Phoenix development image
FROM elixir:1.20-alpine

# Install build dependencies
RUN apk add --no-cache build-base git inotify-tools nodejs npm postgresql-client

# Install Hex + Rebar
RUN mix local.hex --force && mix local.rebar --force

WORKDIR /app

# Copy dependency files first for layer caching
COPY mix.exs mix.lock ./
COPY apps/elixir_test/mix.exs apps/elixir_test/mix.exs
COPY apps/elixir_test_web/mix.exs apps/elixir_test_web/mix.exs

# Install dependencies
RUN mix deps.get

# Copy the rest of the application
COPY . .

# Default command
CMD ["mix", "phx.server"]
