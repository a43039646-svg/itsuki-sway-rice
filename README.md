# Itsuki Sway Rice

A Sway port of the Itsuki-themed Linux desktop rice, with themed Waybar, Kitty, Fuzzel, Dunst, wallpapers and helper scripts.

## Themes

- **Neutral** — rose palette, no distro logo.
- **Debian** — rose palette and Debian logo.
- **Arch Linux** — blue palette and Arch logo.
- **Gentoo** — violet palette and Gentoo logo.

## Install

Install and configure Sway first. On Debian, the core packages can be installed with:

```bash
sudo apt update
sudo apt install sway swaybg swaylock waybar fuzzel kitty dunst brightnessctl python3 python3-tk curl git fonts-font-awesome fonts-fork-awesome fonts-jetbrains-mono xdg-desktop-portal-wlr xdg-desktop-portal-gtk
```

Then clone this repository and run the installer:

```bash
git clone https://github.com/a43039646-svg/itsuki-sway-rice.git
cd itsuki-sway-rice
bash install.sh
```

Choose a theme and wallpaper style when prompted. The installer downloads the selected wallpaper automatically, backs up files it changes to `~/.config/itsuki-sway-backup/`, and adds a managed include to the existing Sway config.

**After installation, log out and choose Sway at the login screen.** Reboot if Sway is not available in the session selector yet.

## Shortcuts

- `Super + D` — Fuzzel launcher.
- `Super + Enter` — Kitty terminal.
- `Super + E` — power menu.

Wallpaper files download automatically from the public wallpaper folder of [Itsuki Niri Rice](https://github.com/a43039646-svg/itsuki-niri-rice) during installation. To copy the images into this repository instead, run `bash scripts/import-wallpapers.sh`, then commit and push the downloaded files. Fetch startup uses `fetch --box --shading-mode sextants` if the `fetch` command is installed.

## Validate

```bash
bash scripts/validate-profiles.sh
```

This checks the profile files and shell/JSON syntax; it does not replace testing in a live Sway session.
