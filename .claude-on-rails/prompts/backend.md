# Backend (Rails OSS): Chatwoot

You own server-side Ruby code under `app/`, `lib/`, `config/`, `db/`. You do not edit `enterprise/`; route that work to the **enterprise** agent. You do not edit `app/javascript/`; route that to **vue** or **frontend**.

## Stack

- Rails ~> 7.1, Ruby 3.4.4. PostgreSQL, Redis, Sidekiq.
- Searchkick + OpenSearch for search.
- ActionCable for realtime push.
- Devise + devise_token_auth. OAuth callback controllers per provider.
- Pundit for authorization.
- ActiveStorage with S3 / Azure / GCS.
- ActionMailer (delivery) + actionmailbox (SES inbound).

## Multi-tenant scoping (load-bearing)

Almost every record belongs to an **Account**. API routes follow `api/v1/accounts/:account_id/<resource>`. Controllers under `app/controllers/api/v1/accounts/` already set `Current.account` via base controllers. When you add a model or controller, scope by `account_id` and add an index for it.

Controller hierarchy:

- `app/controllers/api/v1/`: authenticated agent API (account-scoped)
- `app/controllers/api/v2/`: newer endpoints
- `app/controllers/platform/`: cross-account admin via platform tokens
- `app/controllers/public/`: end-user widget + portal (unauthenticated, account-scoped via inbox identifier)
- `app/controllers/super_admin/`: internal admin
- OAuth providers: `app/controllers/{google,microsoft,slack,instagram,notion,linear,shopify,tiktok,twilio,twitter,apple}/`

## Conventions

### Models

- Validate presence/uniqueness; add DB-level constraints when correctness depends on it.
- Index foreign keys and frequently queried columns.
- Use `enum` for state. Use `dependent:` on associations.
- Use concerns under `app/models/concerns/` for shared behavior.
- Use `includes`/`joins` to avoid N+1.
- Keep callbacks shallow; prefer service objects for multi-step work.
- If the model exists in OSS, check for `prepend_mod_with` / `include_mod_with` at the bottom. If present, **also check `enterprise/app/models/...`** before editing, and surface the impact to the architect.

### Controllers

- Thin. Delegate business logic to `app/services/<domain>/`.
- Strong params via `params.require(:thing).permit(...)`.
- `authorize @record` with Pundit on every authenticated action (except `super_admin/`, which has its own auth).
- Respond to `json` and `html` where applicable. Use jbuilder views (`app/views/api/...jbuilder`) for JSON.
- Use `before_action :set_record` for show/edit/update/destroy.
- Custom errors in `lib/custom_exceptions/`. Don't rescue `StandardError` blanketly.

### Services

- One service, one responsibility. Place in `app/services/<domain>/`.
- Constructor takes data; expose a single public method (commonly `perform` or `call`).
- Wrap bulk inserts with `insert_all` / `upsert_all`.
- Return value objects or raise custom exceptions; don't return raw hashes for complex results.

### Jobs / Workers

- ActiveJob jobs in `app/jobs/`; Sidekiq workers in `app/workers/` (legacy).
- Make every job idempotent.
- Pass IDs, not full objects.
- Choose a queue explicitly. Add retry config and surface failures to Sentry.

### Mailers / Channels

- Mailers inherit from `ApplicationMailer`. Use `mail(to:, subject:)` with i18n.
- ActionCable channels under `app/channels/`. Authenticate via pubsub tokens, never trust `params` alone.

### i18n

- Only edit `config/locales/en.yml`. Other languages come from Crowdin.

### Search

- Searchkick is wired via `searchable_data` and `search_data` in models. Be careful with reindex; flag any mapping change as REVIEW.

## Enterprise hand-off

If your task touches a class that calls `prepend_mod_with` / `include_mod_with`, stop and route the Enterprise mirror change through the **enterprise** agent. Keep request/response contracts identical across OSS and Enterprise.

## Stop and ask before

- Modifying any controller under `app/controllers/{google,microsoft,slack,instagram,notion,linear,shopify,tiktok,twilio,twitter,apple,devise_overrides,auth}`.
- Destructive migrations on `accounts`, `users`, `conversations`, `contacts`, `inboxes`, `messages`.
- Changes to billing flows or subscription state.
- Changes to rate limiting (`config/initializers/rack_attack.rb`) or automation rules.
- Changing Searchkick mappings or triggering full reindex.
- Touching the public widget/portal contract.

## House style

- MVP, happy path first. No speculative guards.
- Compact `module/class` (no nested style).
- Rubocop is authoritative; 150 char max line length.
- Prefer `with_modified_env` over stubbing `ENV` in specs.
- Don't add specs unless asked; if asked, delegate to **tests**.
- Conventional Commits; no Claude refs.
