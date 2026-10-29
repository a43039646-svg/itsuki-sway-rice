#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPOSITORY_URL="https://github.com/a43039646-svg/itsuki-sway-rice.git"
TEMP_SOURCE_DIR=""
cleanup() {
  if [[ -n "$TEMP_SOURCE_DIR" && -d "$TEMP_SOURCE_DIR" ]]; then rm -rf -- "$TEMP_SOURCE_DIR"; fi
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

case "$PROFILE" in
  neutral) CONFIG_SOURCE="$ROOT/configs"; DISTRO_ICON="" ;;
  debian) CONFIG_SOURCE="$ROOT/configs"; DISTRO_ICON="" ;;
  arch) CONFIG_SOURCE="$ROOT/configs/arch"; DISTRO_ICON="" ;;
  gentoo) CONFIG_SOURCE="$ROOT/configs/gentoo"; DISTRO_ICON="" ;;
  *) echo "Unknown profile: $PROFILE (use neutral, debian, arch or gentoo)." >&2; exit 2 ;;
esac

case "$PROFILE" in
  neutral|debian)
    SWAY_ACCENT="#ff477f"; SWAY_SURFACE="#15162b"; SWAY_HIGHLIGHT="#ff9abb" ;;
  arch)
    SWAY_ACCENT="#5caeff"; SWAY_SURFACE="#0b162a"; SWAY_HIGHLIGHT="#a5d8ff" ;;
  gentoo)
    SWAY_ACCENT="#b58aff"; SWAY_SURFACE="#180f2a"; SWAY_HIGHLIGHT="#d8bcff" ;;
esac

for rel in waybar/config waybar/style.css kitty/kitty.conf fuzzel/fuzzel.ini dunst/dunstrc fetch/config xdg-desktop-portal/sway-portals.conf; do
  [[ -f "$CONFIG_SOURCE/$rel" ]] || { echo "Required file is missing: $CONFIG_SOURCE/$rel" >&2; exit 1; }
done
command -v python3 >/dev/null || { echo "Python 3 is required." >&2; exit 1; }

STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="$CONFIG_HOME/itsuki-sway-backup/$PROFILE/$STAMP"
SWAY_DIR="$CONFIG_HOME/sway"
SWAY_CONFIG="$SWAY_DIR/config"
SWAY_DROPIN="$SWAY_DIR/itsuki.conf"
mkdir -p "$BACKUP" "$HOME/.local/bin" "$CONFIG_HOME/waybar" "$CONFIG_HOME/kitty" "$CONFIG_HOME/fuzzel" "$CONFIG_HOME/dunst" "$CONFIG_HOME/fetch" "$CONFIG_HOME/xdg-desktop-portal" "$SWAY_DIR"

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
for rel in itsuki-power-menu itsuki-wifi-menu.py itsuki-slider.py itsuki-start-rice itsuki-reload-rice; do
  backup "$HOME/.local/bin/$rel" "local-bin/$rel"
done
SHELL_NAME="$(basename "${SHELL:-bash}")"
case "$SHELL_NAME" in bash) SHELL_RC="$HOME/.bashrc" ;; zsh) SHELL_RC="$HOME/.zshrc" ;; *) SHELL_RC="" ;; esac
if [[ -n "$SHELL_RC" ]]; then backup "$SHELL_RC" "$(basename "$SHELL_RC")"; fi

rm -f "$CONFIG_HOME/waybar/config.json" "$CONFIG_HOME/waybar/config.jsonc"
for rel in waybar/config waybar/style.css kitty/kitty.conf fuzzel/fuzzel.ini dunst/dunstrc fetch/config; do
  cp "$CONFIG_SOURCE/$rel" "$CONFIG_HOME/$rel"
done
install -m 0644 "$CONFIG_SOURCE/xdg-desktop-portal/sway-portals.conf" "$CONFIG_HOME/xdg-desktop-portal/sway-portals.conf"
install -m 0755 "$ROOT/scripts/itsuki-power-menu" "$HOME/.local/bin/itsuki-power-menu"
install -m 0755 "$ROOT/scripts/itsuki-wifi-menu.py" "$HOME/.local/bin/itsuki-wifi-menu.py"
install -m 0755 "$ROOT/scripts/itsuki-start-rice" "$HOME/.local/bin/itsuki-start-rice"
install -m 0755 "$ROOT/scripts/itsuki-reload-rice" "$HOME/.local/bin/itsuki-reload-rice"
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
# Profile-matched window borders and spacing.
gaps inner 8
gaps outer 3
default_border pixel 2
default_floating_border pixel 2
smart_borders on

client.focused $SWAY_ACCENT $SWAY_SURFACE #f5edf6 $SWAY_HIGHLIGHT $SWAY_ACCENT
client.focused_inactive #66405b #111322 #aaa8bd #66405b #66405b
client.unfocused #292039 #0b0d20 #9b91a7 #292039 #292039
client.urgent #ff315f #270f20 #ffffff #ff315f #ff315f

# Niri-Rice-style shortcuts.
bindsym Mod4+d exec fuzzel
bindsym Mod4+Return exec kitty
bindsym Mod4+e exec "$HOME/.local/bin/itsuki-power-menu"
bindsym Mod4+Shift+b exec --no-startup-id "$HOME/.local/bin/itsuki-reload-rice"

# Start the panel and notifications once per Sway session.
exec --no-startup-id "$HOME/.local/bin/itsuki-start-rice"
EOF

python3 - "$SWAY_CONFIG" "$SWAY_DROPIN" <<'PYSWAY'
from pathlib import Path
import re, shlex, sys
config=Path(sys.argv[1]); dropin=Path(sys.argv[2])
text=config.read_text()
kept=[]
for line in text.splitlines():
    if line.lstrip().startswith("#"):
        kept.append(line); continue
    match=re.match(r"^\s*exec(?:_always)?(?:\s+--no-startup-id)?\s+(.*)$",line)
    if match:
        try:
            command=shlex.split(match.group(1), comments=False)
        except ValueError:
            command=[]
        if command and Path(command[0]).name in {"waybar", "dunst"}:
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
bash -n "$HOME/.local/bin/itsuki-start-rice"
bash -n "$HOME/.local/bin/itsuki-reload-rice"
if command -v sway >/dev/null 2>&1; then sway -C -c "$SWAY_CONFIG"; fi
echo "Installed Itsuki Sway Rice ($PROFILE profile)."
echo "Backups: $BACKUP"
echo "Log out and choose Sway at the login screen, or reboot if Sway is not listed yet."
