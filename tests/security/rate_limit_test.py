"""Rate limiting: bursting requests must eventually return 429.

We fire 60 sequential requests to the AI Coach chat endpoint inside ~10s
and expect at least one 429 (Too Many Requests) response.
"""

from __future__ import annotations

import requests

TIMEOUT = 15


def test_chat_burst_triggers_429(env, user_a) -> None:
    statuses: list[int] = []
    for _ in range(60):
        resp = requests.post(
            f"{env.ai_coach_url}/v1/chat",
            headers={
                "Authorization": f"Bearer {user_a['access_token']}",
                "Content-Type": "application/json",
            },
            json={"message": "burst"},
            timeout=TIMEOUT,
        )
        statuses.append(resp.status_code)
        if resp.status_code == 429:
            break
    assert 429 in statuses, (
        f"Expected at least one 429 in burst, got {statuses!r}"
    )


def test_sync_activity_burst_triggers_429(env, user_a) -> None:
    statuses: list[int] = []
    for _ in range(120):
        resp = requests.post(
            f"{env.supabase_url}/functions/v1/sync-activity",
            headers={
                "apikey": env.anon_key,
                "Authorization": f"Bearer {user_a['access_token']}",
                "Content-Type": "application/json",
            },
            json={
                "distance_km": 0.1,
                "duration_s": 30,
                "started_at": "2026-05-20T07:00:00Z",
            },
            timeout=TIMEOUT,
        )
        statuses.append(resp.status_code)
        if resp.status_code == 429:
            break
    assert 429 in statuses, (
        f"Expected at least one 429 in burst, got {statuses!r}"
    )
