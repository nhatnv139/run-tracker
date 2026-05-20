// Deno integration tests for award-badges.
// Mocks the service client + sets env so the handler can run without a real
// Supabase backend.

import { assertEquals } from "std/testing/asserts.ts";
import { __setServiceClientForTesting } from "@shared/supabase-client";
import { awardBadgesHandler } from "./index.ts";

interface RpcCall {
  readonly name: string;
  readonly args: Record<string, unknown>;
}

interface FakeUser {
  readonly id: string;
  readonly email: string;
}

interface AuthGetUserResult {
  readonly data: { user: FakeUser | null };
  readonly error: { message: string } | null;
}

function buildClient(rpcResult: unknown, calls: RpcCall[]): unknown {
  return {
    rpc: (name: string, args: Record<string, unknown>) => {
      calls.push({ name, args });
      return Promise.resolve({ data: rpcResult, error: null });
    },
    auth: {
      getUser: (_jwt: string): Promise<AuthGetUserResult> =>
        Promise.resolve({
          data: { user: { id: "11111111-1111-1111-1111-111111111111", email: "t@runvie.app" } },
          error: null,
        }),
    },
  };
}

Deno.env.set("SUPABASE_URL", "https://test.supabase.co");
Deno.env.set("SUPABASE_SERVICE_ROLE_KEY", "service-role-test");
Deno.env.set("SUPABASE_ANON_KEY", "anon-test");

Deno.test("award-badges: requires POST", async () => {
  const req = new Request("https://x/award-badges", { method: "GET" });
  const resp = await awardBadgesHandler(req).catch((e) => e);
  // handler throws on bad method; outer serve() converts to error response.
  // We accept either thrown error or a non-200 Response.
  if (resp instanceof Response) {
    assertEquals(resp.status >= 400, true);
  }
});

Deno.test("award-badges: service-role path returns newly_earned", async () => {
  const calls: RpcCall[] = [];
  const fake = buildClient({ newly_earned: ["first_km", "five_k_finisher"], count: 2 }, calls);
  // deno-lint-ignore no-explicit-any
  __setServiceClientForTesting(fake as any);

  const req = new Request("https://x/award-badges", {
    method: "POST",
    headers: {
      "content-type": "application/json",
      "x-service-key": "service-role-test",
    },
    body: JSON.stringify({
      user_id: "11111111-1111-1111-1111-111111111111",
      activity_id: "22222222-2222-2222-2222-222222222222",
    }),
  });

  const resp = await awardBadgesHandler(req);
  assertEquals(resp.status, 200);
  const json = (await resp.json()) as { count: number; newly_earned: string[] };
  assertEquals(json.count, 2);
  assertEquals(json.newly_earned, ["first_km", "five_k_finisher"]);
  assertEquals(calls.length, 1);
  assertEquals(calls[0].name, "award_badges_for_user");

  __setServiceClientForTesting(null);
});
