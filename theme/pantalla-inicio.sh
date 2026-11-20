#!/usr/bin/env bash
# Pantalla de inicio de sesión (GDM) con el mismo estilo: fondo Tahoe difuminado
# y tema WhiteSur. Usa la herramienta oficial de WhiteSur (tweaks.sh -g).
# Pide la contraseña de administrador. Revertir: bash theme/pantalla-inicio.sh --revertir
set -euo pipefail
cd "$(dirname "$0")/.."
REPO=$PWD
WS="$HOME/WhiteSur-gtk-theme"
[ -x "$WS/tweaks.sh" ] || git clone --depth=1 https://github.com/vinceliuice/WhiteSur-gtk-theme.git "$WS"

# WhiteSur busca el comando 'magick' (ImageMagick 7); Ubuntu 24.04 trae 'convert' (ImageMagick 6).
SHIM=$(mktemp -d)
trap 'rm -rf "$SHIM"' EXIT
command -v magick >/dev/null || { command -v convert >/dev/null || sudo apt install -y imagemagick; ln -s "$(command -v convert)" "$SHIM/magick"; }

cd "$WS"
if [ "${1:-}" = --revertir ]; then
  sudo env "PATH=$SHIM:$PATH" ./tweaks.sh -g -r
else
  sudo env "PATH=$SHIM:$PATH" ./tweaks.sh -g -b "$REPO/wallpapers/MacTahoe-day.jpeg" -nd
fi
echo "Listo. Se verá en el próximo reinicio o al cerrar sesión."
