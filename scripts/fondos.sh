#!/usr/bin/env bash
# Descarga fondos estilo macOS con licencia libre (MIT, vinceliuice/WhiteSur-wallpapers)
# y los registra, junto con Tahoe, en Configuración → Apariencia → Fondo.
# Cada fondo tiene versión clara y oscura: cambia sola con el modo claro/oscuro.
set -euo pipefail
cd "$(dirname "$0")/.."
DIR="$HOME/Imágenes/Fondos-macOS"
XML="$HOME/.local/share/gnome-background-properties/zorin-macos.xml"
URL=https://raw.githubusercontent.com/vinceliuice/WhiteSur-wallpapers/main/4k
mkdir -p "$DIR" "$(dirname "$XML")"
cp wallpapers/MacTahoe-day.jpeg wallpapers/MacTahoe-night.jpeg "$DIR/"

# nombre visible | archivo claro | archivo oscuro
PARES=(
  "Tahoe|MacTahoe-day.jpeg|MacTahoe-night.jpeg"
  "Sonoma|Sonoma-light.jpg|Sonoma-dark.jpg"
  "Ventura|Ventura-light.jpg|Ventura-dark.jpg"
  "Monterey|Monterey-light.jpg|Monterey-dark.jpg"
  "Monterey (mañana)|Monterey-morning.jpg|Monterey-dark.jpg"
  "Big Sur|WhiteSur-light.jpg|WhiteSur-dark.jpg"
  "Big Sur (mañana)|WhiteSur-morning.jpg|WhiteSur-dark.jpg"
)
for p in "${PARES[@]}"; do
  IFS='|' read -r _ a b <<<"$p"
  for f in "$a" "$b"; do
    [ -s "$DIR/$f" ] && continue
    echo "› Descargando $f"
    curl -fsSL --retry 4 -o "$DIR/$f.part" "$URL/$f" && mv "$DIR/$f.part" "$DIR/$f"
  done
done

{
  echo '<?xml version="1.0"?>'
  echo '<!DOCTYPE wallpapers SYSTEM "gnome-wp-list.dtd">'
  echo '<wallpapers>'
  for p in "${PARES[@]}"; do
    IFS='|' read -r n a b <<<"$p"
    cat <<W
  <wallpaper deleted="false">
    <name>$n</name>
    <filename>$DIR/$a</filename>
    <filename-dark>$DIR/$b</filename-dark>
    <options>zoom</options>
    <shade_type>solid</shade_type>
    <pcolor>#000000</pcolor>
    <scolor>#000000</scolor>
  </wallpaper>
W
  done
  echo '</wallpapers>'
} > "$XML"
echo "Listo. Elige el fondo en Configuración → Apariencia (cada uno cambia solo entre claro y oscuro)."
