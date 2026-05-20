"""Post-run summary endpoint."""

from __future__ import annotations

import json
from typing import Any

import structlog
from fastapi import APIRouter, Depends, HTTPException
from pydantic import ValidationError

from src.api.deps import get_claude, get_cost_aggregator
from src.config import Settings, get_settings
from src.middleware.auth import get_user_id
from src.middleware.rate_limit import enforce_rate_limit
from src.prompts import load_prompt
from src.schemas import PostRunRequest, PostRunResponse
from src.services.claude_client import CacheableBlock, ClaudeClient
from src.services.cost_tracker import CostAggregator

log = structlog.get_logger(__name__)

router = APIRouter(prefix="/v1", tags=["post-run"])


def _build_user_msg(body: PostRunRequest) -> str:
    a = body.activity
    profile = body.user_profile
    splits = "\n".join(
        f"  km {s.km}: {s.duration_s}s, hr {s.hr_avg if s.hr_avg is not None else 'n/a'}"
        for s in a.splits
    )
    return (
        "Analyze this completed activity and return JSON only.\n\n"
        "ACTIVITY\n"
        f"distance_m: {a.distance_m}\n"
        f"duration_s: {a.duration_s}\n"
        f"pace_s_per_km: {a.pace_s_per_km}\n"
        f"hr_avg: {a.hr_avg}\n"
        f"elevation_gain_m: {a.elevation_gain_m}\n"
        f"splits:\n{splits or '  (none)'}\n\n"
        "USER PROFILE\n"
        f"name: {profile.name}\n"
        f"level: {profile.level}, goal: {profile.goal}\n"
        f"weekly_km: {profile.weekly_km}, max_hr: {profile.max_hr}\n"
        f"recent_prs: {json.dumps(profile.recent_prs, ensure_ascii=False)}\n"
        f"language: {body.language}\n"
    )


@router.post(
    "/post-run",
    response_model=PostRunResponse,
    dependencies=[Depends(enforce_rate_limit)],
)
async def post_run_summary(
    body: PostRunRequest,
    user_id: str = Depends(get_user_id),
    settings: Settings = Depends(get_settings),
    claude: ClaudeClient = Depends(get_claude),
    cost_agg: CostAggregator = Depends(get_cost_aggregator),
) -> PostRunResponse:
    """Analyze an activity and return a motivational, data-grounded summary."""
    system_blocks = [
        CacheableBlock(text=load_prompt("post_run"), cache=True),
    ]
    msgs: list[dict[str, Any]] = [
        {"role": "user", "content": _build_user_msg(body)}
    ]

    # Use Haiku — schema is small and well-defined, Haiku is plenty
    try:
        result = await claude.messages_create(
            model=settings.model_haiku,
            system_blocks=system_blocks,
            messages=msgs,
            max_tokens=600,
            temperature=0.6,
            response_format_json=True,
        )
    except ValueError as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc

    try:
        parsed = claude.parse_json_response(result.text)
    except json.JSONDecodeError as exc:
        log.error("post_run_json_parse_failed", error=str(exc), text=result.text[:500])
        raise HTTPException(status_code=502, detail="Model returned invalid JSON.") from exc

    try:
        response = PostRunResponse(
            title_vi=str(parsed.get("title_vi", "")),
            summary_vi=str(parsed.get("summary_vi", "")),
            achievements=list(parsed.get("achievements", [])),
            tips=list(parsed.get("tips", [])),
            model_used=result.model,
            cost_usd=result.usage.total_usd,
        )
    except ValidationError as exc:
        raise HTTPException(status_code=502, detail=f"Schema invalid: {exc}") from exc

    await cost_agg.record(user_id, result.usage)
    return response
