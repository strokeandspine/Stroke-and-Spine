"""Rebuilds the app's privacy, terms and support pages on the company website
(website/app/*) from docs/legal/*.md, using the site's own header, footer and CSS.

Usage: pip install markdown && python3 scripts/build_app_pages.py
"""
import pathlib
import re

import markdown

ROOT = pathlib.Path(__file__).resolve().parent.parent
SITE = ROOT / "website"
COMPANY = "Stroke and Spine Neuroscience, LLC"
DOMAIN = "https://strokeandspineneuroscience.com"
PAGES = {
    "privacy": ("PRIVACY_POLICY.md", "Stroke & Spine app — Privacy Policy"),
    "terms": ("TERMS_OF_USE.md", "Stroke & Spine app — Terms of Use"),
    "support": ("SUPPORT.md", "Stroke & Spine app — Support"),
}
STYLE = ("<style>.legal{max-width:760px;margin:0 auto;padding:2rem 1rem 4rem}"
         ".legal table{border-collapse:collapse;width:100%;display:block;overflow-x:auto}"
         ".legal th,.legal td{border:1px solid color-mix(in srgb,currentColor 20%,transparent);padding:.5rem;text-align:left;vertical-align:top}"
         ".legal blockquote{border-left:4px solid var(--accent,#007a8c);margin:1rem 0;padding:.25rem 1rem;opacity:.8}</style>")

home = (SITE / "index.html").read_text(encoding="utf-8")
head = re.search(r"<head>.*?</head>", home, re.S).group(0)
header = re.search(r"<header.*?</header>", home, re.S).group(0)
footer = re.search(r"<footer.*?</footer>", home, re.S).group(0)

for slug, (src, title) in PAGES.items():
    md = (ROOT / "docs" / "legal" / src).read_text(encoding="utf-8")
    md = md.replace("(privacy.html)", "(/app/privacy/)").replace("(terms.html)", "(/app/terms/)")
    body = markdown.markdown(md, extensions=["tables"])
    h = re.sub(r"<title>.*?</title>", f"<title>{title}</title>", head)
    h = re.sub(r'<link rel="canonical"[^>]*>', f'<link rel="canonical" href="{DOMAIN}/app/{slug}/">', h)
    h = re.sub(r'<meta name="description"[^>]*>', f'<meta name="description" content="{title}, published by {COMPANY}.">', h)
    h = h.replace("</head>", STYLE + "</head>")
    out = SITE / "app" / slug / "index.html"
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(f'<!DOCTYPE html><html lang="en">{h}<body>{header}<main id="main" class="legal">{body}</main>{footer}</body></html>', encoding="utf-8")
    print("wrote", out.relative_to(ROOT))
