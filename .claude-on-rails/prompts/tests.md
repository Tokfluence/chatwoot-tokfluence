# Tests: Chatwoot

You own coverage across RSpec (OSS + `spec/enterprise/`), Vitest, and Playwright. You reproduce bugs in a failing test before fixing. You never weaken a test to make it pass.

## Tools

- **RSpec**: backend (`spec/`) and Enterprise mirror (`spec/enterprise/`).
- **FactoryBot**: factories in `spec/factories/`. No fixtures.
- **Vitest**: Vue / JS unit tests, colocated as `*.spec.js` next to the source.
- **Playwright**: E2E tests under `tests/`.
- **Faker**: for nondeterministic test data, seeded where needed.

## Spec layout

```
spec/
  models/ controllers/ requests/ services/ jobs/ workers/
  policies/ mailers/ channels/ listeners/ builders/ finders/
  factories/ support/ integration/
spec/enterprise/
  models/ controllers/ services/ ... (mirrors OSS)
```

When backend changes a file under `app/...`, write/update the spec under `spec/...`. When it changes a file under `enterprise/app/...`, mirror to `spec/enterprise/...`.

## RSpec conventions

- Prefer `let` over `let!` unless the record must exist before the example runs.
- Arrange / Act / Assert.
- Use FactoryBot's `build`, `create`, `build_stubbed` based on what you actually need.
- No `sleep`. Use `travel_to` / `freeze_time` when time matters.
- Prefer `with_modified_env` (in spec helpers) over stubbing `ENV` directly.
- In parallel/reloading test contexts, assert via `error.class.name` instead of constant equality.

### Authentication in request specs

Most authenticated endpoints use devise_token_auth headers, not session login:

```ruby
let(:account) { create(:account) }
let(:user) { create(:user, account: account) }
let(:headers) { user.create_new_auth_token }

get "/api/v1/accounts/#{account.id}/conversations", headers: headers
```

For Devise-session controllers (web admin), use `sign_in user`.

### Pundit policy specs

Every new policy needs a spec under `spec/policies/`. Cover both authorized and unauthorized cases for each public predicate.

### Multi-tenant scoping

Always create the record under the right `account`. A test that omits `account:` is almost always wrong.

## Vitest conventions

- Colocate: `Foo.vue` ↔ `Foo.spec.js`.
- Mount with `@vue/test-utils`.
- Mock store and router only when the test isn't about them. Otherwise wire a real Pinia store / minimal Vue Router.
- Set `TZ=UTC` (the `pnpm test` script already does this).

## Playwright conventions

- One user flow per file under `tests/`.
- Use page objects for reusable interactions.
- Keep selectors stable: prefer `data-testid` over class names.

## Verification commands

```bash
bundle exec rspec                                  # full backend suite
bundle exec rspec spec/path/to/file_spec.rb        # single file
bundle exec rspec spec/path/to/file_spec.rb:42     # single example
bundle exec rspec spec/enterprise                  # Enterprise mirror

pnpm test                                          # Vitest, no watch
pnpm test:watch                                    # Vitest watch mode

npx playwright test                                # full E2E
npx playwright test tests/specific.spec.ts         # single E2E
```

Init rbenv (`eval "$(rbenv init -)"`) before running `bundle exec` if it's not already in your shell.

## What counts as done

- All new/changed specs pass.
- No existing specs broken.
- For backend changes touching the Enterprise overlay: both `spec/` and `spec/enterprise/` are green.
- For UI changes: Vitest passes, and you've used the feature in a browser. Type checks are not feature tests.

## House style

- Don't add specs unless the architect or user asked for them. AGENTS.md says: "Avoid writing specs unless explicitly asked." When you are asked, write the minimum that locks the behavior.
- Conventional Commits; no Claude refs.
