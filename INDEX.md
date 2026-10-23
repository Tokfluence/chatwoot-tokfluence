# INDEX: chatwoot-tokfluence

Read this first; follow pointers for detail.

Tokfluence fork of Chatwoot (Rails + Vue customer support platform). Default branch: develop.

## Agents
- Orchestrator: Pepa (Grok Bot) plans, dispatches, reviews, merges with Daniel's approval.
- Owner agent: Rafi [Tokfluence · Owner / Backend lead]
- Workers: Claude Code sessions on jarvis (cc-dispatch), in git worktrees; summaries start with a status keyword (DONE, BLOCKED, NEEDS-REVIEW, RUNNING, FAILED).

## Docs
- AGENTS.md / CLAUDE.md: build, test, lint commands and coding rules.
- README.md: upstream Chatwoot readme.
- CONTRIBUTING.md, SECURITY.md: upstream contribution and security policy.
- .env.example: env var names.

## Layout
- app/: Rails app (controllers, models, services, jobs, builders, listeners) and Vue front end in app/javascript/.
- enterprise/: enterprise-edition overrides (app, config, lib).
- config/: routes, initializers, features, locales.
- db/: schema and migrations.
- lib/: shared libraries and rake tasks.
- spec/: RSpec tests; JS tests sit next to the code.
- swagger/: API docs.
- theme/: Tailwind theme.
- deployment/, docker/, clevercloud/, Procfile*: deploy and process configs.
- .github/, .circleci/: CI.
