// Finds special deals: real discounts off the list price, prices at their
// 30-day low (so "sales" that are really price hikes don't count), and
// time-limited deals that end soon.

export const MIN_DISCOUNT = 0.15;

export function discount(product) {
  if (!product.listPrice || product.listPrice <= product.price) return 0;
  return (product.listPrice - product.price) / product.listPrice;
}

export function dealInfo(product, now = new Date()) {
  const pct = discount(product);
  const atLow = product.low30 != null && product.price <= product.low30;
  const endsInHours = product.dealEndsAt ? (Date.parse(product.dealEndsAt) - now.getTime()) / 3600000 : null;
  const limited = endsInHours != null && endsInHours > 0;
  const isDeal = pct >= MIN_DISCOUNT || (atLow && pct > 0) || (limited && pct > 0);

  // 0-100 score: discount matters most, then a true low, then urgency.
  let score = Math.min(pct, 0.6) * 120;
  if (atLow) score += 15;
  if (limited) score += endsInHours < 24 ? 12 : 6;
  if (product.rating) score += (product.rating - 4) * 10;

  const badges = [];
  if (pct >= 0.05) badges.push(`${Math.round(pct * 100)}% off`);
  if (atLow) badges.push('Lowest price in 30 days');
  if (limited) badges.push(endsInHours < 24 ? `Ends in ${Math.max(1, Math.round(endsInHours))}h` : `Ends in ${Math.round(endsInHours / 24)} days`);

  return {
    isDeal,
    pct: Math.round(pct * 100),
    savings: Math.round((product.listPrice - product.price) * 100) / 100,
    atLow,
    endsAt: limited ? product.dealEndsAt : null,
    score: Math.round(Math.max(0, score)),
    badges,
  };
}

export function findDeals(products, now = new Date()) {
  return products
    .filter((p) => p.inStock)
    .map((p) => ({ product: p, deal: dealInfo(p, now) }))
    .filter((x) => x.deal.isDeal)
    .sort((a, b) => b.deal.score - a.deal.score);
}
