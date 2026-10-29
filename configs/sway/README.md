# Sway integration

The installer backs up the existing ~/.config/sway/config, removes top-level bar { ... } blocks and explicit swaybar startup commands, then adds a managed include for ~/.config/sway/itsuki.conf. The startup helper also stops any stray Swaybar process in case an included config starts one. Waybar is the only panel used by this rice.

The generated drop-in includes:

- 8-pixel inner and 3-pixel outer gaps, pixel borders, and rose/blue/violet focus colors.
- Super+D for Fuzzel, Super+Enter for Kitty, and Super+E for the power menu.
- Super+Shift+B to validate/reload Sway and restart Waybar and Dunst.
- A single session-start command for managed helpers.

When a wallpaper is selected in the installer, direct swaybg startup commands are removed so the selected background is applied consistently. Choosing to keep the current wallpaper preserves existing swaybg lines and clears the managed wallpaper marker. Existing config files and helper scripts are backed up under ~/.config/itsuki-sway-backup/<profile>/<timestamp>/.

The main installer optionally offers LightDM setup at the end. install-lightdm.sh can also be run independently and requires its own confirmation before changing system files.