# Wallpapers

The installer lists supported images in this folder and lets you pick one during installation. The selected file is copied into `~/.local/share/itsuki-sway-rice/wallpapers/` and the Sway startup helper applies it.

Choose `0` in the installer to leave wallpaper management to your own Sway config. Existing `swaybg` commands are preserved. For non-interactive installation, use `ITSUKI_WALLPAPER=filename.png` or `ITSUKI_WALLPAPER=none`.

To check for exact copies and visually similar images, run `python scripts/check-wallpaper-duplicates.py` after installing Pillow. It reports suspected matches without deleting files; review candidates before removing either image.
