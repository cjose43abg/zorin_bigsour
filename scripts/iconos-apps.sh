#!/usr/bin/env bash
# Asigna a cada programa de Linux el icono de su equivalente en macOS
# (WhatsApp → Mensajes, visor de PDF → Libros, etc.). Brave conserva su icono.
# Los iconos son propios (icons/mac/), dibujados al estilo de macOS.
# No toca los archivos del sistema: crea copias en ~/.local/share/applications.
# Revertir: bash scripts/iconos-apps.sh --revertir
set -uo pipefail
cd "$(dirname "$0")/.."
HI="$HOME/.local/share/icons/hicolor/scalable/apps"
mkdir -p "$HI" "$HOME/.local/share/applications" "$HOME/.local/share/zorin-macos"
[ "${1:-}" = --revertir ] || { cp icons/mac/*.svg "$HI/"; gtk-update-icon-cache -f "$HOME/.local/share/icons/hicolor" >/dev/null 2>&1 || true; }

python3 - "${1:-}" <<'PY'
import os, re, sys, glob, shutil
H = os.path.expanduser("~")
LOCAL = f"{H}/.local/share/applications"
LOG = f"{H}/.local/share/zorin-macos/iconos-modificados.txt"
SYS = ["/usr/share/applications", "/usr/local/share/applications",
       "/var/lib/flatpak/exports/share/applications",
       f"{H}/.local/share/flatpak/exports/share/applications",
       "/var/lib/snapd/desktop/applications"]
DESK = [f"{H}/Escritorio", f"{H}/Desktop"]

# icono -> (IDs de .desktop, expresión para el nombre visible o None)
MAP = {
 "safari":     (["firefox", "firefox_firefox",
                 "org.mozilla.firefox", "google-chrome", "chromium", "chromium_chromium", "microsoft-edge"], None),
 "messages":   (["com.rtosta.zapzap", "io.github.mimbrero.WhatsAppDesktop", "com.github.eneshecan.WhatsAppForLinux",
                 "whatsapp-desktop", "whatsdesk", "whatsapp-for-linux"], r"whats ?app"),
 "mail":       (["thunderbird", "org.mozilla.Thunderbird", "thunderbird_thunderbird", "org.gnome.Geary",
                 "org.gnome.Evolution", "mailspring"], None),
 "books":      (["org.gnome.Evince", "evince", "org.gnome.Papers", "com.github.johnfactotum.Foliate",
                 "calibre-gui", "org.kde.okular", "xreader"], None),
 "tv":         (["org.gnome.Totem", "totem", "org.gnome.Showtime", "vlc", "vlc_vlc", "org.videolan.VLC",
                 "io.github.celluloid_player.Celluloid", "celluloid", "mpv"], None),
 "music":      (["rhythmbox", "org.gnome.Rhythmbox3", "org.gnome.Music", "org.gnome.Lollypop",
                 "io.github.neithern.g4music", "com.github.neithern.g4music"], None),
 "photos":     (["org.gnome.Loupe", "org.gnome.eog", "eog", "shotwell", "org.gnome.Shotwell",
                 "org.gnome.Photos", "gthumb", "org.gnome.gThumb"], None),
 "notes":      (["org.gnome.TextEditor", "org.gnome.gedit", "gedit", "org.gnome.Notes", "bijiben", "xed"], None),
 "reminders":  (["org.gnome.Todo", "io.github.alainm23.planify", "endeavour"], None),
 "calculator": (["org.gnome.Calculator", "gnome-calculator"], None),
 "camera":     (["org.gnome.Snapshot", "org.gnome.Cheese", "cheese"], None),
 "clock":      (["org.gnome.clocks"], None),
 "contacts":   (["org.gnome.Contacts"], None),
 "weather":    (["org.gnome.Weather"], None),
 "voicememos": (["org.gnome.SoundRecorder"], None),
 "podcasts":   (["org.gnome.Podcasts"], None),
 "translate":  (["app.drey.Dialect", "com.github.gi_lom.dialect"], None),
 "wallet":     (["org.gnome.seahorse.Application", "seahorse", "org.gnome.World.Secrets"], None),
 "facetime":   (["Zoom", "us.zoom.Zoom", "zoom_zoom-client"], None),
 "settings":   (["org.gnome.Settings", "gnome-control-center"], None),
 "activity":   (["org.gnome.SystemMonitor", "gnome-system-monitor", "gnome-system-monitor-kde",
                 "io.missioncenter.MissionCenter"], None),
}

def log_read():
    try: return [l.rstrip("\n").split("\t") for l in open(LOG) if "\t" in l]
    except FileNotFoundError: return []

if sys.argv[1] == "--revertir":
    for kind, path in log_read():
        if kind == "copia" and os.path.exists(path): os.remove(path)
        elif kind == "orig" and os.path.exists(path + ".antes-mac"): shutil.move(path + ".antes-mac", path)
        print("  revertido:", path)
    if os.path.exists(LOG): os.remove(LOG)
    sys.exit()

done = {p for _, p in log_read()}
log = open(LOG, "a")

def set_icon(path, icon):
    s = open(path, encoding="utf-8", errors="replace").read()
    n = re.sub(r"(?m)^Icon=.*$", f"Icon=mac-{icon}", s)
    if n != s:
        open(path, "w", encoding="utf-8").write(n)
    return n != s

def apply(src, icon, inplace=False):
    did = os.path.basename(src)
    dst = src if inplace else os.path.join(LOCAL, did)
    if not inplace and not os.path.exists(dst):
        shutil.copy2(src, dst)
        if dst not in done: log.write(f"copia\t{dst}\n"); done.add(dst)
    elif dst not in done:
        shutil.copy2(dst, dst + ".antes-mac"); log.write(f"orig\t{dst}\n"); done.add(dst)
    if set_icon(dst, icon): print(f"  {icon:<11} ← {did}")

def find(did):
    for d in [LOCAL] + SYS:
        p = f"{d}/{did}.desktop"
        if os.path.isfile(p): return p
    return None

for icon, (ids, rx) in MAP.items():
    for did in ids:
        p = find(did)
        if p: apply(p, icon)
    if rx:
        pat = re.compile(rx, re.I)
        for d in [LOCAL] + SYS:
            for p in glob.glob(f"{d}/*.desktop"):
                m = re.search(r"(?m)^Name=(.*)$", open(p, encoding="utf-8", errors="replace").read())
                if m and pat.search(m.group(1)): apply(p, icon)
        for d in DESK:
            for p in glob.glob(f"{d}/*.desktop"):
                m = re.search(r"(?m)^Name=(.*)$", open(p, encoding="utf-8", errors="replace").read())
                if m and pat.search(m.group(1)): apply(p, icon, inplace=True)
log.close()
PY
update-desktop-database "$HOME/.local/share/applications" >/dev/null 2>&1 || true
echo "Listo. Si algún icono no cambia en el dock, cierra sesión y vuelve a entrar."
