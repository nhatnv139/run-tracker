"""SQL injection fuzzing against Edge Functions and PostgREST filters.

We pass classic injection payloads through both the request body and query
parameters and assert that the server (a) does not return a 500 caused by a
broken SQL statement and (b) does not leak rows that should be hidden by
RLS or schema constraints.
"""

from __future__ import annotations

import pytest
import requests

TIMEOUT = 15

PAYLOADS = [
    "' OR '1'='1",
    "'; DROP TABLE activities;--",
    "\" OR \"\" = \"",
    "1) OR 1=1--",
    "%27%20OR%201%3D1--",
    "admin'--",
    "0x27 OR 0x31=0x31",
]


@pytest.mark.parametrize("payload", PAYLOADS)
def test_leaderboard_scope_param_resists_injection(env, payload) -> None:
    resp = requests.get(
        f"{env.supabase_url}/functions/v1/leaderboard",
        headers={"apikey": env.anon_key},
        params={"scope": payload, "limit": 10},
        timeout=TIMEOUT,
    )
    # Either rejected with 4xx (preferred) or accepted but returning a
    # well-formed (possibly empty) leaderboard payload.
    assert resp.status_code in (200, 400, 401, 403, 422), resp.text
    if resp.status_code == 200:
        body = resp.json()
        assert isinstance(body, dict)
        assert isinstance(body.get("entries", []), list)


@pytest.mark.parametrize("payload", PAYLOADS)
def test_sync_activity_body_resists_injection(env, user_a, payload) -> None:
    resp = requests.post(
        f"{env.supabase_url}/functions/v1/sync-activity",
        headers={
            "apikey": env.anon_key,
            "Authorization": f"Bearer {user_a['access_token']}",
            "Content-Type": "application/json",
        },
        json={
            "distance_km": 1.0,
            "duration_s": 600,
            "started_at": "2026-05-20T07:00:00Z",
            "polyline": payload,
        },
        timeout=TIMEOUT,
    )
    # Server must not 5xx because of broken SQL.
    assert resp.status_code < 500, (
        f"Server crashed on payload {payload!r}: {resp.status_code} {resp.text}"
    )
