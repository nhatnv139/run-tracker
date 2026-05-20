// k6 load profile for the leaderboard Edge Function (cached read path).
//
// Target: 10,000 req/min for 5 minutes against a hot cache.
// SLO: p95 under 100ms, HTTP failure rate below 0.1%.

import http from "k6/http";
import { check } from "k6";
import { Trend } from "k6/metrics";

export const options = {
  scenarios: {
    leaderboard: {
      executor: "constant-arrival-rate",
      rate: 10000,
      timeUnit: "1m",
      duration: "5m",
      preAllocatedVUs: 100,
      maxVUs: 300,
    },
  },
  thresholds: {
    http_req_failed: ["rate<0.001"],
    http_req_duration: ["p(95)<100", "p(99)<200"],
    leaderboard_latency: ["p(95)<100"],
  },
};

const leaderboardLatency = new Trend("leaderboard_latency", true);

const SUPABASE_URL = __ENV.SUPABASE_URL || "http://localhost:54321";
const ANON_KEY = __ENV.SUPABASE_ANON_KEY || "anon-key";

const SCOPES = ["weekly", "monthly", "all_time"];

export default function () {
  const scope = SCOPES[Math.floor(Math.random() * SCOPES.length)];
  const res = http.get(
    `${SUPABASE_URL}/functions/v1/leaderboard?scope=${scope}&limit=50`,
    {
      headers: {
        apikey: ANON_KEY,
      },
      tags: { endpoint: "leaderboard" },
    },
  );
  leaderboardLatency.add(res.timings.duration);
  check(res, {
    "status is 200": (r) => r.status === 200,
    "has entries": (r) => {
      try {
        const data = r.json();
        return Array.isArray(data.entries);
      } catch (_e) {
        return false;
      }
    },
  });
}
