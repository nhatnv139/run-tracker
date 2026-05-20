// Deno integration tests for redeem-coin.
// Covers happy-path redemption (low-value, no OTP) and insufficient-balance
// error. The supabase client is replaced with an in-memory fake.

import { assertEquals } from "std/testing/asserts.ts";
import { __setServiceClientForTesting } from "@shared/supabase-client";
import { redeemCoinHandler } from "./index.ts";

interface RowSet {
  readonly id?: string;
  // deno-lint-ignore no-explicit-any
  readonly [key: string]: any;
}

class FakeQuery {
  // deno-lint-ignore no-explicit-any
  private filters: Record<string, any> = {};
  // deno-lint-ignore no-explicit-any
  constructor(private rows: RowSet[], private order: "asc" | "desc" = "asc") {}
  // deno-lint-ignore no-explicit-any
  eq(col: string, val: any): this {
    this.filters[col] = val;
    return this;
  }
  order(_col: string, _opts: unknown): this {
    return this;
  }
  limit(_n: number): this {
    return this;
  }
  maybeSingle(): Promise<{ data: RowSet | null; error: null }> {
    const match = this.rows.find((r) =>
      Object.entries(this.filters).every(([k, v]) => r[k] === v)
    ) ?? null;
    return Promise.resolve({ data: match, error: null });
  }
  single(): Promise<{ data: RowSet | null; error: null }> {
    return this.maybeSingle();
  }
}

interface FakeTable {
  readonly rows: RowSet[];
}

function buildClient(tables: Record<string, FakeTable>): unknown {
  return {
    from(name: string) {
      const tbl = tables[name] ?? { rows: [] };
      return {
        select: (_cols: string) => new FakeQuery(tbl.rows),
        insert: (row: RowSet) => {
          const stored = { ...row, id: `gen-${name}-${tbl.rows.length}` };
          tbl.rows.push(stored);
          return {
            select: (_c: string) => ({
              single: () => Promise.resolve({ data: stored, error: null }),
            }),
          };
        },
        update: (_patch: RowSet) => ({
          eq: (_c: string, _v: unknown) => Promise.resolve({ error: null }),
        }),
      };
    },
    rpc: (_name: string, _args: unknown) =>
      Promise.resolve({ data: null, error: { message: "function does not exist" } }),
    auth: {
      getUser: (_jwt: string) =>
        Promise.resolve({
          data: { user: { id: "user-1", email: "t@runvie.app" } },
          error: null,
        }),
    },
  };
}

Deno.env.set("SUPABASE_URL", "https://test.supabase.co");
Deno.env.set("SUPABASE_SERVICE_ROLE_KEY", "service-role-test");
Deno.env.set("SUPABASE_ANON_KEY", "anon-test");
Deno.env.set("PARTNER_API_KEY", ""); // placeholder mode

Deno.test("redeem-coin: happy path low-value voucher", async () => {
  const tables: Record<string, FakeTable> = {
    vouchers: {
      rows: [{
        id: "v-1",
        partner_code: "TEST10",
        title: "10k off",
        cost_coins: 100,
        value_vnd: 10000,
        stock: 5,
        is_active: true,
      }],
    },
    run_coins: { rows: [{ user_id: "user-1", balance: 500 }] },
    voucher_redemptions: { rows: [] },
    coin_transactions: { rows: [] },
  };
  // deno-lint-ignore no-explicit-any
  __setServiceClientForTesting(buildClient(tables) as any);

  const req = new Request("https://x/redeem-coin", {
    method: "POST",
    headers: { "content-type": "application/json", authorization: "Bearer test" },
    body: JSON.stringify({ voucher_id: "00000000-0000-0000-0000-000000000001" }),
  });
  // Override voucher id mapping (schema requires uuid; rows keyed by id field).
  tables.vouchers.rows[0].id = "00000000-0000-0000-0000-000000000001";

  const resp = await redeemCoinHandler(req);
  assertEquals(resp.status, 201);
  const json = (await resp.json()) as { new_balance: number; code: string };
  assertEquals(json.new_balance, 400);
  assertEquals(typeof json.code, "string");

  __setServiceClientForTesting(null);
});

Deno.test("redeem-coin: insufficient balance returns 409", async () => {
  const tables: Record<string, FakeTable> = {
    vouchers: {
      rows: [{
        id: "00000000-0000-0000-0000-000000000002",
        partner_code: "BIG",
        title: "Big",
        cost_coins: 1000,
        value_vnd: 50000,
        stock: 5,
        is_active: true,
      }],
    },
    run_coins: { rows: [{ user_id: "user-1", balance: 100 }] },
  };
  // deno-lint-ignore no-explicit-any
  __setServiceClientForTesting(buildClient(tables) as any);

  const req = new Request("https://x/redeem-coin", {
    method: "POST",
    headers: { "content-type": "application/json", authorization: "Bearer test" },
    body: JSON.stringify({ voucher_id: "00000000-0000-0000-0000-000000000002" }),
  });
  try {
    await redeemCoinHandler(req);
    throw new Error("expected conflict error");
  } catch (e) {
    const err = e as { status?: number };
    assertEquals(err.status, 409);
  }

  __setServiceClientForTesting(null);
});
