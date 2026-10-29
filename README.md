# Itsuki Sway Rice

A Sway port inspired by the Itsuki Niri Rice, with matching profile colors, Waybar, Kitty, Fuzzel, Dunst, wallpaper, power menu and helper scripts. Sway uses its own native config drop-in; no Niri-specific commands are installed.

## Themes

- **Neutral** — rose palette, no distro logo.
- **Debian** — rose palette and Debian logo.
- **Arch Linux** — blue palette and Arch logo.
- **Gentoo** — violet palette and Gentoo logo.

## Install

Install and configure Sway first. On Debian, the core packages can be installed with:

```bash
sudo apt update
sudo apt install sway swaybg swaylock waybar fuzzel kitty dunst brightnessctl python3 python3-tk curl git fonts-font-awesome fonts-fork-awesome fonts-jetbrains-mono xdg-desktop-portal-wlr xdg-desktop-portal-gtk pipewire-pulse wireplumber
```

Keep your current audio stack if it is already working; `pipewire-pulse` and `wireplumber` are only needed if you use PipeWire and do not have them yet. The rice installer configures files and shortcuts but does not install packages for you.

Then clone this repository and run the installer:

```bash
git clone https://github.com/a43039646-svg/itsuki-sway-rice.git
cd itsuki-sway-rice
bash install.sh
```

Choose a theme and wallpaper style when prompted. The installer downloads the selected wallpaper automatically, backs up files it changes to `~/.config/itsuki-sway-backup/`, and adds a managed include to the existing Sway config.

**After installation, log out and choose Sway at the login screen.** Reboot if Sway is not available in the session selector yet. The installer backs up files it changes under `~/.config/itsuki-sway-backup/<profile>/<timestamp>/`, including existing Sway configuration and conflicting helper scripts.

## Shortcuts

- `Super + D` — Fuzzel launcher.
- `Super + Enter` — Kitty terminal.
- `Super + E` — power menu.
- `Super + Shift + B` — validate and reload Sway's config, then restart Waybar, Dunst and the wallpaper helper.
- Scroll over the brightness indicator in Waybar — change screen brightness with `brightnessctl` (on supported hardware).

Sway gets 8-pixel inner gaps, 3-pixel outer gaps and focused window borders matching the selected theme. Unlike Niri, Sway does not provide Niri's built-in background blur, so Kitty transparency may show the wallpaper without blur.

Wallpaper files download automatically from the public wallpaper folder of [Itsuki Niri Rice](https://github.com/a43039646-svg/itsuki-niri-rice) during installation. To copy the images into this repository instead, run `bash scripts/import-wallpapers.sh`, then commit and push the downloaded files. Fetch startup uses `fetch --box --shading-mode sextants` if the `fetch` command is installed.

## Optional: complete the distro-logo icons

The Arch, Debian and Gentoo logos use Nerd Font glyphs. If the logo appears as a box, install JetBrainsMono Nerd Font for your user:

```bash
mkdir -p ~/.local/share/fonts/JetBrainsMonoNerdFont
curl -fL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz -o /tmp/JetBrainsMonoNerdFont.tar.xz
tar -xf /tmp/JetBrainsMonoNerdFont.tar.xz -C ~/.local/share/fonts/JetBrainsMonoNerdFont
fc-cache -f ~/.local/share/fonts
```

Log out and back in after installing the font so Waybar can reload the font cache.

## Validate

```bash
bash scripts/validate-profiles.sh
```

This checks profile files, Waybar JSON/modules, helper script syntax and shell syntax; it does not replace testing in a live Sway session. The Niri Rice's visual style is adapted to Sway's own window-border and gaps settings, not copied as Niri configuration syntax.
