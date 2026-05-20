"""Tests for the intent classifier / router."""

from __future__ import annotations

import pytest

from src.router import classify, resolve_model


@pytest.mark.parametrize(
    "msg, expected_family, expected_intent",
    [
        ("Chào coach", "haiku", "greeting"),
        ("hi", "haiku", "greeting"),
        ("hello", "haiku", "greeting"),
        ("Ăn gì trước khi chạy?", "haiku", "nutrition"),
        ("Pace tempo là gì?", "haiku", "factual"),
        ("Đầu gối tôi đau sau khi chạy long run", "sonnet", "injury"),
        (
            "Tôi muốn giáo án half marathon 12 tuần với pace mục tiêu 5:00/km, hiện chạy 30km/tuần",
            "sonnet",
            "complex_plan",
        ),
        (
            "Giải thích chi tiết periodization Pfitzinger cho người mới chuyển từ 10k lên half "
            "marathon, kèm phân bổ tempo và threshold theo từng pha",
            "sonnet",
            "complex_plan",
        ),
    ],
)
def test_classify_intent(msg: str, expected_family: str, expected_intent: str) -> None:
    decision = classify(msg)
    assert decision.model_family == expected_family
    assert decision.intent == expected_intent


def test_resolve_model_haiku() -> None:
    decision = classify("Hi")
    model = resolve_model(decision, sonnet_id="sonnet-X", haiku_id="haiku-Y")
    assert model == "haiku-Y"


def test_resolve_model_sonnet_default() -> None:
    decision = classify(
        "Tôi muốn nâng VO2max từ 45 lên 50 trong 12 tuần, có nên thêm interval 4x800?"
    )
    model = resolve_model(decision, sonnet_id="sonnet-X", haiku_id="haiku-Y")
    assert model == "sonnet-X"


def test_complexity_increases_with_length() -> None:
    short = classify("Hi")
    long = classify(
        "Tôi cần giáo án 16 tuần full marathon, hiện chạy 50km/tuần, "
        "muốn target sub-4, có injury ITBS bên phải năm ngoái, "
        "có gym 2 buổi/tuần, muốn periodization Pfitzinger 18/55"
    )
    assert long.estimated_complexity > short.estimated_complexity
