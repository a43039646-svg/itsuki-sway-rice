# Wallpapers

The installer chooses a profile-matched image based on the selected distro and wallpaper style. The selected file is copied into `~/.local/share/itsuki-sway-rice/wallpapers/` and the Sway startup helper applies it.

The Itsuki character and clean profile wallpapers from Itsuki Niri Rice are bundled here, so Sway installs do not need to download those files separately.

The interactive installer offers two choices: with Itsuki or without Itsuki. For non-interactive installation, use `ITSUKI_WALLPAPER=filename.png` to select an image, or `ITSUKI_WALLPAPER=none` to leave wallpaper management to your own Sway config.

To check for exact copies and visually similar images, run `python scripts/check-wallpaper-duplicates.py` after installing Pillow. It reports suspected matches without deleting files; review candidates before removing either image.
