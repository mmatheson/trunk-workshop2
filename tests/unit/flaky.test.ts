// SEEDED FLAKY TEST for the Trunk workshop. Fails ~30% of the time on purpose
// so the Flaky Tests dashboard has a real signal to detect and quarantine.
// It asserts nothing about the app — it is isolated and never breaks real flows.
import { test, expect } from "vitest";

test("flaky: intermittent timing assertion", () => {
  const roll = Math.random();
  expect(roll).toBeLessThan(0.7); // ~30% failure rate
});
