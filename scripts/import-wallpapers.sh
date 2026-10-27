#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
BASE="https://raw.githubusercontent.com/a43039646-svg/itsuki-niri-rice/main/wallpaper"
FILES=(
  itsuki-neutral.png
  itsuki-neutral2.png
  itsuki_debian_wallpaper_v2_1600x900.png
  itsuki-arch.png
  itsuki-arch2.png
  itsuki-gentoo.png
  itsuki-gentoo2.png
)
if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
  echo "Install curl or wget first." >&2; exit 1
fi
mkdir -p "$ROOT/wallpaper"
for file in "${FILES[@]}"; do
  [[ -f "$ROOT/wallpaper/$file" ]] && { echo "Already present: $file"; continue; }
  echo "Downloading $file"
  if command -v curl >/dev/null 2>&1; then curl -fL --retry 2 "$BASE/$file" -o "$ROOT/wallpaper/$file"
  else wget -O "$ROOT/wallpaper/$file" "$BASE/$file"
  fi
done
echo "Wallpapers downloaded. Review the files, then git add, commit and push them if you want them stored in this repository."
