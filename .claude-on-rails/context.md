# Chatwoot: Claude Swarm Context

This is a fork of Chatwoot, a multi-channel customer support platform. It is **not** a Rails monolith with server-rendered views. The backend is a Rails 7.1 API; the user-facing apps are Vue 3 SPAs mounted as separate entrypoints.

## Project facts

- **Framework**: Ruby on Rails ~> 7.1, Ruby 3.4.4
- **DB / cache / queue**: PostgreSQL, Redis, Sidekiq
- **Search**: Searchkick + OpenSearch
- **Realtime**: ActionCable
- **Frontend**: Vue 3 (Composition API, `<script setup>`), Vuex (legacy store) + Pinia (new stores), Vue Router 4, FormKit, Tailwind, Vite
- **Auth**: Devise + devise_token_auth + OAuth providers (Slack, Google, Microsoft, Notion, Linear, Shopify, Twitter, Instagram, TikTok, Twilio, Apple, Facebook)
- **Authorization**: Pundit
- **Storage**: ActiveStorage (S3, Azure Blob, GCS)
- **Email**: ActionMailer + actionmailbox (SES)
- **Admin**: `super_admin/` controllers (not Motor Admin)
- **Tests**: RSpec, FactoryBot, Vitest, Playwright

## Multi-tenancy

Every meaningful resource is scoped to an **Account**. API routes follow `api/v1/accounts/:account_id/<resource>` and `api/v2/...`. There's also a `platform/` API for cross-account admin and a `public/` API for end-user widgets/portal. `Current.account` and `account_id` scoping are load-bearing; never write a controller that ignores them.

## Enterprise overlay (critical)

`enterprise/` mirrors the OSS tree (`enterprise/app/{models,controllers,services,policies,jobs,...}`, `enterprise/lib/`, plus `spec/enterprise/`). It is Ruby-only; there is no `enterprise/app/javascript`. OSS code is opened to Enterprise via `prepend_mod_with` / `include_mod_with` calls at the bottom of OSS models, controllers, and services (e.g. `Account.prepend_mod_with('Account')`).

Rules:
- Read the OSS file **and** its Enterprise counterpart before editing.
- For Enterprise-only behavior on existing OSS code, add a module under `enterprise/` and wire it via `prepend_mod_with` / `include_mod_with`. Do not edit OSS files just for Enterprise behavior.
- For Enterprise-exclusive features, put code directly under `enterprise/`.
- Keep request/response contracts identical across OSS and Enterprise.
- Mirror specs into `spec/enterprise/`.

## Repo map

- `app/controllers/{api/v1,api/v2,platform,public,super_admin}/`: main controller hierarchy
- `app/models/`, `app/services/<domain>/`, `app/jobs/`, `app/workers/`, `app/policies/`, `app/listeners/`, `app/builders/`, `app/finders/`
- `app/javascript/dashboard/`: main agent dashboard SPA (Vuex)
- `app/javascript/v3/`: newer dashboard surfaces (Pinia)
- `app/javascript/components-next/`: current shared component library (the rest is being deprecated, see CLAUDE.md)
- `app/javascript/widget/`, `sdk/`, `portal/`, `survey/`: embeddable surfaces
- `app/javascript/shared/`: composables, utils, components used across SPAs
- `enterprise/...`: overlay
- `config/locales/en.yml`: backend i18n (only edit `en.yml`)
- `app/javascript/dashboard/i18n/locale/en/*.json`: frontend i18n (only edit `en/`)
- `spec/`, `spec/enterprise/`, `tests/` (Playwright)

## Conventions

- Only Tailwind, no scoped CSS, no inline styles.
- Vue components in PascalCase, events in camelCase, Composition API + `<script setup>`.
- Thin controllers, business logic in `app/services/<domain>/`.
- Strong params, Pundit `authorize`, multi-format responses (`html`, `json`).
- Custom exceptions in `lib/custom_exceptions/`.
- Conventional Commits for messages (`feat(scope): subject`).
- Branding: prefer `replaceInstallationName` from `shared/composables/useBranding` for "Chatwoot" strings.

## Documentation

- Chatwoot dev handbook: https://chatwoot.help/hc/handbook/articles/developing-enterprise-edition-features-38
- Vue 3: https://vuejs.org/
- Tailwind: https://tailwindcss.com/docs
- Pundit: https://github.com/varvet/pundit
- Pinia: https://pinia.vuejs.org/
- Vuex: https://vuex.vuejs.org/
