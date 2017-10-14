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

    public Sequeler.DataBase db;

    public Sequeler.ButtonType test_button;
    public Sequeler.ButtonType connect_button;

    public Gtk.Entry connection_id;
    public Entry title_entry;
    public Gtk.ColorButton color_entry;
    public Gtk.ComboBox db_type_entry;

    public Label db_host_label;
    public Entry db_host_entry;

    public Label db_port_label;
    public Entry db_port_entry;

    public Label db_name_label;
    public Entry db_name_entry;

    public Label db_username_label;
    public Entry db_username_entry;

    public Label db_password_label;
    public Entry db_password_entry;

    public Gtk.Spinner spinner;
    public ResponseMessage response_msg;

    public signal void save_connection (Gee.HashMap data, bool trigger);
    public signal void connect_to (Gee.HashMap data, Gtk.Spinner spinner, Gtk.Dialog dialog, Gtk.Label response);

    public ConnectionDialog (Gtk.ApplicationWindow parent, Sequeler.Settings settings, Gee.HashMap? data) {
        
        Object (
            use_header_bar: 0,
            border_width: 10,
            modal: true,
            deletable: false,
            resizable: false,
            title: _("New Connection"),
            transient_for: parent
        );

        SettingsView.dialog = this;
        SettingsView.data = data;

        //  set_default_size (350, 700);
        set_size_request (350, 700);

        var cancel_button = new Sequeler.ButtonType (_("Close"), null);

        test_button = new Sequeler.ButtonType (_("Test Connection"), null);
        test_button.sensitive = false;

        var save_button = new Sequeler.ButtonType (_("Save Connection"), null);

        connect_button = new Sequeler.ButtonType (_("Connect"), "suggested-action");
        connect_button.sensitive = false;

        add_action_widget (test_button, 1);
        add_action_widget (save_button, 2);
        add_action_widget (cancel_button, 3);
        add_action_widget (connect_button, 4);

        get_content_area ().add (new SettingsView (settings));

        response_msg = new ResponseMessage ();
        spinner = new Gtk.Spinner ();

        get_content_area ().add (response_msg);
        get_content_area ().add (spinner);

        connect_signals ();

    }

    private void connect_signals () {
        this.response.connect (on_response);
    }

    private void on_response (Gtk.Dialog source, int response_id) {
        switch (response_id) {
            case 1:
                test_connection ();
                break;
            case 2:
                save_data (true);
                break;
            case 3:
                destroy ();
                break;
            case 4:
                init_connection ();
                break;
        }
    }

    public void test_connection () {
        db = new Sequeler.DataBase ();

        spinner.start ();
        response_msg.label = "Testing Connection...";

        var data = create_data ();
        data.set ("host", Gda.rfc1738_encode (data["host"]));
        data.set ("port", Gda.rfc1738_encode (data["port"]));
        data.set ("name", Gda.rfc1738_encode (data["name"]));
        data.set ("username", Gda.rfc1738_encode (data["username"]));
        data.set ("password", Gda.rfc1738_encode (data["password"]));
        db.set_constr_data (data);

        GLib.Timeout.add_seconds(1, () => { 
            test_initdb ();
            return false; 
        });
    }
    
    public void test_initdb () {
        try {
            db.open();
            response_msg.label = "Successfully Connected!";
            db.close ();
        }
        catch (Error e) {
            response_msg.label = e.message;
        }
        spinner.stop ();
    }

    public void init_connection () {
        if (settings.save_quick) {
            save_data (false);
        }
        
        spinner.start ();
        response_msg.label = "Connecting...";

        connect_to (create_data (), spinner, this, response_msg);
    }

    public void save_data (bool trigger) {
        var data = create_data ();
        save_connection (data, trigger);
    }

    public Gee.HashMap<string, string> create_data () {
        var data = new Gee.HashMap<string, string> ();

        data.set ("id", connection_id.text);
        data.set ("title", title_entry.text);
        data.set ("color", color_entry.rgba.to_string ());
        data.set ("type", SettingsView.dbs [db_type_entry.get_active ()]);
        data.set ("host", db_host_entry.text);
        data.set ("port", db_port_entry.text);
        data.set ("name", db_name_entry.text);
        data.set ("username", db_username_entry.text);
        data.set ("password", db_password_entry.text);

        return data;
    }

    public void change_sensitivity () {
        if (db_name_entry.text != "" && db_host_entry.text != "") {
            test_button.sensitive = true;
            connect_button.sensitive = true;
            return;
        }

        test_button.sensitive = false;
        connect_button.sensitive = false;
    }

    public void type_changed () {
        if ( db_type_entry.get_active () == 3) {
            set_size_request (350, 600);

            db_host_label.label = _("Directory:");
            db_host_entry.placeholder_text = "./";
            db_port_label.visible = false;
            db_port_label.no_show_all = true;
            db_port_entry.visible = false;
            db_port_entry.no_show_all = true;
            db_name_label.label = _("File Name:");
            db_username_label.visible = false;
            db_username_label.no_show_all = true;
            db_username_entry.visible = false;
            db_username_entry.no_show_all = true;
            db_password_label.visible = false;
            db_password_label.no_show_all = true;
            db_password_entry.visible = false;
            db_password_entry.no_show_all = true;
            return;
        }
        set_size_request (350, 700);

        db_host_label.label = _("Host:");
        db_host_entry.placeholder_text = "127.0.0.1";
        db_port_label.visible = true;
        db_port_entry.visible = true;
        db_name_label.label = _("Database Name:");
        db_username_label.visible = true;
        db_username_entry.visible = true;
        db_password_label.visible = true;
        db_password_entry.visible = true;
    }

}

public class SettingsView : Sequeler.SimpleSettingsPage {
    
    public static Sequeler.ConnectionDialog dialog;
    public static Gee.HashMap<string, string>? data;

    public static Gee.HashMap<int, string> dbs;

    enum Column {
        DBTYPE
    }

    public SettingsView (Sequeler.Settings settings) {
        Object (
            activatable: false,
            icon_name: "drive-multidisk",
            title: "New Connection"
        );

        dbs = new Gee.HashMap<int, string> ();
        dbs.set (0,"MySQL");
        dbs.set (1,"MariaDB");
        dbs.set (2,"PostgreSQL");
        dbs.set (3,"SQLite");

        var id = settings.tot_connections;
        dialog.connection_id = new Gtk.Entry ();
        dialog.connection_id.text = id.to_string ();

        var title_label = new Label (_("Name:"));
        dialog.title_entry = new Entry (_("Connection's name"), title);

        var color_label = new Label (_("Color:"));
        dialog.color_entry = new Gtk.ColorButton.with_rgba ({ 222, 222, 222, 255 });
        dialog.color_entry.set_use_alpha (true);

        dialog.db_host_label = new Label (_("Host:"));
        dialog.db_host_entry = new Entry (_("127.0.0.1"), null);
        dialog.db_host_entry.changed.connect (() => { 
            dialog.change_sensitivity ();
        });

        dialog.db_port_label = new Label (_("Port:"));
        dialog.db_port_entry = new Entry (_("3306"), null);

        var db_type_label = new Label (_("Database Type:"));
        Gtk.ListStore liststore = new Gtk.ListStore (1, typeof (string));
        
        for (int i = 0; i < dbs.size; i++){
            Gtk.TreeIter iter;
            liststore.append (out iter);
            liststore.set (iter, Column.DBTYPE, dbs[i]);
        }

        dialog.db_type_entry = new Gtk.ComboBox.with_model (liststore);
        Gtk.CellRendererText cell = new Gtk.CellRendererText ();
        dialog.db_type_entry.pack_start (cell, false);

        dialog.db_type_entry.set_attributes (cell, "text", Column.DBTYPE);
        dialog.db_type_entry.set_active (0);
        dialog.db_type_entry.changed.connect (() => { 
            dialog.type_changed ();
        });

        dialog.db_name_label = new Label (_("Database Name:"));
        dialog.db_name_entry = new Entry ("", null);
        dialog.db_name_entry.changed.connect (() => { 
            dialog.change_sensitivity ();
        });

        dialog.db_username_label = new Label (_("Username:"));
        dialog.db_username_entry = new Entry ("", null);

        dialog.db_password_label = new Label (_("Password:"));
        dialog.db_password_entry = new Entry ("", null);
        dialog.db_password_entry.set_visibility (false);

        content_area.attach (title_label, 0, 0, 1, 1);
        content_area.attach (dialog.title_entry, 1, 0, 1, 1);
        content_area.attach (color_label, 0, 1, 1, 1);
        content_area.attach (dialog.color_entry, 1, 1, 1, 1);

        content_area.attach (new Gtk.SeparatorMenuItem (), 0, 2, 2, 1);

        content_area.attach (db_type_label, 0, 3, 1, 1);
        content_area.attach (dialog.db_type_entry, 1, 3, 1, 1);

        content_area.attach (dialog.db_host_label, 0, 4, 1, 1);
        content_area.attach (dialog.db_host_entry, 1, 4, 1, 1);

        content_area.attach (dialog.db_port_label, 0, 5, 1, 1);
        content_area.attach (dialog.db_port_entry, 1, 5, 1, 1);

        content_area.attach (dialog.db_name_label, 0, 6, 1, 1);
        content_area.attach (dialog.db_name_entry, 1, 6, 1, 1);
        content_area.attach (dialog.db_username_label, 0, 7, 1, 1);
        content_area.attach (dialog.db_username_entry, 1, 7, 1, 1);
        content_area.attach (dialog.db_password_label, 0, 8, 1, 1);
        content_area.attach (dialog.db_password_entry, 1, 8, 1, 1);

        dialog.title_entry.changed.connect (() => {
            title = dialog.title_entry.text;
        });

        if (data != null) {
            dialog.connection_id.text = data["id"];
            dialog.title_entry.text = data["title"];

            Gdk.RGBA color = Gdk.RGBA ();
            color.parse (data["color"]);
            dialog.color_entry.rgba = color;

            dialog.db_host_entry.text = data["host"];
            dialog.db_port_entry.text = data["port"];

            foreach (var entry in dbs.entries) {
                if (entry.value == data["type"]) {
                    dialog.db_type_entry.set_active (entry.key);
                }
            }

            dialog.db_name_entry.text = data["name"];
            dialog.db_username_entry.text = data["username"];
            dialog.db_password_entry.text = data["password"];

        }

        dialog.type_changed ();

    }
}

public class Label : Gtk.Label {
    public Label (string text) {
        label = text;
        xalign = 1;
    }
}

public class Entry : Gtk.Entry {
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

public class ResponseMessage : Gtk.Label {
    public ResponseMessage () {
        get_style_context ().add_class ("h4");
        halign = Gtk.Align.CENTER;
        valign = Gtk.Align.CENTER;
        set_justify (Gtk.Justification.CENTER);
        set_line_wrap (true);
    }
}