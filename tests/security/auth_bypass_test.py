"""Authorization bypass: User B must never read User A's activities.

We sign in as user A, create an activity, then attempt to fetch it as
user B. The expected outcome is an empty result set (RLS hides the row)
or an explicit 403 / 401 status code.
"""

from __future__ import annotations

import requests

TIMEOUT = 15


def _post_activity(env, session) -> str:
    resp = requests.post(
        f"{env.supabase_url}/rest/v1/activities",
        headers={
            "apikey": env.anon_key,
            "Authorization": f"Bearer {session['access_token']}",
            "Content-Type": "application/json",
            "Prefer": "return=representation",
        },
        json={
            "distance_km": 3.0,
            "duration_s": 1200,
            "started_at": "2026-05-20T07:00:00Z",
        },
        timeout=TIMEOUT,
    )
    resp.raise_for_status()
    return resp.json()[0]["id"]


def test_user_b_cannot_read_user_a_activity(env, user_a, user_b) -> None:
    activity_id = _post_activity(env, user_a)

    resp = requests.get(
        f"{env.supabase_url}/rest/v1/activities?id=eq.{activity_id}&select=*",
        headers={
            "apikey": env.anon_key,
            "Authorization": f"Bearer {user_b['access_token']}",
        },
        timeout=TIMEOUT,
    )
    # PostgREST with RLS returns an empty array for hidden rows.
    assert resp.status_code in (200, 401, 403), resp.text
    if resp.status_code == 200:
        assert resp.json() == [], "RLS leaked another user's row"


def test_anonymous_cannot_list_activities(env) -> None:
    resp = requests.get(
        f"{env.supabase_url}/rest/v1/activities?select=*",
        headers={"apikey": env.anon_key},
        timeout=TIMEOUT,
    )
    # Either explicit denial or empty result.
    assert resp.status_code in (200, 401, 403), resp.text
    if resp.status_code == 200:
        assert resp.json() == []
