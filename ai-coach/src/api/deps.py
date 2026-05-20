"""Shared FastAPI dependencies for service singletons."""

from __future__ import annotations

from typing import TYPE_CHECKING

from fastapi import Depends, Request

from src.config import Settings, get_settings
from src.services.cache import ChatHistoryCache
from src.services.claude_client import ClaudeClient
from src.services.cost_tracker import CostAggregator

if TYPE_CHECKING:
    from redis.asyncio import Redis


def get_redis(request: Request) -> "Redis | None":
    return getattr(request.app.state, "redis", None)


def get_claude(
    request: Request,
    settings: Settings = Depends(get_settings),
) -> ClaudeClient:
    client: ClaudeClient | None = getattr(request.app.state, "claude", None)
    if client is None:
        client = ClaudeClient(settings)
        request.app.state.claude = client
    return client


def get_chat_cache(
    request: Request,
    settings: Settings = Depends(get_settings),
) -> ChatHistoryCache:
    return ChatHistoryCache(
        redis=get_redis(request),
        window=settings.redis_chat_window,
        ttl_seconds=settings.redis_chat_ttl_seconds,
    )


def get_cost_aggregator(request: Request) -> CostAggregator:
    return CostAggregator(get_redis(request))
