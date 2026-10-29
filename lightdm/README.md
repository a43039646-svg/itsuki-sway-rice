# Itsuki LightDM GTK Greeter

Run the standalone installer from the full Itsuki Sway Rice checkout or extracted ZIP:

    bash install-lightdm.sh

It asks for a profile (Debian, Arch, Gentoo or Neutral), then asks whether to use a wallpaper with Itsuki or a clean background. The script backs up the existing greeter config, the selected background if it already exists, and any existing matching GTK-theme files. It asks for confirmation before writing to /etc/lightdm or /usr/share.

It does not install LightDM, switch display managers, enable services or restart LightDM. The main installer can offer this setup after the Sway rice finishes; answering No leaves LightDM unchanged.

For deliberate non-interactive use, set ITSUKI_LIGHTDM_PROFILE=debian|arch|gentoo|neutral, ITSUKI_LIGHTDM_WALLPAPER=character|clean, and ITSUKI_LIGHTDM_CONFIRM=yes. Use root or an account with sudo access.