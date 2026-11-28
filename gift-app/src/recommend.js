// Gift recommendation engine.
//
// Input: who the gift is for (age, gender, relationship), a price range, and
// optionally interests and a date it must arrive by. Output: products ranked
// by a fit score, each with plain-language reasons.
//
// Rules:
//  - Price range and stock are hard filters.
//  - Age: never recommend below a product's minimum age (toy safety labels
//    are age-based). Above the maximum age the score drops, and far above it
//    the product is removed.
//  - Gender only nudges the score; it never hides "any" products.
//  - Relationship: products not suited to the relationship score lower, and
//    personal items (jewellery, beauty, fashion) are removed for coworkers
//    unless the product explicitly lists coworker.
//  - "Need by" removes products that can't arrive in time.

import { dealInfo } from './deals.js';
import { bestOptionBy, fastestDelivery, formatDay } from './delivery.js';

const PERSONAL_CATEGORIES = new Set(['jewelry', 'beauty', 'fashion']);

const REL_LABEL = {
  partner: 'a partner', parent: 'a parent', child: 'a child', sibling: 'a sibling',
  friend: 'a friend', coworker: 'a coworker', grandparent: 'a grandparent',
};

export function normaliseQuery(q = {}) {
  const num = (v) => (v === undefined || v === null || v === '' || isNaN(Number(v)) ? null : Number(v));
  const list = (v) => (Array.isArray(v) ? v : typeof v === 'string' && v ? v.split(',') : []).map((s) => s.trim().toLowerCase()).filter(Boolean);
  const gender = String(q.gender ?? 'any').toLowerCase();
  return {
    age: num(q.age),
    gender: ['female', 'male'].includes(gender) ? gender : 'any',
    relationship: q.relationship ? String(q.relationship).toLowerCase() : null,
    minPrice: num(q.minPrice) ?? 0,
    maxPrice: num(q.maxPrice) ?? Infinity,
    interests: list(q.interests),
    needBy: /^\d{4}-\d{2}-\d{2}$/.test(q.needBy ?? '') ? q.needBy : null,
    limit: Math.min(num(q.limit) ?? 24, 100),
  };
}

export function scoreProduct(product, query, now = new Date()) {
  const q = query;
  if (!product.inStock) return null;
  if (product.price < q.minPrice || product.price > q.maxPrice) return null;

  let score = 50;
  const reasons = [];

  // Age
  if (q.age != null) {
    if (q.age < product.ageMin) return null;
    if (q.age > product.ageMax) {
      const over = q.age - product.ageMax;
      if (over > 8) return null;
      score -= over * 4;
    } else {
      score += 10;
      // Products aimed narrowly at this age (e.g. kids' toys) fit best.
      const span = product.ageMax - product.ageMin;
      if (span <= 15) {
        score += 10;
        reasons.push(`Made for ages ${product.ageMin}–${product.ageMax}`);
      }
    }
  }

  // Gender (soft)
  if (q.gender !== 'any' && !product.genders.includes('any')) {
    if (product.genders.includes(q.gender)) score += 8;
    else score -= 25;
  }

  // Relationship
  if (q.relationship) {
    const fits = product.relationships.includes(q.relationship);
    if (q.relationship === 'coworker' && PERSONAL_CATEGORIES.has(product.category) && !fits) return null;
    if (fits) {
      score += 15;
      reasons.push(`Popular gift for ${REL_LABEL[q.relationship] ?? q.relationship}`);
    } else {
      score -= 15;
    }
  }

  // Interests
  const matched = q.interests.filter((i) => product.interests.includes(i));
  if (q.interests.length) {
    if (matched.length) {
      score += 14 * matched.length + 6;
      reasons.push(`Matches ${matched.join(', ')}`);
    } else {
      score -= 12;
    }
  }

  // Use the budget: a gift near the top of the range feels generous; one far
  // below it can feel like an afterthought.
  if (Number.isFinite(q.maxPrice) && q.maxPrice > 0) {
    const use = product.price / q.maxPrice;
    score += use >= 0.5 ? 6 : use >= 0.25 ? 2 : -4;
  }

  // Quality
  if (product.rating) {
    score += (product.rating - 4.3) * 20;
    if (product.rating >= 4.7 && product.reviews >= 1000) reasons.push(`${product.rating}★ from ${product.reviews.toLocaleString('en-US')} reviews`);
  }
  if (product.reviews) score += Math.min(Math.log10(product.reviews), 5);

  // Deals
  const deal = dealInfo(product, now);
  if (deal.isDeal) {
    score += Math.min(deal.pct, 50) * 0.25;
    reasons.push(deal.badges[0]);
  }

  // Delivery
  let delivery;
  if (q.needBy) {
    delivery = bestOptionBy(product, q.needBy, now);
    if (!delivery) return null;
    reasons.push(`Arrives ${formatDay(delivery.arrives)} with ${delivery.label.toLowerCase()}`);
  } else {
    delivery = fastestDelivery(product, now);
  }

  return { product, score: Math.round(score * 10) / 10, reasons, deal, delivery };
}

export function recommend(products, rawQuery, now = new Date()) {
  const q = normaliseQuery(rawQuery);
  const results = products
    .map((p) => scoreProduct(p, q, now))
    .filter(Boolean)
    .sort((a, b) => b.score - a.score || a.product.price - b.product.price);

  // Keep the list varied: at most 3 items from the same category near the
  // top, except items that match an interest the shopper picked.
  const perCat = {};
  const top = [];
  const rest = [];
  for (const r of results) {
    const c = r.product.category;
    const matchesInterest = q.interests.some((i) => r.product.interests.includes(i));
    perCat[c] = (perCat[c] ?? 0) + 1;
    (matchesInterest || perCat[c] <= 3 ? top : rest).push(r);
  }
  return { query: { ...q, maxPrice: Number.isFinite(q.maxPrice) ? q.maxPrice : null }, results: top.concat(rest).slice(0, q.limit) };
}
