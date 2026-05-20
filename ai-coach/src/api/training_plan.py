"""Training plan generation endpoint."""

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
from src.schemas import TrainingPlanRequest, TrainingPlanResponse, WorkoutItem
from src.services.claude_client import CacheableBlock, ClaudeClient
from src.services.cost_tracker import CostAggregator

log = structlog.get_logger(__name__)

router = APIRouter(prefix="/v1", tags=["training-plan"])


def _build_user_msg(body: TrainingPlanRequest) -> str:
    profile = body.user_profile
    return (
        "Generate the training plan as JSON only.\n\n"
        f"race_distance: {body.race_distance}\n"
        f"weeks: {body.weeks}\n"
        f"target_pace_s_per_km: {body.target_pace_s_per_km}\n"
        f"start_date: {body.start_date.isoformat()}\n"
        f"language: {body.language}\n\n"
        "USER PROFILE\n"
        f"name: {profile.name}\n"
        f"age: {profile.age}, gender: {profile.gender}\n"
        f"weight_kg: {profile.weight_kg}, height_cm: {profile.height_cm}\n"
        f"level: {profile.level}, goal: {profile.goal}\n"
        f"weekly_km: {profile.weekly_km}, max_hr: {profile.max_hr}, vo2max: {profile.vo2max}\n"
        f"recent_prs: {json.dumps(profile.recent_prs, ensure_ascii=False)}\n"
        f"injuries: {json.dumps(profile.injuries, ensure_ascii=False)}\n"
    )


@router.post(
    "/training-plan",
    response_model=TrainingPlanResponse,
    dependencies=[Depends(enforce_rate_limit)],
)
async def create_training_plan(
    body: TrainingPlanRequest,
    user_id: str = Depends(get_user_id),
    settings: Settings = Depends(get_settings),
    claude: ClaudeClient = Depends(get_claude),
    cost_agg: CostAggregator = Depends(get_cost_aggregator),
) -> TrainingPlanResponse:
    """Generate a full periodized training plan as structured JSON."""
    system_blocks = [
        CacheableBlock(text=load_prompt("training_plan"), cache=True),
    ]

    msgs: list[dict[str, Any]] = [
        {"role": "user", "content": _build_user_msg(body)}
    ]

    # Plans need quality + structure -> always Sonnet
    try:
        result = await claude.messages_create(
            model=settings.model_sonnet,
            system_blocks=system_blocks,
            messages=msgs,
            max_tokens=min(8000, body.weeks * 7 * 60),
            temperature=0.4,
            response_format_json=True,
        )
    except ValueError as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc

    try:
        parsed = claude.parse_json_response(result.text)
    except json.JSONDecodeError as exc:
        log.error("training_plan_json_parse_failed", error=str(exc), text=result.text[:500])
        raise HTTPException(status_code=502, detail="Model returned invalid JSON.") from exc

    try:
        workouts = [WorkoutItem(**w) for w in parsed.get("workouts", [])]
        summary_vi = str(parsed.get("summary_vi", ""))
    except ValidationError as exc:
        raise HTTPException(status_code=502, detail=f"Plan schema invalid: {exc}") from exc

    await cost_agg.record(user_id, result.usage)

    return TrainingPlanResponse(
        workouts=workouts,
        summary_vi=summary_vi,
        model_used=result.model,
        cost_usd=result.usage.total_usd,
    )
