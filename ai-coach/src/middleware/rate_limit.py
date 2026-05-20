"""Sliding-window rate limit per user_id, backed by Redis."""

from __future__ import annotations

import time
from typing import TYPE_CHECKING

import structlog
from fastapi import Depends, HTTPException, Request, status

from src.config import Settings, get_settings
from src.middleware.auth import get_user_id, get_user_tier

if TYPE_CHECKING:
    from redis.asyncio import Redis

log = structlog.get_logger(__name__)


class RateLimiter:
    """Sliding-window counter using Redis sorted sets.

    Free tier: N per 30 days. Paid tier: N per day.
    """

    def __init__(self, redis: Redis | None, settings: Settings) -> None:
        self._redis = redis
        self._settings = settings

    @staticmethod
    def _key(user_id: str) -> str:
        return f"ratelimit:{user_id}"

    def _limits_for(self, tier: str) -> tuple[int, int]:
        if tier == "paid":
            return self._settings.rate_limit_paid_per_day, 24 * 3600
        return self._settings.rate_limit_free_per_month, 30 * 24 * 3600

    async def check_and_consume(self, user_id: str, tier: str) -> None:
        if self._redis is None:
            return  # Fail-open if Redis is down; we still log the call

        limit, window = self._limits_for(tier)
        now = time.time()
        cutoff = now - window
        key = self._key(user_id)

        try:
            async with self._redis.pipeline(transaction=True) as pipe:
                pipe.zremrangebyscore(key, 0, cutoff)
                pipe.zcard(key)
                pipe.zadd(key, {str(now): now})
                pipe.expire(key, window + 60)
                results = await pipe.execute()
            current_count = int(results[1])
        except Exception as exc:  # noqa: BLE001
            log.warning("rate_limit_check_failed", error=str(exc), user_id=user_id)
            return

        if current_count >= limit:
            log.info("rate_limit_exceeded", user_id=user_id, tier=tier, count=current_count)
            raise HTTPException(
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                detail=(
                    f"Rate limit exceeded: {limit} requests per "
                    f"{'day' if tier == 'paid' else '30 days'} for {tier} tier."
                ),
                headers={"Retry-After": str(window)},
            )


async def enforce_rate_limit(
    request: Request,
    user_id: str = Depends(get_user_id),
    tier: str = Depends(get_user_tier),
    settings: Settings = Depends(get_settings),
) -> None:
    redis_client = getattr(request.app.state, "redis", None)
    limiter = RateLimiter(redis_client, settings)
    await limiter.check_and_consume(user_id, tier)
