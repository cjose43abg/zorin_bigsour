# Zorin OS → macOS

Personalización de Zorin OS 18 (GNOME 46, Wayland) para que se vea y se comporte como macOS, sin Zorin Pro y **sin blur** (ligera en RAM/GPU).

## Qué incluye
- **Dock** inferior estilo macOS: centrado, bordes redondeados, ocultación automática (Zorin Taskbar).
- **Iconos propios** dibujados en SVG + PNG: Finder (carita), App Store (A), Launchpad (cuadrícula), logo de Apple.
- **Extensión `clock-right@local`**: reloj a la derecha del panel superior, botones apagar/reiniciar/suspender a la izquierda y acciones D-Bus para los iconos del dock (Launchpad abre todas las apps).
- **Tema**: WhiteSur (GTK, iconos, cursor), botones de ventana rojo/amarillo/verde a la izquierda, panel superior más oscuro, sin transiciones de resaltado.
- **F4** abre la cuadrícula de aplicaciones.

## Requisitos
```bash
sudo apt install git curl gnome-tweaks gnome-shell-extension-manager sassc libglib2.0-dev-bin gnome-control-center -y
git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git --depth=1 && cd WhiteSur-gtk-theme && ./install.sh -l -N glassy --round -c Light -c Dark
git clone https://github.com/vinceliuice/WhiteSur-icon-theme.git --depth=1 && cd WhiteSur-icon-theme && ./install.sh -a
git clone https://github.com/vinceliuice/WhiteSur-cursors.git --depth=1 && cd WhiteSur-cursors && ./install.sh
```

## Instalar
```bash
./install.sh
```
Después **cierra sesión y vuelve a entrar** (en Wayland GNOME no carga extensiones nuevas hasta reiniciar la sesión).

## Notas
- El ancho dinámico y el centrado del dock se guardan por monitor en Zorin Taskbar. Si no se aplican, ajústalos en *Apariencia de Zorin → Opciones de barra de tareas → Position*.
- El radio del dock solo admite 0–5 (×5 px).
- Los botones de ventana de apps con barra de título propia (por ejemplo Claude) no se pueden tematizar.
- `theme/panel-dark.txt` y `theme/no-transitions.css` documentan los ajustes hechos al tema WhiteSur.
