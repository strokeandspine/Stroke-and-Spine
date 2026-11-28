"""Draws the placeholder app icon (1024 × 1024, no transparency) — a white spine on a teal gradient.
Run: python3 scripts/make_app_icon.py   (needs Pillow). Replace with a designer's icon before launch if you like."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter
import math

S = 1024
img = Image.new("RGB", (S, S))
top, bottom = (22, 160, 160), (18, 82, 140)
px = img.load()
for y in range(S):
    t = y / (S - 1)
    c = tuple(round(top[i] + (bottom[i] - top[i]) * t) for i in range(3))
    for x in range(S):
        px[x, y] = c

layer = Image.new("RGBA", (S, S), (0, 0, 0, 0))
d = ImageDraw.Draw(layer)
n = 6
for i in range(n):
    t = i / (n - 1)
    cy = 210 + t * 600
    cx = S / 2 - 40 + math.sin(t * math.pi * 1.2 - 0.3) * 70     # gentle S-curve, centered
    w = 250 + 70 * t                                          # vertebrae widen toward the base
    h = 72
    d.rounded_rectangle([cx - w / 2, cy - h / 2, cx + w / 2, cy + h / 2], radius=34, fill=(255, 255, 255, 255))
    # small side processes
    d.rounded_rectangle([cx - w / 2 - 38, cy - 16, cx - w / 2 + 10, cy + 16], radius=16, fill=(255, 255, 255, 220))
    d.rounded_rectangle([cx + w / 2 - 10, cy - 16, cx + w / 2 + 38, cy + 16], radius=16, fill=(255, 255, 255, 220))

shadow = layer.split()[3].filter(ImageFilter.GaussianBlur(18)).point(lambda a: a * 0.35)
img.paste((0, 40, 70), (0, 14), shadow)
img.paste(layer, (0, 0), layer)

out = Path(__file__).resolve().parent.parent / "SpineCare/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon.png"
img.save(out, "PNG")
print("wrote", out)
