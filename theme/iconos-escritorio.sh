#!/usr/bin/env bash
# Iconos del escritorio más proporcionados: la casilla de cada icono pasa de
# 120 px de ancho (más ancha que alta) a 100 px, en la extensión de iconos de
# escritorio (Zorin / Desktop Icons NG). Se usa una copia local de la extensión,
# así no se tocan archivos del sistema. Revertir: --revertir
set -uo pipefail
LOCAL="$HOME/.local/share/gnome-shell/extensions"
MARCA=".ajuste-mac"
ANCHOS="{'tiny': 64, 'small': 80, 'standard': 100, 'large': 124}"

# Extensión de iconos de escritorio activa: la que define ICON_WIDTH
EXT=""
for d in "$LOCAL"/* /usr/share/gnome-shell/extensions/*; do
  [ -f "$d/app/enums.js" ] && grep -q "ICON_WIDTH" "$d/app/enums.js" && { EXT=$d; break; }
done
[ -n "$EXT" ] || { echo "No se encontró la extensión de iconos del escritorio."; exit 1; }
UUID=$(basename "$EXT")

if [ "${1:-}" = --revertir ]; then
  [ -f "$LOCAL/$UUID/$MARCA" ] && rm -rf "${LOCAL:?}/$UUID" && echo "Revertido: se usa de nuevo la versión del sistema."
  exit 0
fi

if [ "$EXT" != "$LOCAL/$UUID" ]; then
  mkdir -p "$LOCAL"; cp -r "$EXT" "$LOCAL/$UUID"; touch "$LOCAL/$UUID/$MARCA"
fi
sed -i "s/^\(var\|const\|export const\) ICON_WIDTH = .*/\1 ICON_WIDTH = $ANCHOS;/" "$LOCAL/$UUID/app/enums.js"
grep "ICON_WIDTH" "$LOCAL/$UUID/app/enums.js"
echo "Listo ($UUID). Cierra sesión y vuelve a entrar."
