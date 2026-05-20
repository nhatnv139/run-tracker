// k6 load profile for the AI Coach chat endpoint.
//
// Stages:
//   2m ramp 10 -> 50 VUs
//   5m hold  50 VUs
//   3m ramp 50 -> 500 VUs
//   5m hold 500 VUs
//   2m ramp 500 -> 0
//
// SLO: p95 latency under 3000ms with HTTP failure rate below 1%.

import http from "k6/http";
import { check, sleep } from "k6";
import { Trend, Rate } from "k6/metrics";

export const options = {
  stages: [
    { duration: "2m", target: 50 },
    { duration: "5m", target: 50 },
    { duration: "3m", target: 500 },
    { duration: "5m", target: 500 },
    { duration: "2m", target: 0 },
  ],
  thresholds: {
    http_req_failed: ["rate<0.01"],
    http_req_duration: ["p(95)<3000"],
    chat_latency: ["p(95)<3000"],
  },
};

const chatLatency = new Trend("chat_latency", true);
const chatErrors = new Rate("chat_errors");

const BASE = __ENV.AI_COACH_URL || "http://localhost:8080";
const TOKEN = __ENV.LOAD_BEARER_TOKEN || "load-test-token";

const PROMPTS = [
  "How was my run today?",
  "What should I eat after a 10k?",
  "Give me a 4-week plan to break 50:00 on 10k.",
  "Why does my knee hurt after long runs?",
  "How do I recover from cramps?",
];

export default function () {
  const url = `${BASE}/v1/chat`;
  const body = JSON.stringify({
    message: PROMPTS[Math.floor(Math.random() * PROMPTS.length)],
  });
  const res = http.post(url, body, {
    headers: {
      Authorization: `Bearer ${TOKEN}`,
      "Content-Type": "application/json",
    },
    tags: { endpoint: "ai_chat" },
  });
  chatLatency.add(res.timings.duration);
  chatErrors.add(res.status >= 400);
  check(res, {
    "status is 200": (r) => r.status === 200,
    "has reply field": (r) => {
      try {
        return Boolean(r.json("reply"));
      } catch (_e) {
        return false;
      }
    },
  });
  sleep(Math.random() * 2 + 1);
}
