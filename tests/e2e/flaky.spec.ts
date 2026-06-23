// SEEDED FLAKY TEST for the Trunk workshop. Fails ~30% of the time on purpose
// so the e2e suite also produces a flaky signal for detection + quarantine.
// It loads the home page but its assertion is an isolated random roll — it
// never depends on or breaks real app behavior.
import { test, expect } from "@playwright/test";

test("flaky: intermittent post-load assertion", async ({ page }) => {
  await page.goto("/");
  await expect(page.getByRole("heading", { name: "Trunk Workshop Store" })).toBeVisible();
  const roll = Math.random();
  expect(roll).toBeLessThan(0.7); // ~30% failure rate
});
