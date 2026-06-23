import { test, expect } from "vitest";
import { cartTotal, type CartItem } from "@/lib/cart";

test("totals an empty cart to zero", () => {
  expect(cartTotal([])).toBe(0);
});

test("totals a single line item with quantity", () => {
  const items: CartItem[] = [{ name: "Mug", priceCents: 1200, qty: 3 }];
  expect(cartTotal(items)).toBe(3600);
});

test("totals multiple line items", () => {
  const items: CartItem[] = [
    { name: "T-shirt", priceCents: 2500, qty: 2 },
    { name: "Stickers", priceCents: 500, qty: 1 },
  ];
  expect(cartTotal(items)).toBe(5500);
});
