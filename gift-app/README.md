# MerryCart: Christmas gift finder

A web app (installable on phones as a home-screen app) that helps shoppers pick Christmas gifts and buy them from Amazon, Walmart, Target, Best Buy and Etsy. Every purchase goes through an affiliate link, so the app earns a commission on each sale.

## What it does

| Feature | How it works | Code |
|---|---|---|
| **Gift recommendations** | Shopper enters the recipient's age, gender, relationship (partner, parent, child, sibling, friend, coworker, grandparent), price range, optional interests and an optional "must arrive by" date. Products are scored and each result explains why it was picked ("Made for ages 8–16", "Matches cooking", "29% off"). | `src/recommend.js` |
| **Special deals** | Shows only real markdowns: at least 15% off list price, the lowest price in 30 days, or a limited-time deal. Ranked by a deal score, with badges like "Ends in 5h". | `src/deals.js` |
| **Arrives fast** | Lists gifts by earliest delivery date if ordered now, with an "Overnight / same-day only" switch and an "arrive by" date. Each card says whether it arrives in time for Christmas. A banner shows the last day to order with standard, 2-day and overnight shipping. | `src/delivery.js` |
| **Cart and checkout** | Shoppers build one gift list across retailers. At checkout it's split by retailer: Amazon items go into the shopper's Amazon cart with one tap (Amazon's add-to-cart link), and other retailers get one tracked link per item. Payment happens on each retailer's own checkout. | `src/api.js` (`checkout`) |
| **Commission tracking** | Every "Buy" goes through `/go/<product>`, which records the click and redirects with your affiliate ID. The click ID is passed to the affiliate network as a sub-ID so their commission reports can be matched back to clicks. | `src/api.js`, `src/retailers.js` |

### Recommendation rules
- Price range and stock are hard filters.
- Never recommends a product below its minimum age, since toy safety labels are age-based. Products for a much younger age group are dropped.
- Gender only nudges the ranking. It never hides gender-neutral gifts, and "Any" is the default.
- Personal items (jewelry, beauty, clothing) aren't shown for coworkers unless the product is marked as suitable.
- Interests, ratings, deals and how much of the budget the gift uses all add to the score. Results are kept varied: no more than 3 from one category near the top, unless they match a chosen interest.

## Important: what "buy through the app" means

Amazon and the other big retailers **don't let outside apps take payment for their products**. Affiliate programmes work by sending the shopper to the retailer with your tracking ID, and the retailer pays you a percentage when the shopper buys. MerryCart makes this as smooth as possible (one gift list, one tap to fill the Amazon cart), but the shopper always confirms and pays on the retailer's site. Taking payment inside the app would make you a reseller: you'd buy the items yourself, handle returns and carry the payment risk. That's a much bigger business.

## Run it

Requires Node 20 or later. No packages to install.

```bash
cd gift-app
npm run dev        # http://localhost:8787
npm test           # 31 tests: delivery dates, recommendations, deals, checkout, affiliate links
```

To preview a later date during development, add `?now=2026-12-20T15:00:00Z` to the URL.

## Deploy (Cloudflare Workers)

```bash
cd gift-app
npx wrangler deploy
```

`wrangler.jsonc` serves `public/` and the API from one Worker. To keep click records, create a KV namespace and add the `CLICKS` binding shown in the comment in `wrangler.jsonc`.

## Before launch: checklist

1. **Replace the sample catalog.** `src/catalog.js` is made-up sample data, and the app shows a "sample products" notice until it's replaced. Never show sample prices to real shoppers.
2. **Join the affiliate programmes** and set their IDs as Worker variables or secrets:

   | Retailer | Programme | Variables |
   |---|---|---|
   | Amazon | Amazon Associates | `AMAZON_ASSOCIATE_TAG`; for live products also `AMAZON_ACCESS_KEY`, `AMAZON_SECRET_KEY` (secrets) |
   | Walmart | Walmart Creator / Impact | `WALMART_PUBLISHER_ID`, `WALMART_AD_ID`, `WALMART_PROGRAM_ID` |
   | Target | Target Partners / Impact | `TARGET_PUBLISHER_ID`, `TARGET_AD_ID`, `TARGET_PROGRAM_ID` |
   | Best Buy | Best Buy Affiliate / Impact | `BESTBUY_PUBLISHER_ID`, `BESTBUY_AD_ID`, `BESTBUY_PROGRAM_ID` |
   | Etsy | Etsy Affiliate / Awin | `ETSY_AWIN_MID`, `AWIN_AFFILIATE_ID` |

   Each network gives you its exact link format. If it differs from the default in `src/retailers.js`, set `<RETAILER>_LINK_TEMPLATE` (for example `WALMART_LINK_TEMPLATE`) using `{url}` and `{subid}` placeholders. Until a retailer's IDs are set, its links go to the plain product page and earn nothing. A warning is logged when that happens.
3. **Check the commission rates** in `src/retailers.js`. They're planning estimates only. Use the rates from your own affiliate dashboards.
4. **Live products.** `src/providers/amazon.js` pulls live Amazon items through the Product Advertising API. Amazon only grants API access after your Associates account makes qualifying sales, and has been moving developers to newer APIs, so confirm the current API before relying on it. This adapter hasn't been run against the live API. For the other retailers, use the product feeds their affiliate networks provide.
5. **Follow the programme rules.** The main Amazon ones: refresh prices at least every 24 hours, show when an Amazon price was last updated, and keep the "As an Amazon Associate we earn from qualifying purchases" disclosure (it's in the footer). The FTC also requires a clear affiliate disclosure, which is in the footer and the cart.
6. **Delivery dates are estimates** from each retailer's typical cut-off times and transit days (`SHIPPING` in `src/retailers.js`). Live data (for example Amazon's Prime flag) narrows them, but the retailer's checkout is the final word, and the app says so.
