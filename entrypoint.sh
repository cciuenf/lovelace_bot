#!/bin/sh
# Docker entrypoint script.

# Wait until Postgres is ready
while ! pg_isready -q -d $DB_URL 
do
  echo "$(date) - waiting for database to start"
  sleep 2
done

echo "Connected to the database"

DB_URL=$DB_URL BOT_TOKEN=$BOT_TOKEN \ 
  HOST=$HOST PORT=$PORT \
  SECRET_KEY_BASE=$SECRET_KEY_BASE \
  ./prod/rel/lovelace/bin/conts eval Lovelace.Release.migrate

DB_URL=$DB_URL BOT_TOKEN=$BOT_TOKEN \ 
  HOST=$HOST PORT=$PORT \
  SECRET_KEY_BASE=$SECRET_KEY_BASE \
  ./prod/rel/lovelace/bin/conts start
