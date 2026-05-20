# RunVie security tests

Black-box regression tests that probe the deployed stack for common
classes of vulnerabilities.

## Tests

| File | Class |
|------|-------|
| `auth_bypass_test.py` | Cross-tenant data access via RLS |
| `sql_injection_test.py` | Injection payloads through query params + JSON body |
| `jwt_tampering_test.py` | Signature flip, alg=none, claim escalation |
| `rate_limit_test.py` | Burst protection on AI Coach + sync-activity |
| `file_upload_test.py` | Malformed payloads (oversize, binary, wrong CT) |

## Setup

```bash
pip install -e .
```

## Run

```bash
SUPABASE_URL=https://staging.supabase.co \
SUPABASE_ANON_KEY=... \
SUPABASE_SERVICE_ROLE_KEY=... \
AI_COACH_URL=https://ai.staging.runvie.app \
pytest
```

The `env` fixture will `pytest.skip` the entire run if any of the three
Supabase env vars are missing, so the suite is safe to add to nightly CI
without breaking PRs that don't have access to those secrets.

## Expected pass criteria

- Auth-bypass: PostgREST returns `[]` or 401/403 to user B.
- SQLi: no 5xx for any payload; response payloads remain well-formed JSON.
- JWT: every mutated token yields 401/403.
- Rate-limit: at least one 429 within the burst window.
- Upload: every malformed body yields a 4xx with a JSON error.
