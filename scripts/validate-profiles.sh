#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd -- "$(dirname -- "$0")/.." && pwd)"
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
if "backlight" not in mods: raise SystemExit(f"{profile}: missing backlight module")
if cfg.get("modules-right",[]).count("tray")!=1: raise SystemExit(f"{profile}: tray must appear once")
if cfg.get("backlight",{}).get("on-scroll-up") != "brightnessctl -c backlight set +5%":
    raise SystemExit(f"{profile}: incorrect backlight scroll-up command")
if cfg.get("backlight",{}).get("on-scroll-down") != "brightnessctl -c backlight set 5%-":
    raise SystemExit(f"{profile}: incorrect backlight scroll-down command")
if len(re.findall(r"(?m)^color(?:[0-9]|1[0-5])\s+#?[0-9a-fA-F]{6}\s*$",Path(kitty).read_text()))!=16:
    raise SystemExit(f"{profile}: expected 16 Kitty ANSI colors")
PY
  echo "[$profile] OK"
done

for rel in \
  configs/lightdm/lightdm-gtk-greeter.conf \
  configs/lightdm/lightdm-gtk-greeter-arch.conf \
  configs/lightdm/lightdm-gtk-greeter-gentoo.conf \
  configs/lightdm/lightdm-gtk-greeter-neutral.conf \
  lightdm/themes/Itsuki-Rose/gtk-3.0/gtk.css \
  lightdm/themes/Itsuki-Rose/index.theme \
  lightdm/themes/Itsuki-Arch/gtk-3.0/gtk.css \
  lightdm/themes/Itsuki-Arch/index.theme \
  lightdm/themes/Itsuki-Gentoo/gtk-3.0/gtk.css \
  lightdm/themes/Itsuki-Gentoo/index.theme; do
  [[ -f "$ROOT/$rel" ]] || { echo "Missing LightDM file: $rel" >&2; exit 1; }
done

bash -n "$ROOT/install.sh"
bash -n "$ROOT/install-lightdm.sh"
bash -n "$ROOT/scripts/itsuki-power-menu"
bash -n "$ROOT/scripts/itsuki-start-rice"
bash -n "$ROOT/scripts/itsuki-reload-rice"
grep -q 'ITSUKI_WALLPAPER' "$ROOT/install.sh"
grep -q 'remove_swaybar_blocks' "$ROOT/install.sh"
grep -q 'itsuki-wallpaper.path' "$ROOT/scripts/itsuki-start-rice"
bash -n "$ROOT/scripts/import-wallpapers.sh"
for wrapper in "$ROOT"/variants/*/install.sh; do bash -n "$wrapper"; done
python3 - "$ROOT/scripts/itsuki-slider.py" "$ROOT/scripts/itsuki-wifi-menu.py" "$ROOT/scripts/check-wallpaper-duplicates.py" <<'PY'
import sys
from pathlib import Path
for f in sys.argv[1:]: compile(Path(f).read_text(),f,"exec")
PY
echo "Static checks passed."