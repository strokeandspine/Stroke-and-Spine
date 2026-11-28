// SAMPLE catalog used until live retailer feeds are connected.
// SKUs, prices and ratings are made up for development. Never show these to
// shoppers as real offers: switch on the Amazon provider and the affiliate
// product feeds (see README) before launch.

const ALL = ['partner', 'parent', 'child', 'sibling', 'friend', 'coworker', 'grandparent'];
const FAMILY = ['parent', 'sibling', 'grandparent', 'child'];
const CLOSE = ['partner', 'parent', 'sibling', 'friend'];

// Deals end a few days from "now" so the sample always has live deals.
const soon = (days) => new Date(Date.now() + days * 86400000).toISOString();

function p(id, retailer, sku, title, emoji, category, price, listPrice, low30, rating, reviews, age, genders, relationships, interests, shipping, extra = {}) {
  return {
    id, retailer, sku, title, emoji, category, price, listPrice, low30, rating, reviews,
    ageMin: age[0], ageMax: age[1], genders, relationships, interests, shipping,
    inStock: true, sample: true, ...extra,
  };
}

const A3 = ['overnight', 'two_day', 'standard'];
const A2 = ['two_day', 'standard'];
const W3 = ['overnight', 'two_day', 'standard'];
const W2 = ['two_day', 'standard'];
const T3 = ['same_day', 'two_day', 'standard'];
const T2 = ['two_day', 'standard'];
const B2 = ['overnight', 'standard'];
const B1 = ['standard'];
const E2 = ['express', 'standard'];

export const CATALOG = [
  // ---- Tech
  p('amz-anc-headphones', 'amazon', 'B0SAMPLE01', 'Wireless Noise-Cancelling Headphones', '🎧', 'electronics', 199.99, 349.99, 199.99, 4.6, 28410, [13, 99], ['any'], ALL.filter((r) => r !== 'coworker'), ['tech', 'music', 'travel'], A3),
  p('amz-smart-speaker', 'amazon', 'B0SAMPLE02', 'Smart Speaker with Voice Assistant', '🔊', 'electronics', 29.99, 49.99, 24.99, 4.7, 98012, [10, 99], ['any'], ALL, ['tech', 'music', 'home'], A3),
  p('amz-ereader', 'amazon', 'B0SAMPLE03', 'Waterproof E-Reader, 16 GB', '📖', 'electronics', 109.99, 159.99, 109.99, 4.7, 41230, [10, 99], ['any'], CLOSE.concat('grandparent'), ['reading', 'travel', 'tech'], A3, { dealEndsAt: soon(2) }),
  p('amz-streaming-stick', 'amazon', 'B0SAMPLE04', '4K Streaming Stick', '📺', 'electronics', 24.99, 49.99, 24.99, 4.6, 120400, [13, 99], ['any'], ALL, ['tech', 'home'], A3, { dealEndsAt: soon(1) }),
  p('amz-tracker-tags', 'amazon', 'B0SAMPLE05', 'Bluetooth Item Tracker Tags, 4-pack', '📍', 'electronics', 69.99, 99.0, 69.99, 4.7, 60200, [16, 99], ['any'], ALL, ['tech', 'travel'], A3),
  p('bby-instant-camera', 'bestbuy', '6500001', 'Instant Print Camera', '📸', 'electronics', 69.99, 79.99, 69.99, 4.6, 8200, [8, 40], ['any'], ['child', 'sibling', 'friend', 'partner'], ['art', 'travel', 'tech'], B2),
  p('bby-gaming-headset', 'bestbuy', '6500002', 'Wireless Gaming Headset', '🎮', 'electronics', 89.99, 129.99, 89.99, 4.5, 5400, [10, 45], ['any'], ['child', 'sibling', 'friend', 'partner'], ['gaming', 'tech'], B2, { dealEndsAt: soon(3) }),
  p('bby-handheld-console', 'bestbuy', '6500003', 'Handheld Game Console Bundle', '🕹️', 'games', 299.99, 299.99, 289.99, 4.8, 15400, [8, 40], ['any'], ['child', 'sibling', 'partner'], ['gaming', 'tech'], B1),
  p('bby-smartwatch', 'bestbuy', '6500004', 'Fitness Smartwatch with GPS', '⌚', 'electronics', 179.99, 249.99, 179.99, 4.5, 11200, [14, 80], ['any'], CLOSE, ['fitness', 'tech', 'outdoors'], B2),
  p('wmt-retro-console', 'walmart', '555000101', 'Retro Mini Game Console, 200 Built-in Games', '👾', 'games', 39.0, 59.0, 39.0, 4.3, 3100, [8, 60], ['any'], ['child', 'sibling', 'friend', 'parent'], ['gaming'], W3),
  p('wmt-power-bank', 'walmart', '555000102', 'Fast-Charge Power Bank 20,000 mAh', '🔋', 'electronics', 24.88, 39.99, 22.0, 4.5, 8700, [13, 99], ['any'], ALL, ['tech', 'travel'], W3),

  // ---- Kitchen & coffee
  p('amz-pour-over', 'amazon', 'B0SAMPLE10', 'Pour-Over Coffee Set with Gooseneck Kettle', '☕', 'kitchen', 54.99, 79.99, 54.99, 4.6, 4300, [18, 99], ['any'], ALL, ['coffee', 'cooking'], A3),
  p('amz-air-fryer', 'amazon', 'B0SAMPLE11', '6-Quart Air Fryer', '🍟', 'kitchen', 79.99, 129.99, 74.99, 4.7, 52300, [18, 99], ['any'], ['parent', 'partner', 'sibling', 'grandparent'], ['cooking', 'home'], A3, { dealEndsAt: soon(2) }),
  p('amz-knife-set', 'amazon', 'B0SAMPLE12', "Chef's Knife Set with Block", '🔪', 'kitchen', 89.99, 119.99, 89.99, 4.6, 7800, [21, 99], ['any'], ['partner', 'parent', 'sibling', 'friend'], ['cooking'], A2),
  p('tgt-dutch-oven', 'target', '90000001', 'Enameled Cast-Iron Dutch Oven, 5.5 qt', '🍲', 'kitchen', 59.99, 79.99, 59.99, 4.7, 3900, [21, 99], ['any'], ['partner', 'parent', 'grandparent', 'sibling'], ['cooking', 'home'], T3),
  p('tgt-mug-warmer', 'target', '90000002', 'Smart Mug Warmer', '♨️', 'kitchen', 24.99, 29.99, 24.99, 4.4, 1900, [16, 99], ['any'], ALL, ['coffee', 'home'], T3),
  p('etsy-hot-sauce-kit', 'etsy', '1500000001', 'Make-Your-Own Hot Sauce Kit', '🌶️', 'kitchen', 38.0, 38.0, 38.0, 4.9, 2100, [21, 99], ['any'], ALL, ['cooking'], E2, { processingDays: 1 }),
  p('wmt-espresso', 'walmart', '555000110', 'Espresso Machine with Milk Frother', '🫖', 'kitchen', 149.0, 199.0, 149.0, 4.4, 2600, [18, 99], ['any'], ['partner', 'parent', 'sibling'], ['coffee'], W3, { dealEndsAt: soon(4) }),

  // ---- Home & wellness
  p('amz-weighted-blanket', 'amazon', 'B0SAMPLE20', 'Weighted Blanket, 15 lb', '🛏️', 'home', 49.99, 79.99, 49.99, 4.6, 33500, [12, 99], ['any'], ['partner', 'parent', 'sibling', 'friend', 'child'], ['wellness', 'home'], A3),
  p('amz-diffuser', 'amazon', 'B0SAMPLE21', 'Essential Oil Diffuser Gift Set', '🌿', 'home', 32.99, 45.99, 29.99, 4.5, 21000, [16, 99], ['any'], ALL, ['wellness', 'home'], A3),
  p('amz-massage-gun', 'amazon', 'B0SAMPLE22', 'Percussion Massage Gun', '💆', 'sports', 69.99, 129.99, 69.99, 4.5, 18800, [18, 99], ['any'], ['partner', 'parent', 'sibling', 'friend'], ['fitness', 'wellness', 'sports'], A3, { dealEndsAt: soon(1) }),
  p('tgt-candle-set', 'target', '90000010', 'Winter Woods Candle Trio', '🕯️', 'home', 19.99, 24.99, 19.99, 4.6, 2400, [16, 99], ['any'], ALL, ['home', 'wellness'], T3),
  p('tgt-sherpa-throw', 'target', '90000011', 'Sherpa Throw Blanket', '🧣', 'home', 25.0, 30.0, 25.0, 4.7, 5600, [5, 99], ['any'], ALL, ['home'], T3),
  p('wmt-photo-frame', 'walmart', '555000120', 'Wi-Fi Digital Photo Frame', '🖼️', 'electronics', 79.0, 129.0, 79.0, 4.6, 4100, [40, 99], ['any'], ['parent', 'grandparent'], ['home', 'tech'], W3),
  p('etsy-family-map', 'etsy', '1500000010', 'Personalised "Where We Met" Map Print', '🗺️', 'home', 45.0, 45.0, 45.0, 4.9, 6800, [18, 99], ['any'], ['partner'], ['art', 'travel', 'home'], E2, { processingDays: 2 }),
  p('etsy-recipe-board', 'etsy', '1500000011', 'Engraved Family Recipe Cutting Board', '🪵', 'kitchen', 52.0, 58.0, 52.0, 4.9, 4400, [30, 99], ['any'], ['parent', 'grandparent'], ['cooking', 'home'], E2, { processingDays: 3 }),
  p('etsy-birthstone-necklace', 'etsy', '1500000012', 'Dainty Birthstone Necklace', '💎', 'jewelry', 34.0, 42.0, 34.0, 4.8, 15200, [14, 99], ['female'], ['partner', 'parent', 'sibling', 'grandparent', 'friend', 'child'], ['fashion'], E2, { processingDays: 1 }),

  // ---- Beauty & fashion
  p('amz-skincare-set', 'amazon', 'B0SAMPLE30', 'Hydrating Skincare Gift Set', '🧴', 'beauty', 39.99, 54.0, 39.99, 4.5, 6200, [16, 99], ['female', 'any'], ['partner', 'parent', 'sibling', 'friend', 'grandparent'], ['beauty', 'wellness'], A3),
  p('amz-beard-kit', 'amazon', 'B0SAMPLE31', 'Beard Grooming Kit', '🧔', 'beauty', 24.99, 34.99, 22.99, 4.6, 14100, [18, 99], ['male'], ['partner', 'parent', 'sibling', 'friend', 'grandparent'], ['beauty', 'fashion'], A3),
  p('tgt-silk-pillowcase', 'target', '90000020', 'Mulberry Silk Pillowcase', '🌙', 'beauty', 29.99, 39.99, 29.99, 4.5, 3100, [14, 99], ['female', 'any'], ['partner', 'parent', 'sibling', 'friend'], ['beauty', 'wellness'], T3),
  p('tgt-slippers', 'target', '90000021', 'Memory-Foam Moccasin Slippers', '🥿', 'fashion', 22.99, 29.99, 22.99, 4.5, 7900, [12, 99], ['any'], ['parent', 'grandparent', 'partner', 'sibling'], ['home', 'fashion'], T3),
  p('amz-leather-wallet', 'amazon', 'B0SAMPLE32', 'Slim RFID Leather Wallet', '👛', 'fashion', 19.99, 29.99, 17.99, 4.5, 25000, [16, 99], ['male', 'any'], ['partner', 'parent', 'sibling', 'friend', 'grandparent', 'coworker'], ['fashion', 'travel'], A3),
  p('wmt-cashmere-scarf', 'walmart', '555000130', 'Cashmere-Blend Scarf', '🧶', 'fashion', 29.0, 45.0, 29.0, 4.4, 1300, [16, 99], ['any'], ['partner', 'parent', 'grandparent', 'sibling', 'friend'], ['fashion'], W2),

  // ---- Outdoors & fitness
  p('amz-insulated-bottle', 'amazon', 'B0SAMPLE40', 'Insulated Steel Water Bottle, 32 oz', '🧊', 'sports', 27.99, 34.99, 27.99, 4.8, 44100, [8, 99], ['any'], ALL, ['fitness', 'outdoors'], A3),
  p('amz-yoga-set', 'amazon', 'B0SAMPLE41', 'Yoga Mat and Block Set', '🧘', 'sports', 34.99, 49.99, 34.99, 4.6, 9200, [12, 99], ['any'], ['partner', 'sibling', 'friend', 'parent'], ['fitness', 'wellness'], A3),
  p('wmt-camp-lantern', 'walmart', '555000140', 'Rechargeable Camping Lantern, 2-pack', '🏕️', 'sports', 24.97, 34.97, 24.97, 4.6, 5600, [10, 99], ['any'], ALL, ['outdoors'], W3),
  p('tgt-hammock', 'target', '90000030', 'Portable Camping Hammock', '🌲', 'sports', 34.99, 39.99, 34.99, 4.7, 2900, [12, 70], ['any'], ['child', 'sibling', 'friend', 'partner'], ['outdoors', 'travel'], T2),
  p('bby-action-cam', 'bestbuy', '6500010', '4K Action Camera', '🎥', 'electronics', 199.99, 299.99, 199.99, 4.5, 3900, [14, 60], ['any'], ['partner', 'sibling', 'child', 'friend'], ['outdoors', 'sports', 'tech', 'travel'], B2, { dealEndsAt: soon(2) }),

  // ---- Kids & toys
  p('amz-building-set', 'amazon', 'B0SAMPLE50', 'Space Station Building Brick Set, 800 pcs', '🚀', 'toys', 49.99, 69.99, 49.99, 4.8, 12100, [8, 16], ['any'], ['child', 'sibling'], ['art', 'tech'], A3),
  p('amz-art-kit', 'amazon', 'B0SAMPLE51', 'Deluxe Art Set in Wooden Case, 150 pcs', '🎨', 'toys', 29.99, 44.99, 29.99, 4.6, 18300, [6, 16], ['any'], ['child', 'sibling'], ['art'], A3, { dealEndsAt: soon(3) }),
  p('amz-stem-robot', 'amazon', 'B0SAMPLE52', 'Code-Your-Own Robot Kit', '🤖', 'toys', 59.99, 79.99, 54.99, 4.5, 3400, [8, 14], ['any'], ['child'], ['tech', 'gaming'], A2),
  p('wmt-plush', 'walmart', '555000150', 'Giant Cuddly Bear Plush, 3 ft', '🧸', 'toys', 29.97, 39.97, 29.97, 4.7, 7700, [3, 12], ['any'], ['child', 'sibling'], ['home'], W3),
  p('wmt-scooter', 'walmart', '555000151', 'Light-Up Kick Scooter', '🛴', 'toys', 44.0, 59.0, 39.0, 4.6, 6300, [5, 12], ['any'], ['child'], ['outdoors', 'sports'], W3),
  p('tgt-dollhouse', 'target', '90000040', 'Wooden Dollhouse with Furniture', '🏠', 'toys', 89.99, 119.99, 89.99, 4.7, 2200, [3, 9], ['any'], ['child'], ['art', 'home'], T3),
  p('tgt-board-game', 'target', '90000041', 'Family Strategy Board Game', '🎲', 'games', 24.99, 29.99, 24.99, 4.7, 11800, [8, 99], ['any'], ALL, ['gaming'], T3),
  p('tgt-baby-play-mat', 'target', '90000042', 'Baby Activity Play Gym', '🍼', 'toys', 49.99, 59.99, 49.99, 4.8, 3100, [0, 2], ['any'], ['child'], ['home'], T3),

  // ---- Books, music, hobbies
  p('amz-cookbook', 'amazon', 'B0SAMPLE60', 'Bestselling Weeknight Cookbook (Hardcover)', '📗', 'books', 18.99, 35.0, 18.99, 4.8, 9800, [16, 99], ['any'], ALL, ['cooking', 'reading'], A3),
  p('amz-ukulele', 'amazon', 'B0SAMPLE61', 'Beginner Ukulele Starter Kit', '🎸', 'toys', 39.99, 49.99, 39.99, 4.6, 8900, [8, 99], ['any'], ['child', 'sibling', 'friend', 'partner'], ['music', 'art'], A2),
  p('etsy-star-map', 'etsy', '1500000020', 'Custom Star Map of a Special Night', '✨', 'home', 29.0, 36.0, 29.0, 4.9, 22000, [16, 99], ['any'], ['partner', 'parent', 'friend'], ['art', 'home'], E2, { processingDays: 1 }),
  p('etsy-pet-portrait', 'etsy', '1500000021', 'Hand-Drawn Pet Portrait (digital + print)', '🐶', 'home', 42.0, 50.0, 42.0, 4.9, 17300, [12, 99], ['any'], ALL.filter((r) => r !== 'coworker'), ['pets', 'art'], E2, { processingDays: 3 }),
  p('amz-pet-camera', 'amazon', 'B0SAMPLE62', 'Pet Camera with Treat Tosser', '🐾', 'electronics', 99.99, 149.99, 99.99, 4.4, 7200, [18, 99], ['any'], ['partner', 'parent', 'sibling', 'friend'], ['pets', 'tech'], A3),
  p('wmt-puzzle', 'walmart', '555000160', '1000-Piece Winter Village Jigsaw Puzzle', '🧩', 'games', 14.97, 19.97, 14.97, 4.7, 2800, [10, 99], ['any'], [...FAMILY, 'friend', 'coworker'], ['art', 'home'], W2),

  // ---- Safe office picks
  p('amz-desk-plant', 'amazon', 'B0SAMPLE70', 'Self-Watering Desk Succulent Trio', '🪴', 'home', 21.99, 26.99, 21.99, 4.4, 5200, [16, 99], ['any'], ['coworker', 'friend', 'sibling'], ['home'], A2),
  p('amz-cocoa-set', 'amazon', 'B0SAMPLE71', 'Gourmet Hot Cocoa Gift Box', '🍫', 'kitchen', 16.99, 22.99, 16.99, 4.6, 6600, [6, 99], ['any'], ALL, ['cooking', 'coffee'], A3),
  p('tgt-notebook-set', 'target', '90000050', 'Hardcover Notebook and Pen Gift Set', '📓', 'books', 14.99, 19.99, 14.99, 4.6, 2000, [12, 99], ['any'], ['coworker', 'friend', 'sibling', 'child'], ['art', 'reading'], T3),
];

export const INTERESTS = ['tech', 'gaming', 'cooking', 'coffee', 'fitness', 'outdoors', 'sports', 'reading', 'music', 'art', 'beauty', 'fashion', 'home', 'wellness', 'travel', 'pets'];
export const RELATIONSHIPS = ['partner', 'parent', 'child', 'sibling', 'friend', 'coworker', 'grandparent'];

export function byId(id) {
  return CATALOG.find((p) => p.id === id) ?? null;
}
