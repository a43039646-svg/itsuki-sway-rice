#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPOSITORY_URL="https://github.com/a43039646-svg/itsuki-sway-rice.git"
WALLPAPER_REPOSITORY="https://raw.githubusercontent.com/a43039646-svg/itsuki-niri-rice/main/wallpaper"
TEMP_SOURCE_DIR=""
TEMP_WALLPAPER=""
cleanup() {
  if [[ -n "$TEMP_SOURCE_DIR" && -d "$TEMP_SOURCE_DIR" ]]; then rm -rf -- "$TEMP_SOURCE_DIR"; fi
  if [[ -n "$TEMP_WALLPAPER" && -f "$TEMP_WALLPAPER" ]]; then rm -f -- "$TEMP_WALLPAPER"; fi
}
trap cleanup EXIT

if [[ ! -d "$ROOT/configs" || ! -d "$ROOT/scripts" ]]; then
  TEMP_SOURCE_DIR="$(mktemp -d)"
  if command -v git >/dev/null 2>&1 && git clone --depth 1 --quiet "$REPOSITORY_URL" "$TEMP_SOURCE_DIR/repo"; then
    ROOT="$TEMP_SOURCE_DIR/repo"
  else
    echo "Could not download the rice. Install git and clone the repository first." >&2
    exit 1
  fi
fi

CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
PROFILE="${ITSUKI_DISTRO:-}"
if [[ -z "$PROFILE" ]]; then
  printf '\nItsuki Sway Rice — choose a theme\n  1) Neutral (rose, no distro logo)\n  2) Arch Linux (blue)\n  3) Debian (rose)\n  4) Gentoo (violet)\n\n'
  [[ -r /dev/tty && -w /dev/tty ]] || { echo "No interactive terminal; set ITSUKI_DISTRO=neutral|arch|debian|gentoo." >&2; exit 2; }
  while true; do
    IFS= read -r -p "Choose [1-4]: " choice </dev/tty || { echo "Installation cancelled." >&2; exit 2; }
    case "$choice" in
      1) PROFILE=neutral; break ;;
      2) PROFILE=arch; break ;;
      3) PROFILE=debian; break ;;
      4) PROFILE=gentoo; break ;;
      *) echo "Choose 1, 2, 3 or 4." ;;
    esac
  done
fi

WALLPAPER_STYLE="${ITSUKI_WALLPAPER_STYLE:-}"
if [[ -z "$WALLPAPER_STYLE" ]]; then
  printf '\nWallpaper\n  1) With Itsuki\n  2) Clean wallpaper (where available)\n\n'
  [[ -r /dev/tty && -w /dev/tty ]] || { echo "No interactive terminal; set ITSUKI_WALLPAPER_STYLE=character|clean." >&2; exit 2; }
  while true; do
    IFS= read -r -p "Choose [1-2]: " choice </dev/tty || { echo "Installation cancelled." >&2; exit 2; }
    case "$choice" in
      1) WALLPAPER_STYLE=character; break ;;
      2) WALLPAPER_STYLE=clean; break ;;
      *) echo "Choose 1 or 2." ;;
    esac
  done
fi
case "$WALLPAPER_STYLE" in character|clean) ;; *) echo "Unknown wallpaper style: $WALLPAPER_STYLE." >&2; exit 2 ;; esac

case "$PROFILE" in
  neutral) CONFIG_SOURCE="$ROOT/configs"; DISTRO_ICON=""; WALLPAPER_FILE="$([[ "$WALLPAPER_STYLE" == "clean" ]] && echo itsuki-neutral.png || echo itsuki-neutral2.png)" ;;
  debian) CONFIG_SOURCE="$ROOT/configs"; DISTRO_ICON=""; WALLPAPER_FILE="$([[ "$WALLPAPER_STYLE" == "clean" ]] && echo itsuki-neutral.png || echo itsuki_debian_wallpaper_v2_1600x900.png)" ;;
  arch) CONFIG_SOURCE="$ROOT/configs/arch"; DISTRO_ICON=""; WALLPAPER_FILE="$([[ "$WALLPAPER_STYLE" == "clean" ]] && echo itsuki-arch.png || echo itsuki-arch2.png)" ;;
  gentoo) CONFIG_SOURCE="$ROOT/configs/gentoo"; DISTRO_ICON=""; WALLPAPER_FILE="$([[ "$WALLPAPER_STYLE" == "clean" ]] && echo itsuki-gentoo.png || echo itsuki-gentoo2.png)" ;;
  *) echo "Unknown profile: $PROFILE (use neutral, debian, arch or gentoo)." >&2; exit 2 ;;
esac

for rel in waybar/config waybar/style.css kitty/kitty.conf fuzzel/fuzzel.ini dunst/dunstrc fetch/config xdg-desktop-portal/sway-portals.conf; do
  [[ -f "$CONFIG_SOURCE/$rel" ]] || { echo "Required file is missing: $CONFIG_SOURCE/$rel" >&2; exit 1; }
done
command -v python3 >/dev/null || { echo "Python 3 is required." >&2; exit 1; }

# Download and verify the selected wallpaper before changing any configuration.
TEMP_WALLPAPER="$(mktemp)"
WALLPAPER_URL="$WALLPAPER_REPOSITORY/$WALLPAPER_FILE"
if command -v curl >/dev/null 2>&1; then
  curl -fL --retry 2 "$WALLPAPER_URL" -o "$TEMP_WALLPAPER"
elif command -v wget >/dev/null 2>&1; then
  wget -O "$TEMP_WALLPAPER" "$WALLPAPER_URL"
else
  echo "Install curl or wget to download the wallpaper. No configuration was changed." >&2
  exit 1
fi
[[ -s "$TEMP_WALLPAPER" ]] || { echo "Wallpaper download was empty; no configuration was changed." >&2; exit 1; }

STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="$CONFIG_HOME/itsuki-sway-backup/$PROFILE/$STAMP"
SWAY_DIR="$CONFIG_HOME/sway"
SWAY_CONFIG="$SWAY_DIR/config"
SWAY_DROPIN="$SWAY_DIR/itsuki.conf"
mkdir -p "$BACKUP" "$HOME/.local/bin" "$HOME/Pictures/Wallpapers" "$CONFIG_HOME/waybar" "$CONFIG_HOME/kitty" "$CONFIG_HOME/fuzzel" "$CONFIG_HOME/dunst" "$CONFIG_HOME/fetch" "$CONFIG_HOME/xdg-desktop-portal" "$SWAY_DIR"

backup() {
  local path="$1" relative="$2"
  if [[ -f "$path" || -L "$path" ]]; then
    mkdir -p "$BACKUP/$(dirname "$relative")"
    cp -a "$path" "$BACKUP/$relative"
  fi
}
for rel in waybar/config waybar/style.css kitty/kitty.conf fuzzel/fuzzel.ini dunst/dunstrc fetch/config xdg-desktop-portal/sway-portals.conf sway/config sway/itsuki.conf; do
  backup "$CONFIG_HOME/$rel" "$rel"
done
for rel in waybar/config.json waybar/config.jsonc; do backup "$CONFIG_HOME/$rel" "$rel"; done
for file in "$HOME/Pictures/Wallpapers/itsuki.png" "$HOME/Pictures/Wallpapers/itsuki.jpg"; do
  [[ ! -f "$file" ]] || backup "$file" "wallpaper/$(basename "$file")"
done
SHELL_NAME="$(basename "${SHELL:-bash}")"
case "$SHELL_NAME" in bash) SHELL_RC="$HOME/.bashrc" ;; zsh) SHELL_RC="$HOME/.zshrc" ;; *) SHELL_RC="" ;; esac
if [[ -n "$SHELL_RC" ]]; then backup "$SHELL_RC" "$(basename "$SHELL_RC")"; fi

rm -f "$CONFIG_HOME/waybar/config.json" "$CONFIG_HOME/waybar/config.jsonc"
for rel in waybar/config waybar/style.css kitty/kitty.conf fuzzel/fuzzel.ini dunst/dunstrc fetch/config; do
  cp "$CONFIG_SOURCE/$rel" "$CONFIG_HOME/$rel"
done
install -m 0644 "$CONFIG_SOURCE/xdg-desktop-portal/sway-portals.conf" "$CONFIG_HOME/xdg-desktop-portal/sway-portals.conf"
install -m 0644 "$TEMP_WALLPAPER" "$HOME/Pictures/Wallpapers/itsuki.png"
install -m 0755 "$ROOT/scripts/itsuki-power-menu" "$HOME/.local/bin/itsuki-power-menu"
install -m 0755 "$ROOT/scripts/itsuki-wifi-menu.py" "$HOME/.local/bin/itsuki-wifi-menu.py"
SLIDER_SOURCE="$CONFIG_SOURCE/scripts/itsuki-slider.py"
[[ -f "$SLIDER_SOURCE" ]] || SLIDER_SOURCE="$ROOT/scripts/itsuki-slider.py"
install -m 0755 "$SLIDER_SOURCE" "$HOME/.local/bin/itsuki-slider.py"

python3 - "$CONFIG_HOME/waybar/config" "$DISTRO_ICON" "$PROFILE" <<'PYWAYBAR'
import json,sys
from pathlib import Path
path=Path(sys.argv[1]); icon=sys.argv[2]; profile=sys.argv[3]
cfg=json.loads(path.read_text())
left=cfg.setdefault("modules-left",[])
left=[m for m in left if m not in ("custom/debian","custom/distro","niri/workspaces","sway/workspaces")]
cfg.pop("custom/debian",None)
if icon:
    left.insert(0,"custom/distro")
    label={"debian":"Debian","arch":"Arch Linux","gentoo":"Gentoo"}.get(profile,profile.title())
    cfg["custom/distro"]={"format":icon,"tooltip":label,"on-click":"fuzzel"}
else:
    cfg.pop("custom/distro",None)
left.append("sway/workspaces")
cfg["modules-left"]=left
for key in ("modules-center","modules-right"):
    cfg[key]=[m for m in cfg.get(key,[]) if m!="niri/workspaces"]
cfg.setdefault("sway/workspaces",{"format":"{icon}","disable-scroll":True,"all-outputs":True,"format-icons":{"focused":"●","active":"●","default":"○","urgent":"!"}})
cfg.setdefault("modules-right",[])
if "tray" not in cfg["modules-right"]: cfg["modules-right"].append("tray")
path.write_text(json.dumps(cfg,indent=2,ensure_ascii=False)+"\n")
PYWAYBAR

if [[ ! -f "$SWAY_CONFIG" ]]; then
  if [[ -f /etc/sway/config ]]; then cp /etc/sway/config "$SWAY_CONFIG"
  else printf 'set $mod Mod4\nfloating_modifier $mod\nbindsym $mod+Shift+q kill\n' > "$SWAY_CONFIG"
  fi
fi
cat > "$SWAY_DROPIN" <<EOF
# Itsuki Sway Rice — generated by install.sh
bindsym Mod4+d exec fuzzel
bindsym Mod4+Return exec kitty
bindsym Mod4+e exec "$HOME/.local/bin/itsuki-power-menu"
exec_always --no-startup-id waybar
exec_always --no-startup-id dunst
exec_always --no-startup-id swaybg -i "$HOME/Pictures/Wallpapers/itsuki.png" -m fill
EOF

python3 - "$SWAY_CONFIG" "$SWAY_DROPIN" <<'PYSWAY'
from pathlib import Path
import re,sys
config=Path(sys.argv[1]); dropin=Path(sys.argv[2])
text=config.read_text()
kept=[]
for line in text.splitlines():
    if line.lstrip().startswith("#"):
        kept.append(line); continue
    if re.match(r"^\s*exec(?:_always)?(?:\s+--no-startup-id)?\s+.*\b(?:waybar|dunst|swaybg)\b",line):
        continue
    kept.append(line)
text="\n".join(kept).rstrip()+"\n"
marker="# BEGIN ITSUKI SWAY RICE"
end="# END ITSUKI SWAY RICE"
block=f"{marker}\ninclude {dropin}\n{end}"
pattern=re.compile(r"(?ms)^# BEGIN ITSUKI SWAY RICE\n.*?^# END ITSUKI SWAY RICE[ \t]*(?:\n|$)")
if pattern.search(text): text=pattern.sub(block+"\n",text,count=1)
else: text=text.rstrip()+"\n\n"+block+"\n"
config.write_text(text)
PYSWAY

if [[ -n "$SHELL_RC" ]]; then
  python3 - "$SHELL_RC" <<'PYFETCH'
from pathlib import Path
import re,sys
p=Path(sys.argv[1])
block="""# ITSUKI_FETCH_AUTOSTART: show animated system info in interactive terminals.
if [[ $- == *i* ]] && command -v fetch >/dev/null 2>&1; then
    fetch --box --shading-mode sextants
fi"""
text=p.read_text() if p.exists() else ""
pattern=re.compile(r"(?ms)^# ITSUKI_FETCH_AUTOSTART:[^\n]*\n.*?^fi[ \t]*(?:\n|$)")
if "# ITSUKI_FETCH_AUTOSTART:" in text:
    m=pattern.search(text)
    if m: text=text[:m.start()]+block+"\n"+text[m.end():]
    else: raise SystemExit("Found the Fetch marker but could not safely update its block; restore the shell file from the backup.")
else: text=text.rstrip()+"\n\n"+block+"\n"
p.write_text(text)
PYFETCH
fi

python3 -m json.tool "$CONFIG_HOME/waybar/config" >/dev/null
if command -v sway >/dev/null 2>&1; then sway -C -c "$SWAY_CONFIG"; fi
echo "Installed Itsuki Sway Rice ($PROFILE profile)."
echo "Wallpaper: $HOME/Pictures/Wallpapers/itsuki.png"
echo "Backups: $BACKUP"
echo "Log out and choose Sway at the login screen, or reboot if Sway is not listed yet."
