"""Pydantic v2 schemas for requests / responses."""

from __future__ import annotations

from datetime import date
from typing import Literal

from pydantic import BaseModel, ConfigDict, Field, field_validator

Language = Literal["vi", "en"]
Gender = Literal["male", "female", "other"]
Goal = Literal["lose_weight", "general_health", "race_5k", "race_10k", "race_half", "race_full", "habit"]
Level = Literal["beginner", "intermediate", "advanced", "elite"]
RaceDistance = Literal["5k", "10k", "half", "full"]
WorkoutType = Literal["easy", "long", "tempo", "interval", "recovery", "race", "rest", "cross"]
Role = Literal["user", "assistant"]


class UserProfile(BaseModel):
    """Runner profile used to personalize every prompt."""

    model_config = ConfigDict(extra="forbid")

    id: str
    name: str
    age: int = Field(ge=10, le=100)
    gender: Gender
    weight_kg: float = Field(gt=20, lt=250)
    height_cm: float = Field(gt=100, lt=230)
    goal: Goal
    level: Level
    max_hr: int | None = Field(default=None, ge=120, le=230)
    vo2max: float | None = Field(default=None, ge=15, le=90)
    weekly_km: float = Field(default=0, ge=0, le=300)
    recent_prs: dict[str, str] = Field(default_factory=dict)
    injuries: list[str] = Field(default_factory=list)


class ChatMessage(BaseModel):
    model_config = ConfigDict(extra="forbid")

    role: Role
    content: str = Field(min_length=1, max_length=8000)


class ChatRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")

    user_profile: UserProfile
    history: list[ChatMessage] = Field(default_factory=list, max_length=40)
    message: str = Field(min_length=1, max_length=4000)
    language: Language = "vi"


class TokenUsage(BaseModel):
    input_tokens: int = 0
    output_tokens: int = 0
    cached_tokens: int = 0
    cache_creation_tokens: int = 0


class ChatResponse(BaseModel):
    message: str
    model_used: str
    cached_tokens: int
    input_tokens: int
    output_tokens: int
    cost_usd: float
    intent: str | None = None


class TrainingPlanRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")

    user_profile: UserProfile
    race_distance: RaceDistance
    weeks: int = Field(ge=4, le=24)
    target_pace_s_per_km: int | None = Field(default=None, ge=180, le=900)
    start_date: date
    language: Language = "vi"

    @field_validator("start_date")
    @classmethod
    def _no_past(cls, v: date) -> date:
        return v


class WorkoutItem(BaseModel):
    day: int = Field(ge=1, description="Day index within the plan, 1 = start_date.")
    type: WorkoutType
    distance_m: int = Field(ge=0)
    duration_s: int = Field(ge=0)
    pace_target: str
    description_vi: str


class TrainingPlanResponse(BaseModel):
    workouts: list[WorkoutItem]
    summary_vi: str
    model_used: str
    cost_usd: float


class ActivitySplit(BaseModel):
    km: int = Field(ge=1)
    duration_s: int = Field(ge=0)
    hr_avg: int | None = Field(default=None, ge=40, le=230)


class Activity(BaseModel):
    model_config = ConfigDict(extra="forbid")

    distance_m: int = Field(ge=100)
    duration_s: int = Field(ge=60)
    pace_s_per_km: int = Field(ge=180, le=1200)
    hr_avg: int | None = Field(default=None, ge=40, le=230)
    elevation_gain_m: float = Field(default=0, ge=0)
    splits: list[ActivitySplit] = Field(default_factory=list)


class PostRunRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")

    activity: Activity
    user_profile: UserProfile
    language: Language = "vi"


class PostRunResponse(BaseModel):
    title_vi: str
    summary_vi: str
    achievements: list[str]
    tips: list[str]
    model_used: str
    cost_usd: float


class HealthResponse(BaseModel):
    status: Literal["ok", "degraded"]
    redis: bool
    anthropic_configured: bool


class MetricsResponse(BaseModel):
    cache_hit_rate: float
    avg_cost_per_request_usd: float
    total_requests: int
    total_cached_tokens: int
    total_input_tokens: int
