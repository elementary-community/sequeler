/*
* Copyright (c) 2011-2018 Alecaddd (http://alecaddd.com)
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
    public weak Sequeler.Window window { get; construct; }

    public Sequeler.Partials.ButtonClass test_button;
    public Sequeler.Partials.ButtonClass connect_button;

    private Gtk.Label header_title;
    private Gtk.ColorButton color_picker;

    private Sequeler.Partials.LabelForm db_file_label;
    private Sequeler.Partials.LabelForm db_host_label;
    private Sequeler.Partials.LabelForm db_name_label;
    private Sequeler.Partials.LabelForm db_username_label;
    private Sequeler.Partials.LabelForm db_password_label;
    private Sequeler.Partials.LabelForm db_port_label;

    private Gtk.Entry connection_id;
    private Sequeler.Partials.Entry title_entry;
    private Gee.HashMap<int, string> db_types;
    private Gtk.ComboBox db_type_entry;
    private Sequeler.Partials.Entry db_host_entry;
    private Sequeler.Partials.Entry db_name_entry;
    private Sequeler.Partials.Entry db_username_entry;
    private Sequeler.Partials.Entry db_password_entry;
    private Sequeler.Partials.Entry db_port_entry;
    private Gtk.FileChooserButton db_file_entry;

    private Gtk.Spinner spinner;
    private Sequeler.Partials.ResponseMessage response_msg;

    enum Column {
        DBTYPE
    }

    public ConnectionDialog (Sequeler.Window? parent) {
        Object (
            border_width: 5,
            deletable: false,
            resizable: false,
            title: _("Connection"),
            transient_for: parent,
            window: parent
        );
    }

    construct {
        set_id ();
        build_content ();
        build_actions ();
        populate_data ();

        response.connect (on_response);
    }

    private void set_id () {
        var id = settings.tot_connections;

        connection_id = new Gtk.Entry ();
        connection_id.text = id.to_string ();
    }

    private void build_content () {
        var body = get_content_area ();

        db_types = new Gee.HashMap<int, string> ();
        db_types.set (0,"MySQL");
        db_types.set (1,"MariaDB");
        db_types.set (2,"PostgreSQL");
        db_types.set (3,"SQLite");

        var header_grid = new Gtk.Grid ();
        header_grid.margin_start = 5;
        header_grid.margin_end = 5;
        header_grid.margin_bottom = 20;

        var image = new Gtk.Image.from_icon_name ("drive-multidisk", Gtk.IconSize.DIALOG);
        image.margin_end = 10;

        header_title = new Gtk.Label (_("New Connection"));
        header_title.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);
        header_title.halign = Gtk.Align.START;
        header_title.margin_end = 10;
        header_title.set_line_wrap (true);
        header_title.hexpand = true;

        color_picker = new Gtk.ColorButton.with_rgba ({ 222, 222, 222, 255 });
        color_picker.set_use_alpha (true);
        color_picker.get_style_context ().add_class ("color-picker");
        color_picker.can_focus = false;

        header_grid.attach (image, 0, 0, 1, 2);
        header_grid.attach (header_title, 1, 0, 1, 2);
        header_grid.attach (color_picker, 2, 0, 1, 1);

        body.add (header_grid);

        var form_grid = new Gtk.Grid ();
        form_grid.margin_top = 5;
        form_grid.margin_bottom = 20;
        form_grid.margin_start = 30;
        form_grid.margin_end = 30;
        form_grid.row_spacing = 10;
        form_grid.column_spacing = 20;

        var title_label = new Sequeler.Partials.LabelForm (_("Connection Name:"));
        title_entry = new Sequeler.Partials.Entry (_("Connection's name"), title);
        title_entry.changed.connect (() => {
            header_title.label = title_entry.text;
        });
        form_grid.attach (title_label, 0, 0, 1, 1);
        form_grid.attach (title_entry, 1, 0, 1, 1);

        var db_type_label = new Sequeler.Partials.LabelForm (_("Database Type:"));
        var list_store = new Gtk.ListStore (1, typeof (string));
        
        for (int i = 0; i < db_types.size; i++){
            Gtk.TreeIter iter;
            list_store.append (out iter);
            list_store.set (iter, Column.DBTYPE, db_types[i]);
        }

        db_type_entry = new Gtk.ComboBox.with_model (list_store);
        var cell = new Gtk.CellRendererText ();
        db_type_entry.pack_start (cell, false);

        db_type_entry.set_attributes (cell, "text", Column.DBTYPE);
        db_type_entry.set_active (0);
        db_type_entry.changed.connect (() => { 
            db_type_changed ();
        });

        form_grid.attach (db_type_label, 0, 1, 1, 1);
        form_grid.attach (db_type_entry, 1, 1, 1, 1);

        db_host_label = new Sequeler.Partials.LabelForm (_("Host:"));
        db_host_entry = new Sequeler.Partials.Entry (_("127.0.0.1"), null);
        db_host_entry.changed.connect (change_sensitivity);

        form_grid.attach (db_host_label, 0, 2, 1, 1);
        form_grid.attach (db_host_entry, 1, 2, 1, 1);

        db_name_label = new Sequeler.Partials.LabelForm (_("Database Name:"));
        db_name_entry = new Sequeler.Partials.Entry ("", null);
        db_name_entry.changed.connect (change_sensitivity);

        form_grid.attach (db_name_label, 0, 3, 1, 1);
        form_grid.attach (db_name_entry, 1, 3, 1, 1);

        db_username_label = new Sequeler.Partials.LabelForm (_("Username:"));
        db_username_entry = new Sequeler.Partials.Entry ("", null);

        form_grid.attach (db_username_label, 0, 4, 1, 1);
        form_grid.attach (db_username_entry, 1, 4, 1, 1);

        db_password_label = new Sequeler.Partials.LabelForm (_("Password:"));
        db_password_entry = new Sequeler.Partials.Entry ("", null);
        db_password_entry.visibility = false;
        db_password_entry.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, "dialog-information-symbolic");
		db_password_entry.icon_press.connect ((pos, event) => {
			if (pos == Gtk.EntryIconPosition.SECONDARY) {
				db_password_entry.visibility = !db_password_entry.visibility;
			}
		});

        form_grid.attach (db_password_label, 0, 5, 1, 1);
        form_grid.attach (db_password_entry, 1, 5, 1, 1);

        db_port_label = new Sequeler.Partials.LabelForm (_("Port:"));
        db_port_entry = new Sequeler.Partials.Entry ("3306", null);

        form_grid.attach (db_port_label, 0, 6, 1, 1);
        form_grid.attach (db_port_entry, 1, 6, 1, 1);

        db_file_label = new Sequeler.Partials.LabelForm (_("File Path:"));
        db_file_entry = new Gtk.FileChooserButton (_("Select your SQLite File..."), Gtk.FileChooserAction.OPEN);
        var filter = new Gtk.FileFilter ();
        filter.add_pattern ("*.db");
        db_file_entry.add_filter (filter);

        db_file_entry.selection_changed.connect (change_sensitivity);

        form_grid.attach (db_file_label, 0, 7, 1, 1);
        form_grid.attach (db_file_entry, 1, 7, 1, 1);
        db_file_label.visible = false;
        db_file_label.no_show_all = true;
        db_file_entry.visible = false;
        db_file_entry.no_show_all = true;

        body.add (form_grid);

        spinner = new Gtk.Spinner ();
        response_msg = new Sequeler.Partials.ResponseMessage ();

        body.add (spinner);
        body.add (response_msg);
    }

    private void build_actions () {
        var cancel_button = new Sequeler.Partials.ButtonClass (_("Close"), null);
        var save_button = new Sequeler.Partials.ButtonClass (_("Save Connection"), null);

        test_button = new Sequeler.Partials.ButtonClass (_("Test Connection"), null);
        test_button.sensitive = false;

        connect_button = new Sequeler.Partials.ButtonClass (_("Connect"), "suggested-action");
        connect_button.sensitive = false;

        add_action_widget (test_button, 1);
        add_action_widget (save_button, 2);
        add_action_widget (cancel_button, 3);
        add_action_widget (connect_button, 4);
    }

    private void populate_data () {
        if (window.data_manager.data == null || window.data_manager.data.size == 0) {
            return;
        }

        var update_data = window.data_manager.data;

        connection_id.text = update_data["id"];
        title_entry.text = update_data["title"];

        var color = Gdk.RGBA ();
        color.parse (update_data["color"]);
        color_picker.rgba = color;

        foreach (var entry in db_types.entries) {
            if (entry.value == update_data["type"]) {
                db_type_entry.set_active (entry.key);
            }
        }

        db_host_entry.text = update_data["host"];
        db_name_entry.text = update_data["name"];
        db_username_entry.text = update_data["username"];
        db_password_entry.text = update_data["password"];

        if (update_data["file_path"] != null) {
            db_file_entry.set_uri (update_data["file_path"]);
        }

        if (update_data["type"] == "SQLite" && update_data["file_path"] == null) {
            var update_file_path = "file:/" + update_data["host"] + "/" + update_data["name"] + ".db";
            warning (update_file_path);
            try {
                db_file_entry.set_uri (update_file_path);
                db_file_entry.set_file (GLib.File.new_for_uri (update_file_path));
                db_file_entry.set_filename (update_data["name"] + ".db");
            } catch (Error e) {
                write_response (e.message);
            }
        }

        if (update_data["port"] != null) {
            db_port_entry.text = update_data["port"];
        }
    }

    private void db_type_changed () {
        var toggle = db_type_entry.get_active () == 3 ? true : false;
        toggle_database_info (toggle);
        change_sensitivity ();

        if (db_type_entry.get_active () == 2) {
            db_port_entry.placeholder_text = "5432";
        } else {
            db_port_entry.placeholder_text = "3306";
        }
    }

    private void toggle_database_info (bool toggle) {
        db_file_label.visible = toggle;
        db_file_label.no_show_all = !toggle;
        db_file_entry.visible = toggle;
        db_file_entry.no_show_all = !toggle;

        db_host_label.visible = !toggle;
        db_host_label.no_show_all = toggle;
        db_host_entry.visible = !toggle;
        db_host_entry.no_show_all = toggle;
        db_name_label.visible = !toggle;
        db_name_label.no_show_all = toggle;
        db_name_entry.visible = !toggle;
        db_name_entry.no_show_all = toggle;
        db_username_label.visible = !toggle;
        db_username_label.no_show_all = toggle;
        db_username_entry.visible = !toggle;
        db_username_entry.no_show_all = toggle;
        db_password_label.visible = !toggle;
        db_password_label.no_show_all = toggle;
        db_password_entry.visible = !toggle;
        db_password_entry.no_show_all = toggle;
        db_port_label.visible = !toggle;
        db_port_label.no_show_all = toggle;
        db_port_entry.visible = !toggle;
        db_port_entry.no_show_all = toggle;
    }

    private void change_sensitivity () {
        if ((db_type_entry.get_active () != 3 && db_name_entry.text != "" && db_host_entry.text != "") 
            || (db_type_entry.get_active () == 3 && db_file_entry.get_uri () != null)) {
            test_button.sensitive = true;
            connect_button.sensitive = true;
            return;
        }

        test_button.sensitive = false;
        connect_button.sensitive = false;
    }

    private void on_response (Gtk.Dialog source, int response_id) {
        switch (response_id) {
            case 1:
                test_connection ();
                break;
            case 2:
                save_connection ();
                break;
            case 3:
                destroy ();
                break;
            case 4:
                init_connection ();
                break;
        }
    }

    private async void test_connection () throws ThreadError {
        toggle_spinner (true);
        write_response (_("Testing Connection..."));

        var connection = new Sequeler.Services.ConnectionManager (package_data ());
        SourceFunc callback = test_connection.callback;

        new Thread <void*> (null, () => {
            try {
                connection.test ();
                write_response (_("Successfully Connected!"));
            }
            catch (Error e) {
                write_response (e.message);
            }
            Idle.add ((owned) callback);
            toggle_spinner (false);
            return null;
        });

        yield;
    }

    private async void save_connection () throws ThreadError {
        toggle_spinner (true);
        write_response (_("Saving Connection..."));

        SourceFunc callback = save_connection.callback;

        new Thread <void*> (null, () => {
            try {
                settings.add_connection (package_data ());
                window.main.library.reload_library ();

                write_response (_("Connection Saved!"));
            }
            catch (Error e) {
                write_response (e.message);
            }
            Idle.add ((owned) callback);
            toggle_spinner (false);
            return null;
        });

        yield;
    }

    private async void init_connection () throws ThreadError {
        toggle_spinner (true);
        write_response (_("Connection..."));

        var connection = new Sequeler.Services.ConnectionManager (package_data ());
        SourceFunc callback = init_connection.callback;

        new Thread <void*> (null, () => {
            try {
                connection.test ();

                if (settings.save_quick) {
                    settings.add_connection (package_data ());
                    window.main.library.reload_library ();
                }

                write_response (_("Successfully Connected!"));
            }
            catch (Error e) {
                write_response (e.message);
            }
            Idle.add ((owned) callback);
            toggle_spinner (false);
            return null;
        });

        yield;
    }

    private Gee.HashMap<string, string> package_data () {
        var packaged_data = new Gee.HashMap<string, string> ();

        packaged_data.set ("id", connection_id.text);
        packaged_data.set ("title", title_entry.text);
        packaged_data.set ("color", color_picker.rgba.to_string ());
        packaged_data.set ("type", db_types [db_type_entry.get_active ()]);
        packaged_data.set ("host", db_host_entry.text);
        packaged_data.set ("name", db_name_entry.text);
        packaged_data.set ("file_path", db_file_entry.get_uri ());
        packaged_data.set ("username", db_username_entry.text);
        packaged_data.set ("password", db_password_entry.text);
        packaged_data.set ("port", db_port_entry.text);

        return packaged_data;
    }

    public void toggle_spinner (bool type) {
        if (type == true) {
            spinner.start ();
            return;
        }

        spinner.stop ();
    }

    public void write_response (string? response_text) {
        response_msg.label = response_text;
    }
}