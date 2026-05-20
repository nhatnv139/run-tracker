// Service-role client used by Edge Functions to bypass RLS where needed.
// Never expose the service role key to the client.

import { createClient, type SupabaseClient } from "supabase";
import { Errors } from "@shared/errors";

let cachedService: SupabaseClient | null = null;

export function getServiceClient(): SupabaseClient {
  if (cachedService) return cachedService;
  const url = Deno.env.get("SUPABASE_URL");
  const key = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!url || !key) throw Errors.internal("service-role env not configured");
  cachedService = createClient(url, key, {
    auth: { persistSession: false, autoRefreshToken: false },
    db: { schema: "public" },
  });
  return cachedService;
}

/** Returns a client scoped to the caller's JWT (respects RLS). */
export function getUserClient(jwt: string): SupabaseClient {
  const url = Deno.env.get("SUPABASE_URL");
  const anon = Deno.env.get("SUPABASE_ANON_KEY");
  if (!url || !anon) throw Errors.internal("supabase env not configured");
  return createClient(url, anon, {
    auth: { persistSession: false, autoRefreshToken: false },
    global: { headers: { Authorization: `Bearer ${jwt}` } },
  });
}

/** Test seam: lets tests inject a mock service client. */
export function __setServiceClientForTesting(client: SupabaseClient | null): void {
  cachedService = client;
}
