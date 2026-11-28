// Live Amazon products through the Product Advertising API 5.0 (PA-API).
//
// Turned on when AMAZON_ACCESS_KEY, AMAZON_SECRET_KEY and
// AMAZON_ASSOCIATE_TAG are set. PA-API access is granted only to Associates
// accounts that have made qualifying sales, and Amazon has been moving
// developers to newer APIs, so check the current Associates documentation
// before relying on this. This adapter has not been run against the live API.
//
// Amazon's rules that matter here: prices must be refreshed at least every
// 24 hours (we cache for 1 hour), and show "Price and availability accurate
// as of <time>" next to Amazon prices.

const HOST = 'webservices.amazon.com';
const REGION = 'us-east-1';
const SERVICE = 'ProductAdvertisingAPI';

const RESOURCES = [
  'ItemInfo.Title',
  'ItemInfo.Classifications',
  'Images.Primary.Medium',
  'Offers.Listings.Price',
  'Offers.Listings.SavingBasis',
  'Offers.Listings.DeliveryInfo.IsPrimeEligible',
  'Offers.Listings.Availability.Type',
  'CustomerReviews.Count',
  'CustomerReviews.StarRating',
];

const enc = new TextEncoder();
const hex = (buf) => [...new Uint8Array(buf)].map((b) => b.toString(16).padStart(2, '0')).join('');
const sha256 = async (s) => hex(await crypto.subtle.digest('SHA-256', enc.encode(s)));
async function hmac(key, s) {
  const k = await crypto.subtle.importKey('raw', typeof key === 'string' ? enc.encode(key) : key, { name: 'HMAC', hash: 'SHA-256' }, false, ['sign']);
  return crypto.subtle.sign('HMAC', k, enc.encode(s));
}

// AWS Signature Version 4.
export async function signRequest({ accessKey, secretKey, path, target, body, now = new Date() }) {
  const amzDate = now.toISOString().replace(/[:-]|\.\d{3}/g, '');
  const date = amzDate.slice(0, 8);
  const headers = {
    'content-encoding': 'amz-1.0',
    'content-type': 'application/json; charset=utf-8',
    host: HOST,
    'x-amz-date': amzDate,
    'x-amz-target': target,
  };
  const signed = Object.keys(headers).sort();
  const canonical = ['POST', path, '', ...signed.map((h) => `${h}:${headers[h]}`), '', signed.join(';'), await sha256(body)].join('\n');
  const scope = `${date}/${REGION}/${SERVICE}/aws4_request`;
  const toSign = ['AWS4-HMAC-SHA256', amzDate, scope, await sha256(canonical)].join('\n');
  let key = await hmac('AWS4' + secretKey, date);
  key = await hmac(key, REGION);
  key = await hmac(key, SERVICE);
  key = await hmac(key, 'aws4_request');
  const signature = hex(await hmac(key, toSign));
  headers.authorization = `AWS4-HMAC-SHA256 Credential=${accessKey}/${scope}, SignedHeaders=${signed.join(';')}, Signature=${signature}`;
  return headers;
}

export function isConfigured(env) {
  return Boolean(env.AMAZON_ACCESS_KEY && env.AMAZON_SECRET_KEY && env.AMAZON_ASSOCIATE_TAG);
}

// Map a PA-API item to the app's product shape. Amazon doesn't give age,
// gender or relationship data, so those are left open; the recommender still
// uses price, rating, deals and delivery for these items.
export function mapItem(item, category = 'electronics') {
  const listing = item.Offers?.Listings?.[0];
  const price = listing?.Price?.Amount;
  if (price == null) return null;
  const prime = listing?.DeliveryInfo?.IsPrimeEligible;
  return {
    id: `amz-${item.ASIN}`,
    retailer: 'amazon',
    sku: item.ASIN,
    title: item.ItemInfo?.Title?.DisplayValue ?? 'Amazon item',
    image: item.Images?.Primary?.Medium?.URL,
    emoji: '🎁',
    category,
    price,
    listPrice: listing?.SavingBasis?.Amount ?? price,
    low30: null,
    rating: item.CustomerReviews?.StarRating?.Value ?? null,
    reviews: item.CustomerReviews?.Count ?? 0,
    ageMin: 0, ageMax: 120, genders: ['any'],
    relationships: ['partner', 'parent', 'child', 'sibling', 'friend', 'coworker', 'grandparent'],
    interests: [],
    shipping: prime ? ['overnight', 'two_day', 'standard'] : ['standard'],
    inStock: listing?.Availability?.Type !== 'OutOfStock',
    priceAsOf: new Date().toISOString(),
    sample: false,
  };
}

export async function searchItems(env, { keywords, minPrice, maxPrice, category, fetchImpl = fetch }) {
  const path = '/paapi5/searchitems';
  const target = 'com.amazon.paapi5.v1.ProductAdvertisingAPIv1.SearchItems';
  const payload = {
    Keywords: keywords,
    SearchIndex: 'All',
    ItemCount: 10,
    PartnerTag: env.AMAZON_ASSOCIATE_TAG,
    PartnerType: 'Associates',
    Marketplace: 'www.amazon.com',
    Resources: RESOURCES,
  };
  if (minPrice) payload.MinPrice = Math.round(minPrice * 100);
  if (maxPrice && Number.isFinite(maxPrice)) payload.MaxPrice = Math.round(maxPrice * 100);
  const body = JSON.stringify(payload);
  const headers = await signRequest({ accessKey: env.AMAZON_ACCESS_KEY, secretKey: env.AMAZON_SECRET_KEY, path, target, body });
  const res = await fetchImpl(`https://${HOST}${path}`, { method: 'POST', headers, body });
  if (!res.ok) throw new Error(`PA-API ${res.status}: ${await res.text()}`);
  const data = await res.json();
  return (data.SearchResult?.Items ?? []).map((i) => mapItem(i, category)).filter(Boolean);
}
