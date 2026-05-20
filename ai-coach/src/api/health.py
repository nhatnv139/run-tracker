"""Health and metrics endpoints."""

from __future__ import annotations

from typing import Any

from fastapi import APIRouter, Depends, Request

from src.api.deps import get_cost_aggregator
from src.config import Settings, get_settings
from src.schemas import HealthResponse, MetricsResponse
from src.services.cost_tracker import CostAggregator

router = APIRouter(tags=["health"])


@router.get("/health", response_model=HealthResponse)
async def health(
    request: Request,
    settings: Settings = Depends(get_settings),
) -> HealthResponse:
    redis = getattr(request.app.state, "redis", None)
    redis_ok = False
    if redis is not None:
        try:
            pong = await redis.ping()
            redis_ok = bool(pong)
        except Exception:  # noqa: BLE001
            redis_ok = False

    return HealthResponse(
        status="ok" if redis_ok else "degraded",
        redis=redis_ok,
        anthropic_configured=bool(settings.anthropic_api_key),
    )


@router.get("/metrics", response_model=MetricsResponse)
async def metrics(
    cost_agg: CostAggregator = Depends(get_cost_aggregator),
) -> MetricsResponse:
    snap: dict[str, Any] = await cost_agg.global_snapshot()
    return MetricsResponse(
        cache_hit_rate=float(snap.get("cache_hit_rate", 0.0)),
        avg_cost_per_request_usd=float(snap.get("avg_cost_per_request_usd", 0.0)),
        total_requests=int(snap.get("total_requests", 0)),
        total_cached_tokens=int(snap.get("total_cached_tokens", 0)),
        total_input_tokens=int(snap.get("total_input_tokens", 0)),
    )
