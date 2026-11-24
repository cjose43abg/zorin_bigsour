// Separación entre iconos del dock. Zorin Taskbar usa 24 px fijos
// (4 px de margen + 8 px de relleno a cada lado). Aquí se quita el margen y se
// reduce el relleno lateral; el alto (y por tanto el tamaño del icono) no cambia.
import GLib from 'gi://GLib';

const MARGIN = 0;   // px a cada lado del icono (Zorin: 4)
const SIDE = 6;     // relleno lateral del icono (Zorin: 8). Hueco total = 2*MARGIN + 2*SIDE

export class DockSpacing {
    enable() {
        this._tries = 0;
        this._timer = GLib.timeout_add_seconds(GLib.PRIORITY_DEFAULT, 1, () => {
            if (this._patch() || ++this._tries > 60) { this._timer = 0; return GLib.SOURCE_REMOVE; }
            return GLib.SOURCE_CONTINUE;
        });
    }

    disable() {
        if (this._timer) GLib.source_remove(this._timer);
        this._timer = 0;
        if (this._proto && this._orig) {
            this._proto._setAppIconPadding = this._orig;
            this._each(icon => this._orig.call(icon));
        }
        this._proto = this._orig = null;
        for (const [a, id] of this._showAppsSigs ?? []) { try { a.disconnect(id); } catch (e) {} }
        this._showAppsSigs = [];
    }

    // Un solo acceso a las apps: Launchpad. Se oculta el botón de cuadrícula de Zorin
    _hideShowApps() {
        this._showAppsSigs ??= [];
        for (const p of global.zorinTaskbar?.panels ?? []) {
            const a = p?.taskbar?._showAppsIconWrapper?.realShowAppsIcon;
            if (!a || this._showAppsSigs.some(([x]) => x === a)) continue;
            a.hide();
            this._showAppsSigs.push([a, a.connect('notify::visible', () => { if (a.visible) a.hide(); })]);
        }
    }

    _each(fn) {
        for (const p of global.zorinTaskbar?.panels ?? [])
            for (const c of p?.taskbar?._box?.get_children() ?? [])
                if (c.child?._setAppIconPadding) { try { fn(c.child); } catch (e) { logError(e, 'DockSpacing'); } }
    }

    _patch() {
        let icon = null;
        this._each(i => { icon ??= i; });
        if (!icon) return false;
        const proto = Object.getPrototypeOf(icon);
        if (!proto._setAppIconPadding || proto._setAppIconPadding._macSpacing) return true;
        const orig = proto._setAppIconPadding;
        const patched = function () {
            orig.call(this);
            if (this.dtpPanel?.geom?.vertical) return;
            this.set_style(`padding: 0 ${MARGIN}px;`);
            const m = /padding:\s*([\d.]+)px/.exec(this._iconContainer?.get_style() ?? '');
            if (m) this._iconContainer.set_style(`padding: ${m[1]}px ${SIDE}px;`);
        };
        patched._macSpacing = true;
        this._proto = proto; this._orig = orig;
        proto._setAppIconPadding = patched;
        this._each(i => i._setAppIconPadding());
        this._hideShowApps();
        return true;
    }
}
