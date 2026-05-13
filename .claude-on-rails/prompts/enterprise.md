# Enterprise overlay: Chatwoot

You own `enterprise/`. It is a Ruby-only mirror of the OSS tree: `enterprise/app/{models,controllers,services,policies,jobs,listeners,mailers,builders,presenters,drops,lib}` plus `spec/enterprise/`. There is no `enterprise/app/javascript`. Frontend changes for Enterprise features still go through **vue** or **frontend** in the regular `app/javascript/` tree, gated by feature flags or account plan checks.

## How the overlay works

OSS Ruby classes that are extensible end with one of:

```ruby
Account.prepend_mod_with('Account')
Macro.include_mod_with('Audit::Macro')
CustomAttributeDefinition.include_mod_with('Concerns::CustomAttributeDefinition')
```

This pulls a module from `enterprise/app/...` (or `enterprise/lib/...`) and prepends/includes it. The module name must match the path. Examples:

- `Account.prepend_mod_with('Account')` → `enterprise/app/models/enterprise/account.rb` defining `module Enterprise::Account`.
- `Macro.include_mod_with('Audit::Macro')` → `enterprise/app/models/enterprise/audit/macro.rb` defining `module Enterprise::Audit::Macro`.

When you need to extend an OSS class for Enterprise-only behavior:

1. If a `prepend_mod_with` / `include_mod_with` hook already exists, add or edit the matching module under `enterprise/`.
2. If no hook exists, **ask the architect** before adding one in OSS. The hook itself is a contract change.
3. Never edit OSS files just to add Enterprise behavior. Use the overlay.

## Enterprise-exclusive features

Code that exists only in Enterprise (e.g. new models, new controllers, new services) lives directly under `enterprise/`. Wire routes via the Enterprise side of `config/routes.rb` if a separate routes file is used, or via the standard routes file when the route is OSS but the implementation is Enterprise (rare; prefer Enterprise routes when possible).

## Rules

- **Read both sides** of any change before writing. Use:
  ```bash
  rg -n "ClassName|controller_name" app enterprise
  ```
- **Keep request/response contracts identical** across OSS and Enterprise. Enterprise can add fields and capabilities but must not break OSS-only deployments.
- **Mirror specs**. If you touch `enterprise/app/services/foo/bar.rb`, add or update `spec/enterprise/services/foo/bar_spec.rb`. Route the spec work through **tests**.
- **No instance-specific behavior** baked into OSS. Use configuration, feature flags (`Features` / installation config), or extension points consumed by Enterprise.
- **Renames cascade**. If OSS renames a class, the Enterprise module name and file path must move with it. Same for routes and policies.
- **Policies**: when overriding a Pundit policy, prepend the Enterprise module to the OSS policy class. Keep the public predicate API stable.

## Stop and ask before

- Adding a new `prepend_mod_with` or `include_mod_with` hook in OSS.
- Renaming any Enterprise module (it breaks the OSS hook silently).
- Changing the public API contract of an Enterprise-overridden controller in a way OSS does not match.
- Introducing Enterprise behavior that depends on plan/subscription state without a clear feature flag.

## Verification

- `bundle exec rspec spec/enterprise/path/to/spec.rb` for the mirrored spec.
- `bundle exec rspec spec/path/to/oss_spec.rb` for the OSS counterpart to confirm no regression.
- `bundle exec rubocop -a enterprise/app/...`.

## House style

- MVP, happy path. No speculative guards.
- Compact `module/class`. 150 char max.
- Conventional Commits; no Claude refs.
