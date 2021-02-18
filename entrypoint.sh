#!/bin/sh
# Docker entrypoint script.

# Wait until Postgres is ready
while ! pg_isready -q -d $DB_URL 
do
  echo "$(date) - waiting for database to start"
  sleep 2
done

echo "Connected to the database"

echo "Set Telegram WebHook"
URL=https://lovelace-szh7fuhjxa-ue.a.run.app/integrations/telegram

curl "https://api.telegram.org/bot$BOT_TOKEN/setWebhook?url=$URL"

echo "Executing Migrations"

DB_URL=$DB_URL BOT_TOKEN=$BOT_TOKEN SECRET_KEY_BASE=$SECRET_KEY_BASE \
  ./prod/rel/lovelace/bin/lovelace eval Lovelace.Release.migrate

echo "Starting Lovelace app!"

DB_URL=$DB_URL BOT_TOKEN=$BOT_TOKEN SECRET_KEY_BASE=$SECRET_KEY_BASE \
  ./prod/rel/lovelace/bin/lovelace start
