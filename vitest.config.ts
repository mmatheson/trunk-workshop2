import { fileURLToPath } from "node:url";
import { defineConfig } from "vitest/config";

export default defineConfig({
  resolve: {
    // Mirror the tsconfig "@/*" path alias so tests can import app/lib code.
    alias: {
      "@": fileURLToPath(new URL(".", import.meta.url)),
    },
  },
  test: {
    // Only run the unit suite here; Playwright owns tests/e2e.
    include: ["tests/unit/**/*.test.ts"],
    // Emit JUnit XML for Trunk to ingest, alongside the default console reporter.
    reporters: ["default", ["junit", { outputFile: "./test-results/unit-junit.xml" }]],
  },
});
