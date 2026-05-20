// Verify Supabase JWT and extract user id.
// Uses the Supabase client `auth.getUser(jwt)` which validates signature + expiry
// against the project's JWT secret (no manual decoding required).

import { createClient, type SupabaseClient } from "supabase";
import { Errors } from "@shared/errors";

export interface AuthedUser {
  readonly id: string;
  readonly email: string | null;
  readonly jwt: string;
}

export function extractBearer(req: Request): string {
  const header = req.headers.get("authorization") ?? req.headers.get("Authorization");
  if (!header) throw Errors.unauthorized("missing authorization header");
  const [scheme, token] = header.split(" ");
  if (scheme?.toLowerCase() !== "bearer" || !token) {
    throw Errors.unauthorized("authorization header must be 'Bearer <jwt>'");
  }
  return token.trim();
}

export async function authenticate(req: Request): Promise<AuthedUser> {
  const jwt = extractBearer(req);
  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
  if (!supabaseUrl || !anonKey) {
    throw Errors.internal("supabase env not configured");
  }
  const client: SupabaseClient = createClient(supabaseUrl, anonKey, {
    auth: { persistSession: false, autoRefreshToken: false },
    global: { headers: { Authorization: `Bearer ${jwt}` } },
  });
  const { data, error } = await client.auth.getUser(jwt);
  if (error || !data.user) {
    throw Errors.unauthorized(error?.message ?? "invalid jwt");
  }
  return { id: data.user.id, email: data.user.email ?? null, jwt };
}

/** Throws 403 if caller is not the resource owner. */
export function assertSameUser(caller: AuthedUser, ownerId: string): void {
  if (caller.id !== ownerId) {
    throw Errors.forbidden("user does not own this resource");
  }
}

/** For internal service-to-service calls using the service role key. */
export function assertServiceRole(req: Request): void {
  const provided = req.headers.get("x-service-key") ?? req.headers.get("X-Service-Key");
  const expected = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!expected || !provided || provided !== expected) {
    throw Errors.forbidden("service-role key required");
  }
}
