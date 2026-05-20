"""JWT tampering: any modification to the token must yield 401.

We mutate the signature, the algorithm header and a claim, then attempt to
call an authenticated endpoint. Each variant must be rejected with 401
(or 403 when the upstream chooses to mask 401s).
"""

from __future__ import annotations

import base64
import json

import pytest
import requests

TIMEOUT = 15


def _split(token: str) -> list[str]:
    return token.split(".")


def _b64url(data: bytes) -> str:
    return base64.urlsafe_b64encode(data).rstrip(b"=").decode("ascii")


def _b64url_decode(value: str) -> bytes:
    pad = "=" * (-len(value) % 4)
    return base64.urlsafe_b64decode(value + pad)


def _flip_signature(token: str) -> str:
    parts = _split(token)
    sig = bytearray(_b64url_decode(parts[2]))
    sig[0] ^= 0xFF
    parts[2] = _b64url(bytes(sig))
    return ".".join(parts)


def _set_alg_none(token: str) -> str:
    parts = _split(token)
    header = json.loads(_b64url_decode(parts[0]))
    header["alg"] = "none"
    parts[0] = _b64url(json.dumps(header).encode())
    parts[2] = ""
    return ".".join(parts)


def _mutate_claim(token: str) -> str:
    parts = _split(token)
    payload = json.loads(_b64url_decode(parts[1]))
    payload["role"] = "service_role"
    parts[1] = _b64url(json.dumps(payload).encode())
    return ".".join(parts)


MUTATIONS = [
    ("flipped_signature", _flip_signature),
    ("alg_none", _set_alg_none),
    ("mutated_claim", _mutate_claim),
]


@pytest.mark.parametrize("name, mutate", MUTATIONS)
def test_tampered_jwt_is_rejected(env, user_a, name, mutate) -> None:
    bad_token = mutate(user_a["access_token"])
    resp = requests.get(
        f"{env.supabase_url}/rest/v1/profiles?select=*",
        headers={
            "apikey": env.anon_key,
            "Authorization": f"Bearer {bad_token}",
        },
        timeout=TIMEOUT,
    )
    assert resp.status_code in (401, 403), (
        f"Expected 401/403 for {name}, got {resp.status_code}: {resp.text}"
    )
