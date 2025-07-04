# create a dockerfile for that elixir project. The dockerfile will be used to build the docker image.
# The docker image will be used to run the docker container.
FROM erlang:27-alpine AS builder

# elixir expects utf8.
ENV ELIXIR_VERSION="v1.18.1" \
    LANG=C.UTF-8 \
    TERM=xterm \
    HOME=/root

RUN set -xe \
    && ELIXIR_DOWNLOAD_URL="https://repo.hex.pm/builds/elixir/${ELIXIR_VERSION}-otp-27.zip" \
    && ELIXIR_DOWNLOAD_SHA256="65ff2bc9a604de1793c62971d624b473672b6dbafecaeb4474416a1fc27b4a82" \
    && buildDeps=' \
    ca-certificates \
    curl \
    ' \
    && apk add --no-cache --virtual .build-deps $buildDeps \
    && curl -fSL -o elixir-release.zip $ELIXIR_DOWNLOAD_URL \
    && echo "$ELIXIR_DOWNLOAD_SHA256  elixir-release.zip" | sha256sum -c - \
    && mkdir -p /elixir \
    && unzip -d /elixir elixir-release.zip

ENV PATH=/elixir/bin:$PATH

RUN set -ex && \
    apk --update add libstdc++ curl ca-certificates libc6-compat

RUN apk update && \
    apk upgrade --no-cache && \
    apk add --no-cache bash git openssh-client alpine-sdk curl python3 py3-pip cargo

# Setup SSH for private dependencies
RUN mkdir -p ~/.ssh && \
    chmod 700 ~/.ssh && \
    ssh-keyscan -p 443 ssh.github.com >> ~/.ssh/known_hosts

# The name of your application/release (required)
ARG app_name=mini_e_commerce
# The version of the application we are building (required)
ARG app_vsn=1.0.0
# The environment to build with
ARG mix_env=prod

ENV MIX_ENV=${mix_env}

# First create the directories (everything under /app)
RUN mkdir -p /opt/build \
    && mkdir -p /opt/build/_build \
    && mkdir -p /opt/build/deps

# Switch to the work dir
WORKDIR /opt/build

# Copy in the base mixfiles
COPY mix.exs mix.lock /opt/build/

# Setup hex/rebar
RUN mix do local.rebar --force, local.hex --force

# Copy in the directories
COPY config /opt/build/config

# Copy the app source code and files needed to build the release.
COPY lib/ ./lib
COPY priv/ ./priv/
COPY mix.exs ./mix.exs
COPY rel/ ./rel/

# Get dependencies
RUN mix deps.get --only ${mix_env}
RUN mix deps.compile

# Build and digest assets
RUN mix assets.deploy

RUN mix compile

# Build the release.
RUN MIX_ENV=${mix_env} mix release


########################################################################
#
# Start from a clean image
#
########################################################################
FROM erlang:26-alpine

ENV LANG=en_US.UTF-8 \
    TERM=xterm \
    SHELL=/bin/bash \
    HOME=/root \
    REPLACE_OS_VARS=true

RUN set -ex && \
    apk --update add libstdc++ curl ca-certificates libc6-compat

RUN apk update && \
    apk add --no-cache bash ncurses-libs openssl elixir build-base

RUN apk update && \
    apk upgrade --no-cache && \
    apk add --no-cache bash git openssh-client alpine-sdk curl vim libpq pgcli

WORKDIR /opt/app

# The name of your application/release
ARG app_name=mini_e_commerce
# The version of the application we are building
ARG app_vsn=1.0.0
# The environment to build for.
ARG mix_env=prod

ENV APP_NAME=${app_name} \
    APP_VSN=${app_vsn} \
    MIX_ENV=${mix_env}

COPY --from=builder /opt/build/_build/prod/rel/${app_name}/ ./

COPY start.sh ./start.sh

RUN ["chmod", "+x", "start.sh"]

ENTRYPOINT ["/opt/app/start.sh"]