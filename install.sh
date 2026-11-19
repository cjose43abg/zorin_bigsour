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

echo "› F4 = todas las aplicaciones"
gsettings set org.gnome.shell.keybindings toggle-application-view "['<Super>a','F4','XF86LaunchA','XF86Launch1']"

echo "Listo. Cierra sesión y vuelve a entrar para aplicar todo."
