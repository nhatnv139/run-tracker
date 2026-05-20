// k6 load profile for sync-activity Edge Function.
//
// Target: 1000 activities/min sustained for 10 minutes.
// With ~3s sleep per iteration we need roughly 50 VUs to reach 1000/min.
// SLO: p99 latency under 500ms and HTTP failure rate below 0.5%.

import http from "k6/http";
import { check, sleep } from "k6";
import { Counter, Trend } from "k6/metrics";

export const options = {
  scenarios: {
    sync: {
      executor: "constant-arrival-rate",
      rate: 1000,
      timeUnit: "1m",
      duration: "10m",
      preAllocatedVUs: 50,
      maxVUs: 200,
    },
  },
  thresholds: {
    http_req_failed: ["rate<0.005"],
    http_req_duration: ["p(99)<500", "p(95)<300"],
    sync_latency: ["p(99)<500"],
  },
};

const syncCount = new Counter("sync_activities_total");
const syncLatency = new Trend("sync_latency", true);

const SUPABASE_URL = __ENV.SUPABASE_URL || "http://localhost:54321";
const ANON_KEY = __ENV.SUPABASE_ANON_KEY || "anon-key";
const USER_TOKEN = __ENV.LOAD_USER_TOKEN || "user-token";

export default function () {
  const url = `${SUPABASE_URL}/functions/v1/sync-activity`;
  const payload = JSON.stringify({
    distance_km: Math.random() * 10,
    duration_s: Math.floor(Math.random() * 3600) + 600,
    started_at: new Date().toISOString(),
    polyline: "abcdef".repeat(20),
  });
  const res = http.post(url, payload, {
    headers: {
      apikey: ANON_KEY,
      Authorization: `Bearer ${USER_TOKEN}`,
      "Content-Type": "application/json",
    },
    tags: { endpoint: "sync_activity" },
  });
  syncCount.add(1);
  syncLatency.add(res.timings.duration);
  check(res, {
    "status is 2xx": (r) => r.status >= 200 && r.status < 300,
  });
  sleep(0.2);
}
