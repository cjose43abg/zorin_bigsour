// Efecto "ola" del dock (magnificación estilo macOS) para Zorin Taskbar.
// El icono bajo el puntero crece y los vecinos crecen menos; el resto se aparta.
import Clutter from 'gi://Clutter';
import GLib from 'gi://GLib';
import * as PointerWatcher from 'resource:///org/gnome/shell/ui/pointerWatcher.js';

const MAX = 1.6;        // tamaño máximo del icono bajo el puntero (1.6 = +60 %)
const SPREAD = 1.4;     // ancho de la ola, en iconos
const ABOVE = 1.0;      // margen sobre el dock, en alturas de icono, que mantiene la ola
const BACK_MS = 140;    // duración del regreso al soltar

export class DockMagnifier {
    enable() {
        this._prepared = new WeakSet();
        this._active = new Set();
        this._watch = PointerWatcher.getPointerWatcher().addWatch(16, (x, y) => {
            try { this._update(x, y); } catch (e) { logError(e, 'DockMagnifier'); }
        });
    }

    disable() {
        this._watch?.remove(); this._watch = null;
        for (const tb of this._taskbars()) {
            this._reset(tb, 0);
            if (tb._container) tb._container.clip_to_allocation = true;
            if (tb._box && 'clip_to_view' in tb._box) tb._box.clip_to_view = true;
        }
        this._active?.clear();
    }

    _taskbars() {
        const panels = global.zorinTaskbar?.panels ?? [];
        return panels.filter(p => p?.taskbar && !p.geom?.vertical).map(p => p.taskbar);
    }

    _prep(tb) {
        if (this._prepared.has(tb)) return;
        // Sin recorte, para que el icono crezca por encima del dock
        tb._container.clip_to_allocation = false;
        if ('clip_to_view' in tb._box) tb._box.clip_to_view = false;
        this._prepared.add(tb);
    }

    // El contenedor del dock recorta a su alto; se amplía hacia arriba solo mientras dura la ola
    _open(tb, extra) {
        const p = tb.dtpPanel;
        if (!p?.clipContainer || tb._magOpen) return;
        tb._magOpen = true;
        if (tb._magTimer) { GLib.source_remove(tb._magTimer); tb._magTimer = 0; }
        const cc = p.clipContainer;
        tb._magClip = cc.has_clip ? cc.get_clip() : null;
        if (tb._magClip) {
            const [cx, cy, cw, ch] = tb._magClip;
            cc.set_clip(cx, cy - extra, cw, ch + extra);
        }
        if (p.panelBox && 'clip_to_view' in p.panelBox) p.panelBox.clip_to_view = false;
        // El panel se dibuja en una capa en caché del tamaño del dock; mientras dura la ola, sin caché
        tb._magRedirect = p.offscreen_redirect;
        p.set_offscreen_redirect(Clutter.OffscreenRedirect.AUTOMATIC_FOR_OPACITY);
    }

    _close(tb) {
        const p = tb.dtpPanel;
        if (tb._magClip && p?.clipContainer) p.clipContainer.set_clip(...tb._magClip);
        if (p?.panelBox && 'clip_to_view' in p.panelBox) p.panelBox.clip_to_view = true;
        if (p && tb._magRedirect !== undefined) p.set_offscreen_redirect(tb._magRedirect);
        tb._magRedirect = undefined;
        tb._magClip = null;
        tb._magOpen = false;
    }

    _items(tb) {
        return tb._box.get_children().filter(c => c.visible && c.child?._dtpIconContainer);
    }

    _reset(tb, ms = BACK_MS) {
        for (const it of this._items(tb)) {
            const ic = it.child._dtpIconContainer;
            it.remove_all_transitions(); ic.remove_all_transitions();
            if (ms) {
                it.ease({translation_x: 0, duration: ms, mode: Clutter.AnimationMode.EASE_OUT_QUAD});
                ic.ease({scale_x: 1, scale_y: 1, duration: ms, mode: Clutter.AnimationMode.EASE_OUT_QUAD});
            } else {
                it.translation_x = 0; ic.set_scale(1, 1);
            }
        }
        this._active.delete(tb);
        if (tb._magTimer) GLib.source_remove(tb._magTimer);
        if (ms) {
            tb._magTimer = GLib.timeout_add(GLib.PRIORITY_DEFAULT, ms + 30, () => {
                tb._magTimer = 0;
                if (!this._active?.has(tb)) this._close(tb);
                return GLib.SOURCE_REMOVE;
            });
        } else {
            tb._magTimer = 0; this._close(tb);
        }
    }

    _update(x, y) {
        for (const tb of this._taskbars()) {
            if (!tb._container || !tb._box) continue;
            this._prep(tb);
            const items = this._items(tb);
            if (!items.length) continue;

            const [bx, by] = tb._box.get_transformed_position();
            const geo = items.map(it => {
                const a = it.get_allocation_box();
                return {it, left: bx + a.x1, w: a.x2 - a.x1};
            });
            const h = items[0].get_height();
            const first = geo[0].left, last = geo[geo.length - 1].left + geo[geo.length - 1].w;
            const [, cy] = tb._container.get_transformed_position();
            const ch = tb._container.get_height();
            const inside = x >= first - 8 && x <= last + 8 && y >= cy - h * ABOVE && y <= cy + ch + 4;

            if (!inside) {
                if (this._active.has(tb)) this._reset(tb);
                continue;
            }
            this._active.add(tb);
            this._open(tb, Math.ceil(h * (MAX - 1)) + 12);

            // Escala de cada icono según su distancia al puntero (curva gaussiana)
            for (const g of geo) {
                const d = (x - (g.left + g.w / 2)) / (g.w * SPREAD);
                g.s = 1 + (MAX - 1) * Math.exp(-d * d);
            }
            // El punto bajo el puntero queda fijo; los demás se reacomodan alrededor
            let k = geo.findIndex(g => x < g.left + g.w);
            if (k < 0) k = geo.length - 1;
            const f = Math.min(Math.max((x - geo[k].left) / geo[k].w, 0), 1);
            geo[k].nl = x - f * geo[k].s * geo[k].w;
            for (let i = k + 1; i < geo.length; i++) geo[i].nl = geo[i - 1].nl + geo[i - 1].s * geo[i - 1].w;
            for (let i = k - 1; i >= 0; i--) geo[i].nl = geo[i + 1].nl - geo[i].s * geo[i].w;

            for (const g of geo) {
                const ic = g.it.child._dtpIconContainer;
                g.it.remove_all_transitions(); ic.remove_all_transitions();
                ic.set_pivot_point(0.5, 1);
                ic.set_scale(g.s, g.s);
                g.it.translation_x = (g.nl + g.s * g.w / 2) - (g.left + g.w / 2);
            }
        }
    }
}
