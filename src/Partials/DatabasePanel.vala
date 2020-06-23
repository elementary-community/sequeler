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
    private Sequeler.Partials.Entry db_entry;

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

        // Title area.
        var title = new Gtk.Label (_("Create a new Database"));
        title.get_style_context ().add_class ("h4");
        title.margin_start = title.margin_end = 3;
        title.margin_top = 6;
        title.ellipsize = Pango.EllipsizeMode.END;

        // Body area.
        var body = new Gtk.Grid ();
        body.margin = 3;

        db_entry = new Sequeler.Partials.Entry (_("Database name"), null);
        db_entry.margin = 6;

        body.add (db_entry);

        // Action buttons area.
        var buttons_area = new Gtk.Grid ();
        buttons_area.hexpand = true;
        buttons_area.get_style_context ().add_class ("database-panel-bottom");

        var button_save = new Gtk.Button.with_label (_("Save"));
        button_save.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
        button_save.margin = 9;

        var button_cancel = new Gtk.Button.with_label (_("Cancel"));
        button_cancel.clicked.connect (() => {
            panel_revealer.reveal_child = false;
            reveal_child = false;
        });
        button_cancel.margin = 9;

        var separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
        separator.expand = true;
        separator.halign = Gtk.Align.CENTER;

        buttons_area.attach (button_cancel, 0, 0);
        buttons_area.attach (separator, 1, 0);
        buttons_area.attach (button_save, 2, 0);

        panel.attach (title, 0, 0);
        panel.attach (body, 0, 1);
        panel.attach (buttons_area, 0, 2);

        panel_revealer.add (panel);
        base_grid.add (panel_revealer);
        add (base_grid);
    }
}
