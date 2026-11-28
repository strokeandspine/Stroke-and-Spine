import { test } from 'node:test';
import assert from 'node:assert/strict';
import { arrivalDate, deliveryOptions, christmasEve, daysUntil } from '../src/delivery.js';
import { SHIPPING, affiliateUrl, amazonCartUrl, commissionRate } from '../src/retailers.js';
import { recommend } from '../src/recommend.js';
import { dealInfo, findDeals } from '../src/deals.js';
import { CATALOG, byId } from '../src/catalog.js';

// Times are UTC; Eastern = UTC-5 in December.
const SAT_10AM = new Date('2026-11-28T15:00:00Z');
const WED_10AM = new Date('2026-12-02T15:00:00Z');
const WED_1PM = new Date('2026-12-02T18:00:00Z');
const FRI_10AM = new Date('2026-12-04T15:00:00Z');

test('overnight ordered on a Saturday ships Monday, arrives Tuesday', () => {
  assert.equal(arrivalDate(SHIPPING.amazon.overnight, SAT_10AM), '2026-12-01');
});

test('order before cutoff ships same day; after cutoff ships next day', () => {
  assert.equal(arrivalDate(SHIPPING.amazon.overnight, WED_10AM), '2026-12-03');
  assert.equal(arrivalDate(SHIPPING.amazon.overnight, WED_1PM), '2026-12-04');
});

test('Saturday delivery only for carriers that offer it', () => {
  assert.equal(arrivalDate(SHIPPING.amazon.overnight, FRI_10AM), '2026-12-05');
  assert.equal(arrivalDate(SHIPPING.bestbuy.overnight, FRI_10AM), '2026-12-07');
});

test('same-day delivery works on weekends before cutoff', () => {
  assert.equal(arrivalDate(SHIPPING.target.same_day, SAT_10AM), '2026-11-28');
});

test('standard shipping skips weekends', () => {
  // Wed ships same day, 5 business days -> next Wed.
  assert.equal(arrivalDate(SHIPPING.amazon.standard, WED_10AM), '2026-12-09');
});

test('made-to-order processing days push arrival out', () => {
  const opt = SHIPPING.etsy.express;
  assert.ok(arrivalDate(opt, WED_10AM, 3) > arrivalDate(opt, WED_10AM, 0));
});

test('delivery options are sorted fastest first', () => {
  const opts = deliveryOptions(byId('amz-anc-headphones'), WED_10AM);
  assert.deepEqual(opts.map((o) => o.method), ['overnight', 'two_day', 'standard']);
});

test('Christmas countdown', () => {
  assert.equal(christmasEve(SAT_10AM), '2026-12-24');
  assert.equal(daysUntil('2026-12-24', SAT_10AM), 26);
  assert.equal(christmasEve(new Date('2026-12-26T15:00:00Z')), '2027-12-24');
});

test('never recommends below the product minimum age', () => {
  const { results } = recommend(CATALOG, { age: 6 }, WED_10AM);
  assert.ok(results.length > 0);
  for (const r of results) assert.ok(r.product.ageMin <= 6, r.product.title);
  assert.ok(!results.some((r) => r.product.id === 'amz-knife-set'));
});

test('adults do not get baby toys', () => {
  const { results } = recommend(CATALOG, { age: 35, limit: 100 }, WED_10AM);
  assert.ok(!results.some((r) => r.product.id === 'tgt-baby-play-mat'));
  assert.ok(!results.some((r) => r.product.id === 'amz-building-set'));
});

test('kid-focused toys rank top for a child', () => {
  const { results } = recommend(CATALOG, { age: 9, relationship: 'child' }, WED_10AM);
  assert.ok(['toys', 'games'].includes(results[0].product.category), results[0].product.title);
});

test('price range is a hard filter', () => {
  const { results } = recommend(CATALOG, { minPrice: 25, maxPrice: 50, limit: 100 }, WED_10AM);
  assert.ok(results.length > 0);
  for (const r of results) assert.ok(r.product.price >= 25 && r.product.price <= 50);
});

test('no personal items for coworkers', () => {
  const { results } = recommend(CATALOG, { age: 40, relationship: 'coworker', limit: 100 }, WED_10AM);
  assert.ok(!results.some((r) => r.product.category === 'jewelry' || r.product.id === 'tgt-silk-pillowcase'));
  // ...but a wallet that explicitly lists coworker is allowed.
  assert.ok(results.some((r) => r.product.id === 'amz-leather-wallet'));
});

test('gender nudges ranking without hiding neutral gifts', () => {
  const male = recommend(CATALOG, { age: 40, gender: 'male', relationship: 'partner', limit: 100 }, WED_10AM).results;
  const ids = male.map((r) => r.product.id);
  assert.ok(ids.indexOf('amz-beard-kit') < ids.indexOf('etsy-birthstone-necklace') || !ids.includes('etsy-birthstone-necklace'));
  assert.ok(ids.includes('amz-smart-speaker'));
});

test('interests boost matching products and explain why', () => {
  const { results } = recommend(CATALOG, { age: 30, interests: 'coffee' }, WED_10AM);
  assert.ok(results[0].product.interests.includes('coffee'));
  assert.ok(results[0].reasons.some((r) => r.includes('coffee')));
});

test('needBy removes gifts that cannot arrive in time', () => {
  const by = '2026-12-03'; // tomorrow from WED_10AM
  const { results } = recommend(CATALOG, { needBy: by, limit: 100 }, WED_10AM);
  assert.ok(results.length > 0);
  for (const r of results) assert.ok(r.delivery.arrives <= by);
  assert.ok(!results.some((r) => r.product.retailer === 'etsy'));
});

test('deals: discount, 30-day low and expiry', () => {
  const d = dealInfo({ price: 70, listPrice: 100, low30: 70, rating: 4.5, dealEndsAt: new Date(WED_10AM.getTime() + 5 * 3600000).toISOString() }, WED_10AM);
  assert.equal(d.pct, 30);
  assert.ok(d.atLow && d.isDeal);
  assert.ok(d.badges.includes('Ends in 5h'));
  assert.equal(dealInfo({ price: 100, listPrice: 100, low30: 90 }, WED_10AM).isDeal, false);
  // Small discount that's not a 30-day low isn't a deal.
  assert.equal(dealInfo({ price: 95, listPrice: 100, low30: 90 }, WED_10AM).isDeal, false);
});

test('deals are sorted best first', () => {
  const deals = findDeals(CATALOG, WED_10AM);
  for (let i = 1; i < deals.length; i++) assert.ok(deals[i - 1].deal.score >= deals[i].deal.score);
});

test('affiliate links carry our IDs', () => {
  const env = { AMAZON_ASSOCIATE_TAG: 'merry-20', WALMART_PUBLISHER_ID: '1', WALMART_AD_ID: '2', WALMART_PROGRAM_ID: '3' };
  assert.match(affiliateUrl(byId('amz-ereader'), env), /amazon\.com\/dp\/B0SAMPLE03\?tag=merry-20/);
  const w = affiliateUrl(byId('wmt-puzzle'), env, 'click123');
  assert.match(w, /^https:\/\/goto\.walmart\.com\/c\/1\/2\/3\?u=https%3A%2F%2Fwww\.walmart\.com/);
  assert.match(w, /subId1=click123/);
  const cart = amazonCartUrl([{ product: byId('amz-ereader'), qty: 2 }, { product: byId('amz-cookbook'), qty: 1 }], env);
  assert.match(cart, /AssociateTag=merry-20/);
  assert.match(cart, /ASIN\.1=B0SAMPLE03&Quantity\.1=2&ASIN\.2=B0SAMPLE60&Quantity\.2=1/);
});

test('commission rates by retailer and category', () => {
  assert.equal(commissionRate(byId('amz-pour-over')), 0.045);
  assert.equal(commissionRate(byId('tgt-candle-set')), 0.04);
});

test('every catalog item is valid', () => {
  const ids = new Set();
  for (const p of CATALOG) {
    assert.ok(!ids.has(p.id), 'duplicate ' + p.id); ids.add(p.id);
    assert.ok(p.price > 0 && p.listPrice >= p.price, p.id);
    assert.ok(p.ageMin <= p.ageMax, p.id);
    assert.ok(deliveryOptions(p, WED_10AM).length > 0, 'no shipping for ' + p.id);
  }
});

test('missing affiliate IDs fall back to the plain product page', () => {
  assert.equal(affiliateUrl(byId('wmt-puzzle'), {}, 'c1'), 'https://www.walmart.com/ip/555000160');
});

test('interest matches are not pushed down by the variety rule', () => {
  const { results } = recommend(CATALOG, { age: 34, relationship: 'partner', minPrice: 50, maxPrice: 100, interests: 'cooking' }, WED_10AM);
  const firstNonMatch = results.findIndex((r) => !r.product.interests.includes('cooking'));
  const knife = results.findIndex((r) => r.product.id === 'amz-knife-set');
  assert.ok(knife >= 0 && knife < firstNonMatch);
});
