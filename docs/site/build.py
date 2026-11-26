"""Builds the hostable HTML pages in docs/site from the Markdown in docs/legal.

Usage: pip install markdown && python3 docs/site/build.py
"""
from pathlib import Path
import markdown

ROOT = Path(__file__).resolve().parent
LEGAL = ROOT.parent / "legal"
PAGES = {"privacy.html": ("PRIVACY_POLICY.md", "Privacy Policy"),
         "terms.html": ("TERMS_OF_USE.md", "Terms of Use"),
         "support.html": ("SUPPORT.md", "Support")}

TEMPLATE = """<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{title} — Stroke &amp; Spine</title>
<style>
  :root {{ --fg:#1d1d1f; --muted:#6e6e73; --bg:#fff; --line:#e5e5ea; --accent:#007a8c; }}
  @media (prefers-color-scheme: dark) {{ :root {{ --fg:#f5f5f7; --muted:#a1a1a6; --bg:#111; --line:#333; --accent:#38bdcc; }} }}
  body {{ margin:0; background:var(--bg); color:var(--fg); font:17px/1.6 -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; }}
  main {{ max-width:760px; margin:0 auto; padding:32px 16px 64px; }}
  h1 {{ font-size:2rem; line-height:1.2; }} h2 {{ margin-top:2rem; font-size:1.3rem; }}
  a {{ color:var(--accent); }} blockquote {{ margin:1rem 0; padding:.5rem 1rem; border-left:4px solid var(--accent); color:var(--muted); }}
  table {{ border-collapse:collapse; width:100%; display:block; overflow-x:auto; font-size:.95rem; }}
  th, td {{ border:1px solid var(--line); padding:8px; text-align:left; vertical-align:top; }}
</style>
</head>
<body><main>
{body}
</main></body>
</html>
"""

for out, (src, title) in PAGES.items():
    text = (LEGAL / src).read_text(encoding="utf-8")
    body = markdown.markdown(text, extensions=["tables"])
    (ROOT / out).write_text(TEMPLATE.format(title=title, body=body), encoding="utf-8")
    print("wrote", ROOT / out)
