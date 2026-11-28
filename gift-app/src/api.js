// HTTP API shared by the Cloudflare Worker and the local dev server.
//
//   GET  /api/meta                    countdown, shipping deadlines, options
//   GET  /api/recommendations?...     gift finder (age, gender, relationship, minPrice, maxPrice, interests, needBy)
//   GET  /api/deals                   special deals, best first
//   GET  /api/fast?overnight=1&by=    gifts sorted by how soon they arrive
//   GET  /api/products/:id            one product with all delivery options
//   POST /api/checkout                {items:[{id, qty}]} -> per-retailer checkout links + commission estimate
//   GET  /go/:id                      records the click, then redirects to the retailer with our affiliate tag

import { CATALOG, INTERESTS, RELATIONSHIPS, byId } from './catalog.js';
import { RETAILERS, affiliateUrl, amazonCartUrl, commissionRate } from './retailers.js';
import { christmasEve, daysUntil, deliveryOptions, fastestDelivery, isOvernight, formatDay, arrivalDate } from './delivery.js';
import { dealInfo, findDeals } from './deals.js';
import { recommend } from './recommend.js';
import * as amazon from './providers/amazon.js';

const json = (data, status = 200) =>
  new Response(JSON.stringify(data), { status, headers: { 'content-type': 'application/json; charset=utf-8', 'cache-control': 'no-store' } });

const round2 = (n) => Math.round(n * 100) / 100;

// Public product view: adds links, deal and delivery info.
function view(product, now, extra = {}) {
  return {
    ...product,
    retailerName: RETAILERS[product.retailer]?.name ?? product.retailer,
    buyUrl: `/go/${encodeURIComponent(product.id)}`,
    deal: dealInfo(product, now),
    delivery: fastestDelivery(product, now),
    ...extra,
  };
}

// Live Amazon results are merged in when PA-API keys are set; cached 1 hour.
const liveCache = new Map();
async function products(env, query = {}) {
  if (!amazon.isConfigured(env) || !query.interests) return CATALOG;
  const key = `${query.interests}|${query.minPrice}|${query.maxPrice}`;
  const hit = liveCache.get(key);
  if (hit && Date.now() - hit.at < 3600000) return CATALOG.concat(hit.items);
  try {
    const items = await amazon.searchItems(env, { keywords: `${query.interests} gift`, minPrice: Number(query.minPrice) || 0, maxPrice: Number(query.maxPrice) || Infinity });
    liveCache.set(key, { at: Date.now(), items });
    return CATALOG.concat(items);
  } catch (e) {
    console.error('Amazon PA-API failed, using catalog only:', e.message);
    return CATALOG;
  }
}

function meta(now) {
  const eve = christmasEve(now);
  // Last day to order each shipping speed for Christmas Eve delivery, using an Amazon item as the reference.
  const deadlines = [
    { label: 'Standard shipping', option: { businessDays: 5, cutoffHourET: 14, saturday: false } },
    { label: '2-day shipping', option: { businessDays: 2, cutoffHourET: 14, saturday: true } },
    { label: 'Overnight', option: { businessDays: 1, cutoffHourET: 12, saturday: true } },
  ].map(({ label, option }) => {
    // Walk back from Christmas Eve to find the last order day that still arrives in time.
    const eveMs = Date.parse(eve + 'T17:00:00Z'); // noon ET on the 24th
    let last = null;
    for (let d = 0; d <= 30; d++) {
      const orderAt = new Date(eveMs - d * 86400000 - 1000); // just before the cutoff hour, ET
      orderAt.setUTCHours(option.cutoffHourET + 5 - 1, 0, 0, 0);
      if (orderAt < now) break;
      if (arrivalDate(option, orderAt) <= eve) { last = orderAt.toISOString().slice(0, 10); break; }
    }
    return { label, lastOrderDay: last, lastOrderDayLabel: last ? formatDay(last) : 'Passed' };
  });
  return {
    now: now.toISOString(),
    christmasEve: eve,
    daysToChristmas: daysUntil(eve, now) + 1,
    deadlines,
    interests: INTERESTS,
    relationships: RELATIONSHIPS,
    retailers: Object.entries(RETAILERS).map(([id, r]) => ({ id, name: r.name })),
    sampleData: true,
    disclosure: 'We earn a commission from qualifying purchases made through links in this app, at no extra cost to you. As an Amazon Associate we earn from qualifying purchases.',
  };
}

function checkout(items, env, now) {
  const lines = items
    .map(({ id, qty }) => ({ product: byId(id), qty: Math.max(1, Math.min(10, Number(qty) || 1)) }))
    .filter((l) => l.product);
  const groups = {};
  for (const l of lines) (groups[l.product.retailer] ??= []).push(l);

  const retailers = Object.entries(groups).map(([retailer, ls]) => {
    const subtotal = round2(ls.reduce((s, l) => s + l.product.price * l.qty, 0));
    const estCommission = round2(ls.reduce((s, l) => s + l.product.price * l.qty * commissionRate(l.product), 0));
    const multi = RETAILERS[retailer]?.supportsMultiItemCart;
    return {
      retailer,
      name: RETAILERS[retailer]?.name ?? retailer,
      subtotal,
      estCommission,
      // Amazon: one link adds every item to the shopper's Amazon cart.
      // Others: one tracked link per item (their affiliate programmes don't offer multi-item carts).
      checkoutUrl: multi ? amazonCartUrl(ls, env) : null,
      items: ls.map((l) => ({
        id: l.product.id, title: l.product.title, qty: l.qty, price: l.product.price,
        buyUrl: `/go/${encodeURIComponent(l.product.id)}`,
        delivery: fastestDelivery(l.product, now),
      })),
    };
  });
  return {
    retailers,
    total: round2(retailers.reduce((s, r) => s + r.subtotal, 0)),
    estCommission: round2(retailers.reduce((s, r) => s + r.estCommission, 0)),
    note: 'You finish paying on each retailer\'s own secure checkout. Prices and delivery dates are confirmed there.',
  };
}

async function recordClick(env, click) {
  // Bind a KV namespace called CLICKS in wrangler.jsonc to keep these;
  // the click ID is passed to the affiliate network as a sub-ID so their
  // commission reports can be matched back to it.
  if (env.CLICKS?.put) await env.CLICKS.put(`click:${click.id}`, JSON.stringify(click), { expirationTtl: 60 * 60 * 24 * 120 });
  else console.log('click', JSON.stringify(click));
}

export async function handle(request, env = {}, ctx = {}) {
  const url = new URL(request.url);
  const now = url.searchParams.get('now') && env.ALLOW_TIME_TRAVEL ? new Date(url.searchParams.get('now')) : new Date();
  const q = Object.fromEntries(url.searchParams);
  const path = url.pathname;

  try {
    if (path === '/api/meta') return json(meta(now));

    if (path === '/api/recommendations') {
      const { query, results } = recommend(await products(env, q), q, now);
      return json({ query, results: results.map((r) => view(r.product, now, { score: r.score, reasons: r.reasons, delivery: r.delivery })) });
    }

    if (path === '/api/deals') {
      const retailer = q.retailer;
      const list = findDeals(CATALOG, now).filter((d) => !retailer || d.product.retailer === retailer);
      return json({ results: list.slice(0, Number(q.limit) || 40).map((d) => view(d.product, now)) });
    }

    if (path === '/api/fast') {
      const by = /^\d{4}-\d{2}-\d{2}$/.test(q.by ?? '') ? q.by : christmasEve(now);
      const overnightOnly = q.overnight === '1' || q.overnight === 'true';
      const maxPrice = Number(q.maxPrice) || Infinity;
      const results = CATALOG.filter((p) => p.inStock && p.price <= maxPrice)
        .map((p) => {
          const opts = deliveryOptions(p, now);
          const fastest = opts[0];
          return { p, fastest, overnight: opts.find(isOvernight) };
        })
        .filter((x) => x.fastest && x.fastest.arrives <= by && (!overnightOnly || x.overnight))
        .sort((a, b) => a.fastest.arrives.localeCompare(b.fastest.arrives) || a.fastest.price - b.fastest.price || b.p.rating - a.p.rating)
        .map((x) => view(x.p, now, { delivery: overnightOnly ? x.overnight : x.fastest, overnightAvailable: Boolean(x.overnight) }));
      return json({ by, overnightOnly, results });
    }

    const prod = path.match(/^\/api\/products\/([\w-]+)$/);
    if (prod) {
      const p = byId(prod[1]);
      if (!p) return json({ error: 'Not found' }, 404);
      return json(view(p, now, { deliveryOptions: deliveryOptions(p, now) }));
    }

    if (path === '/api/checkout' && request.method === 'POST') {
      const body = await request.json().catch(() => ({}));
      if (!Array.isArray(body.items) || !body.items.length) return json({ error: 'Cart is empty' }, 400);
      return json(checkout(body.items.slice(0, 50), env, now));
    }

    const go = path.match(/^\/go\/([\w-]+)$/);
    if (go) {
      const p = byId(go[1]);
      if (!p) return json({ error: 'Not found' }, 404);
      const id = crypto.randomUUID();
      const click = { id, productId: p.id, retailer: p.retailer, price: p.price, estCommission: round2(p.price * commissionRate(p)), at: now.toISOString(), source: q.src ?? 'app' };
      const save = recordClick(env, click);
      if (ctx.waitUntil) ctx.waitUntil(save); else await save;
      return new Response(null, { status: 302, headers: { location: affiliateUrl(p, env, id), 'cache-control': 'no-store', 'referrer-policy': 'no-referrer-when-downgrade' } });
    }

    if (path.startsWith('/api/')) return json({ error: 'Not found' }, 404);
    return null; // let static assets handle it
  } catch (e) {
    console.error(e);
    return json({ error: 'Something went wrong' }, 500);
  }
}
