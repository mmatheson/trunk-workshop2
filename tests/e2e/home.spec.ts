import { test, expect } from "@playwright/test";

test("home page renders the store heading", async ({ page }) => {
  await page.goto("/");
  await expect(page.getByRole("heading", { name: "Trunk Workshop Store" })).toBeVisible();
});

test("home page navigates to the cart", async ({ page }) => {
  await page.goto("/");
  await page.getByTestId("cart-link").click();
  await expect(page).toHaveURL(/\/cart$/);
  await expect(page.getByRole("heading", { name: "Your Cart" })).toBeVisible();
});
