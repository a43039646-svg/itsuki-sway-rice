# Itsuki Sway Rice

A Sway port inspired by Itsuki Niri Rice. It includes profile-matched colors, **Waybar as the only panel**, Kitty, Fuzzel, Dunst, a power menu and helper scripts.

## Choose a profile and install

Install Sway first, then run:

    git clone https://github.com/a43039646-svg/itsuki-sway-rice.git
    cd itsuki-sway-rice
    bash install.sh

The installer first asks which distro profile to use (Neutral, Arch Linux, Debian or Gentoo), then offers two wallpaper choices: **with Itsuki** or **without Itsuki**. It next asks whether to apply that same profile and wallpaper to LightDM. Existing Sway settings are backed up under **~/.config/itsuki-sway-backup/**. The installer removes built-in **bar { ... }** blocks and explicit Swaybar startup commands from the active Sway config. The startup helper also stops Swaybar as a fallback if a separate included config starts it, so Waybar remains the only panel. For non-interactive installs, `ITSUKI_WALLPAPER_STYLE=none` or `ITSUKI_WALLPAPER=none` preserves the existing wallpaper setup.

On Debian, common packages are:

    sudo apt update
    sudo apt install sway swaybg swaylock waybar fuzzel kitty dunst brightnessctl python3 python3-tk curl git fonts-font-awesome fonts-fork-awesome fonts-jetbrains-mono xdg-desktop-portal-wlr xdg-desktop-portal-gtk

Keep your current audio stack if it already works. The rice installer configures files and shortcuts but does not install packages for you.

The main installer offers to apply the selected profile and wallpaper to LightDM at the end. Answer **No** to skip it and configure it later with the separate installer:

    bash install-lightdm.sh

The LightDM installer asks for a profile and wallpaper style, makes backups and requests confirmation before writing system files. It does not install LightDM, switch display managers, enable services or restart LightDM.

## Shortcuts

- **Super + D** — Fuzzel launcher.
- **Super + Enter** — Kitty terminal.
- **Super + E** — power menu.
- **Super + Shift + B** — validate/reload the Sway config, then restart Waybar and Dunst.
- Scroll on Waybar's brightness module — adjust brightness with **brightnessctl** on supported hardware.

Sway receives 8-pixel inner gaps, 3-pixel outer gaps and window-border colors matching the selected profile. Sway does not provide Niri's built-in background blur, so Kitty transparency may show the wallpaper without blur.

## Wallpaper controls

For non-interactive installs, set **ITSUKI_DISTRO=neutral|arch|debian|gentoo** and **ITSUKI_WALLPAPER_STYLE=character|clean|none**. Existing wrappers under **variants/** remain available. **ITSUKI_WALLPAPER=filename.png** can select an image already in **wallpaper/**, while **ITSUKI_WALLPAPER=none** leaves your own wallpaper setup in place. Missing neutral/clean profile variants may be downloaded from the companion Niri repository only when selected.

To report exact copies and possible visual near-duplicates in **wallpaper/**, install Pillow and run:

    python -m pip install Pillow
    python scripts/check-wallpaper-duplicates.py

The check only reports candidates; it never deletes files automatically.

## Validate

    bash scripts/validate-profiles.sh

This checks profile files, Waybar JSON/modules, helper script syntax and the LightDM installer. It does not replace testing in a live Sway session.
