// Retailers the app sells through, their shipping options and how their
// affiliate (commission) links are built.
//
// Commission rates are ESTIMATES for planning only. The real rate is whatever
// each affiliate programme pays you, and it changes by category and over time.
// Update them from your affiliate dashboards before showing earnings to anyone.

// Shipping presets. `businessDays` is transit time after the order ships.
// `cutoffHourET` is the latest Eastern-time hour an order can be placed and
// still ship that day. `saturday` means the carrier delivers on Saturdays.
export const SHIPPING = {
  amazon: {
    overnight: { method: 'overnight', label: 'Overnight (Prime)', businessDays: 1, cutoffHourET: 12, price: 0, saturday: true },
    two_day: { method: 'two_day', label: '2-day (Prime)', businessDays: 2, cutoffHourET: 14, price: 0, saturday: true },
    standard: { method: 'standard', label: 'Free standard', businessDays: 5, cutoffHourET: 14, price: 0, saturday: false },
  },
  walmart: {
    overnight: { method: 'overnight', label: 'Next-day', businessDays: 1, cutoffHourET: 11, price: 0, saturday: true },
    two_day: { method: 'two_day', label: '2-day', businessDays: 2, cutoffHourET: 14, price: 0, saturday: false },
    standard: { method: 'standard', label: 'Standard', businessDays: 4, cutoffHourET: 14, price: 0, saturday: false },
  },
  target: {
    same_day: { method: 'same_day', label: 'Same-day delivery', businessDays: 0, cutoffHourET: 15, price: 9.99, saturday: true },
    two_day: { method: 'two_day', label: '2-day', businessDays: 2, cutoffHourET: 13, price: 0, saturday: false },
    standard: { method: 'standard', label: 'Standard', businessDays: 5, cutoffHourET: 14, price: 0, saturday: false },
  },
  bestbuy: {
    overnight: { method: 'overnight', label: 'Next-day', businessDays: 1, cutoffHourET: 13, price: 19.99, saturday: false },
    standard: { method: 'standard', label: 'Free standard', businessDays: 3, cutoffHourET: 15, price: 0, saturday: false },
  },
  etsy: {
    express: { method: 'express', label: 'Express (made to order)', businessDays: 4, cutoffHourET: 12, price: 14.99, saturday: false },
    standard: { method: 'standard', label: 'Standard (made to order)', businessDays: 9, cutoffHourET: 12, price: 4.99, saturday: false },
  },
};

export const RETAILERS = {
  amazon: {
    name: 'Amazon',
    // Amazon Associates pays by category.
    commissionByCategory: { electronics: 0.03, toys: 0.03, home: 0.03, kitchen: 0.045, beauty: 0.03, fashion: 0.04, books: 0.045, sports: 0.03, games: 0.01, jewelry: 0.04 },
    defaultCommission: 0.03,
    cookieDays: 1,
    supportsMultiItemCart: true,
  },
  walmart: { name: 'Walmart', defaultCommission: 0.03, cookieDays: 3, network: 'Impact' },
  target: { name: 'Target', defaultCommission: 0.04, cookieDays: 7, network: 'Impact' },
  bestbuy: { name: 'Best Buy', defaultCommission: 0.01, cookieDays: 1, network: 'Impact' },
  etsy: { name: 'Etsy', defaultCommission: 0.04, cookieDays: 30, network: 'Awin' },
};

export function commissionRate(product) {
  const r = RETAILERS[product.retailer];
  if (!r) return 0;
  return r.commissionByCategory?.[product.category] ?? r.defaultCommission;
}

// The plain product page on the retailer's own site.
export function productUrl(product) {
  switch (product.retailer) {
    case 'amazon': return `https://www.amazon.com/dp/${product.sku}`;
    case 'walmart': return `https://www.walmart.com/ip/${product.sku}`;
    case 'target': return `https://www.target.com/p/-/A-${product.sku}`;
    case 'bestbuy': return `https://www.bestbuy.com/site/${product.sku}.p`;
    case 'etsy': return `https://www.etsy.com/listing/${product.sku}`;
    default: return product.url ?? '#';
  }
}

// Affiliate link templates. {url} is the encoded product URL, {subid} is our
// click ID so the network's conversion report can be matched back to a click.
// Replace the placeholder IDs with the ones from each programme (set them as
// environment variables; see README).
const DEFAULT_TEMPLATES = {
  walmart: 'https://goto.walmart.com/c/{WALMART_PUBLISHER_ID}/{WALMART_AD_ID}/{WALMART_PROGRAM_ID}?u={url}&subId1={subid}',
  target: 'https://goto.target.com/c/{TARGET_PUBLISHER_ID}/{TARGET_AD_ID}/{TARGET_PROGRAM_ID}?u={url}&subId1={subid}',
  bestbuy: 'https://bestbuy.7tiv.net/c/{BESTBUY_PUBLISHER_ID}/{BESTBUY_AD_ID}/{BESTBUY_PROGRAM_ID}?u={url}&subId1={subid}',
  etsy: 'https://www.awin1.com/cread.php?awinmid={ETSY_AWIN_MID}&awinaffid={AWIN_AFFILIATE_ID}&clickref={subid}&ued={url}',
};

// Returns null if any ID is missing, so we never send shoppers to a broken link.
function fill(template, vars) {
  let missing = false;
  const out = template.replace(/\{(\w+)\}/g, (_, k) => {
    if (vars[k] == null || vars[k] === '') missing = true;
    return vars[k] ?? '';
  });
  return missing ? null : out;
}

export function affiliateUrl(product, env = {}, subid = '') {
  const url = productUrl(product);
  if (product.retailer === 'amazon') {
    const tag = env.AMAZON_ASSOCIATE_TAG || 'yourtag-20';
    const u = new URL(url);
    u.searchParams.set('tag', tag);
    // Amazon does not report sub-IDs on standard links; tracking IDs per
    // campaign are the supported way to segment.
    return u.toString();
  }
  const template = env[`${product.retailer.toUpperCase()}_LINK_TEMPLATE`] || DEFAULT_TEMPLATES[product.retailer];
  if (!template) return url;
  const link = fill(template, { ...env, url: encodeURIComponent(url), subid: encodeURIComponent(subid) });
  if (!link) console.warn(`Affiliate IDs for ${product.retailer} are not set; linking without commission tracking.`);
  return link ?? url;
}

// Amazon's "add to cart" form URL puts several items in the shopper's Amazon
// cart at once, credited to our Associates tag. The shopper confirms and pays
// on Amazon.
export function amazonCartUrl(items, env = {}) {
  const tag = env.AMAZON_ASSOCIATE_TAG || 'yourtag-20';
  const u = new URL('https://www.amazon.com/gp/aws/cart/add.html');
  u.searchParams.set('AssociateTag', tag);
  items.forEach(({ product, qty }, i) => {
    u.searchParams.set(`ASIN.${i + 1}`, product.sku);
    u.searchParams.set(`Quantity.${i + 1}`, String(qty));
  });
  return u.toString();
}
