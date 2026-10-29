# Sway integration

The installer preserves and backs up the existing `~/.config/sway/config`, then adds a managed include for `~/.config/sway/itsuki.conf`. The drop-in is generated for the chosen palette and includes:

- 8-pixel inner and 3-pixel outer gaps, pixel borders and rose/blue/violet focus colors.
- `Super+D` for Fuzzel, `Super+Enter` for Kitty, and `Super+E` for the power menu.
- `Super+Shift+B` to validate/reload Sway and restart Waybar, Dunst and swaybg.
- A single session-start command for the managed helpers, avoiding repeated `exec_always` launches on every config reload.

The root Sway config is not replaced wholesale. The installer backs it up, removes direct Waybar/Dunst/swaybg autostart commands that would duplicate the rice, and places the managed include at the end so Itsuki's theme settings take effect. Other config lines are preserved. The backup is stored under `~/.config/itsuki-sway-backup/<profile>/<timestamp>/`.
