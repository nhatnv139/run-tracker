// Shared CORS helpers for RunVie Edge Functions.
// Allows app, web landing, and local dev origins.

export const ALLOWED_ORIGINS: readonly string[] = [
  "https://runvie.app",
  "https://www.runvie.app",
  "http://localhost:3000",
  "http://localhost:19006",
  "capacitor://localhost",
  "ionic://localhost",
];

export interface CorsOptions {
  readonly origin?: string | null;
  readonly methods?: string;
  readonly headers?: string;
  readonly allowCredentials?: boolean;
}

export function corsHeaders(options: CorsOptions = {}): Record<string, string> {
  const origin = options.origin ?? "*";
  const allowOrigin = origin === "*" || ALLOWED_ORIGINS.includes(origin) ? origin : "https://runvie.app";
  const headers: Record<string, string> = {
    "Access-Control-Allow-Origin": allowOrigin,
    "Access-Control-Allow-Methods": options.methods ?? "GET, POST, OPTIONS",
    "Access-Control-Allow-Headers":
      options.headers ?? "authorization, x-client-info, apikey, content-type, x-request-id",
    "Access-Control-Max-Age": "86400",
    "Vary": "Origin",
  };
  if (options.allowCredentials) {
    headers["Access-Control-Allow-Credentials"] = "true";
  }
  return headers;
}

export function handlePreflight(req: Request): Response | null {
  if (req.method !== "OPTIONS") return null;
  return new Response(null, {
    status: 204,
    headers: corsHeaders({ origin: req.headers.get("origin") }),
  });
}
