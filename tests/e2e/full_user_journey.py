"""Full RunVie user journey driven entirely through HTTP.

Steps performed (each is asserted):

1. Sign up a brand-new test user via Supabase Auth.
2. POST a synthetic activity to the `sync-activity` Edge Function.
3. Verify that the badge service awarded at least one badge and that the
   coin wallet was incremented.
4. Open an AI Coach chat and exchange one message.
5. Redeem coins for a Shopee voucher via the `redeem-coin` Edge Function.
6. Delete the account via the `delete-account` Edge Function and verify
   that all rows belonging to this user are gone (RLS cleanup).

Expected pass criteria:
    All HTTP calls return 2xx, the badge list is non-empty, the redeem call
    returns a voucher code, and a post-cleanup query returns zero rows.

Run:
    SUPABASE_URL=... \
    SUPABASE_ANON_KEY=... \
    SUPABASE_SERVICE_ROLE_KEY=... \
    AI_COACH_URL=... \
    python full_user_journey.py
"""

from __future__ import annotations

import os
import sys
import time
import uuid
from dataclasses import dataclass

import requests

SUPABASE_URL = os.environ.get("SUPABASE_URL", "")
SUPABASE_ANON_KEY = os.environ.get("SUPABASE_ANON_KEY", "")
SUPABASE_SERVICE_ROLE_KEY = os.environ.get("SUPABASE_SERVICE_ROLE_KEY", "")
AI_COACH_URL = os.environ.get("AI_COACH_URL", "http://localhost:8080")

TIMEOUT = 15


@dataclass
class Session:
    user_id: str
    access_token: str
    email: str


def _require_env() -> None:
    missing = [
        name
        for name, value in {
            "SUPABASE_URL": SUPABASE_URL,
            "SUPABASE_ANON_KEY": SUPABASE_ANON_KEY,
            "SUPABASE_SERVICE_ROLE_KEY": SUPABASE_SERVICE_ROLE_KEY,
        }.items()
        if not value
    ]
    if missing:
        raise SystemExit(f"Missing required env vars: {', '.join(missing)}")


def sign_up() -> Session:
    email = f"journey+{uuid.uuid4().hex[:10]}@runvie.test"
    password = f"P-{uuid.uuid4().hex[:16]}"
    resp = requests.post(
        f"{SUPABASE_URL}/auth/v1/signup",
        headers={
            "apikey": SUPABASE_ANON_KEY,
            "Content-Type": "application/json",
        },
        json={"email": email, "password": password},
        timeout=TIMEOUT,
    )
    resp.raise_for_status()
    body = resp.json()
    return Session(
        user_id=body["user"]["id"],
        access_token=body["access_token"],
        email=email,
    )


def post_activity(session: Session) -> dict:
    payload = {
        "distance_km": 5.1,
        "duration_s": 1830,
        "started_at": "2026-05-20T07:00:00Z",
        "polyline": "abcdef",
    }
    resp = requests.post(
        f"{SUPABASE_URL}/functions/v1/sync-activity",
        headers={
            "Authorization": f"Bearer {session.access_token}",
            "apikey": SUPABASE_ANON_KEY,
            "Content-Type": "application/json",
        },
        json=payload,
        timeout=TIMEOUT,
    )
    resp.raise_for_status()
    return resp.json()


def fetch_badges_and_coins(session: Session) -> tuple[list, int]:
    badges = requests.get(
        f"{SUPABASE_URL}/rest/v1/user_badges?user_id=eq.{session.user_id}&select=badge_code",
        headers={
            "apikey": SUPABASE_ANON_KEY,
            "Authorization": f"Bearer {session.access_token}",
        },
        timeout=TIMEOUT,
    )
    badges.raise_for_status()
    wallet = requests.get(
        f"{SUPABASE_URL}/rest/v1/coin_wallets?user_id=eq.{session.user_id}&select=balance",
        headers={
            "apikey": SUPABASE_ANON_KEY,
            "Authorization": f"Bearer {session.access_token}",
        },
        timeout=TIMEOUT,
    )
    wallet.raise_for_status()
    rows = wallet.json()
    balance = rows[0]["balance"] if rows else 0
    return badges.json(), balance


def chat_with_coach(session: Session) -> str:
    resp = requests.post(
        f"{AI_COACH_URL}/v1/chat",
        headers={
            "Authorization": f"Bearer {session.access_token}",
            "Content-Type": "application/json",
        },
        json={"message": "How was my run?"},
        timeout=TIMEOUT,
    )
    resp.raise_for_status()
    return resp.json().get("reply", "")


def redeem_voucher(session: Session) -> str:
    resp = requests.post(
        f"{SUPABASE_URL}/functions/v1/redeem-coin",
        headers={
            "Authorization": f"Bearer {session.access_token}",
            "apikey": SUPABASE_ANON_KEY,
            "Content-Type": "application/json",
        },
        json={"product": "shopee_50k", "cost_coins": 500},
        timeout=TIMEOUT,
    )
    resp.raise_for_status()
    return resp.json().get("voucher_code", "")


def delete_account(session: Session) -> None:
    resp = requests.post(
        f"{SUPABASE_URL}/functions/v1/delete-account",
        headers={
            "Authorization": f"Bearer {session.access_token}",
            "apikey": SUPABASE_ANON_KEY,
        },
        timeout=TIMEOUT,
    )
    resp.raise_for_status()


def assert_cleanup(session: Session) -> None:
    headers = {
        "apikey": SUPABASE_SERVICE_ROLE_KEY,
        "Authorization": f"Bearer {SUPABASE_SERVICE_ROLE_KEY}",
    }
    tables = ("activities", "user_badges", "coin_wallets", "profiles")
    for table in tables:
        resp = requests.get(
            f"{SUPABASE_URL}/rest/v1/{table}?user_id=eq.{session.user_id}&select=user_id",
            headers=headers,
            timeout=TIMEOUT,
        )
        resp.raise_for_status()
        rows = resp.json()
        assert rows == [], f"Cleanup failed for table {table}: {rows!r}"


def main() -> int:
    _require_env()
    print("[1/7] sign-up")
    session = sign_up()
    print(f"      user_id={session.user_id}")

    print("[2/7] post activity")
    activity = post_activity(session)
    assert activity, "empty activity response"

    print("[3/7] verify badges + coins")
    time.sleep(2)
    badges, balance = fetch_badges_and_coins(session)
    assert badges, "expected at least one badge"
    assert balance > 0, "expected positive coin balance"

    print("[4/7] chat with AI Coach")
    reply = chat_with_coach(session)
    assert reply, "empty AI Coach reply"

    print("[5/7] redeem voucher")
    code = redeem_voucher(session)
    assert code, "expected voucher code"

    print("[6/7] delete account")
    delete_account(session)

    print("[7/7] verify cleanup")
    time.sleep(2)
    assert_cleanup(session)

    print("OK - journey passed")
    return 0


if __name__ == "__main__":
    sys.exit(main())
