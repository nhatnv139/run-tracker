import { createClient, type SupabaseClient } from "@supabase/supabase-js";

let cached: SupabaseClient | null = null;

export function getSupabase(): SupabaseClient | null {
  if (cached) return cached;

  const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const key = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;

  if (!url || !key || url.includes("your-project") || key.includes("your-anon-key")) {
    return null;
  }

  cached = createClient(url, key, {
    auth: { persistSession: false },
  });
  return cached;
}

export type WaitlistEntry = {
  email: string;
  user_type: "beginner" | "walker" | "runner" | "trainer";
  source?: string;
};

export async function submitWaitlist(entry: WaitlistEntry) {
  const supabase = getSupabase();

  if (!supabase) {
    // Dev/demo fallback: simulate latency, succeed.
    await new Promise((r) => setTimeout(r, 600));
    return { ok: true as const, demo: true as const };
  }

  const { error } = await supabase.from("waitlist").insert({
    email: entry.email,
    user_type: entry.user_type,
    source: entry.source ?? "landing",
    created_at: new Date().toISOString(),
  });

  if (error) {
    return { ok: false as const, error: error.message };
  }
  return { ok: true as const, demo: false as const };
}
