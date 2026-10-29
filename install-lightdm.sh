#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPOSITORY_URL="https://github.com/a43039646-svg/itsuki-sway-rice.git"
TEMP_SOURCE_DIR=""
TEMP_WALLPAPER=""
TEMP_CONFIG=""
LIGHTDM_DIR="/etc/lightdm"
CONFIG_DEST="$LIGHTDM_DIR/lightdm-gtk-greeter.conf"

if [[ ! -d "$ROOT/configs/lightdm" || ! -d "$ROOT/lightdm/themes" || ! -d "$ROOT/wallpaper" ]]; then
  TEMP_SOURCE_DIR="$(mktemp -d)"
  if command -v git >/dev/null 2>&1 && git clone --depth 1 --quiet "$REPOSITORY_URL" "$TEMP_SOURCE_DIR/repo"; then
    ROOT="$TEMP_SOURCE_DIR/repo"
  elif command -v curl >/dev/null 2>&1 && command -v tar >/dev/null 2>&1; then
    if ! curl -fsSL "https://github.com/a43039646-svg/itsuki-sway-rice/archive/refs/heads/main.tar.gz" -o "$TEMP_SOURCE_DIR/repo.tar.gz"; then
      echo "Could not download Itsuki Sway Rice assets. No LightDM files were changed." >&2
      exit 1
    fi
    tar -xzf "$TEMP_SOURCE_DIR/repo.tar.gz" -C "$TEMP_SOURCE_DIR"
    ROOT="$TEMP_SOURCE_DIR/itsuki-sway-rice-main"
  else
    echo "Could not download Itsuki Sway Rice assets. Install git, or curl and tar." >&2
    exit 1
  fi
fi

cleanup_lightdm() {
  [[ -n "$TEMP_WALLPAPER" ]] && rm -f -- "$TEMP_WALLPAPER"
  [[ -n "$TEMP_CONFIG" ]] && rm -f -- "$TEMP_CONFIG"
  [[ -n "$TEMP_SOURCE_DIR" && -d "$TEMP_SOURCE_DIR" ]] && rm -rf -- "$TEMP_SOURCE_DIR"
}
trap cleanup_lightdm EXIT

if [[ ! -d "$LIGHTDM_DIR" ]]; then
  echo "LightDM configuration directory $LIGHTDM_DIR does not exist. Is LightDM installed?" >&2
  exit 1
fi

if [[ ! -r /dev/tty || ! -w /dev/tty ]]; then
  if [[ -z "${ITSUKI_LIGHTDM_PROFILE:-}" || -z "${ITSUKI_LIGHTDM_WALLPAPER:-}" ]]; then
    echo "An interactive terminal is required, or set ITSUKI_LIGHTDM_PROFILE and ITSUKI_LIGHTDM_WALLPAPER." >&2
    exit 2
  fi
fi

if [[ -n "${ITSUKI_LIGHTDM_PROFILE:-}" ]]; then
  PROFILE="$ITSUKI_LIGHTDM_PROFILE"
else
  printf '\nItsuki LightDM greeter — choose a profile\n'
  printf '  1) Debian\n'
  printf '  2) Arch Linux\n'
  printf '  3) Gentoo\n'
  printf '  4) Neutral (no distro logo)\n\n'
  while true; do
    if ! IFS= read -r -p "Choose profile [1-4]: " choice </dev/tty; then
      echo "No profile selected; cancelled." >&2
      exit 2
    fi
    case "$choice" in
      1) PROFILE="debian"; break ;;
      2) PROFILE="arch"; break ;;
      3) PROFILE="gentoo"; break ;;
      4) PROFILE="neutral"; break ;;
      *) echo "Invalid choice. Enter 1, 2, 3, or 4." >&2 ;;
    esac
  done
fi

if [[ -n "${ITSUKI_LIGHTDM_WALLPAPER:-}" ]]; then
  WALLPAPER_STYLE="$ITSUKI_LIGHTDM_WALLPAPER"
else
  printf '\nChoose the greeter background\n'
  printf '  1) With Itsuki\n'
  printf '  2) Without Itsuki\n\n'
  while true; do
    if ! IFS= read -r -p "Choose background [1-2]: " choice </dev/tty; then
      echo "No background selected; cancelled." >&2
      exit 2
    fi
    case "$choice" in
      1) WALLPAPER_STYLE="character"; break ;;
      2) WALLPAPER_STYLE="clean"; break ;;
      *) echo "Invalid choice. Enter 1 or 2." >&2 ;;
    esac
  done
fi

case "$PROFILE" in
  debian)
    PROFILE_LABEL="Debian"
    GTK_THEME_NAME="Itsuki-Rose"
    CONFIG_SRC="$ROOT/configs/lightdm/lightdm-gtk-greeter.conf"
    if [[ "$WALLPAPER_STYLE" == "character" ]]; then
      WALLPAPER_SRC="$ROOT/wallpaper/itsuki_debian_wallpaper_v2_1600x900.png"
      WALLPAPER_DEST="/usr/share/backgrounds/itsuki-lightdm-debian-character.png"
    elif [[ "$WALLPAPER_STYLE" == "clean" ]]; then
      WALLPAPER_SRC="$ROOT/wallpaper/neutral.png"
      WALLPAPER_DEST="/usr/share/backgrounds/itsuki-lightdm-debian-clean.png"
    else
      echo "Unknown wallpaper style '$WALLPAPER_STYLE' (use character or clean)." >&2
      exit 2
    fi
    ;;
  arch)
    PROFILE_LABEL="Arch Linux"
    GTK_THEME_NAME="Itsuki-Arch"
    CONFIG_SRC="$ROOT/configs/lightdm/lightdm-gtk-greeter-arch.conf"
    if [[ "$WALLPAPER_STYLE" == "character" ]]; then
      WALLPAPER_SRC="$ROOT/wallpaper/itsuki-arch2.png"
      WALLPAPER_DEST="/usr/share/backgrounds/itsuki-lightdm-arch-character.png"
    elif [[ "$WALLPAPER_STYLE" == "clean" ]]; then
      WALLPAPER_SRC="$ROOT/wallpaper/itsuki-arch.png"
      WALLPAPER_DEST="/usr/share/backgrounds/itsuki-lightdm-arch.png"
    else
      echo "Unknown wallpaper style '$WALLPAPER_STYLE' (use character or clean)." >&2
      exit 2
    fi
    ;;
  gentoo)
    PROFILE_LABEL="Gentoo"
    GTK_THEME_NAME="Itsuki-Gentoo"
    CONFIG_SRC="$ROOT/configs/lightdm/lightdm-gtk-greeter-gentoo.conf"
    if [[ "$WALLPAPER_STYLE" == "character" ]]; then
      WALLPAPER_SRC="$ROOT/wallpaper/itsuki-gentoo2.png"
      WALLPAPER_DEST="/usr/share/backgrounds/itsuki-lightdm-gentoo-character.png"
    elif [[ "$WALLPAPER_STYLE" == "clean" ]]; then
      WALLPAPER_SRC="$ROOT/wallpaper/itsuki-gentoo.png"
      WALLPAPER_DEST="/usr/share/backgrounds/itsuki-lightdm-gentoo.png"
    else
      echo "Unknown wallpaper style '$WALLPAPER_STYLE' (use character or clean)." >&2
      exit 2
    fi
    ;;
  neutral)
    PROFILE_LABEL="Neutral"
    GTK_THEME_NAME="Itsuki-Rose"
    CONFIG_SRC="$ROOT/configs/lightdm/lightdm-gtk-greeter-neutral.conf"
    if [[ "$WALLPAPER_STYLE" == "character" ]]; then
      WALLPAPER_SRC="$ROOT/wallpaper/itsuki-neutral2.png"
      WALLPAPER_DEST="/usr/share/backgrounds/itsuki-lightdm-neutral-character.png"
    elif [[ "$WALLPAPER_STYLE" == "clean" ]]; then
      WALLPAPER_SRC="$ROOT/wallpaper/itsuki-neutral.png"
      WALLPAPER_DEST="/usr/share/backgrounds/itsuki-lightdm-neutral.png"
    else
      echo "Unknown wallpaper style '$WALLPAPER_STYLE' (use character or clean)." >&2
      exit 2
    fi
    ;;
  *)
    echo "Unknown profile '$PROFILE'. Use debian, arch, gentoo, or neutral." >&2
    exit 2
    ;;
esac

GTK_THEME_CSS_SRC="$ROOT/lightdm/themes/$GTK_THEME_NAME/gtk-3.0/gtk.css"
GTK_THEME_INDEX_SRC="$ROOT/lightdm/themes/$GTK_THEME_NAME/index.theme"
GTK_THEME_CSS_DEST="/usr/share/themes/$GTK_THEME_NAME/gtk-3.0/gtk.css"
GTK_THEME_INDEX_DEST="/usr/share/themes/$GTK_THEME_NAME/index.theme"

if [[ ! -f "$CONFIG_SRC" ]]; then
  echo "Missing LightDM greeter profile: $CONFIG_SRC" >&2
  exit 1
fi
if [[ ! -f "$GTK_THEME_CSS_SRC" || ! -f "$GTK_THEME_INDEX_SRC" ]]; then
  echo "Missing GTK theme files for $GTK_THEME_NAME under $ROOT/lightdm/themes/." >&2
  echo "No LightDM settings have been changed." >&2
  exit 1
fi
if [[ ! -f "$WALLPAPER_SRC" ]]; then
  WALLPAPER_FILE="$(basename "$WALLPAPER_SRC")"
  case "$WALLPAPER_FILE" in
    itsuki-neutral.png|itsuki-neutral2.png|itsuki-arch.png|itsuki-gentoo.png) ;;
    *)
      echo "Wallpaper not found: $WALLPAPER_SRC" >&2
      echo "No LightDM settings have been changed." >&2
      exit 1
      ;;
  esac
  command -v curl >/dev/null 2>&1 || { echo "curl is required to download $WALLPAPER_FILE." >&2; exit 1; }
  [[ -n "$TEMP_SOURCE_DIR" ]] || TEMP_SOURCE_DIR="$(mktemp -d)"
  TEMP_WALLPAPER="$TEMP_SOURCE_DIR/$WALLPAPER_FILE"
  if ! curl -fsSL "https://raw.githubusercontent.com/a43039646-svg/itsuki-niri-rice/main/wallpaper/$WALLPAPER_FILE" -o "$TEMP_WALLPAPER"; then
    echo "Could not download $WALLPAPER_FILE. No LightDM settings have been changed." >&2
    exit 1
  fi
  WALLPAPER_SRC="$TEMP_WALLPAPER"
fi
if ! grep -q '^background=' "$CONFIG_SRC"; then
  echo "The greeter profile has no background= setting: $CONFIG_SRC" >&2
  exit 1
fi
if ! grep -q '^theme-name=' "$CONFIG_SRC"; then
  echo "The greeter profile has no theme-name= setting: $CONFIG_SRC" >&2
  exit 1
fi
if [[ "$EUID" -ne 0 ]] && ! command -v sudo >/dev/null 2>&1; then
  echo "sudo is required to install LightDM settings (or run this script as root)." >&2
  exit 1
fi

TEMP_CONFIG="$(mktemp)"

# Select both the matching background image and the bundled profile-specific GTK theme.
sed -e "s|^background=.*|background=$WALLPAPER_DEST|" \
    -e "s|^theme-name=.*|theme-name=$GTK_THEME_NAME|" \
    "$CONFIG_SRC" > "$TEMP_CONFIG"
if ! grep -Fxq "background=$WALLPAPER_DEST" "$TEMP_CONFIG" || ! grep -Fxq "theme-name=$GTK_THEME_NAME" "$TEMP_CONFIG"; then
  echo "Failed to prepare the selected LightDM greeter config." >&2
  exit 1
fi

STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$LIGHTDM_DIR/itsuki-backup-$STAMP"

printf '\nSelected LightDM profile: %s\n' "$PROFILE_LABEL"
printf 'Wallpaper style: %s\n' "$([[ "$WALLPAPER_STYLE" == "character" ]] && echo "with Itsuki" || echo "without Itsuki")"
printf 'Background image: %s\n' "$WALLPAPER_SRC"
printf '\nThis will update %s and install the selected background.\n' "$CONFIG_DEST"
printf 'GTK theme: %s -> %s\n' "$GTK_THEME_NAME" "$GTK_THEME_CSS_DEST"
printf 'Existing config, background, and matching GTK-theme files will be backed up.\n'
printf 'It will not switch display managers or restart LightDM.\n'

if [[ -r /dev/tty && -w /dev/tty ]]; then
  read -r -p "Continue? [y/N] " answer </dev/tty
  case "$answer" in
    y|Y|yes|YES) ;;
    *) echo "Cancelled."; exit 0 ;;
  esac
elif [[ "${ITSUKI_LIGHTDM_CONFIRM:-}" == "yes" ]]; then
  echo "ITSUKI_LIGHTDM_CONFIRM=yes: proceeding with the requested system config change."
else
  echo "No interactive terminal available; no changes were made." >&2
  echo "For deliberate automated installation, also set ITSUKI_LIGHTDM_CONFIRM=yes." >&2
  exit 2
fi

as_root() {
  if [[ "$EUID" -eq 0 ]]; then
    "$@"
  else
    sudo "$@"
  fi
}

as_root install -d -m 0700 "$BACKUP_DIR"
if [[ -e "$CONFIG_DEST" || -L "$CONFIG_DEST" ]]; then
  as_root cp -a "$CONFIG_DEST" "$BACKUP_DIR/lightdm-gtk-greeter.conf"
fi
if [[ -e "$WALLPAPER_DEST" || -L "$WALLPAPER_DEST" ]]; then
  as_root cp -a "$WALLPAPER_DEST" "$BACKUP_DIR/$(basename "$WALLPAPER_DEST")"
fi
if [[ -e "$GTK_THEME_CSS_DEST" || -L "$GTK_THEME_CSS_DEST" ]]; then
  as_root install -d -m 0700 "$BACKUP_DIR/themes/$GTK_THEME_NAME/gtk-3.0"
  as_root cp -a "$GTK_THEME_CSS_DEST" "$BACKUP_DIR/themes/$GTK_THEME_NAME/gtk-3.0/gtk.css"
fi
if [[ -e "$GTK_THEME_INDEX_DEST" || -L "$GTK_THEME_INDEX_DEST" ]]; then
  as_root install -d -m 0700 "$BACKUP_DIR/themes/$GTK_THEME_NAME"
  as_root cp -a "$GTK_THEME_INDEX_DEST" "$BACKUP_DIR/themes/$GTK_THEME_NAME/index.theme"
fi

# Install the theme assets first; only then point LightDM at the new theme.
as_root install -D -m 0644 "$GTK_THEME_CSS_SRC" "$GTK_THEME_CSS_DEST"
as_root install -D -m 0644 "$GTK_THEME_INDEX_SRC" "$GTK_THEME_INDEX_DEST"
as_root install -D -m 0644 "$WALLPAPER_SRC" "$WALLPAPER_DEST"
as_root install -D -m 0644 "$TEMP_CONFIG" "$CONFIG_DEST"

echo "LightDM greeter profile installed: $PROFILE_LABEL."
echo "Config: $CONFIG_DEST"
echo "Background: $WALLPAPER_DEST"
echo "GTK theme: $GTK_THEME_NAME"
echo "GTK CSS: $GTK_THEME_CSS_DEST"
echo "Backup: $BACKUP_DIR"
echo "The greeter will use these settings at the next login screen. LightDM was not restarted."
