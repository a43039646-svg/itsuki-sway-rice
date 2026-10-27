#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
for profile in neutral debian arch gentoo; do
  case "$profile" in arch|gentoo) source="$ROOT/configs/$profile" ;; *) source="$ROOT/configs" ;; esac
  for rel in waybar/config waybar/style.css kitty/kitty.conf fuzzel/fuzzel.ini dunst/dunstrc fetch/config xdg-desktop-portal/sway-portals.conf; do
    [[ -f "$source/$rel" ]] || { echo "Missing $profile file: $rel" >&2; exit 1; }
  done
  python3 - "$profile" "$source/waybar/config" "$source/kitty/kitty.conf" <<'PY'
import json,re,sys
from pathlib import Path
profile,waybar,kitty=sys.argv[1:]
cfg=json.loads(Path(waybar).read_text())
mods=sum((cfg.get(k,[]) for k in ("modules-left","modules-center","modules-right")),[])
if len(mods)!=len(set(mods)): raise SystemExit(f"{profile}: duplicate Waybar module")
if "sway/workspaces" not in mods: raise SystemExit(f"{profile}: missing sway/workspaces")
if cfg.get("modules-right",[]).count("tray")!=1: raise SystemExit(f"{profile}: tray must appear once")
if len(re.findall(r"(?m)^color(?:[0-9]|1[0-5])\\s+#?[0-9a-fA-F]{6}\\s*$",Path(kitty).read_text()))!=16:
    raise SystemExit(f"{profile}: expected 16 Kitty ANSI colors")
PY
  echo "[$profile] OK"
done
bash -n "$ROOT/install.sh"
bash -n "$ROOT/scripts/itsuki-power-menu"
python3 - "$ROOT/scripts/itsuki-slider.py" "$ROOT/scripts/itsuki-wifi-menu.py" <<'PY'
import sys
from pathlib import Path
for f in sys.argv[1:]: compile(Path(f).read_text(),f,"exec")
PY
echo "Static checks passed."
