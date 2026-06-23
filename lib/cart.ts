export interface CartItem {
  name: string;
  priceCents: number;
  qty: number;
}

/** Sum the line items in a cart, returning the total in cents. */
export function cartTotal(items: CartItem[]): number {
  return items.reduce((total, item) => total + item.priceCents * item.qty, 0);
}
