#!/usr/bin/env bash
# Botones cerrar/minimizar/maximizar como en macOS: círculos de 12 px
# separados 7 px (antes 16 px con 10 px de hueco). Aplica a apps GTK4/libadwaita,
# GTK3 y Brave/Chrome con tema GTK. Se puede ejecutar varias veces.
INI='/* BOTONES-MAC-INICIO */'; FIN='/* BOTONES-MAC-FIN */'
CSS4="$INI
windowcontrols, headerbar.titlebar windowcontrols { border-spacing: 7px; }
windowcontrols button.close, windowcontrols button.minimize, windowcontrols button.maximize {
  min-width: 12px; min-height: 12px; margin: 0; padding: 4px 0; background-size: 12px 12px;
}
$FIN"
CSS3="$INI
headerbar button.titlebutton.close, headerbar button.titlebutton.minimize, headerbar button.titlebutton.maximize,
.titlebar button.titlebutton.close, .titlebar button.titlebutton.minimize, .titlebar button.titlebutton.maximize {
  min-width: 12px; min-height: 12px; margin: 0 2px; padding: 0; background-size: 12px 12px;
}
$FIN"
put() { # archivo bloque
  f=$(readlink -f "$1"); [ -f "$f" ] || return
  sed -i '/\/\* BOTONES-MAC-INICIO \*\//,/\/\* BOTONES-MAC-FIN \*\//d' "$f"
  printf '\n%s\n' "$2" >> "$f"; echo "  $f"
}
for f in "$HOME"/.config/gtk-4.0/gtk*.css "$HOME"/.themes/WhiteSur-*/gtk-4.0/gtk*.css; do put "$f" "$CSS4"; done
for f in "$HOME"/.themes/WhiteSur-*/gtk-3.0/gtk*.css; do put "$f" "$CSS3"; done
echo "Listo. Cierra y vuelve a abrir las ventanas para ver el cambio."
