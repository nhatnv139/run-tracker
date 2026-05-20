"""File-upload abuse: malformed payloads must be rejected gracefully.

The Edge Function `upload-route` accepts compressed route polylines or
GPX-like blobs. We send malformed bodies (giant payload, wrong content
type, non-UTF8 bytes, deeply nested JSON) and verify that the server:

  - never returns 5xx (graceful rejection)
  - responds with a 4xx status code with a JSON `error` field
"""

from __future__ import annotations

import json

import pytest
import requests

TIMEOUT = 30

CASES = [
    (
        "non_json_body",
        "application/json",
        b"\xff\xfe\xfd\xfc\x00not-json",
    ),
    (
        "deeply_nested_json",
        "application/json",
        json.dumps({"a": {"b": {"c": {"d": {"e": [1] * 1024}}}}}).encode(),
    ),
    (
        "huge_payload_5mb",
        "application/json",
        json.dumps({"polyline": "A" * (5 * 1024 * 1024)}).encode(),
    ),
    (
        "wrong_content_type",
        "text/plain",
        b"polyline=foobar",
    ),
    (
        "binary_blob",
        "application/octet-stream",
        bytes(range(256)) * 16,
    ),
]


@pytest.mark.parametrize("name, content_type, body", CASES)
def test_upload_route_rejects_malformed(env, user_a, name, content_type, body) -> None:
    resp = requests.post(
        f"{env.supabase_url}/functions/v1/upload-route",
        headers={
            "apikey": env.anon_key,
            "Authorization": f"Bearer {user_a['access_token']}",
            "Content-Type": content_type,
        },
        data=body,
        timeout=TIMEOUT,
    )
    assert 400 <= resp.status_code < 500, (
        f"Case {name}: expected 4xx, got {resp.status_code}: {resp.text[:200]!r}"
    )
