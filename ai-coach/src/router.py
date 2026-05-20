"""Smart model routing: cheap heuristic + optional Haiku zero-shot classifier."""

from __future__ import annotations

import re
from dataclasses import dataclass
from typing import Literal

Intent = Literal[
    "greeting",
    "factual",
    "training",
    "nutrition",
    "injury",
    "complex_plan",
    "small_talk",
    "unknown",
]


_GREETING_PATTERNS = [
    r"\b(hi|hello|hey|chao|chào|xin chào|hola)\b",
    r"^(hi|chào|chao|hello|hey)[\s!.?]*$",
]

_NUTRITION_PATTERNS = [
    r"\b(ăn|uống|dinh dưỡng|protein|carb|nước|chuối|cơm|phở|cà phê|caffeine|gel|electrolyte)\b",
    r"\b(eat|drink|nutrition|fuel|hydration|carbs?|calorie)\b",
]

_INJURY_PATTERNS = [
    r"\b(đau|chấn thương|injury|knee|shin|ankle|gối|ống quyển|gân|chuột rút|cramp)\b",
    r"\b(itbs|plantar|tendon|hurt|pain|ache)\b",
]

_TRAINING_PATTERNS = [
    r"\b(tempo|interval|long run|easy run|recovery|vo2|threshold|zone\s?[1-5])\b",
    r"\b(giáo án|kế hoạch|tập|chạy)\b",
]

_COMPLEX_PLAN_PATTERNS = [
    r"\b(giáo án|kế hoạch|plan|schedule)\s+(\d+\s*(tuần|weeks?|month))",
    r"\b(half|full|marathon|10k|5k|race)\b.*\b(\d+\s*(tuần|weeks?))",
    r"\b(periodization|pfitzinger|daniels|hansons|80/20)\b",
]


def _matches_any(text: str, patterns: list[str]) -> bool:
    return any(re.search(p, text, flags=re.IGNORECASE) for p in patterns)


@dataclass(slots=True)
class RouteDecision:
    intent: Intent
    model_family: Literal["haiku", "sonnet"]
    reason: str
    estimated_complexity: int  # 1=trivial, 5=complex


def classify(message: str, *, history_len: int = 0) -> RouteDecision:
    """Heuristic classifier — fast, deterministic, zero API cost."""
    text = message.strip()
    n_chars = len(text)
    n_words = len(text.split())

    # Greeting / very short small talk -> Haiku
    if n_words <= 3 and _matches_any(text, _GREETING_PATTERNS):
        return RouteDecision(
            intent="greeting",
            model_family="haiku",
            reason="short greeting",
            estimated_complexity=1,
        )

    if n_chars < 25 and "?" not in text and history_len == 0:
        return RouteDecision(
            intent="small_talk",
            model_family="haiku",
            reason="very short opener",
            estimated_complexity=1,
        )

    # Complex multi-week plan -> Sonnet
    if _matches_any(text, _COMPLEX_PLAN_PATTERNS) or n_words > 80:
        return RouteDecision(
            intent="complex_plan",
            model_family="sonnet",
            reason="long-form planning request",
            estimated_complexity=5,
        )

    # Injury talk: route to Sonnet for safety/nuance
    if _matches_any(text, _INJURY_PATTERNS):
        return RouteDecision(
            intent="injury",
            model_family="sonnet",
            reason="injury context needs careful reasoning",
            estimated_complexity=4,
        )

    # Training methodology questions -> Sonnet (need depth)
    if _matches_any(text, _TRAINING_PATTERNS) and n_words > 8:
        return RouteDecision(
            intent="training",
            model_family="sonnet",
            reason="training methodology depth",
            estimated_complexity=4,
        )

    # Nutrition factual: Haiku is enough for common Q&A
    if _matches_any(text, _NUTRITION_PATTERNS):
        if n_words <= 20:
            return RouteDecision(
                intent="nutrition",
                model_family="haiku",
                reason="common nutrition Q",
                estimated_complexity=2,
            )
        return RouteDecision(
            intent="nutrition",
            model_family="sonnet",
            reason="detailed nutrition plan",
            estimated_complexity=3,
        )

    # Short factual question -> Haiku
    if n_words <= 15 and "?" in text:
        return RouteDecision(
            intent="factual",
            model_family="haiku",
            reason="short factual question",
            estimated_complexity=2,
        )

    # Default: medium complexity -> Sonnet
    return RouteDecision(
        intent="unknown",
        model_family="sonnet",
        reason="default to Sonnet for quality",
        estimated_complexity=3,
    )


def resolve_model(decision: RouteDecision, *, sonnet_id: str, haiku_id: str) -> str:
    return haiku_id if decision.model_family == "haiku" else sonnet_id
