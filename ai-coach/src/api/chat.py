"""Chat endpoints: non-streaming and SSE streaming."""

from __future__ import annotations

import json
from collections.abc import AsyncIterator
from typing import Any

import structlog
from fastapi import APIRouter, Depends, HTTPException
from sse_starlette.sse import EventSourceResponse

from src.api.deps import get_chat_cache, get_claude, get_cost_aggregator
from src.config import Settings, get_settings
from src.middleware.auth import get_user_id
from src.middleware.rate_limit import enforce_rate_limit
from src.prompts import load_prompt
from src.router import classify, resolve_model
from src.schemas import ChatMessage, ChatRequest, ChatResponse, UserProfile
from src.services.cache import ChatHistoryCache
from src.services.claude_client import CacheableBlock, ClaudeClient
from src.services.cost_tracker import CostAggregator

log = structlog.get_logger(__name__)

router = APIRouter(prefix="/v1", tags=["chat"])


def _user_profile_block(profile: UserProfile, language: str) -> str:
    """Serialize user profile as a stable, cacheable block."""
    return (
        "USER PROFILE\n"
        f"name: {profile.name}\n"
        f"age: {profile.age}\n"
        f"gender: {profile.gender}\n"
        f"weight_kg: {profile.weight_kg}\n"
        f"height_cm: {profile.height_cm}\n"
        f"level: {profile.level}\n"
        f"goal: {profile.goal}\n"
        f"weekly_km: {profile.weekly_km}\n"
        f"max_hr: {profile.max_hr}\n"
        f"vo2max: {profile.vo2max}\n"
        f"recent_prs: {json.dumps(profile.recent_prs, ensure_ascii=False)}\n"
        f"injuries: {json.dumps(profile.injuries, ensure_ascii=False)}\n"
        f"response_language: {language}\n"
    )


def _build_system_blocks(profile: UserProfile, language: str) -> list[CacheableBlock]:
    """Two cache breakpoints: (1) static persona, (2) user profile.

    Recent conversation history goes in `messages`, NOT cached.
    """
    system_prompt = load_prompt("system_coach")
    return [
        CacheableBlock(text=system_prompt, cache=True),
        CacheableBlock(text=_user_profile_block(profile, language), cache=True),
    ]


def _messages_payload(history: list[ChatMessage], user_msg: str) -> list[dict[str, Any]]:
    payload: list[dict[str, Any]] = [
        {"role": m.role, "content": m.content} for m in history
    ]
    payload.append({"role": "user", "content": user_msg})
    return payload


@router.post(
    "/chat",
    response_model=ChatResponse,
    dependencies=[Depends(enforce_rate_limit)],
)
async def chat(
    body: ChatRequest,
    user_id: str = Depends(get_user_id),
    settings: Settings = Depends(get_settings),
    claude: ClaudeClient = Depends(get_claude),
    cache: ChatHistoryCache = Depends(get_chat_cache),
    cost_agg: CostAggregator = Depends(get_cost_aggregator),
) -> ChatResponse:
    """Non-streaming chat. Returns a single response with usage + cost."""
    # Merge cached history with client-provided history (cached wins on overlap)
    cached_history = await cache.get(user_id)
    history = cached_history or body.history

    decision = classify(body.message, history_len=len(history))
    model = resolve_model(
        decision, sonnet_id=settings.model_sonnet, haiku_id=settings.model_haiku
    )

    system_blocks = _build_system_blocks(body.user_profile, body.language)
    msgs = _messages_payload(history, body.message)

    try:
        result = await claude.messages_create(
            model=model,
            system_blocks=system_blocks,
            messages=msgs,
            max_tokens=settings.max_tokens_default,
            temperature=0.7,
        )
    except ValueError as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc

    # Persist to history cache
    await cache.append(
        user_id,
        [
            ChatMessage(role="user", content=body.message),
            ChatMessage(role="assistant", content=result.text),
        ],
    )
    await cost_agg.record(user_id, result.usage)

    return ChatResponse(
        message=result.text,
        model_used=result.model,
        cached_tokens=result.usage.cached_read_tokens,
        input_tokens=result.usage.input_tokens,
        output_tokens=result.usage.output_tokens,
        cost_usd=result.usage.total_usd,
        intent=decision.intent,
    )


async def _sse_generator(
    claude: ClaudeClient,
    model: str,
    system_blocks: list[CacheableBlock],
    msgs: list[dict[str, Any]],
    max_tokens: int,
    user_id: str,
    user_message: str,
    cache: ChatHistoryCache,
    cost_agg: CostAggregator,
) -> AsyncIterator[dict[str, str]]:
    """Yield SSE events. Captures final usage to record cost + persist history."""
    collected: list[str] = []

    async for ev in claude.chat_stream(
        model=model,
        system_blocks=system_blocks,
        messages=msgs,
        max_tokens=max_tokens,
    ):
        if ev["type"] == "delta":
            collected.append(ev["text"])
            yield {"event": "delta", "data": json.dumps({"text": ev["text"]})}
        elif ev["type"] == "done":
            full_text = "".join(collected)
            await cache.append(
                user_id,
                [
                    ChatMessage(role="user", content=user_message),
                    ChatMessage(role="assistant", content=full_text),
                ],
            )
            from src.services.cost_tracker import compute_cost

            usage = ev["usage"]
            cost = compute_cost(
                model,
                usage["input_tokens"],
                usage["output_tokens"],
                usage["cache_read_input_tokens"],
                usage["cache_creation_input_tokens"],
            )
            await cost_agg.record(user_id, cost)
            yield {"event": "done", "data": json.dumps(ev)}
        elif ev["type"] == "error":
            yield {"event": "error", "data": json.dumps(ev)}


@router.post(
    "/chat/stream",
    dependencies=[Depends(enforce_rate_limit)],
)
async def chat_stream(
    body: ChatRequest,
    user_id: str = Depends(get_user_id),
    settings: Settings = Depends(get_settings),
    claude: ClaudeClient = Depends(get_claude),
    cache: ChatHistoryCache = Depends(get_chat_cache),
    cost_agg: CostAggregator = Depends(get_cost_aggregator),
) -> EventSourceResponse:
    """SSE streaming chat. Emits `delta`, then `done` with usage + cost."""
    cached_history = await cache.get(user_id)
    history = cached_history or body.history

    decision = classify(body.message, history_len=len(history))
    model = resolve_model(
        decision, sonnet_id=settings.model_sonnet, haiku_id=settings.model_haiku
    )

    system_blocks = _build_system_blocks(body.user_profile, body.language)
    msgs = _messages_payload(history, body.message)

    return EventSourceResponse(
        _sse_generator(
            claude=claude,
            model=model,
            system_blocks=system_blocks,
            msgs=msgs,
            max_tokens=settings.max_tokens_default,
            user_id=user_id,
            user_message=body.message,
            cache=cache,
            cost_agg=cost_agg,
        ),
        media_type="text/event-stream",
    )
