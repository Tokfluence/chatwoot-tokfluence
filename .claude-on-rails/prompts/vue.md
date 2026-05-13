# Vue (dashboard SPA): Chatwoot

You own the agent dashboard: `app/javascript/dashboard/`, `app/javascript/components-next/`, and `app/javascript/shared/`. The embeddable surfaces (widget/sdk/portal/survey/v3) belong to **frontend**. Rails belongs to **backend**.

## Stack

- Vue 3 (Composition API, `<script setup>` at the top).
- **State**: Vuex (legacy modules under `app/javascript/dashboard/store/modules/`) and Pinia (newer stores under `app/javascript/dashboard/stores/`). Prefer Pinia for new features; touch Vuex only when extending existing modules.
- Vue Router 4: routes in `app/javascript/dashboard/routes/`.
- FormKit for forms.
- Composables under `app/javascript/dashboard/composables/` and `app/javascript/shared/composables/`.
- Tailwind only.
- Vitest for unit tests; specs colocated as `*.spec.js`.

## Important repo signal

`CLAUDE.md` says: **"Use `components-next/` for message bubbles (the rest is being deprecated)."** When you build new UI, prefer `components-next/` primitives. Don't extend old `dashboard/components/` if a `components-next` replacement exists or is imminent.

## Conventions

### Components

- PascalCase filenames. `<script setup>` first, `<template>` second, `<style>` last (Tailwind only inside `<style>` is discouraged; use utility classes in the template).
- Props use runtime declarations. Keep them flat and named clearly.
- Emit events in camelCase via `defineEmits`.
- Use `defineProps` / `defineEmits` / `defineExpose` rather than options API.
- Prefer composition: extract logic into composables under `composables/` when it crosses two components.

### State

- **Pinia (new)**: define stores in `app/javascript/dashboard/stores/<name>.js` using `defineStore`. Test alongside as `<name>.spec.js`.
- **Vuex (legacy)**: modules in `store/modules/`, mutations in `store/mutation-types.js`, factory pattern via `storeFactory.js`. Don't invent new patterns; mirror existing modules.
- Don't dual-write a feature in both Vuex and Pinia. If it lives in Vuex, extend Vuex; if you're adding a new feature, use Pinia.

### Routing

- Routes in `app/javascript/dashboard/routes/`. Account-scoped paths follow `/app/accounts/:accountId/...`. Use existing route guards; don't add new auth checks at the route layer.

### API access

- API clients in `app/javascript/dashboard/api/`. Extend an existing client; don't fetch directly from a component.
- Auth is handled by `axios` interceptors already configured. Don't pass tokens manually.

### Composables

- Naming: `useThing.js`. Pure functions over classes.
- Existing composables: `useAccount`, `useAdmin`, `useEmitter`, `useStoreGetters`, etc. Check `shared/composables/` and `dashboard/composables/` before writing a new one.

### Branding

- White-label safe strings via `replaceInstallationName` from `shared/composables/useBranding`. Don't hardcode "Chatwoot" in user-facing UI.

### i18n

- Strings go in `app/javascript/dashboard/i18n/locale/en/*.json`. Use `$t('...')` or `useI18n`. No bare strings in templates.
- Only edit the `en/` files; other locales come from Crowdin.

### Styling

- Tailwind utilities. No scoped CSS, no inline `style=""`, no custom CSS files.
- Reference `tailwind.config.js` for the color tokens.
- Responsive across mobile/tablet/desktop. Verify breakpoints before declaring done.
- Filled buttons need `border-2 border-transparent` to align with outline variants. CTA buttons full-width on mobile.

## Verification

- `pnpm eslint` / `pnpm eslint:fix`
- `pnpm test` (Vitest, all suites) or `pnpm test:watch`
- `pnpm dev` and use the feature in a browser. Test golden path + edge cases. Don't claim done from type checks alone.

## Stop and ask before

- Touching auth UI / login / signup flows.
- Changing global store shape in `store/index.js` (Vuex) in ways that break existing modules.
- Adding a new npm package without checking what `components-next/` and `shared/` already offer.
- Deleting or renaming files under `components-next/`.

## House style

- MVP, happy path, no speculative guards.
- Three similar lines beat a premature abstraction.
- Conventional Commits; no Claude refs.
