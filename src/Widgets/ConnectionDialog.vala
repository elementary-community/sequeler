/*
* Copyright (c) 2011-2017 Alecaddd (http://alecaddd.com)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Alessandro "Alecaddd" Castellani <castellani.ale@gmail.com>
*/

public class Sequeler.Widgets.ConnectionDialog : Gtk.Dialog {

    public ConnectionDialog (Gtk.ApplicationWindow parent, Sequeler.Services.Settings settings) {
        
        Object (
            use_header_bar: 0,
            border_width: 20,
            modal: true,
            deletable: false,
            resizable: false,
            title: _("Quick Connection"),
            transient_for: parent
        );

    }

    construct {

        var main_stack = new Gtk.Stack ();
        main_stack.set_transition_type(Gtk.StackTransitionType.SLIDE_LEFT_RIGHT);
        main_stack.set_transition_duration(320);
        main_stack.halign = Gtk.Align.CENTER;
        main_stack.margin = 6;
        main_stack.margin_bottom = 25;
        main_stack.margin_top = 15;

        main_stack.add_titled (get_socket_box (), "socket", _("Socket"));
        main_stack.add_titled (get_ftp_box (), "ftp", _("FTP"));
        main_stack.add_titled (get_ssh_box (), "ssh", _("SSH"));

        var main_stackswitcher = new Gtk.StackSwitcher ();
        main_stackswitcher.set_stack (main_stack);
        main_stackswitcher.halign = Gtk.Align.CENTER;

        var main_grid = new Gtk.Grid ();
        main_grid.halign = Gtk.Align.CENTER;
        main_grid.attach (main_stackswitcher, 1, 1, 1, 1);
        main_grid.attach (main_stack, 1, 2, 1, 1);

        var cancel_button = new Sequeler.Partials.ButtonType (_("Cancel"), null);

        var test_button = new Sequeler.Partials.ButtonType (_("Test Connection"), null);
        test_button.sensitive = false;

        var save_button = new Sequeler.Partials.ButtonType (_("Save Connection"), "safe-action");

        var connect_button = new Sequeler.Partials.ButtonType (_("Connect"), "suggested-action");
        connect_button.sensitive = false;

        add_action_widget (cancel_button, 1);
        add_action_widget (test_button, 0);
        add_action_widget (save_button, 0);
        add_action_widget (connect_button, 0);

        get_content_area ().add (main_grid);

        connect_signals ();

    }

    private Gtk.Widget get_socket_box () {
        var grid = new DialogGrid ();        

        grid.attach (new SettingsView(), 0, 1, 40, 70);

        return grid;
    }

    private Gtk.Widget get_ftp_box () {
        var grid = new DialogGrid ();        

        grid.attach (new DialogHeader (_("Connect to a Remote Host")), 1, 1, 1, 1);        

        return grid;
    }

    private Gtk.Widget get_ssh_box () {
        var grid = new DialogGrid ();

        grid.attach (new DialogHeader (_("Connect via SSH")), 1, 1, 1, 1);        

        return grid;
    }

    private void connect_signals () {
        this.response.connect (on_response);
    }

    private void on_response (Gtk.Dialog source, int response_id) {
        switch (response_id) {
            case 1:
                destroy ();
                break;
            case 2:
                //  test_connection ();
                break;
            case 3:
                //  save_connection ();
                break;
            case 4:
                //  init_connection ();
                break;
        }
    }

    private class DialogGrid : Gtk.Grid {
        public DialogGrid () {
            column_spacing = 12;
            row_spacing = 6;
            halign = Gtk.Align.CENTER;
        }
    }

    private class DialogHeader : Gtk.Label {
        public DialogHeader (string text) {
            label = text;
            get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);
            halign = Gtk.Align.CENTER;
        }
    }

    public class SettingsView : Granite.SimpleSettingsPage {

        string[] dbs = {"MySql", "MariaDB", "PostgreSql", "SqlLite"};

        enum Column {
            DISTRO
        }

        public SettingsView () {
            Object (
                activatable: false,
                description: "New connection to localhost",
                icon_name: "drive-multidisk",
                title: "New Connection"
            );
    
            var title_label = new Label (_("Name:"));
            var title_entry = new Entry (_("Connection's name"), title);
    
            var description_label = new Label (_("Description:"));
            var description_entry = new Entry (_("Connection's description"), description);

            var color_label = new Label (_("Color:"));
            var color_entry = new Gtk.ColorButton.with_rgba ({ 222, 222, 222, 255 });

            var db_type_label = new Label (_("Database Type:"));
            Gtk.ListStore liststore = new Gtk.ListStore (1, typeof (string));
            
            for (int i = 0; i < dbs.length; i++){
                Gtk.TreeIter iter;
                liststore.append (out iter);
                liststore.set (iter, Column.DISTRO, dbs[i]);
            }
    
            Gtk.ComboBox db_type_entry = new Gtk.ComboBox.with_model (liststore);
            Gtk.CellRendererText cell = new Gtk.CellRendererText ();
            db_type_entry.pack_start (cell, false);
    
            db_type_entry.set_attributes (cell, "text", Column.DISTRO);
    
            /* Set the first item in the list to be selected (active). */
            db_type_entry.set_active (0);

            var db_name_label = new Label (_("Database Name:"));
            var db_name_entry = new Entry ("", null);

            var db_username_label = new Label (_("Username:"));
            var db_username_entry = new Entry ("", null);

            var db_password_label = new Label (_("Password:"));
            var db_password_entry = new Entry ("", null);
            db_password_entry.set_visibility (false);

            content_area.attach (title_label, 0, 0, 1, 1);
            content_area.attach (title_entry, 1, 0, 1, 1);
            content_area.attach (description_label, 0, 1, 1, 1);
            content_area.attach (description_entry, 1, 1, 1, 1);
            content_area.attach (color_label, 0, 2, 1, 1);
            content_area.attach (color_entry, 1, 2, 1, 1);

            content_area.attach (new Gtk.SeparatorMenuItem (), 0, 3, 2, 1);

            content_area.attach (db_type_label, 0, 4, 1, 1);
            content_area.attach (db_type_entry, 1, 4, 1, 1);
            content_area.attach (db_name_entry, 1, 5, 1, 1);
            content_area.attach (db_name_label, 0, 5, 1, 1);
            content_area.attach (db_username_label, 0, 6, 1, 1);
            content_area.attach (db_username_entry, 1, 6, 1, 1);
            content_area.attach (db_password_label, 0, 7, 1, 1);
            content_area.attach (db_password_entry, 1, 7, 1, 1);

            title_entry.changed.connect (() => {
                title = title_entry.text;
            });

            description_entry.changed.connect (() => {
                description = description_entry.text;
            });

        }
    }

    private class Label : Gtk.Label {
        public Label (string text) {
            label = text;
            xalign = 1;
        }
    }
    
    private class Entry : Gtk.Entry {
        public Entry (string* placeholder, string* val) {
            hexpand = true;

            if (placeholder != null) {
                placeholder_text = placeholder;
            }

            if (val != null) {
                text = val;
            }
        }
    }
}