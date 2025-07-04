# syntax=docker/dockerfile:1

FROM hexpm/elixir:1.15.0-erlang-26.0.2-alpine-3.18.0 AS build

# install build dependencies
RUN apk add --no-cache build-base npm git python3

# prepare build dir
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && mix local.rebar --force

# set build ENV
ENV MIX_ENV=prod

# install deps
COPY mix.exs mix.lock ./
COPY config config
RUN mix deps.get --only $MIX_ENV

# build project
COPY . .
RUN mix deps.compile
RUN mix assets.deploy
RUN mix release

# prepare release image
FROM alpine:3.18.0 AS app

RUN apk add --no-cache libstdc++ openssl ncurses-libs

WORKDIR /app

COPY --from=build /app/_build/prod/rel/mini_e_commerce ./

ENV HOME=/app
ENV MIX_ENV=prod
ENV PORT=4000

CMD ["bin/mini_e_commerce", "start"]
