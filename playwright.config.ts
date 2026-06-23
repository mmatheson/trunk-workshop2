import { defineConfig } from "@playwright/test";

export default defineConfig({
  testDir: "tests/e2e",
  // IMPORTANT: no retries. Retries hide the real pass/fail signal that Trunk's
  // flake detection relies on — quarantine handles the failures instead.
  retries: 0,
  // Emit JUnit XML for Trunk to ingest, alongside the list reporter.
  reporter: [["list"], ["junit", { outputFile: "test-results/e2e-junit.xml" }]],
  use: { baseURL: "http://localhost:3000" },
  // Tests run against the production server, so `npm run build` must run first.
  webServer: {
    command: "npm run start",
    url: "http://localhost:3000",
    reuseExistingServer: !process.env.CI,
  },
});
