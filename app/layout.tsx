import type { ReactNode } from "react";

export const metadata = {
  title: "Trunk Workshop",
  description: "Demo app for the Trunk PlatformCon workshop.",
};

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
