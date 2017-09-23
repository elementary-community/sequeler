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

public class Sequeler.ConnectionDialog : Gtk.Dialog {

    public Sequeler.ButtonType test_button;
    public Sequeler.ButtonType connect_button;

    private Gtk.Entry connection_id;
    private Entry title_entry;
    private Gtk.ColorButton color_entry;
    private Gtk.ComboBox db_type_entry;
    private Entry db_host_entry;
    private Entry db_name_entry;
    private Entry db_username_entry;
    private Entry db_password_entry;

    public signal void save_connection (Gee.HashMap data);

    public ConnectionDialog (Gtk.ApplicationWindow parent, Sequeler.Settings settings, Gee.HashMap? data) {
        
        Object (
            use_header_bar: 0,
            border_width: 20,
            modal: true,
            deletable: false,
            resizable: true,
            title: _("New Connection"),
            transient_for: parent
        );

        SettingsView.dialog = this;
        SettingsView.data = data;

        set_default_size (350, 650);
        set_size_request (350, 650);

        var main_stack = new Gtk.Stack ();

        var cancel_button = new Sequeler.ButtonType (_("Close"), null);

        test_button = new Sequeler.ButtonType (_("Test Connection"), null);
        test_button.sensitive = false;

        var save_button = new Sequeler.ButtonType (_("Save Connection"), null);

        connect_button = new Sequeler.ButtonType (_("Connect"), "suggested-action");
        connect_button.sensitive = false;

        add_action_widget (cancel_button, 1);
        add_action_widget (test_button, 2);
        add_action_widget (save_button, 3);
        add_action_widget (connect_button, 4);

        get_content_area ().add (new SettingsView ());

        connect_signals ();

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
                create_data ();
                break;
            case 4:
                //  init_connection ();
                break;
        }
    }

    public void create_data () {
        var data = new Gee.HashMap<string, string> ();

        data.set ("id", connection_id.text);
        data.set ("title", title_entry.text);
        data.set ("color", color_entry.rgba.to_string ());
        data.set ("type", SettingsView.dbs [db_type_entry.get_active ()]);
        data.set ("host", db_host_entry.text);
        data.set ("name", db_name_entry.text);
        data.set ("username", db_username_entry.text);
        data.set ("password", db_password_entry.text);

        save_connection (data);
    }

    public void change_sensitivity () {
        if (db_name_entry.text != "" && db_username_entry.text != "" && db_host_entry.text != "") {
            test_button.sensitive = true;
            connect_button.sensitive = true;
            return;
        }

        test_button.sensitive = false;
        connect_button.sensitive = false;
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

        public static ConnectionDialog dialog;
        public static Gee.HashMap<string, string>? data;

        public static string[] dbs = {"MySql", "MariaDB", "PostgreSql", "SqlLite"};

        enum Column {
            DISTRO
        }

        public SettingsView () {
            Object (
                activatable: false,
                icon_name: "drive-multidisk",
                title: "New Connection"
            );

            var id = settings.saved_connections.length;
            dialog.connection_id = new Gtk.Entry ();
            dialog.connection_id.text = id.to_string ();
    
            var title_label = new Label (_("Name:"));
            dialog.title_entry = new Entry (_("Connection's name"), title);


            var color_label = new Label (_("Color:"));
            dialog.color_entry = new Gtk.ColorButton.with_rgba ({ 222, 222, 222, 255 });

            var db_host_label = new Label (_("Host:"));
            dialog.db_host_entry = new Entry (_("127.0.0.1"), null);

            var db_type_label = new Label (_("Database Type:"));
            Gtk.ListStore liststore = new Gtk.ListStore (1, typeof (string));
            
            for (int i = 0; i < dbs.length; i++){
                Gtk.TreeIter iter;
                liststore.append (out iter);
                liststore.set (iter, Column.DISTRO, dbs[i]);
            }
    
            dialog.db_type_entry = new Gtk.ComboBox.with_model (liststore);
            Gtk.CellRendererText cell = new Gtk.CellRendererText ();
            dialog.db_type_entry.pack_start (cell, false);
    
            dialog.db_type_entry.set_attributes (cell, "text", Column.DISTRO);
    
            /* Set the first item in the list to be selected (active). */
            dialog.db_type_entry.set_active (0);

            var db_name_label = new Label (_("Database Name:"));
            dialog.db_name_entry = new Entry ("", null);
            dialog.db_name_entry.changed.connect (() => { 
                dialog.change_sensitivity ();
            });

            var db_username_label = new Label (_("Username:"));
            dialog.db_username_entry = new Entry ("", null);
            dialog.db_username_entry.changed.connect (() => { 
                dialog.change_sensitivity ();
            });

            var db_password_label = new Label (_("Password:"));
            dialog.db_password_entry = new Entry ("", null);
            dialog.db_password_entry.set_visibility (false);
            dialog.db_password_entry.changed.connect (() => { 
                dialog.change_sensitivity ();
            });

            content_area.attach (title_label, 0, 0, 1, 1);
            content_area.attach (dialog.title_entry, 1, 0, 1, 1);
            content_area.attach (color_label, 0, 2, 1, 1);
            content_area.attach (dialog.color_entry, 1, 2, 1, 1);

            content_area.attach (new Gtk.SeparatorMenuItem (), 0, 3, 2, 1);

            content_area.attach (db_host_label, 0, 4, 1, 1);
            content_area.attach (dialog.db_host_entry, 1, 4, 1, 1);

            content_area.attach (db_type_label, 0, 5, 1, 1);
            content_area.attach (dialog.db_type_entry, 1, 5, 1, 1);
            content_area.attach (db_name_label, 0, 6, 1, 1);
            content_area.attach (dialog.db_name_entry, 1, 6, 1, 1);
            content_area.attach (db_username_label, 0, 7, 1, 1);
            content_area.attach (dialog.db_username_entry, 1, 7, 1, 1);
            content_area.attach (db_password_label, 0, 8, 1, 1);
            content_area.attach (dialog.db_password_entry, 1, 8, 1, 1);

            dialog.title_entry.changed.connect (() => {
                title = dialog.title_entry.text;
            });

            if (data != null) {
                dialog.connection_id.text = data["id"];
                dialog.title_entry.text = data["title"];
                // rgba
                dialog.db_host_entry.text = data["host"];
                // db
                dialog.db_name_entry.text = data["name"];
                dialog.db_username_entry.text = data["username"];
                dialog.db_password_entry.text = data["password"];
            }

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