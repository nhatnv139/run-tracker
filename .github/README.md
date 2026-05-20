# RunVie GitHub Actions

This folder configures CI/CD, security, governance, and automation for the RunVie monorepo.

## Workflows

| File | Trigger | Purpose |
| --- | --- | --- |
| `workflows/landing.yml` | push main + PR on `landing/**` | Lint, typecheck, vitest, Next.js build, Vercel preview (PR) and production (main) deploy. |
| `workflows/ai-coach.yml` | push main + PR on `ai-coach/**` | ruff lint/format, mypy strict, pytest+cov, Docker build to `ghcr.io/runvie/ai-coach:{sha,latest}`, deploy staging to Fly.io and/or GCP Cloud Run. |
| `workflows/flutter.yml` | push main + PR on `app/**` | `dart format` check, `flutter analyze` (fatal warnings), `flutter test --coverage`, Android APK+AAB on main, iOS no-codesign on macos-latest. Production iOS signed builds go through Codemagic. |
| `workflows/supabase.yml` | push main + PR on `supabase/migrations/**` | `supabase db lint`, apply migrations into ephemeral Postgres 15 and verify with `\d`, push to staging then production via the `supabase-production` environment (manual approval). |
| `workflows/release.yml` | tag `v*` | Generate changelog, create GitHub Release, tag Docker images `:stable` + `:vX.Y.Z`, notify Slack/Discord webhooks. |
| `workflows/security.yml` | weekly cron (Mon 03:00 UTC) + push main | `npm audit`, `pip-audit`, `flutter pub` audit, Trivy image scan, Gitleaks secrets scan, CodeQL JS/TS + Python. |
| `workflows/pr-checks.yml` | PR open/sync/edit/label | Conventional Commits PR title lint, >500 LOC size warning, CHANGELOG entry required, path-based auto-label (`.github/labeler.yml`). |

All workflows: minimum `permissions:`, per-job `timeout-minutes`, concurrency groups (PR previews cancel-in-progress, production deploys do not).

## Required secrets

Configure these in repository `Settings -> Secrets and variables -> Actions`.

### Vercel (landing)
- `VERCEL_TOKEN`
- `VERCEL_ORG_ID`
- `VERCEL_PROJECT_ID`

### AI Coach
- `ANTHROPIC_API_KEY_TEST` (test-only API key used during pytest)
- `FLY_API_TOKEN` (if deploying via Fly.io)
- `GCP_SA_KEY` (service-account JSON for Cloud Run, if deploying via GCP)

### Supabase
- `SUPABASE_ACCESS_TOKEN`
- `SUPABASE_PROJECT_REF_STAGING`
- `SUPABASE_DB_PASSWORD_STAGING`
- `SUPABASE_PROJECT_REF_PROD`
- `SUPABASE_DB_PASSWORD_PROD`

### Release notifications
- `SLACK_WEBHOOK_URL` (optional)
- `DISCORD_WEBHOOK_URL` (optional)

### Security
- `GITLEAKS_LICENSE` (optional, only required for Gitleaks org-level features)

`GITHUB_TOKEN` is provided automatically and is used by GHCR publish, CodeQL, Trivy SARIF upload, and PR automation.

## Deploy targets

| Module | Environment | Target |
| --- | --- | --- |
| landing | preview | Vercel (per-PR) |
| landing | production | Vercel |
| ai-coach | staging | Fly.io (`fly.staging.toml`) and/or GCP Cloud Run `asia-southeast1` |
| ai-coach | container registry | `ghcr.io/runvie/ai-coach:{sha-<sha>,latest,stable,vX.Y.Z}` |
| app (Android) | artifacts | Workflow artifacts (APK + AAB); Play Store upload handled separately |
| app (iOS) | artifacts | Unsigned `.xcarchive`; production signing via Codemagic |
| supabase | staging | `supabase db push --linked` -> `SUPABASE_PROJECT_REF_STAGING` |
| supabase | production | `supabase db push --linked` -> `SUPABASE_PROJECT_REF_PROD` (env `supabase-production` gated by manual approval) |

## Environments

Create the following Environments in GitHub (`Settings -> Environments`) and attach required reviewers + secrets:

- `preview` (no reviewers)
- `production` (landing) - require 1 reviewer
- `ai-coach-staging`
- `supabase-staging`
- `supabase-production` - require 1 reviewer, optional wait timer

## Governance files

- `CODEOWNERS` - per-path review routing (mobile / backend / web / design / legal / maintainers)
- `dependabot.yml` - daily updates for npm, pip, pub, docker, github-actions; minor+patch grouped weekly; majors ignored
- `labels.yml` + `scripts/sync-labels.sh` - canonical label set sync via `gh label`
- `labeler.yml` - path-based auto-label rules used by PR checks
- `PULL_REQUEST_TEMPLATE.md` - PR checklist
- `ISSUE_TEMPLATE/` - bug report, feature request forms + Discord/security contact links

## Suggested branch protection (apply on `main`)

- Require PR before merging, 1 approval
- Dismiss stale approvals on new commits
- Require review from Code Owners
- Require status checks (select after the first green run):
  - `Landing CI/CD / Lint and Typecheck`
  - `Landing CI/CD / Build`
  - `AI Coach CI/CD / Lint and Typecheck`
  - `AI Coach CI/CD / Pytest with coverage`
  - `Flutter CI/CD / Flutter Analyze`
  - `Flutter CI/CD / Flutter Tests`
  - `Flutter CI/CD / Dart Format Check`
  - `Supabase Migrations / Supabase Lint`
  - `Supabase Migrations / Validate Migrations against Postgres`
  - `PR Checks / PR Title (Conventional Commits)`
  - `PR Checks / Changelog Entry Required`
  - `Security Scans / Gitleaks Secrets Scan`
- Require branches to be up to date before merging
- Require linear history
- Require signed commits (recommended)
- Restrict force pushes and deletions
- Include administrators

## Local maintenance

```sh
# Sync labels into the repo
bash .github/scripts/sync-labels.sh

# Optional: prune labels not in labels.yml
PRUNE=1 bash .github/scripts/sync-labels.sh
```
