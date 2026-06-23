import { test, expect } from "vitest";
import { formatCurrency } from "@/lib/money";

test("formats whole dollars", () => {
  expect(formatCurrency(2500)).toBe("$25.00");
});

test("formats cents", () => {
  expect(formatCurrency(1299)).toBe("$12.99");
});

test("formats zero", () => {
  expect(formatCurrency(0)).toBe("$0.00");
});
