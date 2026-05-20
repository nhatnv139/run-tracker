"""Application settings loaded from environment variables."""

from __future__ import annotations

from functools import lru_cache
from typing import Literal

from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Strongly-typed settings, populated from `.env` or process env."""

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
        extra="ignore",
    )

    # Anthropic
    anthropic_api_key: str = Field(default="", description="Anthropic API key (required at runtime).")
    model_sonnet: str = Field(default="claude-sonnet-4-7")
    model_haiku: str = Field(default="claude-haiku-4-5-20251001")
    max_tokens_default: int = Field(default=1024, ge=64, le=8192)
    enable_cache: bool = Field(default=True)

    # Redis
    redis_url: str = Field(default="redis://localhost:6379/0")
    redis_chat_ttl_seconds: int = Field(default=86_400)
    redis_chat_window: int = Field(default=20)

    # Sentry
    sentry_dsn: str | None = Field(default=None)
    sentry_traces_sample_rate: float = Field(default=0.1, ge=0.0, le=1.0)
    sentry_environment: str = Field(default="development")

    # App
    app_env: Literal["development", "staging", "production"] = Field(default="development")
    log_level: Literal["DEBUG", "INFO", "WARNING", "ERROR"] = Field(default="INFO")
    cors_origins: list[str] = Field(default_factory=lambda: ["*"])

    # Rate limit (per user_id)
    rate_limit_free_per_month: int = Field(default=20)
    rate_limit_paid_per_day: int = Field(default=100)

    # Supabase auth (for JWT verification)
    supabase_url: str | None = Field(default=None)
    supabase_jwks_url: str | None = Field(default=None)
    supabase_jwt_audience: str = Field(default="authenticated")
    auth_required: bool = Field(default=False)


@lru_cache(maxsize=1)
def get_settings() -> Settings:
    """Return cached settings instance."""
    return Settings()


def require_anthropic_key(settings: Settings) -> str:
    """Return the API key or raise a clear error if missing."""
    if not settings.anthropic_api_key:
        raise ValueError(
            "ANTHROPIC_API_KEY is not configured. "
            "Set it in your .env file or environment before calling Claude APIs."
        )
    return settings.anthropic_api_key
