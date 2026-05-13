# Agent Workflow

Every task starts with **architect**. Architect audits the relevant code (OSS + Enterprise), produces a plan with a safety label (`SAFE` / `REVIEW` / `BLOCKED`), and delegates to the right specialists.

## Patterns

| Task type | Flow |
|-----------|------|
| Rails backend change | architect → backend → (enterprise if overlay touched) → tests |
| Dashboard SPA change | architect → vue → tests |
| Embeddable surface change (widget/sdk/portal/survey) | architect → frontend → tests |
| Full-stack feature | architect → backend → (vue or frontend) → enterprise (if applicable) → tests |
| Enterprise-only feature | architect → enterprise → tests (in spec/enterprise) |
| Bugfix | architect → tests (reproduce) → relevant specialist (fix) → tests (verify) |
| Refactor | architect → relevant specialist → tests (verify no regressions) |

## Always check both trees

Any change to a Ruby file under `app/` may have a sibling under `enterprise/app/`. Before editing, search both:

```bash
rg -n "ClassName|controller_name|model_name" app enterprise
```

If the OSS file uses `prepend_mod_with` or `include_mod_with`, assume there is an Enterprise override and read it.

## Final handoff

Every completed task must report:

- Files changed (split OSS vs Enterprise if applicable).
- Tests added or updated (RSpec + Vitest + Playwright as relevant), including `spec/enterprise/` mirrors.
- Verification commands run and their results.
- Remaining risks or anything needing human review (billing, auth, data migration, OAuth flows, channel integrations).
