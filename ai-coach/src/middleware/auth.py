"""Supabase JWT verification (RS256 via JWKS)."""

from __future__ import annotations

import time
from typing import Any

import jwt
import structlog
from fastapi import Depends, HTTPException, Request, status
from jwt import PyJWKClient

from src.config import Settings, get_settings

log = structlog.get_logger(__name__)

_JWKS_CLIENT: PyJWKClient | None = None
_JWKS_LAST_FETCH: float = 0
_JWKS_TTL = 3600.0


def _get_jwks_client(settings: Settings) -> PyJWKClient:
    global _JWKS_CLIENT, _JWKS_LAST_FETCH  # noqa: PLW0603

    now = time.time()
    if _JWKS_CLIENT is not None and (now - _JWKS_LAST_FETCH) < _JWKS_TTL:
        return _JWKS_CLIENT

    jwks_url = settings.supabase_jwks_url
    if not jwks_url and settings.supabase_url:
        jwks_url = f"{settings.supabase_url.rstrip('/')}/auth/v1/jwks"

    if not jwks_url:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Supabase JWKS URL not configured.",
        )

    _JWKS_CLIENT = PyJWKClient(jwks_url, cache_keys=True, lifespan=int(_JWKS_TTL))
    _JWKS_LAST_FETCH = now
    return _JWKS_CLIENT


async def _verify_supabase_jwt(token: str, settings: Settings) -> dict[str, Any]:
    try:
        client = _get_jwks_client(settings)
        signing_key = client.get_signing_key_from_jwt(token).key
        payload: dict[str, Any] = jwt.decode(
            token,
            signing_key,
            algorithms=["RS256", "ES256"],
            audience=settings.supabase_jwt_audience,
            options={"require": ["exp", "sub"]},
        )
    except jwt.PyJWTError as exc:
        log.info("jwt_verify_failed", error=str(exc))
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired token.",
        ) from exc
    return payload


async def get_current_user(
    request: Request,
    settings: Settings = Depends(get_settings),
) -> dict[str, Any]:
    """Return decoded JWT claims. If auth_required is False, returns a dev stub."""
    auth_header = request.headers.get("authorization") or ""
    parts = auth_header.split()
    token = parts[1] if len(parts) == 2 and parts[0].lower() == "bearer" else None

    if not token:
        if not settings.auth_required:
            # Dev mode: derive a stable anonymous user from X-User-Id or fallback
            anon_id = request.headers.get("x-user-id", "anon-dev")
            return {"sub": anon_id, "tier": "free", "anonymous": True}
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Missing bearer token.",
        )

    return await _verify_supabase_jwt(token, settings)


def get_user_id(user: dict[str, Any] = Depends(get_current_user)) -> str:
    sub = user.get("sub")
    if not isinstance(sub, str) or not sub:
        raise HTTPException(status_code=400, detail="Invalid user identity.")
    return sub


def get_user_tier(user: dict[str, Any] = Depends(get_current_user)) -> str:
    """Return 'free' or 'paid' based on JWT custom claim."""
    tier = user.get("tier") or user.get("app_metadata", {}).get("tier")
    return tier if tier in {"free", "paid"} else "free"


__all__ = ["get_current_user", "get_user_id", "get_user_tier"]
