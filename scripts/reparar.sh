#!/usr/bin/env bash
# Repara y vuelve a aplicar lo que suele romperse (tras actualizar Zorin, reinstalar
# WhiteSur o cambiar de monitor) y muestra un diagnóstico. Pide contraseña de administrador.
set -uo pipefail
cd "$(dirname "$0")/.."
EXT="$HOME/.local/share/gnome-shell/extensions"
HI="$HOME/.local/share/icons/hicolor"
UT=user-theme@gnome-shell-extensions.gcampax.github.com

echo "› Extensión propia (reloj, apagado, efecto ola, dock)"
mkdir -p "$EXT"; cp -r extension/clock-right@local "$EXT/"

echo "› Iconos propios"
cp icons/*.svg "$HI/scalable/apps/"
for s in 48 64 128 256 512; do mkdir -p "$HI/${s}x${s}/apps"; cp icons/${s}x${s}/*.png "$HI/${s}x${s}/apps/"; done
gtk-update-icon-cache -f "$HI" >/dev/null 2>&1 || true

echo "› Tema del Shell (WhiteSur) activo"
gsettings set org.gnome.shell disable-user-extensions false
cur=$(gsettings get org.gnome.shell enabled-extensions)
case "$cur" in *"$UT"*) ;; *) gsettings set org.gnome.shell enabled-extensions "$(echo "$cur" | sed "s/\]$/, '$UT']/")";; esac
gnome-extensions enable "$UT" 2>/dev/null || true
mkdir -p "$HOME/.local/bin"; cp scripts/zorin-tema-sync "$HOME/.local/bin/"; chmod +x "$HOME/.local/bin/zorin-tema-sync"
pkill -f zorin-tema-sync 2>/dev/null || true
case "$(gsettings get org.gnome.desktop.interface color-scheme)" in *dark*) M=dark;; *) M=light;; esac
"$HOME/.local/bin/zorin-tema-sync" "$M"
(nohup "$HOME/.local/bin/zorin-tema-sync" >/dev/null 2>&1 &)

echo "› Botones de ventana iguales en todas las apps"
bash theme/botones-ventana.sh >/dev/null
echo "› Fondo de vidrio en Actividades / Launchpad"
bash theme/overview-glass.sh
echo "› Dock (monitores, ocultación)"
bash scripts/ajustar-equipo.sh >/dev/null
echo "› Iconos del escritorio"
bash theme/iconos-escritorio.sh

echo
echo "=== Diagnóstico (mándalo si algo sigue mal) ==="
echo "Modo: $(gsettings get org.gnome.desktop.interface color-scheme)  | Tema Shell: $(gsettings get org.gnome.shell.extensions.user-theme name 2>/dev/null)"
for e in "$UT" clock-right@local zorin-taskbar@zorinos.com zorin-desktop-icons@zorinos.com ding@rastersoft.com; do
  st=$(gnome-extensions info "$e" 2>/dev/null | grep -i "state\|estado" | head -1 | sed 's/^ *//')
  [ -n "$st" ] && echo "$e → $st"
done
for v in Light Dark; do
  f="$HOME/.themes/WhiteSur-$v/gnome-shell/gnome-shell.css"
  echo "WhiteSur-$v Shell: $([ -f "$f" ] && echo "existe, vidrio=$(grep -c OVERVIEW-GLASS-INICIO "$f")" || echo "NO EXISTE")"
done
ls -l "$HOME/.config/gtk-4.0/gtk.css" "$HOME/.config/gtk-4.0/gtk-dark.css" 2>&1 | awk '{print $(NF-2),$(NF-1),$NF}'
echo "Cierra sesión y vuelve a entrar."
