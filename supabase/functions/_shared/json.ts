// JSON response helper.

import { corsHeaders } from "@shared/cors";

export function jsonResponse<T>(
  body: T,
  init: { status?: number; req?: Request; extraHeaders?: Record<string, string> } = {},
): Response {
  const origin = init.req?.headers.get("origin") ?? null;
  return new Response(JSON.stringify(body), {
    status: init.status ?? 200,
    headers: {
      ...corsHeaders({ origin }),
      "content-type": "application/json; charset=utf-8",
      ...(init.extraHeaders ?? {}),
    },
  });
}
