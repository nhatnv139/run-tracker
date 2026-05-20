"""FastAPI application entrypoint."""

from __future__ import annotations

from collections.abc import AsyncIterator
from contextlib import asynccontextmanager
from typing import TYPE_CHECKING

import sentry_sdk
import structlog
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from sentry_sdk.integrations.fastapi import FastApiIntegration
from sentry_sdk.integrations.starlette import StarletteIntegration

from src.api import chat as chat_api
from src.api import health as health_api
from src.api import post_run as post_run_api
from src.api import training_plan as training_plan_api
from src.config import Settings, get_settings
from src.logging_setup import configure_logging
from src.services.claude_client import ClaudeClient

if TYPE_CHECKING:
    from redis.asyncio import Redis

log = structlog.get_logger(__name__)


def _init_sentry(settings: Settings) -> None:
    if not settings.sentry_dsn:
        return
    sentry_sdk.init(
        dsn=settings.sentry_dsn,
        environment=settings.sentry_environment,
        traces_sample_rate=settings.sentry_traces_sample_rate,
        integrations=[
            FastApiIntegration(transaction_style="endpoint"),
            StarletteIntegration(transaction_style="endpoint"),
        ],
        send_default_pii=False,
    )
    log.info("sentry_initialized", env=settings.sentry_environment)


async def _init_redis(settings: Settings) -> "Redis | None":
    try:
        from redis.asyncio import Redis  # noqa: PLC0415

        redis = Redis.from_url(settings.redis_url, decode_responses=False)
        await redis.ping()
        log.info("redis_connected", url=settings.redis_url)
        return redis
    except Exception as exc:  # noqa: BLE001
        log.warning("redis_unavailable", error=str(exc))
        return None


@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncIterator[None]:
    settings = get_settings()
    configure_logging(settings)
    _init_sentry(settings)

    app.state.redis = await _init_redis(settings)
    app.state.claude = ClaudeClient(settings)

    log.info(
        "app_startup",
        env=settings.app_env,
        sonnet=settings.model_sonnet,
        haiku=settings.model_haiku,
        cache_enabled=settings.enable_cache,
    )

    try:
        yield
    finally:
        log.info("app_shutdown")
        try:
            if app.state.redis is not None:
                await app.state.redis.aclose()
        except Exception as exc:  # noqa: BLE001
            log.warning("redis_close_failed", error=str(exc))
        try:
            await app.state.claude.aclose()
        except Exception as exc:  # noqa: BLE001
            log.warning("claude_close_failed", error=str(exc))


def create_app() -> FastAPI:
    settings = get_settings()
    configure_logging(settings)

    app = FastAPI(
        title="RunVie AI Coach",
        version="0.1.0",
        description="AI Coach backend: chat, training plan generation, post-run summaries.",
        lifespan=lifespan,
        docs_url="/docs",
        redoc_url="/redoc",
    )

    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.cors_origins,
        allow_credentials=True,
        allow_methods=["GET", "POST", "OPTIONS"],
        allow_headers=["*"],
    )

    app.include_router(health_api.router)
    app.include_router(chat_api.router)
    app.include_router(training_plan_api.router)
    app.include_router(post_run_api.router)

    return app


app = create_app()
