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

public class Sequeler.Partials.DataBasePanel : Gtk.Revealer {
    public weak Sequeler.Window window { get; construct; }

    private Gtk.Label title;
    private Sequeler.Partials.Entry db_entry;
    private Gtk.Stack button_stack;
    private Gtk.Button button_save;
    private Gtk.Button button_edit;

    public bool reveal {
        get {
            return reveal_child;
        }
        set {
            reveal_child = value;
        }
    }

    public DataBasePanel (Sequeler.Window main_window) {
        Object (
            window: main_window
        );
    }

    construct {
        valign = Gtk.Align.START;
        hexpand = true;
        transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN;
        reveal_child = false;

        var panel = new Gtk.Grid ();
        panel.margin = 9;
        panel.get_style_context ().add_class ("database-panel");

        // Title area.
        title = new Gtk.Label ("");
        title.get_style_context ().add_class ("h4");
        title.margin_start = title.margin_end = 3;
        title.margin_top = 6;
        title.ellipsize = Pango.EllipsizeMode.END;

        // Body area.
        var body = new Gtk.Grid ();
        body.margin = 3;

        db_entry = new Sequeler.Partials.Entry (_("Database name"), null);
        db_entry.margin = 6;
        db_entry.changed.connect (change_sensitivity);

        body.add (db_entry);

        // Action buttons area.
        var buttons_area = new Gtk.Grid ();
        buttons_area.hexpand = true;
        buttons_area.get_style_context ().add_class ("database-panel-bottom");

        button_save = new Gtk.Button.with_label (_("Save"));
        button_save.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
        button_save.margin = 9;
        button_save.sensitive = false;
        button_save.clicked.connect (() => {
            window.main.database_schema.create_database.begin (db_entry.text);
        });

        button_edit = new Gtk.Button.with_label (_("Edit"));
        button_edit.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
        button_edit.margin = 9;
        button_edit.sensitive = false;
        button_edit.clicked.connect (() => {
            var dialog = new Granite.MessageDialog.with_image_from_icon_name (_("Are you sure you want to edit this Database?"), _("This is a dangerous operation and it might cause data loss, a backup before proceeding is recommended."), "dialog-warning", Gtk.ButtonsType.CANCEL);
            dialog.transient_for = window;

            var suggested_button = new Gtk.Button.with_label (_("Yes, proceed!"));
            suggested_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
            dialog.add_action_widget (suggested_button, Gtk.ResponseType.ACCEPT);

            dialog.show_all ();
            if (dialog.run () == Gtk.ResponseType.ACCEPT) {
                window.main.database_schema.edit_database.begin (db_entry.text);
            }

            dialog.destroy ();
        });

        button_stack = new Gtk.Stack ();
        button_stack.expand = false;
        button_stack.add_named (button_save, "new");
        button_stack.add_named (button_edit, "edit");

        var button_cancel = new Gtk.Button.with_label (_("Cancel"));
        button_cancel.clicked.connect (() => {
            window.main.database_schema.hide_database_panel ();
        });
        button_cancel.margin = 9;

        var separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
        separator.expand = true;
        separator.halign = Gtk.Align.CENTER;

        buttons_area.attach (button_cancel, 0, 0);
        buttons_area.attach (separator, 1, 0);
        buttons_area.attach (button_stack, 2, 0);

        panel.attach (title, 0, 0);
        panel.attach (body, 0, 1);
        panel.attach (buttons_area, 0, 2);

        add (panel);
    }

    private void change_sensitivity () {
        button_save.sensitive = db_entry.text != "";
        button_edit.sensitive = db_entry.text != "";
    }

    public void new_database () {
        title.label = _("Create a new Database");
        db_entry.text = "";
        button_stack.visible_child_name = "new";
    }

    public void edit_database (string name) {
        title.label = _("Edit Database");
        db_entry.text = name;
        button_stack.visible_child_name = "edit";
    }
}
