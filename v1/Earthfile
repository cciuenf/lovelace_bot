all:
  BUILD +formatter-test
  BUILD +analisys-test
  BUILD +unit-test

all-test:
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

  RUN mix test

setup-base:
   ARG ELIXIR=1.11.2
   ARG OTP=23.1.1
   FROM hexpm/elixir:$ELIXIR-erlang-$OTP-alpine-3.12.0
   RUN apk add --no-progress --update build-base
   ENV ELIXIR_ASSERT_TIMEOUT=10000
   WORKDIR /bank

test-setup:
   FROM +setup-base

   ENV MIX_ENV=test
   COPY mix.exs .
   COPY mix.lock .
   COPY .formatter.exs .
   RUN mix local.rebar --force
   RUN mix local.hex --force
   RUN mix do deps.get, deps.compile
   COPY --dir config lib test ./

dialyzer-setup:
   FROM +setup-base

   ENV MIX_ENV=dev
   COPY mix.exs .
   COPY mix.lock .
   RUN mix local.rebar --force
   RUN mix local.hex --force
   RUN mix do deps.get, deps.compile
   COPY --dir lib ./
