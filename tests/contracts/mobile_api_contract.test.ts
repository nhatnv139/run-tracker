/**
 * Mobile API contract tests.
 *
 * These tests load both OpenAPI specs, derive JSON schemas for the response
 * bodies of selected endpoints, and validate fixture payloads (mirroring
 * what the Flutter client expects to deserialise) using ajv. The goal is to
 * fail CI whenever the schema in this repository drifts from the assumptions
 * baked into the mobile client.
 *
 * Run: pnpm jest
 */

import fs from "node:fs";
import path from "node:path";
import yaml from "js-yaml";
import Ajv from "ajv";
import addFormats from "ajv-formats";

type OpenApi = {
  components: { schemas: Record<string, unknown> };
};

function loadSpec(name: string): OpenApi {
  const raw = fs.readFileSync(path.join(__dirname, name), "utf8");
  return yaml.load(raw) as OpenApi;
}

function buildAjv(spec: OpenApi): Ajv {
  const ajv = new Ajv({ strict: false, allErrors: true });
  addFormats(ajv);
  for (const [name, schema] of Object.entries(spec.components.schemas)) {
    ajv.addSchema(schema as object, `#/components/schemas/${name}`);
  }
  return ajv;
}

describe("AI Coach contract", () => {
  const spec = loadSpec("ai-coach-openapi.yaml");
  const ajv = buildAjv(spec);

  test("ChatReply fixture validates", () => {
    const fixture = {
      reply: "Nice job on the run!",
      usage: { input_tokens: 12, output_tokens: 30 },
      request_id: "req_abc",
    };
    const validate = ajv.getSchema("#/components/schemas/ChatReply");
    expect(validate).toBeDefined();
    expect(validate!(fixture)).toBe(true);
  });

  test("ChatReply fixture rejects missing reply", () => {
    const fixture = { usage: { input_tokens: 1, output_tokens: 1 } };
    const validate = ajv.getSchema("#/components/schemas/ChatReply");
    expect(validate!(fixture)).toBe(false);
  });

  test("TrainingPlan fixture validates", () => {
    const fixture = {
      weeks: [
        {
          index: 1,
          sessions: [
            { day: "Mon", type: "easy", distance_km: 5 },
            { day: "Wed", type: "tempo", distance_km: 7 },
          ],
        },
      ],
    };
    const validate = ajv.getSchema("#/components/schemas/TrainingPlan");
    expect(validate!(fixture)).toBe(true);
  });
});

describe("Edge Functions contract", () => {
  const spec = loadSpec("edge-functions-openapi.yaml");
  const ajv = buildAjv(spec);

  test("ActivityInsertResult fixture validates", () => {
    const fixture = {
      activity_id: "11111111-2222-3333-4444-555555555555",
      badges_awarded: ["first_5k"],
      coins_earned: 25,
    };
    const validate = ajv.getSchema(
      "#/components/schemas/ActivityInsertResult",
    );
    expect(validate!(fixture)).toBe(true);
  });

  test("Leaderboard fixture validates", () => {
    const fixture = {
      scope: "weekly",
      entries: [
        {
          user_id: "11111111-2222-3333-4444-555555555555",
          display_name: "tester",
          distance_km: 42.0,
          rank: 1,
        },
      ],
    };
    const validate = ajv.getSchema("#/components/schemas/Leaderboard");
    expect(validate!(fixture)).toBe(true);
  });

  test("Voucher rejects missing voucher_code", () => {
    const fixture = { partner: "shopee" };
    const validate = ajv.getSchema("#/components/schemas/Voucher");
    expect(validate!(fixture)).toBe(false);
  });
});
