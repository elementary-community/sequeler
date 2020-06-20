/*
 * Copyright (c) 2020 Alecaddd (https://alecaddd.com)
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public
 * License along with this program; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA
 *
 * Authored by: Alessandro "Alecaddd" Castellani <castellani.ale@gmail.com>
 */

public class Sequeler.Partials.DatabasePanel : Gtk.Revealer {
    private Gtk.Revealer panel_revealer;

    public bool reveal {
        get {
            return reveal_child;
        }
        set {
            reveal_child = value;
            Timeout.add (transition_duration, () => {
                panel_revealer.reveal_child = value;
                return false;
            });
        }
    }

    construct {
        transition_type = Gtk.RevealerTransitionType.CROSSFADE;
        reveal_child = false;

        var base_grid = new Gtk.Grid ();
        base_grid.get_style_context ().add_class ("database-panel-overlay");

        panel_revealer = new Gtk.Revealer ();
        panel_revealer.valign = Gtk.Align.START;
        panel_revealer.hexpand = true;
        panel_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN;
        panel_revealer.reveal_child = false;

        var panel = new Gtk.Grid ();
        panel.margin = 9;
        panel.get_style_context ().add_class ("database-panel");

        panel_revealer.add (panel);
        base_grid.add (panel_revealer);
        add (base_grid);
    }
}
