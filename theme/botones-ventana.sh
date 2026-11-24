#!/usr/bin/env bash
# Botones cerrar/minimizar/maximizar del mismo tamaño en todas las apps: el de
# Brave (círculo de ~14 px, 22 px entre centros) (WhiteSur: 24 px). Aplica a apps GTK4/libadwaita,
# GTK3 y Brave/Chrome con tema GTK. Se puede ejecutar varias veces.
INI='/* BOTONES-MAC-INICIO */'; FIN='/* BOTONES-MAC-FIN */'
CSS4="$INI
headerbar windowcontrols, headerbar.titlebar headerbar windowcontrols { border-spacing: 6px; }
headerbar windowcontrols button.close.close, headerbar windowcontrols button.minimize.minimize,
headerbar windowcontrols button.maximize.maximize {
  min-width: 16px; min-height: 16px; margin: 0; padding: 0; border: none; background-size: 16px 16px;
}
headerbar windowcontrols button.close > image, headerbar windowcontrols button.minimize > image,
headerbar windowcontrols button.maximize > image { -gtk-icon-size: 16px; min-width: 0; min-height: 0; }
$FIN"
CSS3="$INI
headerbar button.titlebutton.close.close, headerbar button.titlebutton.minimize.minimize,
headerbar button.titlebutton.maximize.maximize {
  min-width: 16px; min-height: 16px; margin: 0; padding: 0; border: none; background-size: 16px 16px;
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
