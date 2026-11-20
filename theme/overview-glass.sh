#!/usr/bin/env bash
# Fondo de Actividades / Launchpad: el fondo de pantalla difuminado con una capa
# de vidrio (tipo "liquid glass"). Son imágenes ya difuminadas: no usa blur en
# tiempo real, así que no gasta GPU. Claro -> día, oscuro -> noche.
cd "$(dirname "$0")/.."
DIR="$HOME/.local/share/zorin-macos"
mkdir -p "$DIR"
cp wallpapers/overview-glass-day.jpeg wallpapers/overview-glass-night.jpeg "$DIR/"
for v in Light Dark; do
  css="$HOME/.themes/WhiteSur-$v/gnome-shell/gnome-shell.css"
  [ -f "$css" ] || { echo "  No existe $css; se omite."; continue; }
  img="$DIR/overview-glass-day.jpeg"; [ $v = Dark ] && img="$DIR/overview-glass-night.jpeg"
  sed -i '/\/\* OVERVIEW-GLASS-INICIO \*\//,/\/\* OVERVIEW-GLASS-FIN \*\//d' "$css"
  cat >> "$css" <<CSS
/* OVERVIEW-GLASS-INICIO */
#overviewGroup {
  background-color: transparent;
  background-image: url("file://$img");
  background-size: cover;
  background-position: center;
}
/* OVERVIEW-GLASS-FIN */
CSS
done
# Recargar el tema del Shell sin cerrar sesión
t=$(gsettings get org.gnome.shell.extensions.user-theme name)
gsettings set org.gnome.shell.extensions.user-theme name "''"; sleep 1
gsettings set org.gnome.shell.extensions.user-theme name "$t"
