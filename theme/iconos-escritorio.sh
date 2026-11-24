#!/usr/bin/env bash
# Iconos del escritorio más proporcionados: casilla de 92 px de ancho (Zorin: 120),
# nombres a 9 pt y recuadro de selección ceñido.
# Se ajusta la extensión original del sistema (con copia de respaldo) en vez de usar
# una copia local: así la extensión sigue siendo la de Zorin y sus reinicios tras
# la suspensión o Actividades funcionan como siempre. Pide contraseña de administrador.
# Revertir: bash theme/iconos-escritorio.sh --revertir
# Tras una actualización de Zorin que reinstale la extensión, vuelve a ejecutarlo.
set -uo pipefail
LOCAL="$HOME/.local/share/gnome-shell/extensions"
ANCHOS="{'tiny': 62, 'small': 76, 'standard': 92, 'large': 116}"

# Versiones anteriores de este script dejaban una copia local: se elimina
for d in "$LOCAL"/*; do
  [ -f "$d/.ajuste-mac" ] && rm -rf "$d" && echo "  Eliminada copia local anterior: $(basename "$d")"
done

EXT=""
for d in /usr/share/gnome-shell/extensions/*; do
  [ -f "$d/app/enums.js" ] && grep -q "ICON_WIDTH" "$d/app/enums.js" && { EXT=$d; break; }
done
[ -n "$EXT" ] || { echo "No se encontró la extensión de iconos del escritorio."; exit 1; }
ENUMS="$EXT/app/enums.js"; CSS="$EXT/app/stylesheet.css"

if [ "${1:-}" = --revertir ]; then
  for f in "$ENUMS" "$CSS"; do [ -f "$f.antes-mac" ] && sudo cp "$f.antes-mac" "$f"; done
  echo "Revertido ($(basename "$EXT")). Cierra sesión y vuelve a entrar."
  exit 0
fi

for f in "$ENUMS" "$CSS"; do [ -f "$f" ] && [ ! -f "$f.antes-mac" ] && sudo cp "$f" "$f.antes-mac"; done
sudo sed -i "s/^\(var\|const\|export const\) ICON_WIDTH = .*/\1 ICON_WIDTH = $ANCHOS;/" "$ENUMS"
if [ -f "$CSS" ]; then
  sudo sed -i '/\/\* AJUSTE-MAC-INICIO \*\//,/\/\* AJUSTE-MAC-FIN \*\//d' "$CSS"
  sudo tee -a "$CSS" >/dev/null <<'C'
/* AJUSTE-MAC-INICIO */
.file-label, label.file-label:backdrop, .file-label-dark, label.file-label-dark:backdrop { font-size: 9pt; }
.file-item { padding: 1px 3px; border-radius: 4px; }
/* AJUSTE-MAC-FIN */
C
fi
grep "ICON_WIDTH" "$ENUMS"
echo "Listo ($(basename "$EXT")). Cierra sesión y vuelve a entrar."
