import { test } from 'node:test';
import assert from 'node:assert/strict';
import { handle } from '../src/api.js';
import { signRequest, mapItem } from '../src/providers/amazon.js';

const env = { ALLOW_TIME_TRAVEL: '1', AMAZON_ASSOCIATE_TAG: 'merry-20' };
const NOW = '2026-12-02T15:00:00Z';
const get = async (path) => {
  const res = await handle(new Request(`http://x${path}${path.includes('?') ? '&' : '?'}now=${NOW}`), env);
  return { res, body: res.headers.get('content-type')?.includes('json') ? await res.json() : null };
};

test('meta has countdown and order-by deadlines', async () => {
  const { body } = await get('/api/meta');
  assert.equal(body.christmasEve, '2026-12-24');
  assert.equal(body.daysToChristmas, 23);
  assert.equal(body.deadlines.length, 3);
  // Overnight deadline is later than standard.
  assert.ok(body.deadlines[2].lastOrderDay > body.deadlines[0].lastOrderDay);
  assert.match(body.disclosure, /Amazon Associate/);
});

test('recommendations endpoint', async () => {
  const { body } = await get('/api/recommendations?age=30&relationship=partner&minPrice=25&maxPrice=100&interests=cooking');
  assert.ok(body.results.length > 0);
  assert.ok(body.results[0].buyUrl.startsWith('/go/'));
  assert.ok(body.results[0].reasons.length > 0);
});

test('fast endpoint sorts by arrival and filters overnight', async () => {
  const { body } = await get('/api/fast?overnight=1');
  assert.ok(body.results.length > 0);
  for (let i = 1; i < body.results.length; i++) assert.ok(body.results[i - 1].delivery.arrives <= body.results[i].delivery.arrives);
  for (const p of body.results) assert.ok(['overnight', 'same_day'].includes(p.delivery.method));
});

test('checkout groups by retailer with an Amazon multi-item cart', async () => {
  const req = new Request(`http://x/api/checkout?now=${NOW}`, {
    method: 'POST', body: JSON.stringify({ items: [{ id: 'amz-ereader', qty: 1 }, { id: 'amz-cookbook', qty: 2 }, { id: 'tgt-candle-set', qty: 1 }, { id: 'nope', qty: 1 }] }),
  });
  const body = await (await handle(req, env)).json();
  assert.equal(body.retailers.length, 2);
  const amz = body.retailers.find((r) => r.retailer === 'amazon');
  assert.match(amz.checkoutUrl, /amazon\.com\/gp\/aws\/cart\/add\.html/);
  assert.equal(amz.subtotal, 147.97);
  assert.ok(body.estCommission > 0);
  const tgt = body.retailers.find((r) => r.retailer === 'target');
  assert.equal(tgt.checkoutUrl, null);
});

test('/go records the click and redirects with the affiliate tag', async () => {
  const saved = [];
  const kvEnv = { ...env, CLICKS: { put: async (k, v) => saved.push([k, JSON.parse(v)]) } };
  const res = await handle(new Request('http://x/go/amz-ereader'), kvEnv);
  assert.equal(res.status, 302);
  assert.match(res.headers.get('location'), /tag=merry-20/);
  assert.equal(saved.length, 1);
  assert.equal(saved[0][1].productId, 'amz-ereader');
});

test('unknown API path is 404, other paths fall through to static files', async () => {
  assert.equal((await handle(new Request('http://x/api/nope'), env)).status, 404);
  assert.equal(await handle(new Request('http://x/index.html'), env), null);
});

test('Amazon request signing produces a SigV4 header', async () => {
  const h = await signRequest({ accessKey: 'AKIDEXAMPLE', secretKey: 'secret', path: '/paapi5/searchitems', target: 'x', body: '{}', now: new Date('2026-12-02T15:00:00Z') });
  assert.equal(h['x-amz-date'], '20261202T150000Z');
  assert.match(h.authorization, /^AWS4-HMAC-SHA256 Credential=AKIDEXAMPLE\/20261202\/us-east-1\/ProductAdvertisingAPI\/aws4_request, SignedHeaders=content-encoding;content-type;host;x-amz-date;x-amz-target, Signature=[0-9a-f]{64}$/);
});

test('Amazon item mapping', () => {
  const p = mapItem({ ASIN: 'B0X', ItemInfo: { Title: { DisplayValue: 'Thing' } }, Offers: { Listings: [{ Price: { Amount: 20 }, SavingBasis: { Amount: 30 }, DeliveryInfo: { IsPrimeEligible: true } }] } });
  assert.equal(p.price, 20);
  assert.equal(p.listPrice, 30);
  assert.deepEqual(p.shipping, ['overnight', 'two_day', 'standard']);
});
