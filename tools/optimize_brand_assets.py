#!/usr/bin/env python3
"""Resize brand PNGs for mobile runtime memory (run from repo root)."""
from __future__ import annotations

from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
BRAND = ROOT / "assets" / "brand"


def save_png(img: Image.Image, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    # Palette/RGBA preserved; optimize reduces file size.
    img.save(path, format="PNG", optimize=True, compress_level=9)


def fit_max_side(img: Image.Image, max_side: int) -> Image.Image:
    w, h = img.size
    longest = max(w, h)
    if longest <= max_side:
        return img
    scale = max_side / longest
    nw = max(1, int(round(w * scale)))
    nh = max(1, int(round(h * scale)))
    return img.resize((nw, nh), Image.Resampling.LANCZOS)


def fit_max_width(img: Image.Image, max_w: int) -> Image.Image:
    w, h = img.size
    if w <= max_w:
        return img
    scale = max_w / w
    nw = max_w
    nh = max(1, int(round(h * scale)))
    return img.resize((nw, nh), Image.Resampling.LANCZOS)


def square_center_crop(img: Image.Image, side: int) -> Image.Image:
    w, h = img.size
    short = min(w, h)
    left = (w - short) // 2
    top = (h - short) // 2
    cropped = img.crop((left, top, left + short, top + short))
    return cropped.resize((side, side), Image.Resampling.LANCZOS)


def main() -> None:
    # Illustrations: cap longest side 1200px (~900–1200 wide typical landscape).
    ill = BRAND / "illustrations"
    for path in sorted(ill.glob("*.png")):
        im = Image.open(path).convert("RGBA")
        out = fit_max_side(im, 1200)
        save_png(out, path)
        print(f"illustration {path.name}: {im.size} -> {out.size}")

    # Logos
    logos = [
        ("prani_doctor_primary_logo.png", lambda i: fit_max_width(i, 512)),
        ("prani_doctor_horizontal_wordmark.png", lambda i: fit_max_side(fit_max_width(i, 900), 1000)),
        ("prani_doctor_alt_logo_earth_tone.png", lambda i: fit_max_width(i, 512)),
    ]
    for name, fn in logos:
        path = BRAND / "logos" / name
        im = Image.open(path).convert("RGBA")
        out = fn(im)
        save_png(out, path)
        print(f"logo {name}: {im.size} -> {out.size}")

    # Launcher source: 1024 square (tool generates mipmaps).
    icon_path = BRAND / "app_icons" / "prani_doctor_app_icon.png"
    im = Image.open(icon_path).convert("RGBA")
    out = square_center_crop(im, 1024)
    save_png(out, icon_path)
    print(f"app icon: {im.size} -> {out.size}")

    print("Done.")


if __name__ == "__main__":
    main()
