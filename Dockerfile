FROM elixir:1.12.2-alpine
WORKDIR /app
COPY mix.exs mix.lock ./
RUN mix do local.rebar --force, local.hex --force, deps.get, compile
COPY . .