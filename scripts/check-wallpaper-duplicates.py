#!/usr/bin/env python3
"""Report identical and perceptually close wallpaper images; never deletes files.

Requires Pillow. The perceptual hash is useful for finding resized/recompressed
copies, while the RGB error helps avoid flagging intentional colorway variants.
"""
from __future__ import annotations

import hashlib
import math
import statistics
from itertools import combinations
from pathlib import Path

from PIL import Image, ImageOps

ROOT = Path(__file__).resolve().parent.parent
WALLPAPER_DIR = ROOT / "wallpaper"
EXTENSIONS = {".png", ".jpg", ".jpeg", ".webp", ".bmp"}
DCT_SIZE = 32
LOW_FREQ = 8


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def image_data(path: Path) -> tuple[list[bool], list[int], tuple[int, int]]:
    with Image.open(path) as source:
        size = source.size
        gray = source.convert("L").resize((DCT_SIZE, DCT_SIZE), Image.Resampling.LANCZOS)
        gray_pixels = list(gray.getdata())
        color = ImageOps.fit(source.convert("RGB"), (64, 36), method=Image.Resampling.LANCZOS)
        rgb_pixels = [channel for pixel in color.getdata() for channel in pixel]

    cosine_x = [
        [math.cos((2 * x + 1) * u * math.pi / (2 * DCT_SIZE)) for x in range(DCT_SIZE)]
        for u in range(LOW_FREQ)
    ]
    cosine_y = [
        [math.cos((2 * y + 1) * v * math.pi / (2 * DCT_SIZE)) for y in range(DCT_SIZE)]
        for v in range(LOW_FREQ)
    ]
    coeffs: list[float] = []
    for v in range(LOW_FREQ):
        for u in range(LOW_FREQ):
            total = 0.0
            cx, cy = cosine_x[u], cosine_y[v]
            for y in range(DCT_SIZE):
                row_start = y * DCT_SIZE
                total += cy[y] * sum(gray_pixels[row_start + x] * cx[x] for x in range(DCT_SIZE))
            coeffs.append(total)

    median = statistics.median(coeffs[1:])
    bits = [coefficient > median for coefficient in coeffs[1:]]
    return bits, rgb_pixels, size


def hamming(first: list[bool], second: list[bool]) -> int:
    return sum(left != right for left, right in zip(first, second, strict=True))


def mean_rgb_error(first: list[int], second: list[int]) -> float:
    return sum(abs(left - right) for left, right in zip(first, second, strict=True)) / len(first)


def main() -> int:
    if not WALLPAPER_DIR.is_dir():
        print("No wallpaper/ directory; skipping image check.")
        return 0

    files = sorted(
        path for path in WALLPAPER_DIR.iterdir()
        if path.is_file() and path.suffix.lower() in EXTENSIONS
    )
    if len(files) < 2:
        print(f"Found {len(files)} wallpaper image(s); nothing to compare.")
        return 0

    print(f"Wallpaper image check: {len(files)} files")
    file_hashes: dict[str, list[str]] = {}
    features = {}
    for path in files:
        digest = sha256(path)
        file_hashes.setdefault(digest, []).append(path.name)
        bits, rgb, size = image_data(path)
        features[path] = (bits, rgb)
        print(f"  {path.name} — {size[0]}x{size[1]} — sha256 {digest[:16]}")

    exact_found = False
    for names in file_hashes.values():
        if len(names) > 1:
            exact_found = True
            print("EXACT DUPLICATE: " + " == ".join(names))
    if not exact_found:
        print("Exact duplicate files: none.")

    candidates = []
    for first, second in combinations(files, 2):
        first_bits, first_rgb = features[first]
        second_bits, second_rgb = features[second]
        distance = hamming(first_bits, second_bits)
        rgb_error = mean_rgb_error(first_rgb, second_rgb)
        if distance <= 8:
            label = "LIKELY DUPLICATE" if distance <= 2 and rgb_error <= 12 else "REVIEW"
            candidates.append((distance, rgb_error, first.name, second.name, label))

    if not candidates:
        print("Perceptual check: no close image pairs were flagged.")
    else:
        print("Closest image pairs (perceptual hash distance / average RGB error):")
        for distance, rgb_error, first, second, label in sorted(candidates):
            print(f"  {label}: {first} <> {second} — pHash distance={distance}, RGB error={rgb_error:.2f}/255")
        print("No files were deleted; review flagged pairs before removing any image.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
