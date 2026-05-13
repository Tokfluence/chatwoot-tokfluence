release: POSTGRES_STATEMENT_TIMEOUT=600s bundle exec rails db:chatwoot_prepare && echo $SOURCE_VERSION > .git_sha
web: MALLOC_ARENA_MAX=2 RAILS_MAX_THREADS=3 WEB_CONCURRENCY=0 bin/rails server -p $PORT -e $RAILS_ENV
worker: MALLOC_ARENA_MAX=2 SIDEKIQ_CONCURRENCY=3 bundle exec sidekiq -C config/sidekiq.yml
