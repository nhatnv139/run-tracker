// Playwright E2E for the RunVie landing page.
//
// Pre-conditions:
//   - LANDING_URL points to a running landing dev server (defaults to localhost:3000).
//   - SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY are set in the environment so that
//     we can verify the row was actually written to the `waitlist` table.
//
// Expected pass: the test submits an email, sees the "thank you" UI, and finds
// exactly one matching row in Supabase within 5 seconds.

import { test, expect, request } from "@playwright/test";

const LANDING_URL = process.env.LANDING_URL ?? "http://localhost:3000";
const SUPABASE_URL = process.env.SUPABASE_URL ?? "";
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY ?? "";

function uniqueEmail(): string {
  const stamp = Date.now();
  return `e2e+${stamp}@runvie.test`;
}

test.describe("landing waitlist", () => {
  test("submits the form and writes a Supabase row", async ({ page }) => {
    test.skip(
      !SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY,
      "Supabase credentials not configured for this run",
    );

    const email = uniqueEmail();

    await page.goto(LANDING_URL);
    await page.getByTestId("waitlist-email").fill(email);
    await page.getByTestId("waitlist-submit").click();

    await expect(page.getByTestId("waitlist-success")).toBeVisible({
      timeout: 5_000,
    });

    const api = await request.newContext({
      baseURL: SUPABASE_URL,
      extraHTTPHeaders: {
        apikey: SUPABASE_SERVICE_ROLE_KEY,
        Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
      },
    });

    const res = await api.get(
      `/rest/v1/waitlist?email=eq.${encodeURIComponent(email)}&select=*`,
    );
    expect(res.ok()).toBeTruthy();
    const rows = (await res.json()) as unknown[];
    expect(rows.length).toBe(1);
  });
});
