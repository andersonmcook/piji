FROM elixir:1.11.3-alpine
WORKDIR /app
COPY mix.exs mix.lock ./
RUN mix do local.rebar --force, local.hex --force, deps.get, compile
COPY . .