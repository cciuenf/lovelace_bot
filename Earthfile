all:
  BUILD +formatter-test
  BUILD +analisys-test
  BUILD +unit-test

ci:
  BUILD +formatter-test
  BUILD +unit-test

analisys-test:
  FROM +dialyzer-setup

  RUN mix dialyzer --format dialyxir 

formatter-test:
  FROM +test-setup

  RUN mix format --check-formatted
  RUN mix compile --warning-as-errors
  RUN mix credo --strict

unit-test:
  FROM +test-setup

  COPY docker-compose.yaml ./

  WITH DOCKER --compose docker-compose.yaml
    RUN mix do ecto.setup, test
  END

setup-base:
  FROM earthly/dind:alpine

  RUN apk add --no-progress --update build-base elixir
  ENV ELIXIR_ASSERT_TIMEOUT=10000

  WORKDIR /lovelace

  COPY mix.exs .
  COPY mix.lock .

test-setup:
  FROM +setup-base

  ENV MIX_ENV=test

  COPY .formatter.exs .
  RUN mix local.rebar --force \
      && mix local.hex --force \
      && mix do deps.get, deps.compile

  COPY --dir config lib priv test ./
