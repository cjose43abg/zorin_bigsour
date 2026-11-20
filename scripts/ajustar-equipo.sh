#!/usr/bin/env bash
# Ajustes que dependen del equipo donde se instala (monitor, sesión, apps).
# - Dock centrado y de ancho dinámico en TODOS los monitores conectados
#   (el snapshot de dconf solo traía el ID del monitor del equipo original).
# - Dock sin logo de Zorin, sin bandeja ni reloj (ya están en el panel superior).
# - Dock que se oculta siempre y aparece al llevar el puntero al borde inferior.
# - Extensiones activas (reloj a la derecha, tema del Shell).
# - Claude: intento de botones de ventana con el tema WhiteSur (GTK4).
# Se puede ejecutar varias veces sin problema.
set -uo pipefail
TB=/org/gnome/shell/extensions/zorin-taskbar

echo "› Dock: centrado, dinámico, sin logo de Zorin ni bandeja, en cada monitor"
python3 - <<'PY'
import json, subprocess
from gi.repository import Gio, GLib

TB = "/org/gnome/shell/extensions/zorin-taskbar/"
ELEMENTS = [
    {"element": "leftBox",          "visible": False, "position": "stackedTL"},
    {"element": "showAppsButton",   "visible": False, "position": "stackedTL"},
    {"element": "taskbar",          "visible": True,  "position": "centerMonitor"},
    {"element": "centerBox",        "visible": False, "position": "stackedBR"},
    {"element": "activitiesButton", "visible": False, "position": "stackedBR"},
    {"element": "rightBox",         "visible": False, "position": "stackedBR"},
    {"element": "systemMenu",       "visible": False, "position": "stackedBR"},
    {"element": "dateMenu",         "visible": False, "position": "stackedBR"},
    {"element": "desktopButton",    "visible": False, "position": "stackedBR"},
]

def read(key):
    out = subprocess.run(["dconf", "read", TB + key], capture_output=True, text=True).stdout.strip()
    try:
        return json.loads(GLib.Variant.parse(None, out, None, None).unpack()) if out else {}
    except Exception:
        return {}

def write(key, obj):
    val = GLib.Variant("s", json.dumps(obj, separators=(",", ":"))).print_(False)
    subprocess.run(["dconf", "write", TB + key, val], check=True)

ids = set()
try:
    bus = Gio.bus_get_sync(Gio.BusType.SESSION, None)
    res = bus.call_sync("org.gnome.Mutter.DisplayConfig", "/org/gnome/Mutter/DisplayConfig",
                        "org.gnome.Mutter.DisplayConfig", "GetCurrentState", None, None,
                        Gio.DBusCallFlags.NONE, -1, None).unpack()
    for i, mon in enumerate(res[1]):
        connector, vendor, product, serial = mon[0]
        ids.update({f"{vendor}-{serial}", connector, str(i)})
        print(f"  monitor {i}: {connector} {vendor} {product} (ID {vendor}-{serial})")
except Exception as e:
    print("  No se pudo leer la lista de monitores:", e)

# También se conservan los IDs que la extensión ya haya guardado.
for key in ("panel-element-positions", "panel-lengths", "panel-anchors"):
    ids.update(read(key).keys())

if not ids:
    print("  Sin monitores detectados; se omite este paso.")
else:
    pos, lengths, anchors = read("panel-element-positions"), read("panel-lengths"), read("panel-anchors")
    for mid in ids:
        pos[mid], lengths[mid], anchors[mid] = ELEMENTS, -1, "MIDDLE"
    write("panel-element-positions", pos)
    write("panel-lengths", lengths)
    write("panel-anchors", anchors)
PY

echo "› Dock: se oculta siempre y sube al llevar el puntero abajo"
dconf write $TB/intellihide true
dconf write $TB/intellihide-hide-from-windows false
dconf write $TB/intellihide-use-pointer true
dconf write $TB/intellihide-revealed-hover true
dconf write $TB/intellihide-use-pressure false

echo "› Extensiones (reloj a la derecha y tema del Shell)"
gsettings set org.gnome.shell disable-user-extensions false
for e in clock-right@local user-theme@gnome-shell-extensions.gcampax.github.com; do
  cur=$(gsettings get org.gnome.shell enabled-extensions)
  case "$cur" in
    *"$e"*) ;;
    "@as []"|"[]") gsettings set org.gnome.shell enabled-extensions "['$e']" ;;
    *) gsettings set org.gnome.shell enabled-extensions "$(echo "$cur" | sed "s/\]$/, '$e']/")" ;;
  esac
  gnome-extensions enable "$e" 2>/dev/null || true
done

echo "› Claude: botones de ventana con el tema WhiteSur (experimental)"
APPS="$HOME/.local/share/applications"
CL="$APPS/com.anthropic.Claude.desktop"
mkdir -p "$APPS"
if command -v claude-desktop >/dev/null 2>&1; then
  if [ -f "$CL" ]; then
    grep -q -- '--gtk-version=4' "$CL" || sed -i 's|^Exec=claude-desktop %U|Exec=claude-desktop --gtk-version=4 %U|' "$CL"
  else
    cp "$(dirname "$0")/../launchers-extra/com.anthropic.Claude.desktop" "$CL"
  fi
  update-desktop-database "$APPS" >/dev/null 2>&1 || true
  echo "  Cierra Claude por completo y ábrelo desde el dock para ver el cambio."
else
  echo "  claude-desktop no está instalado con ese nombre; se omite."
fi

echo "Listo. Cierra sesión y vuelve a entrar."
