#!/usr/bin/env bash
# Instala la personalización estilo macOS para Zorin OS (GNOME 46, Wayland).
set -euo pipefail
cd "$(dirname "$0")"
HI="$HOME/.local/share/icons/hicolor"
APPS="$HOME/.local/share/applications"
EXT="$HOME/.local/share/gnome-shell/extensions"
THEME_CSS="$HOME/.themes/WhiteSur-Light/gnome-shell/gnome-shell.css"
TB=org.gnome.shell.extensions.zorin-taskbar

echo "› Iconos"
mkdir -p "$HI/scalable/apps" "$APPS" "$EXT"
cp icons/*.svg "$HI/scalable/apps/"
for s in 48 64 128 256 512; do mkdir -p "$HI/${s}x${s}/apps"; cp icons/${s}x${s}/*.png "$HI/${s}x${s}/apps/"; done
gtk-update-icon-cache -f "$HI" >/dev/null 2>&1 || true

echo "› Lanzadores del dock"
cp applications/*.desktop "$APPS/"
gsettings set org.gnome.shell favorite-apps "['org.gnome.Nautilus.desktop','launchpad.desktop','apple-menu.desktop','brave-browser.desktop','org.gnome.Software.desktop','org.gnome.Settings.desktop']"

echo "› Extensión (reloj a la derecha, apagar/reiniciar/suspender, acciones del dock)"
cp -r extension/clock-right@local "$EXT/"
cur=$(gsettings get org.gnome.shell enabled-extensions)
case "$cur" in *clock-right@local*) ;; *) gsettings set org.gnome.shell enabled-extensions "$(echo "$cur" | sed "s/\]$/, 'clock-right@local']/")";; esac

echo "› Tema WhiteSur (requiere WhiteSur-gtk-theme ya instalado)"
gsettings set org.gnome.desktop.interface gtk-theme 'WhiteSur-Light'
gsettings set org.gnome.desktop.interface icon-theme 'WhiteSur'
gsettings set org.gnome.desktop.interface cursor-theme 'WhiteSur-cursors'
gsettings set org.gnome.shell.extensions.user-theme name 'WhiteSur-Light'
gsettings set org.gnome.desktop.wm.preferences button-layout 'close,minimize,maximize:'
if [ -f "$THEME_CSS" ]; then
  grep -q SIN-LATENCIA "$THEME_CSS" || cat theme/no-transitions.css >> "$THEME_CSS"
  sed -i 's/rgba(255, 255, 255, 0.155)/rgba(12, 12, 20, 0.62)/g' "$THEME_CSS"
fi

echo "› Dock (Zorin Taskbar): compacto, centrado y con ocultación automática"
gsettings set $TB intellihide true
gsettings set $TB intellihide-behaviour 'ALL_WINDOWS'
gsettings set $TB stockgs-keep-top-panel true
gsettings set $TB panel-position 'BOTTOM'
gsettings set $TB panel-size 72
gsettings set $TB panel-margin 10
gsettings set $TB global-border-radius 5
gsettings set $TB trans-use-custom-opacity true
gsettings set $TB trans-panel-opacity 0.5

echo "› Tipografía (Inter, el equivalente libre de San Francisco)"
if ! fc-list | grep -qi "Inter-Regular\|Inter,"; then echo "  Instala la fuente: sudo apt install fonts-inter"; fi
gsettings set org.gnome.desktop.interface font-name 'Inter 10'
gsettings set org.gnome.desktop.interface document-font-name 'Inter 10'
gsettings set org.gnome.desktop.wm.preferences titlebar-font 'Inter Bold 10'

echo "› Brave: barra de título del sistema (botones rojo/amarillo/verde)"
# Brave se abre en modo X11 para que GNOME dibuje la barra; la opción
# "Usar la barra de título del sistema" debe estar activa en brave://settings/appearance
cp launchers-extra/brave-browser.desktop "$APPS/"
gsettings set org.gnome.desktop.wm.preferences theme 'WhiteSur-Light'

echo "› Fondos de pantalla Tahoe"
mkdir -p "$HOME/Imágenes/Fondos-Tahoe"
cp wallpapers/*.jpeg "$HOME/Imágenes/Fondos-Tahoe/"
gsettings set org.gnome.desktop.background picture-uri "file://$HOME/Imágenes/Fondos-Tahoe/MacTahoe-day.jpeg"
gsettings set org.gnome.desktop.background picture-uri-dark "file://$HOME/Imágenes/Fondos-Tahoe/MacTahoe-night.jpeg"
gsettings set org.gnome.desktop.background picture-options 'zoom'

echo "› F4 = todas las aplicaciones"
gsettings set org.gnome.shell.keybindings toggle-application-view "['<Super>a','F4','XF86LaunchA','XF86Launch1']"

echo "› Botones de ventana GTK4 pequeños"
bash theme/gtk4-window-buttons.sh

echo "› Snapshot exacto de ajustes (dock, tema, fuentes, fondo, atajos)"
# Sobrescribe los valores anteriores con los del equipo original.
# OJO: panel-lengths/anchors/element-positions usan el ID del monitor (APP-0x00000000, MacBook Air).
# En otro monitor, ajusta esas claves o repítelas desde Apariencia de Zorin → Opciones de barra de tareas.
dconf load /org/gnome/shell/extensions/zorin-taskbar/ < dconf/org_gnome_shell_extensions_zorin-taskbar.ini
dconf load /org/gnome/shell/extensions/user-theme/ < dconf/org_gnome_shell_extensions_user-theme.ini
dconf load /org/gnome/desktop/interface/ < dconf/org_gnome_desktop_interface.ini
dconf load /org/gnome/desktop/wm/preferences/ < dconf/org_gnome_desktop_wm_preferences.ini
dconf load /org/gnome/desktop/background/ < dconf/org_gnome_desktop_background.ini
dconf load /org/gnome/shell/keybindings/ < dconf/org_gnome_shell_keybindings.ini

echo "› Sincronización claro/oscuro (todo sigue la apariencia elegida)"
mkdir -p "$HOME/.local/bin" "$HOME/.config/autostart"
cp scripts/zorin-tema-sync "$HOME/.local/bin/" && chmod +x "$HOME/.local/bin/zorin-tema-sync"
sed "s|/home/carlos|$HOME|" autostart/zorin-tema-sync.desktop > "$HOME/.config/autostart/zorin-tema-sync.desktop"
# libadwaita/GTK4: claro -> gtk.css, oscuro -> gtk-dark.css
if [ -f "$HOME/.config/gtk-4.0/gtk-Light.css" ]; then
  ln -sf gtk-Light.css "$HOME/.config/gtk-4.0/gtk.css"; ln -sf gtk-Dark.css "$HOME/.config/gtk-4.0/gtk-dark.css"
fi

echo "› Fondo de Actividades/Launchpad difuminado (vidrio)"
bash theme/overview-glass.sh

echo "› Ajustes de este equipo (monitor, dock, extensiones)"
bash scripts/ajustar-equipo.sh

echo "Listo. Cierra sesión y vuelve a entrar para aplicar todo."
