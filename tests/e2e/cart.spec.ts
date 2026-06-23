import { test, expect } from "@playwright/test";

test("cart page shows a computed total", async ({ page }) => {
  await page.goto("/cart");
  // Items: 2×$25.00 + 1×$5.00 + 3×$12.00 = $91.00
  await expect(page.getByTestId("cart-total")).toHaveText("Total: $91.00");
});
