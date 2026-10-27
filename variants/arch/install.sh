#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
export ITSUKI_DISTRO="arch"
export ITSUKI_WALLPAPER_STYLE="${ITSUKI_WALLPAPER_STYLE:-character}"
exec bash "$ROOT/install.sh"
