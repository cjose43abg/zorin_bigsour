# Zorin OS → macOS

Personalización de Zorin OS 18 (GNOME 46, Wayland) para que se vea y se comporte como macOS, sin Zorin Pro y sin desenfoque en tiempo real (ligera en RAM y GPU).

## Instalar

En un equipo nuevo, un solo comando instala los requisitos y aplica todo:

```bash
git clone https://github.com/cjose43abg/zorin_bigsour.git && cd zorin_bigsour && ./install.sh --requisitos
```

Si los requisitos ya están instalados:

```bash
./install.sh
```

El instalador pregunta antes de dos pasos: ajustar Brave (lo cierra) y cambiar la pantalla de inicio de sesión (pide contraseña de administrador). Con `--si` responde «sí» a todo.

Al terminar, **cierra sesión y vuelve a entrar**: en Wayland, GNOME no carga extensiones nuevas hasta reiniciar la sesión.

Cada parte también se puede aplicar por separado con su script (ver tabla).

## Qué incluye

### Barra superior
| Qué | Dónde |
|---|---|
| Reloj y fecha a la derecha, junto a la bandeja | `extension/clock-right@local/extension.js` |
| Botones apagar, reiniciar y suspender a la izquierda | `extension/clock-right@local/extension.js` |
| Panel más oscuro, sin transiciones de resaltado | `theme/panel-dark.txt`, `theme/no-transitions.css` |

### Dock (Zorin Taskbar)
| Qué | Dónde |
|---|---|
| Centrado, ancho dinámico, bordes redondeados, sin logo de Zorin ni bandeja, en cada monitor | `scripts/ajustar-equipo.sh` |
| Se oculta siempre y aparece al llevar el puntero al borde inferior | `scripts/ajustar-equipo.sh` |
| **Efecto ola**: el icono bajo el puntero crece hasta 1,6× y sus vecinos menos (`MAX`, `SPREAD`) | `extension/clock-right@local/magnify.js` |
| Iconos a 12 px de distancia en vez de 24, sin cambiar su tamaño (`MARGIN`, `SIDE`) | `extension/clock-right@local/spacing.js` |
| Finder, Launchpad (abre todas las apps), menú Apple, App Store, Configuración | `applications/`, `icons/` |

### Iconos
| Qué | Dónde |
|---|---|
| Tema WhiteSur (iconos y cursor) | requisitos |
| Iconos propios: Finder (carita), App Store (A), Launchpad (cuadrícula), Apple | `icons/` |
| **Iconos por función**: cada programa toma el icono de su equivalente en macOS (Firefox/Chrome → Safari, WhatsApp → Mensajes, correo → Mail, PDF → Libros, vídeos → TV, música, fotos, notas, recordatorios, calculadora, cámara, reloj, contactos, tiempo, grabadora → Notas de voz, podcasts, traductor, contraseñas → Cartera, Zoom → FaceTime, configuración, monitor del sistema). Brave conserva su icono original. Revertir: `--revertir` | `scripts/iconos-apps.sh`, `icons/mac/` |
| **Iconos del escritorio proporcionados**: casilla de 92 px en vez de 120, nombres a 9 pt, selección ceñida. Revertir: `--revertir` | `theme/iconos-escritorio.sh` |

### Ventanas
| Qué | Dónde |
|---|---|
| Tema WhiteSur claro/oscuro; botones rojo/amarillo/verde a la izquierda | requisitos, `install.sh` |
| Botones de 12 px y juntos (17 px entre centros) en apps GTK4, GTK3 y Brave | `theme/botones-ventana.sh`, `theme/gtk4-window-buttons.sh` |
| **Brave** con los botones del sistema al lado de las pestañas (tema GTK) y sin el aviso de WebGPU | `scripts/brave-ajustes.sh` |
| Tipografía Inter en toda la interfaz (equivalente libre de San Francisco; SF no se puede usar fuera de Apple) | `install.sh` |

### Claro / oscuro
`scripts/zorin-tema-sync` (se inicia con la sesión) vigila el modo claro/oscuro y ajusta tema GTK, Shell, iconos y ventanas a WhiteSur-Light o WhiteSur-Dark. También repara los enlaces `~/.config/gtk-4.0/gtk.css` y `gtk-dark.css` para que **Finder** cambie con el modo. Manual: `zorin-tema-sync dark|light`. En Brave: *Apariencia → Modo: Igual que el dispositivo*; en Claude: *Ajustes → Apariencia → Sistema*.

### Fondos y pantallas
| Qué | Dónde |
|---|---|
| Fondo Tahoe día/noche (cambia con el modo claro/oscuro) | `wallpapers/` |
| **Más fondos** con versión clara y oscura en Configuración → Apariencia: Tahoe, Sonoma, Ventura, Monterey, Big Sur. Se descargan (no se guardan aquí) | `scripts/fondos.sh` |
| **Launchpad y Actividades con vidrio**: el fondo difuminado con una capa translúcida, en vez de negro. Imágenes pre-difuminadas, sin desenfoque en tiempo real | `theme/overview-glass.sh`, `wallpapers/overview-glass-*.jpeg` |
| Pantalla de bloqueo: GNOME ya usa el fondo difuminado | — |
| **Pantalla de inicio de sesión (GDM)** con el fondo Tahoe difuminado y WhiteSur. Revertir: `--revertir` | `theme/pantalla-inicio.sh` |

### Atajos
- **F4** abre la cuadrícula de aplicaciones.

## Copia exacta de ajustes
`dconf/` contiene un snapshot de los ajustes del equipo original (dock, tema, fuentes, fondo y atajos). `install.sh` lo aplica y luego `scripts/ajustar-equipo.sh` lo adapta a los monitores del equipo. Para volver a capturarlo: `dconf dump /ruta/ > dconf/archivo.ini`. Para vigilar cambios del dock: `dconf watch /org/gnome/shell/extensions/zorin-taskbar/`.

## Notas
- Tras conectar otro monitor, ejecuta de nuevo `scripts/ajustar-equipo.sh` y vuelve a entrar.
- Los botones de ventana de **Claude** no se pueden tematizar: la app los dibuja dentro de su propia página. `launchers-extra/com.anthropic.Claude.desktop` es un intento experimental.
- **Brave**: si los botones vuelven a ser grises, revisa en `brave://settings/appearance` que «Tema» diga **GTK** (botón «Usar GTK») y que «Usar barra de título y bordes del sistema» esté desactivado. Si se revierte solo, desactiva la sincronización de «Configuración» en `brave://settings/braveSync/setup`.
- `theme/iconos-escritorio.sh` usa una copia local de la extensión de iconos del escritorio; tras una actualización de Zorin, si el escritorio falla, ejecuta `--revertir` y vuelve a aplicarlo.
- Si una actualización de Zorin reinstala su tema de inicio de sesión o WhiteSur se reinstala, vuelve a ejecutar `theme/pantalla-inicio.sh`, `theme/overview-glass.sh` y `theme/botones-ventana.sh`.
- El radio del dock solo admite 0–5 (×5 px).

## Créditos y licencias
- Fondos Tahoe: [vinceliuice/MacTahoe-gtk-theme](https://github.com/vinceliuice/MacTahoe-gtk-theme) (MIT).
- Fondos Sonoma, Ventura, Monterey y Big Sur: [vinceliuice/WhiteSur-wallpapers](https://github.com/vinceliuice/WhiteSur-wallpapers) (MIT).
- Tema, iconos y cursor: [vinceliuice/WhiteSur](https://github.com/vinceliuice) (GPL/MIT según el proyecto).
- Los iconos de `icons/` e `icons/mac/` son dibujos propios al estilo de macOS; no contienen material de Apple.
