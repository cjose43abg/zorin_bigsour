#!/usr/bin/env bash
# Botones de ventana más pequeños (12 px) en las apps GTK4/libadwaita con WhiteSur.
for f in "$HOME/.config/gtk-4.0/gtk-Light.css" "$HOME/.config/gtk-4.0/gtk-Dark.css"; do
  [ -f "$f" ] || continue
  python3 - "$f" <<'PY'
import sys
p=sys.argv[1]; s=open(p).read()
old="  min-width: 16px;\n  min-height: 16px;\n  padding: 4px 1px;\n  background-position: center;\n  background-repeat: no-repeat;\n  background-size: 16px 16px;"
new="  min-width: 12px;\n  min-height: 12px;\n  padding: 3px 1px;\n  background-position: center;\n  background-repeat: no-repeat;\n  background-size: 12px 12px;"
open(p,'w').write(s.replace(old,new))
PY
done
