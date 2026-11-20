#!/usr/bin/env bash
# Brave con los botones de ventana del sistema (tema GTK → círculos de WhiteSur)
# y sin el aviso de "--enable-unsafe-webgpu". Cierra Brave por su cuenta si está abierto.
set -uo pipefail
B="$HOME/.config/BraveSoftware/Brave-Browser"
[ -d "$B" ] || { echo "No se encontró el perfil de Brave en $B"; exit 0; }
if pgrep -x brave >/dev/null; then
  echo "› Cerrando Brave (también el que queda en segundo plano)..."
  pkill -x brave
  for _ in $(seq 20); do pgrep -x brave >/dev/null || break; sleep 0.5; done
  pkill -9 -x brave 2>/dev/null; sleep 1
fi
python3 - "$B" <<'PY'
import json, os, sys, shutil, glob
B = sys.argv[1]
def edit(path, fn):
    if not os.path.isfile(path): return
    shutil.copy2(path, path + ".antes-mac")
    d = json.load(open(path, encoding="utf-8"))
    fn(d)
    json.dump(d, open(path, "w", encoding="utf-8"), separators=(",", ":"))
    print("  editado:", path)
def theme(d):
    t = d.setdefault("extensions", {}).setdefault("theme", {})
    t["system_theme"] = 1          # 1 = GTK
    t.pop("id", None)
    d.setdefault("browser", {})["custom_chrome_frame"] = True   # pestañas en la barra
def flags(d):
    lab = d.get("browser", {}).get("enabled_labs_experiments", [])
    d.setdefault("browser", {})["enabled_labs_experiments"] = [f for f in lab if "unsafe-webgpu" not in f]
for p in glob.glob(f"{B}/*/Preferences"):
    if os.path.basename(os.path.dirname(p)) in ("Default",) or os.path.basename(os.path.dirname(p)).startswith("Profile "):
        edit(p, theme)
edit(f"{B}/Local State", flags)
PY
for f in "$HOME/.config/brave-flags.conf" "$HOME/.config/brave-browser-flags.conf"; do
  [ -f "$f" ] && sed -i '/unsafe-webgpu/d' "$f" && echo "  limpiado: $f"
done
grep -rl "unsafe-webgpu" "$HOME/.local/share/applications" "$HOME/Escritorio" "$HOME/Desktop" 2>/dev/null | while read -r f; do
  sed -i 's/ *--enable-unsafe-webgpu//g' "$f" && echo "  limpiado: $f"
done
echo "Listo. Abre Brave."
