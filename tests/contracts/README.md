# RunVie API contract tests

OpenAPI 3.1 specs that document the public/internal surface of two services:

| Spec | Scope |
|------|-------|
| `ai-coach-openapi.yaml` | FastAPI AI Coach service (`/v1/chat`, `/v1/chat/stream`, `/v1/training-plan`, `/v1/post-run`, `/health`, `/metrics`) |
| `edge-functions-openapi.yaml` | Supabase Edge Functions (`/sync-activity`, `/award-badges`, `/leaderboard`, `/redeem-coin`, `/delete-account`, `/recalc-streak`, `/send-push`, `/weekly-recap`) |

## Run contract tests

```bash
pnpm install
pnpm test
```

`mobile_api_contract.test.ts` loads both YAML files, registers every schema
under `#/components/schemas/*` with ajv and validates representative
fixtures. A failure means either the spec changed (update the fixture) or
the mobile client expectations drifted (regenerate the model code).

## Generate a Postman collection

```bash
pnpm dlx openapi-to-postmanv2 -s ai-coach-openapi.yaml \
  -o ai-coach.postman_collection.json -p
pnpm dlx openapi-to-postmanv2 -s edge-functions-openapi.yaml \
  -o edge-functions.postman_collection.json -p
```

## Lint the specs

```bash
pnpm dlx @redocly/cli lint ai-coach-openapi.yaml
pnpm dlx @redocly/cli lint edge-functions-openapi.yaml
```

## Expected pass criteria

`pnpm test` must report 0 failures, and `redocly lint` must report no
errors (warnings tolerated). CI enforces these in `pr-checks.yml`.
