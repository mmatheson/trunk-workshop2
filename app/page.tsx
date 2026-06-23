import Link from "next/link";

export default function HomePage() {
  return (
    <main style={{ fontFamily: "system-ui, sans-serif", padding: "2rem" }}>
      <h1>Trunk Workshop Store</h1>
      <p>A tiny demo app for the Trunk Merge Queue + Flaky Tests workshop.</p>
      <nav>
        <Link href="/cart" data-testid="cart-link">
          View cart
        </Link>
      </nav>
    </main>
  );
}
