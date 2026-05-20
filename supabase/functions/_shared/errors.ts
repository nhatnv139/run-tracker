// Typed error responses for RunVie Edge Functions.

import { corsHeaders } from "@shared/cors";

export type ErrorCode =
  | "unauthorized"
  | "forbidden"
  | "bad_request"
  | "not_found"
  | "conflict"
  | "rate_limited"
  | "upstream_error"
  | "internal_error";

export interface ErrorBody {
  readonly error: ErrorCode;
  readonly message: string;
  readonly details?: unknown;
}

export class AppError extends Error {
  readonly code: ErrorCode;
  readonly status: number;
  readonly details?: unknown;

  constructor(code: ErrorCode, message: string, status: number, details?: unknown) {
    super(message);
    this.code = code;
    this.status = status;
    this.details = details;
  }
}

export const Errors = {
  unauthorized: (message = "missing or invalid jwt") =>
    new AppError("unauthorized", message, 401),
  forbidden: (message = "forbidden") => new AppError("forbidden", message, 403),
  badRequest: (message: string, details?: unknown) =>
    new AppError("bad_request", message, 400, details),
  notFound: (message = "not found") => new AppError("not_found", message, 404),
  conflict: (message: string, details?: unknown) =>
    new AppError("conflict", message, 409, details),
  rateLimited: (message = "rate limited", details?: unknown) =>
    new AppError("rate_limited", message, 429, details),
  upstream: (message: string, details?: unknown) =>
    new AppError("upstream_error", message, 502, details),
  internal: (message = "internal error", details?: unknown) =>
    new AppError("internal_error", message, 500, details),
} as const;

export function errorResponse(err: unknown, req?: Request): Response {
  const origin = req?.headers.get("origin") ?? null;
  const headers: Record<string, string> = {
    ...corsHeaders({ origin }),
    "content-type": "application/json",
  };
  if (err instanceof AppError) {
    const body: ErrorBody = { error: err.code, message: err.message, details: err.details };
    return new Response(JSON.stringify(body), { status: err.status, headers });
  }
  console.error("unhandled error", err);
  const message = err instanceof Error ? err.message : "internal error";
  const body: ErrorBody = { error: "internal_error", message };
  return new Response(JSON.stringify(body), { status: 500, headers });
}
