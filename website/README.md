# strokeandspineneuroscience.com

A static copy of gerarddeibmd.com for Stroke and Spine Neuroscience, LLC. It adds two things:

- **Company identity:** "Published by Stroke and Spine Neuroscience, LLC" in the footer of every page. Apple looks for this when verifying an organization.
- **App pages:** `/app/privacy/`, `/app/terms/` and `/app/support/` for the Stroke & Spine iPhone app. These are built from `docs/legal/*.md` by `scripts/build_app_pages.py`.

Notes on the copy:

- **Videos (380 MB) are not copied.** They still play from `https://gerarddeibmd.com/files/…`.
- **Canonical tags still point to gerarddeibmd.com,** so Google treats gerarddeibmd.com as the original and doesn't penalize the copy as duplicate content.
- **Email addresses are plain `mailto:` links.** The original site uses Cloudflare's email obfuscation, which only works on that site's own Cloudflare setup.

## 1. Buy the domain (about $10 a year)

gerarddeibmd.com is hosted on Cloudflare, so buying through **Cloudflare Registrar** keeps everything in one account. It sells domains at cost, with no markup.

1. Log in at https://dash.cloudflare.com with the account that runs gerarddeibmd.com.
2. Go to **Domain Registration → Register Domains**, search `strokeandspineneuroscience.com`, and buy it. Register it in the company's name: Stroke and Spine Neuroscience, LLC.

## 2. Publish this folder with Cloudflare Pages (free)

1. In the Cloudflare dashboard go to **Workers & Pages → Create → Pages → Connect to Git**.
2. Pick the GitHub repository `strokeandspine/Stroke-and-Spine` and the branch to publish from.
3. Build settings: Framework preset **None**, build command **empty**, build output directory **`website`**.
4. Click **Save and Deploy**.
5. Open the new project → **Custom domains → Set up a custom domain**, and add `strokeandspineneuroscience.com`, then `www.strokeandspineneuroscience.com`. Cloudflare creates the DNS records and the HTTPS certificate automatically.

From then on, every push to that branch updates the website.

## 3. Set up a company email address

Apple prefers a work email on the company's domain. With **Cloudflare Email Routing** (free), mail sent to an address like `apps@strokeandspineneuroscience.com` is forwarded to your existing inbox:

1. Open the domain in Cloudflare → **Email → Email Routing → Get started**.
2. Add a custom address such as `apps@`, `support@` or `privacy@`, and enter your existing inbox as the destination.

That address can then be used in the privacy policy, terms and support page.

## Updating the copy when gerarddeibmd.com changes

The pages here are a snapshot. If you change gerarddeibmd.com, ask Claude to refresh the mirror. Or, if that site's Astro source is in a repository, point both domains at the same Cloudflare Pages project and add the `/app/` pages to that source.
