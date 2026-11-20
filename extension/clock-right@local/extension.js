import GLib from 'gi://GLib';
import St from 'gi://St';
import Gio from 'gi://Gio';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';
import {Extension} from 'resource:///org/gnome/shell/extensions/extension.js';
import {DockMagnifier} from './magnify.js';

const IFACE = `<node><interface name="org.local.DockActions">
  <method name="Launchpad"/>
  <method name="Menu"/>
</interface></node>`;

export default class ClockLeft extends Extension {
    // Reloj a la derecha, pegado a los iconos de la bandeja (junto al de Claude)
    _move() {
        const c = Main.panel.statusArea.dateMenu?.container;
        if (!c) return;
        const right = Main.panel._rightBox;
        if (c.get_parent() === right && right.get_children().indexOf(c) === 0) return;
        if (!this._parent) {
            this._parent = c.get_parent();
            this._index = this._parent.get_children().indexOf(c);
        }
        c.get_parent()?.remove_child(c);
        right.insert_child_at_index(c, 0);
    }

    _addPowerButtons() {
        const items = [
            ['system-shutdown-symbolic', 'Apagar', ['gnome-session-quit', '--power-off']],
            ['system-reboot-symbolic', 'Reiniciar', ['gnome-session-quit', '--reboot']],
            ['weather-clear-night-symbolic', 'Suspender', ['systemctl', 'suspend']],
        ];
        this._box = new St.BoxLayout({style_class: 'panel-status-menu-box', y_align: 2});
        for (const [icon, label, cmd] of items) {
            const b = new St.Button({
                style_class: 'panel-button',
                reactive: true, can_focus: true, track_hover: true,
                accessible_name: label,
                child: new St.Icon({icon_name: icon, style_class: 'system-status-icon', icon_size: 15}),
            });
            b.connect('clicked', () => {
                try { Gio.Subprocess.new(cmd, Gio.SubprocessFlags.NONE); } catch (e) { logError(e); }
            });
            this._box.add_child(b);
        }
        Main.panel._leftBox.add_child(this._box);
    }

    // Acciones para los iconos del dock (Inicio / Launchpad)
    _exportDBus() {
        const impl = {
            Launchpad() {
                if (Main.overview.visible) Main.overview.hide();
                else Main.overview.showApps();
            },
            Menu() {
                const ext = Main.extensionManager.lookup('zorin-menu@zorinos.com');
                const obj = ext?.stateObj;
                if (obj?._toggleMenu) obj._toggleMenu();
                else Main.overview.showApps();
            },
        };
        this._dbus = Gio.DBusExportedObject.wrapJSObject(IFACE, impl);
        this._dbus.export(Gio.DBus.session, '/org/local/DockActions');
        this._owner = Gio.bus_own_name_on_connection(
            Gio.DBus.session, 'org.local.DockActions', Gio.BusNameOwnerFlags.NONE, null, null);
    }

    enable() {
        this._addPowerButtons();
        this._move();
        this._exportDBus();
        this._mag = new DockMagnifier();
        this._mag.enable();
        this._t1 = GLib.timeout_add_seconds(GLib.PRIORITY_DEFAULT, 3, () => {
            this._move(); this._t1 = 0; return GLib.SOURCE_REMOVE;
        });
        this._sig = Main.panel._rightBox.connect('actor-added', () => this._move());
    }

    disable() {
        this._mag?.disable(); this._mag = null;
        if (this._t1) GLib.source_remove(this._t1);
        if (this._sig) Main.panel._rightBox.disconnect(this._sig);
        this._box?.destroy(); this._box = null;
        if (this._owner) Gio.bus_unown_name(this._owner);
        this._dbus?.unexport(); this._dbus = null;
        const c = Main.panel.statusArea.dateMenu?.container;
        if (c && this._parent) {
            c.get_parent()?.remove_child(c);
            this._parent.insert_child_at_index(c, this._index);
        }
        this._parent = null; this._t1 = 0; this._sig = 0; this._owner = 0;
    }
}
