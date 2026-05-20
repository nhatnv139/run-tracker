"""Tests for cost computation."""

from __future__ import annotations

import math

import pytest

from src.services.cost_tracker import PRICING, compute_cost


def test_sonnet_basic_cost() -> None:
    cost = compute_cost(
        model="claude-sonnet-4-7",
        input_tokens=1_000_000,
        output_tokens=1_000_000,
    )
    assert math.isclose(cost.input_cost_usd, 3.0, rel_tol=1e-6)
    assert math.isclose(cost.output_cost_usd, 15.0, rel_tol=1e-6)
    assert math.isclose(cost.total_usd, 18.0, rel_tol=1e-6)


def test_haiku_basic_cost() -> None:
    cost = compute_cost(
        model="claude-haiku-4-5-20251001",
        input_tokens=1_000_000,
        output_tokens=1_000_000,
    )
    assert math.isclose(cost.input_cost_usd, PRICING["haiku"]["input"], rel_tol=1e-6)
    assert math.isclose(cost.output_cost_usd, PRICING["haiku"]["output"], rel_tol=1e-6)


def test_cache_read_is_cheap() -> None:
    """Cache reads must be ~10x cheaper than fresh input for Sonnet."""
    cost = compute_cost(
        model="claude-sonnet-4-7",
        input_tokens=0,
        output_tokens=0,
        cached_read_tokens=1_000_000,
    )
    assert math.isclose(cost.cache_read_cost_usd, 0.30, rel_tol=1e-6)
    assert math.isclose(cost.total_usd, 0.30, rel_tol=1e-6)


def test_cache_hit_rate_calculation() -> None:
    cost = compute_cost(
        model="claude-sonnet-4-7",
        input_tokens=100,
        output_tokens=200,
        cached_read_tokens=900,
    )
    # cached / (input + cached + creation) = 900 / 1000 = 0.9
    assert math.isclose(cost.cache_hit_rate, 0.9, rel_tol=1e-6)


def test_cache_hit_rate_no_input() -> None:
    cost = compute_cost(
        model="claude-haiku-4-5-20251001",
        input_tokens=0,
        output_tokens=10,
        cached_read_tokens=0,
    )
    assert cost.cache_hit_rate == 0.0


def test_zero_tokens_costs_zero() -> None:
    cost = compute_cost(model="claude-sonnet-4-7", input_tokens=0, output_tokens=0)
    assert cost.total_usd == 0.0


@pytest.mark.parametrize("model", ["claude-sonnet-4-7", "claude-haiku-4-5-20251001"])
def test_totals_sum_components(model: str) -> None:
    cost = compute_cost(
        model=model,
        input_tokens=1234,
        output_tokens=567,
        cached_read_tokens=8910,
        cache_creation_tokens=42,
    )
    expected = (
        cost.input_cost_usd
        + cost.output_cost_usd
        + cost.cache_read_cost_usd
        + cost.cache_write_cost_usd
    )
    assert math.isclose(cost.total_usd, round(expected, 8), abs_tol=1e-8)
