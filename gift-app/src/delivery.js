// Estimated delivery dates. All maths is done on Eastern time (US retailers
// set their cut-offs in ET). December is always EST, i.e. UTC-5.

import { SHIPPING } from './retailers.js';

const ET_OFFSET_HOURS = -5;
const DAY = 86400000;

// Days carriers don't deliver, as YYYY-MM-DD (Eastern).
const HOLIDAYS = new Set(['2026-11-26', '2026-12-25', '2027-01-01', '2027-11-25', '2027-12-25']);

export function christmasEve(now = new Date()) {
  const et = toET(now);
  let year = et.getUTCFullYear();
  if (et.getUTCMonth() === 11 && et.getUTCDate() > 24) year += 1;
  return `${year}-12-24`;
}

function toET(date) {
  return new Date(date.getTime() + ET_OFFSET_HOURS * 3600000);
}

export function ymd(d) {
  return d.toISOString().slice(0, 10);
}

function isShippingDay(d) {
  const dow = d.getUTCDay();
  return dow !== 0 && dow !== 6 && !HOLIDAYS.has(ymd(d));
}

function isDeliveryDay(d, saturday) {
  const dow = d.getUTCDay();
  if (HOLIDAYS.has(ymd(d)) || dow === 0) return false;
  return dow !== 6 || saturday;
}

// Returns the arrival date (YYYY-MM-DD, Eastern) for one shipping option.
export function arrivalDate(option, now = new Date(), extraProcessingDays = 0) {
  const et = toET(now);
  // Midnight of today, Eastern, represented in UTC fields.
  let day = new Date(Date.UTC(et.getUTCFullYear(), et.getUTCMonth(), et.getUTCDate()));
  const pastCutoff = et.getUTCHours() >= option.cutoffHourET;

  // Same-day delivery runs every day except holidays.
  if (option.businessDays === 0) {
    if (pastCutoff || HOLIDAYS.has(ymd(day))) {
      do day = new Date(day.getTime() + DAY); while (HOLIDAYS.has(ymd(day)));
    }
    return ymd(day);
  }

  // Find the ship day.
  if (pastCutoff || !isShippingDay(day)) {
    do day = new Date(day.getTime() + DAY); while (!isShippingDay(day));
  }
  // Seller processing time (e.g. made-to-order items).
  for (let i = 0; i < extraProcessingDays; i++) {
    do day = new Date(day.getTime() + DAY); while (!isShippingDay(day));
  }
  // Transit.
  let left = option.businessDays;
  while (left > 0) {
    day = new Date(day.getTime() + DAY);
    if (isDeliveryDay(day, option.saturday)) left--;
  }
  return ymd(day);
}

// All shipping options for a product with arrival dates, fastest first.
export function deliveryOptions(product, now = new Date()) {
  const presets = SHIPPING[product.retailer] ?? {};
  return product.shipping
    .map((key) => presets[key])
    .filter(Boolean)
    .map((opt) => ({ ...opt, arrives: arrivalDate(opt, now, product.processingDays ?? 0) }))
    .sort((a, b) => a.arrives.localeCompare(b.arrives) || a.price - b.price);
}

export function fastestDelivery(product, now = new Date()) {
  return deliveryOptions(product, now)[0] ?? null;
}

// Cheapest option that still arrives by the date (YYYY-MM-DD), or null.
export function bestOptionBy(product, byDate, now = new Date()) {
  const ok = deliveryOptions(product, now).filter((o) => o.arrives <= byDate);
  if (!ok.length) return null;
  return ok.sort((a, b) => a.price - b.price || a.arrives.localeCompare(b.arrives))[0];
}

export function isOvernight(option) {
  return option && (option.method === 'overnight' || option.method === 'same_day');
}

export function daysUntil(dateStr, now = new Date()) {
  const et = toET(now);
  const today = Date.UTC(et.getUTCFullYear(), et.getUTCMonth(), et.getUTCDate());
  return Math.round((Date.parse(dateStr + 'T00:00:00Z') - today) / DAY);
}

export function formatDay(dateStr) {
  const d = new Date(dateStr + 'T12:00:00Z');
  return d.toLocaleDateString('en-US', { weekday: 'short', month: 'short', day: 'numeric', timeZone: 'UTC' });
}
