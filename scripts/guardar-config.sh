#!/usr/bin/env bash
# Guarda en el repositorio la configuración actual de este equipo y la sube a GitHub:
# ajustes de dconf (dock, tema, fuentes, fondo, atajos, iconos del escritorio),
# favoritos del dock y extensiones activas.
set -euo pipefail
cd "$(dirname "$0")/.."
d() { dconf dump "$1" > "dconf/$2.ini"; echo "  $1"; }
echo "› Guardando ajustes"
d /org/gnome/shell/extensions/zorin-taskbar/ org_gnome_shell_extensions_zorin-taskbar
d /org/gnome/shell/extensions/user-theme/     org_gnome_shell_extensions_user-theme
d /org/gnome/desktop/interface/               org_gnome_desktop_interface
d /org/gnome/desktop/wm/preferences/          org_gnome_desktop_wm_preferences
d /org/gnome/desktop/background/              org_gnome_desktop_background
d /org/gnome/shell/keybindings/               org_gnome_shell_keybindings
for p in $(dconf list /org/gnome/shell/extensions/ | grep -iE "desk|ding"); do
  d "/org/gnome/shell/extensions/$p" "org_gnome_shell_extensions_${p%/}"
done
gsettings get org.gnome.shell favorite-apps     > dconf/favorite-apps.txt
gsettings get org.gnome.shell enabled-extensions > dconf/enabled-extensions.txt

echo "› Subiendo a GitHub"
git add dconf/
if git diff --cached --quiet; then echo "  No hay cambios que guardar."; exit 0; fi
git commit -q -m "Configuración de $(hostname) al $(date +%F)"
git pull -q --no-rebase origin main && git push -q origin HEAD:main
echo "Listo: configuración guardada en GitHub."
