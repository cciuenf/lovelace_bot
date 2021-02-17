FROM elixir:1.11.2-alpine AS builder

RUN apk add --no-cache yarn build-base

RUN mkdir /app
WORKDIR /app

# Mix env
ENV MIX_ENV=prod

# Cache elixir deps
ADD mix.exs mix.lock ./
RUN mix local.rebar
RUN mix local.hex --force
RUN mix do deps.get, deps.compile

# Same with node deps
COPY assets assets
RUN yarn --cwd assets install --force

COPY lib lib
COPY config config
COPY priv priv

# Run frontend build, compile, and digest assets
RUN yarn --cwd assets deploy && \
    cd - && mix do compile, phx.digest

RUN mix release

# ---- Application Stage ----
FROM alpine AS app

ARG HOST
ARG PORT
ARG DB_URL
ARG BOT_TOKEN
ARG SECRET_KEY_BASE

ENV MIX_ENV=prod \
    DB_URL=$DB_URL \
    HOST=$HOST \
    PORT=$PORT \
    BOT_TOKEN=$BOT_TOKEN \
    SECRET_KEY_BASE=$SECRET_KEY_BASE

# Intall needed packages
RUN apk add --no-cache openssl \
      ncurses-libs postgresql-client

# Copy over the build artifact from the previous step and create a non root user
RUN adduser -D -h /home/lovelace lovelace
WORKDIR /home/lovelace
COPY --from=builder /app/_build .
RUN chown -R lovelace: ./prod
USER lovelace

COPY entrypoint.sh .

# Run the Phoenix app
CMD ["./entrypoint.sh"]
