"""Builds BioStack/web/index.html (a single self-contained page) from app.src.html
and Resources/catalog.json.

Usage: python3 BioStack/web/build.py
"""
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
catalog = json.loads((HERE.parent / "Resources" / "catalog.json").read_text())
src = (HERE / "app.src.html").read_text()
out = src.replace("__CATALOG__", json.dumps(catalog, ensure_ascii=False, separators=(",", ":")).replace("</", "<\\/"))
(HERE / "index.html").write_text(out)
print(f"wrote {HERE / 'index.html'} ({len(out) // 1024} KB)")
