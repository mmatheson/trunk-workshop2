import { cartTotal, type CartItem } from "@/lib/cart";
import { formatCurrency } from "@/lib/money";

const items: CartItem[] = [
  { name: "Trunk T-shirt", priceCents: 2500, qty: 2 },
  { name: "Sticker pack", priceCents: 500, qty: 1 },
  { name: "Coffee mug", priceCents: 1200, qty: 3 },
];

export default function CartPage() {
  return (
    <main style={{ fontFamily: "system-ui, sans-serif", padding: "2rem" }}>
      <h1>Your Cart</h1>
      <ul>
        {items.map((item) => (
          <li key={item.name}>
            {item.name} × {item.qty} — {formatCurrency(item.priceCents * item.qty)}
          </li>
        ))}
      </ul>
      <p data-testid="cart-total">Total: {formatCurrency(cartTotal(items))}</p>
    </main>
  );
}
