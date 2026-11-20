#!/usr/bin/env bash
# Botones cerrar/minimizar/maximizar como en macOS: círculos de 12 px
# a 20 px entre centros, como en macOS (WhiteSur: 24 px). Aplica a apps GTK4/libadwaita,
# GTK3 y Brave/Chrome con tema GTK. Se puede ejecutar varias veces.
INI='/* BOTONES-MAC-INICIO */'; FIN='/* BOTONES-MAC-FIN */'
CSS4="$INI
headerbar windowcontrols, headerbar.titlebar headerbar windowcontrols { border-spacing: 8px; }
headerbar windowcontrols button.close.close, headerbar windowcontrols button.minimize.minimize,
headerbar windowcontrols button.maximize.maximize {
  min-width: 12px; min-height: 12px; margin: 0; padding: 0; border: none; background-size: 12px 12px;
}
headerbar windowcontrols button.close > image, headerbar windowcontrols button.minimize > image,
headerbar windowcontrols button.maximize > image { -gtk-icon-size: 12px; min-width: 0; min-height: 0; }
$FIN"
CSS3="$INI
headerbar button.titlebutton.close.close, headerbar button.titlebutton.minimize.minimize,
headerbar button.titlebutton.maximize.maximize {
  min-width: 12px; min-height: 12px; margin: 0; padding: 0; border: none; background-size: 12px 12px;
}
headerbar button.titlebutton.close > image, headerbar button.titlebutton.minimize > image,
headerbar button.titlebutton.maximize > image { -gtk-icon-size: 12px; min-width: 0; min-height: 0; }
$FIN"
put() { # archivo bloque
  f=$(readlink -f "$1"); [ -f "$f" ] || return
  sed -i '/\/\* BOTONES-MAC-INICIO \*\//,/\/\* BOTONES-MAC-FIN \*\//d' "$f"
  printf '\n%s\n' "$2" >> "$f"; echo "  $f"
}
for f in "$HOME"/.config/gtk-4.0/gtk*.css "$HOME"/.themes/WhiteSur-*/gtk-4.0/gtk*.css; do put "$f" "$CSS4"; done
for f in "$HOME"/.themes/WhiteSur-*/gtk-3.0/gtk*.css; do put "$f" "$CSS3"; done
echo "Listo. Cierra y vuelve a abrir las ventanas para ver el cambio."
