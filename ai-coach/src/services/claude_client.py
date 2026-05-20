"""Anthropic Claude client wrapper with prompt caching, streaming, and retries."""

from __future__ import annotations

import json
from collections.abc import AsyncIterator, Sequence
from dataclasses import dataclass, field
from typing import Any

import structlog
from anthropic import APIConnectionError, APIError, APIStatusError, AsyncAnthropic, RateLimitError
from tenacity import (
    AsyncRetrying,
    retry_if_exception_type,
    stop_after_attempt,
    wait_exponential,
)

from src.config import Settings, require_anthropic_key
from src.services.cost_tracker import CostBreakdown, compute_cost

log = structlog.get_logger(__name__)


@dataclass(slots=True)
class CacheableBlock:
    """A single text block that may carry a cache_control breakpoint."""

    text: str
    cache: bool = False

    def to_dict(self) -> dict[str, Any]:
        block: dict[str, Any] = {"type": "text", "text": self.text}
        if self.cache:
            block["cache_control"] = {"type": "ephemeral"}
        return block


@dataclass(slots=True)
class ClaudeCallResult:
    text: str
    model: str
    stop_reason: str | None
    usage: CostBreakdown
    raw_usage: dict[str, int] = field(default_factory=dict)


class ClaudeClient:
    """Thin async wrapper around `AsyncAnthropic` with caching & retries."""

    def __init__(self, settings: Settings) -> None:
        self._settings = settings
        self._client: AsyncAnthropic | None = None

    @property
    def client(self) -> AsyncAnthropic:
        if self._client is None:
            api_key = require_anthropic_key(self._settings)
            self._client = AsyncAnthropic(api_key=api_key, max_retries=0)
        return self._client

    async def aclose(self) -> None:
        if self._client is not None:
            await self._client.close()
            self._client = None

    # ---------- helpers ----------

    def _build_system(self, blocks: Sequence[CacheableBlock]) -> list[dict[str, Any]]:
        """Build system parameter as a list of content blocks (caching requires this form)."""
        if not self._settings.enable_cache:
            return [{"type": "text", "text": b.text} for b in blocks]
        return [b.to_dict() for b in blocks]

    @staticmethod
    def _extract_usage(usage_obj: Any) -> tuple[int, int, int, int]:
        """Return (input, output, cache_read, cache_creation) from anthropic Usage."""
        input_tokens = int(getattr(usage_obj, "input_tokens", 0) or 0)
        output_tokens = int(getattr(usage_obj, "output_tokens", 0) or 0)
        cache_read = int(getattr(usage_obj, "cache_read_input_tokens", 0) or 0)
        cache_creation = int(getattr(usage_obj, "cache_creation_input_tokens", 0) or 0)
        return input_tokens, output_tokens, cache_read, cache_creation

    @staticmethod
    def _retryer() -> AsyncRetrying:
        return AsyncRetrying(
            stop=stop_after_attempt(4),
            wait=wait_exponential(multiplier=0.5, min=0.5, max=8),
            retry=retry_if_exception_type(
                (APIConnectionError, RateLimitError, APIStatusError)
            ),
            reraise=True,
        )

    # ---------- non-streaming ----------

    async def messages_create(
        self,
        *,
        model: str,
        system_blocks: Sequence[CacheableBlock],
        messages: list[dict[str, Any]],
        max_tokens: int | None = None,
        temperature: float = 0.7,
        response_format_json: bool = False,
    ) -> ClaudeCallResult:
        """One-shot completion with retries; returns full text + usage."""
        max_tok = max_tokens or self._settings.max_tokens_default
        system = self._build_system(system_blocks)

        if response_format_json:
            # Encourage strict JSON via prefill assistant message
            messages = [*messages, {"role": "assistant", "content": "{"}]

        response: Any = None
        async for attempt in self._retryer():
            with attempt:
                response = await self.client.messages.create(
                    model=model,
                    system=system,
                    messages=messages,
                    max_tokens=max_tok,
                    temperature=temperature,
                )

        if response is None:  # pragma: no cover - tenacity reraises before this
            raise RuntimeError("Claude call failed without raising — unexpected.")

        text_parts: list[str] = []
        for block in response.content:
            if getattr(block, "type", None) == "text":
                text_parts.append(block.text)  # type: ignore[attr-defined]
        text = "".join(text_parts)
        if response_format_json:
            text = "{" + text

        in_tok, out_tok, cached, created = self._extract_usage(response.usage)
        cost = compute_cost(model, in_tok, out_tok, cached, created)

        log.info(
            "claude_call_complete",
            model=model,
            input_tokens=in_tok,
            output_tokens=out_tok,
            cached=cached,
            created=created,
            cost_usd=cost.total_usd,
            stop_reason=response.stop_reason,
        )

        return ClaudeCallResult(
            text=text,
            model=model,
            stop_reason=response.stop_reason,
            usage=cost,
            raw_usage={
                "input_tokens": in_tok,
                "output_tokens": out_tok,
                "cache_read_input_tokens": cached,
                "cache_creation_input_tokens": created,
            },
        )

    # ---------- streaming ----------

    async def chat_stream(
        self,
        *,
        model: str,
        system_blocks: Sequence[CacheableBlock],
        messages: list[dict[str, Any]],
        max_tokens: int | None = None,
        temperature: float = 0.7,
    ) -> AsyncIterator[dict[str, Any]]:
        """Yield streaming events as dicts.

        Event shapes:
          {"type": "delta", "text": "..."}
          {"type": "done", "usage": {...}, "cost": {...}, "model": "..."}
          {"type": "error", "message": "..."}
        """
        max_tok = max_tokens or self._settings.max_tokens_default
        system = self._build_system(system_blocks)

        try:
            async with self.client.messages.stream(
                model=model,
                system=system,
                messages=messages,
                max_tokens=max_tok,
                temperature=temperature,
            ) as stream:
                async for event in stream:
                    et = getattr(event, "type", None)
                    if et == "content_block_delta":
                        delta = getattr(event, "delta", None)
                        if delta is not None and getattr(delta, "type", "") == "text_delta":
                            yield {"type": "delta", "text": delta.text}  # type: ignore[attr-defined]

                final = await stream.get_final_message()

            in_tok, out_tok, cached, created = self._extract_usage(final.usage)
            cost = compute_cost(model, in_tok, out_tok, cached, created)

            log.info(
                "claude_stream_complete",
                model=model,
                input_tokens=in_tok,
                output_tokens=out_tok,
                cached=cached,
                created=created,
                cost_usd=cost.total_usd,
            )

            yield {
                "type": "done",
                "model": model,
                "usage": {
                    "input_tokens": in_tok,
                    "output_tokens": out_tok,
                    "cache_read_input_tokens": cached,
                    "cache_creation_input_tokens": created,
                },
                "cost": {
                    "total_usd": cost.total_usd,
                    "cache_hit_rate": cost.cache_hit_rate,
                },
            }
        except APIError as exc:
            log.error("claude_stream_error", error=str(exc), model=model)
            yield {"type": "error", "message": str(exc)}

    @staticmethod
    def parse_json_response(text: str) -> dict[str, Any]:
        """Parse a JSON response, tolerating leading/trailing whitespace."""
        cleaned = text.strip()
        # Strip optional markdown fences
        if cleaned.startswith("```"):
            lines = cleaned.splitlines()
            cleaned = "\n".join(lines[1:-1] if len(lines) >= 2 else lines)
        return json.loads(cleaned)  # type: ignore[no-any-return]
