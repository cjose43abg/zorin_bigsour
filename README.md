# Zorin OS → macOS

Personalización de Zorin OS 18 (GNOME 46, Wayland) para que se vea y se comporte como macOS, sin Zorin Pro y **sin blur** (ligera en RAM/GPU).

## Qué incluye
- **Dock** inferior estilo macOS: centrado, bordes redondeados, ocultación automática (Zorin Taskbar).
- **Iconos propios** dibujados en SVG + PNG: Finder (carita), App Store (A), Launchpad (cuadrícula), logo de Apple.
- **Extensión `clock-right@local`**: reloj a la derecha del panel superior, botones apagar/reiniciar/suspender a la izquierda y acciones D-Bus para los iconos del dock (Launchpad abre todas las apps).
- **Tema**: WhiteSur (GTK, iconos, cursor), botones de ventana rojo/amarillo/verde a la izquierda, panel superior más oscuro, sin transiciones de resaltado.
- **Tipografía**: Inter 10 en toda la interfaz (equivalente libre de San Francisco, la fuente de macOS; SF no se puede redistribuir).
- **Fondos Tahoe** (día/noche, 4K) de [vinceliuice/MacTahoe-gtk-theme](https://github.com/vinceliuice/MacTahoe-gtk-theme), licencia MIT.
- **Brave** en modo X11 con la barra de título del sistema, para tener los botones de colores de WhiteSur.
- **Botones de ventana juntos** como en macOS: círculos de 12 px a 7 px de distancia (`theme/botones-ventana.sh`), en apps GTK4, GTK3 y Brave con tema GTK.
- **Brave con botones del sistema**: `scripts/brave-ajustes.sh` (con Brave cerrado) activa el tema GTK —círculos de WhiteSur en vez de los botones propios de Chromium— y quita el aviso de `--enable-unsafe-webgpu`. Guarda copia `*.antes-mac` de lo que edita.
- **Iconos por función** (`scripts/iconos-apps.sh`, iconos propios en `icons/mac/`): cada programa toma el icono de su equivalente en macOS — navegador → Safari, WhatsApp → Mensajes, correo → Mail, visor de PDF → Libros, vídeos → TV, música → Música, visor de imágenes → Fotos, editor de texto → Notas, tareas → Recordatorios, calculadora, cámara, relojes, contactos, tiempo, grabadora → Notas de voz, podcasts, traductor, contraseñas → Cartera, Zoom → FaceTime, configuración y monitor del sistema. Revertir: `bash scripts/iconos-apps.sh --revertir`.
- **Efecto ola en el dock** (`extension/clock-right@local/magnify.js`): al pasar el puntero, el icono crece hasta 1,6× y sus vecinos menos, como en macOS. Zorin Taskbar no lo trae; lo añade nuestra extensión. Ajustes al inicio del archivo (`MAX`, `SPREAD`).
- **Iconos del dock más juntos** (`extension/clock-right@local/spacing.js`): 18 px entre iconos en vez de los 24 fijos de Zorin Taskbar, sin cambiar su tamaño. Ajuste: `MARGIN`.
- **F4** abre la cuadrícula de aplicaciones.
- **Launchpad con vidrio**: Actividades y la cuadrícula de apps muestran el fondo difuminado con una capa translúcida (`theme/overview-glass.sh`). Son imágenes pre-difuminadas, sin blur en tiempo real.

## Requisitos
```bash
sudo apt install git curl gnome-tweaks gnome-shell-extension-manager sassc libglib2.0-dev-bin gnome-control-center fonts-inter -y
git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git --depth=1 && cd WhiteSur-gtk-theme && ./install.sh -l -N glassy --round -c Light -c Dark
git clone https://github.com/vinceliuice/WhiteSur-icon-theme.git --depth=1 && cd WhiteSur-icon-theme && ./install.sh -a
git clone https://github.com/vinceliuice/WhiteSur-cursors.git --depth=1 && cd WhiteSur-cursors && ./install.sh
```

## Instalar
```bash
./install.sh
```
Después **cierra sesión y vuelve a entrar** (en Wayland GNOME no carga extensiones nuevas hasta reiniciar la sesión).

## Copia exacta
`dconf/` contiene un snapshot de los ajustes reales del equipo original (dock con ancho dinámico, margen, esquinas, tema, fuentes, fondo y atajos). `install.sh` lo aplica al final, de modo que el resultado coincide con el original. Para volver a capturarlo: `dconf dump /ruta/ > dconf/archivo.ini`.

Para vigilar cambios de ajustes del dock mientras los modificas: `dconf watch /org/gnome/shell/extensions/zorin-taskbar/`.

## Claro / oscuro
`scripts/zorin-tema-sync` vigila `color-scheme` y ajusta tema GTK, Shell, iconos y tema de ventanas a WhiteSur-Light o WhiteSur-Dark. Se inicia con la sesión. Manual: `zorin-tema-sync dark|light`. En Brave elige *Apariencia → Modo: Igual que el dispositivo*; en Claude, *Ajustes → Apariencia → Sistema*.

## Notas
- El ancho dinámico y el centrado del dock se guardan por monitor en Zorin Taskbar. `scripts/ajustar-equipo.sh` (lo llama `install.sh`) detecta los monitores del equipo y les aplica dock centrado y dinámico, sin logo de Zorin ni bandeja. Tras conectar otro monitor, ejecútalo de nuevo.
- El radio del dock solo admite 0–5 (×5 px).
- Los botones de ventana de apps con barra de título propia (por ejemplo Claude) no se pueden tematizar. `launchers-extra/com.anthropic.Claude.desktop` es un intento experimental (`--gtk-version=4`) que no se instala por defecto.
- El dock se oculta siempre (`intellihide-hide-from-windows=false`) y aparece al llevar el puntero al borde inferior.
- `theme/panel-dark.txt` y `theme/no-transitions.css` documentan los ajustes hechos al tema WhiteSur.
