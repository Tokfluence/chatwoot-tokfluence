#!/bin/sh

set -x

# Remove a potentially pre-existing server.pid for Rails.
rm -rf /app/tmp/pids/server.pid
rm -rf /app/tmp/cache/*

echo "Waiting for postgres to become ready...."

# Let DATABASE_URL env take presedence over individual connection params.
# This is done to avoid printing the DATABASE_URL in the logs
$(docker/entrypoints/helpers/pg_database_url.rb)
PG_READY="pg_isready -h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USERNAME"

until $PG_READY
do
  sleep 2;
done

echo "Database ready to accept connections."

#install missing gems for local dev as we are using base image compiled for production
bundle install

BUNDLE="bundle check"

until $BUNDLE
do
  sleep 2;
done

if [ "$RUN_DB_PREPARE" = "true" ]; then
  echo "Running db:chatwoot_prepare..."
  bundle exec rails db:chatwoot_prepare
fi

if [ "$RUN_IP_LOOKUP_SETUP" = "true" ]; then
  echo "Running ip_lookup:setup..."
  bundle exec rails ip_lookup:setup
fi

# Execute the main process of the container
exec "$@"
