"""Shared pytest fixtures for RunVie security tests."""

from __future__ import annotations

import os
import uuid
from dataclasses import dataclass

import pytest
import requests

TIMEOUT = 15


@dataclass(frozen=True)
class Env:
    supabase_url: str
    anon_key: str
    service_role_key: str
    ai_coach_url: str


def _env_or_skip(name: str) -> str:
    value = os.environ.get(name)
    if not value:
        pytest.skip(f"Missing env var {name} required for security suite")
    return value


@pytest.fixture(scope="session")
def env() -> Env:
    return Env(
        supabase_url=_env_or_skip("SUPABASE_URL"),
        anon_key=_env_or_skip("SUPABASE_ANON_KEY"),
        service_role_key=_env_or_skip("SUPABASE_SERVICE_ROLE_KEY"),
        ai_coach_url=os.environ.get(
            "AI_COACH_URL", "http://localhost:8080"
        ),
    )


def _sign_up(env: Env) -> dict:
    email = f"sec+{uuid.uuid4().hex[:10]}@runvie.test"
    password = f"P-{uuid.uuid4().hex[:16]}"
    resp = requests.post(
        f"{env.supabase_url}/auth/v1/signup",
        headers={
            "apikey": env.anon_key,
            "Content-Type": "application/json",
        },
        json={"email": email, "password": password},
        timeout=TIMEOUT,
    )
    resp.raise_for_status()
    body = resp.json()
    return {
        "user_id": body["user"]["id"],
        "access_token": body["access_token"],
        "email": email,
    }


@pytest.fixture()
def user_a(env: Env) -> dict:
    return _sign_up(env)


@pytest.fixture()
def user_b(env: Env) -> dict:
    return _sign_up(env)
