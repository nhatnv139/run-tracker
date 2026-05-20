"""Redis-backed chat history rotating window cache."""

from __future__ import annotations

import json
from typing import TYPE_CHECKING

import structlog

from src.schemas import ChatMessage

if TYPE_CHECKING:
    from redis.asyncio import Redis

log = structlog.get_logger(__name__)


class ChatHistoryCache:
    """Rotating window of the last N messages per user, TTL-bounded."""

    def __init__(self, redis: Redis | None, window: int = 20, ttl_seconds: int = 86_400) -> None:
        self._redis = redis
        self._window = window
        self._ttl = ttl_seconds

    @staticmethod
    def _key(user_id: str) -> str:
        return f"chat:history:{user_id}"

    async def get(self, user_id: str) -> list[ChatMessage]:
        if self._redis is None:
            return []
        try:
            raw = await self._redis.lrange(self._key(user_id), 0, -1)
        except Exception as exc:  # noqa: BLE001
            log.warning("chat_history_get_failed", error=str(exc), user_id=user_id)
            return []

        result: list[ChatMessage] = []
        for item in raw:
            try:
                payload = json.loads(item.decode() if isinstance(item, bytes) else item)
                result.append(ChatMessage(**payload))
            except (ValueError, TypeError) as exc:
                log.warning("chat_history_parse_failed", error=str(exc))
                continue
        return result

    async def append(self, user_id: str, messages: list[ChatMessage]) -> None:
        if self._redis is None or not messages:
            return
        try:
            key = self._key(user_id)
            payloads = [json.dumps(m.model_dump(), ensure_ascii=False) for m in messages]
            async with self._redis.pipeline(transaction=False) as pipe:
                pipe.rpush(key, *payloads)
                pipe.ltrim(key, -self._window, -1)
                pipe.expire(key, self._ttl)
                await pipe.execute()
        except Exception as exc:  # noqa: BLE001
            log.warning("chat_history_append_failed", error=str(exc), user_id=user_id)

    async def clear(self, user_id: str) -> None:
        if self._redis is None:
            return
        try:
            await self._redis.delete(self._key(user_id))
        except Exception as exc:  # noqa: BLE001
            log.warning("chat_history_clear_failed", error=str(exc), user_id=user_id)
