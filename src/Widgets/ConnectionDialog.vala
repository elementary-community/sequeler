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
	private Gtk.Grid form_grid;
	private Gtk.InfoBar infobar;

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
	private Gtk.Separator db_separator;

	private string keyfile1;
	private string keyfile2;
	private Gtk.Separator ssh_separator;
	private Sequeler.Partials.LabelForm ssh_switch_label;
	private Gtk.Grid ssh_switch_container;
	private Gtk.Switch ssh_switch;
	private Sequeler.Partials.LabelForm ssh_host_label;
	private Sequeler.Partials.Entry ssh_host_entry;
	private Sequeler.Partials.LabelForm ssh_username_label;
	private Sequeler.Partials.Entry ssh_username_entry;
	private Sequeler.Partials.LabelForm ssh_password_label;
	private Sequeler.Partials.Entry ssh_password_entry;
	private Sequeler.Partials.LabelForm ssh_port_label;
	private Sequeler.Partials.Entry ssh_port_entry;

	private Gtk.Spinner spinner;
	private Sequeler.Partials.ResponseMessage response_msg;

	enum Column {
		DBTYPE
	}

	enum Action {
		TEST,
		SAVE,
		CANCEL,
		CONNECT
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
		toggle_ssh_fields (false);
		build_actions ();
		populate_data ();
		change_sensitivity ();

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
		header_grid.margin_start = 30;
		header_grid.margin_end = 30;
		header_grid.margin_bottom = 10;

		var image = new Gtk.Image.from_icon_name ("office-database", Gtk.IconSize.DIALOG);
		image.margin_end = 10;

		header_title = new Gtk.Label (_("New Connection"));
		header_title.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);
		header_title.halign = Gtk.Align.START;
		header_title.margin_end = 10;
		header_title.set_line_wrap (true);
		header_title.hexpand = true;

		color_picker = new Gtk.ColorButton.with_rgba ({ 222, 222, 222, 255 });
		color_picker.get_style_context ().add_class ("color-picker");
		color_picker.can_focus = false;

		header_grid.attach (image, 0, 0, 1, 2);
		header_grid.attach (header_title, 1, 0, 1, 2);
		header_grid.attach (color_picker, 2, 0, 1, 1);

		body.add (header_grid);

		form_grid = new Gtk.Grid ();
		form_grid.margin = 30;
		form_grid.row_spacing = 10;
		form_grid.column_spacing = 20;

		var title_label = new Sequeler.Partials.LabelForm (_("Connection Name:"));
		title_entry = new Sequeler.Partials.Entry (_("Connection's name"), _("New Connection"));
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
		db_host_entry = new Sequeler.Partials.Entry ("127.0.0.1", null);

		form_grid.attach (db_host_label, 0, 2, 1, 1);
		form_grid.attach (db_host_entry, 1, 2, 1, 1);

		db_separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
		db_separator.margin_top = 10;
		db_separator.margin_bottom = 10;
		form_grid.attach (db_separator, 0, 3, 2, 1);

		db_name_label = new Sequeler.Partials.LabelForm (_("Database Name:"));
		db_name_entry = new Sequeler.Partials.Entry ("", null);
		db_name_entry.changed.connect (change_sensitivity);

		form_grid.attach (db_name_label, 0, 4, 1, 1);
		form_grid.attach (db_name_entry, 1, 4, 1, 1);

		db_username_label = new Sequeler.Partials.LabelForm (_("Username:"));
		db_username_entry = new Sequeler.Partials.Entry ("", null);

		form_grid.attach (db_username_label, 0, 5, 1, 1);
		form_grid.attach (db_username_entry, 1, 5, 1, 1);

		db_password_label = new Sequeler.Partials.LabelForm (_("Password:"));
		db_password_entry = new Sequeler.Partials.Entry ("", null);
		db_password_entry.visibility = false;
		db_password_entry.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, "changes-prevent-symbolic");
		db_password_entry.icon_press.connect ((pos, event) => {
			if (pos == Gtk.EntryIconPosition.SECONDARY) {
				db_password_entry.visibility = !db_password_entry.visibility;
			}
 			if (db_password_entry.visibility) {
				db_password_entry.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, "changes-allow-symbolic");
			} else {
				db_password_entry.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, "changes-prevent-symbolic");
			}
		});

		form_grid.attach (db_password_label, 0, 6, 1, 1);
		form_grid.attach (db_password_entry, 1, 6, 1, 1);

		db_port_label = new Sequeler.Partials.LabelForm (_("Port:"));
		db_port_entry = new Sequeler.Partials.Entry ("3306", null);

		form_grid.attach (db_port_label, 0, 7, 1, 1);
		form_grid.attach (db_port_entry, 1, 7, 1, 1);

		db_file_label = new Sequeler.Partials.LabelForm (_("File Path:"));
		db_file_entry = new Gtk.FileChooserButton (_("Select Your SQLite File\u2026"), Gtk.FileChooserAction.OPEN);
		var filter = new Gtk.FileFilter ();
		filter.set_filter_name ("Database File");
		filter.add_pattern ("*.db");
		filter.add_pattern ("*.sqlite");
		filter.add_pattern ("*.sqlite3");
		db_file_entry.add_filter (filter);

		db_file_entry.selection_changed.connect (change_sensitivity);

		form_grid.attach (db_file_label, 0, 8, 1, 1);
		form_grid.attach (db_file_entry, 1, 8, 1, 1);
		db_file_label.visible = false;
		db_file_label.no_show_all = true;
		db_file_entry.visible = false;
		db_file_entry.no_show_all = true;

		ssh_separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
		ssh_separator.margin_top = 10;
		ssh_separator.margin_bottom = 10;
		form_grid.attach (ssh_separator, 0, 9, 2, 1);

		ssh_switch = new Gtk.Switch ();
		ssh_switch_container = new Gtk.Grid ();
		ssh_switch_container.add (ssh_switch);
		ssh_switch_label = new Sequeler.Partials.LabelForm (_("Connect via SSH Tunnel:"));

		ssh_switch.notify["active"].connect (() => {
			toggle_ssh_fields (ssh_switch.get_active ());
		});

		form_grid.attach (ssh_switch_label, 0, 10, 1, 1);
		form_grid.attach (ssh_switch_container, 1, 10, 1, 1);

		ssh_host_label = new Sequeler.Partials.LabelForm (_("SSH Host:"));;
		ssh_host_entry = new Sequeler.Partials.Entry ("", null);
		form_grid.attach (ssh_host_label, 0, 11, 1, 1);
		form_grid.attach (ssh_host_entry, 1, 11, 1, 1);
		
		ssh_username_label = new Sequeler.Partials.LabelForm (_("SSH Username:"));;
		ssh_username_entry = new Sequeler.Partials.Entry ("", null);
		form_grid.attach (ssh_username_label, 0, 12, 1, 1);
		form_grid.attach (ssh_username_entry, 1, 12, 1, 1);

		ssh_password_label = new Sequeler.Partials.LabelForm (_("SSH Password:"));;
		ssh_password_entry = new Sequeler.Partials.Entry ("", null);
		ssh_password_entry.visibility = false;
		ssh_password_entry.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, "changes-prevent-symbolic");
		ssh_password_entry.icon_press.connect ((pos, event) => {
			if (pos == Gtk.EntryIconPosition.SECONDARY) {
				ssh_password_entry.visibility = !ssh_password_entry.visibility;
			}
			if (ssh_password_entry.visibility) {
				ssh_password_entry.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, "changes-allow-symbolic");
			} else {
				ssh_password_entry.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, "changes-prevent-symbolic");
			}
		});
		form_grid.attach (ssh_password_label, 0, 13, 1, 1);
		form_grid.attach (ssh_password_entry, 1, 13, 1, 1);
		
		ssh_port_label = new Sequeler.Partials.LabelForm (_("SSH Port:"));;
		ssh_port_entry = new Sequeler.Partials.Entry (_("Optional"), null);
		form_grid.attach (ssh_port_label, 0, 14, 1, 1);
		form_grid.attach (ssh_port_entry, 1, 14, 1, 1);

		var info_label = new Gtk.Label (_("Missing SSH Key file!"));
		info_label.show ();

		infobar = new Gtk.InfoBar ();
		infobar.message_type = Gtk.MessageType.WARNING;
		infobar.get_style_context ().add_class ("inline");
		infobar.get_content_area ().add (info_label);
		infobar.show_close_button = false;
		infobar.add_button (_("Generate SSH Key"), 0);
		infobar.revealed = false;

		infobar.response.connect ((response) => {
			if (response == 0) {
				try {
					ssh_switch.active = false;
                    AppInfo.launch_default_for_uri ("https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/", null);
                } catch (Error e) {
                    warning ("%s\n", e.message);
                }
			}
		});

		form_grid.attach (infobar, 0, 15, 2, 1);

		body.add (form_grid);

		spinner = new Gtk.Spinner ();
		response_msg = new Sequeler.Partials.ResponseMessage ();

		body.add (spinner);
		body.add (response_msg);
	}

	private void toggle_ssh_fields (bool toggle) {
		if (toggle) {
			var home_dir = Environment.get_home_dir ();
			keyfile1 = home_dir + "/.ssh/id_rsa.pub";
			keyfile2 = home_dir + "/.ssh/id_rsa";
			if (! File.new_for_path (keyfile1).query_exists () || ! File.new_for_path (keyfile2).query_exists ()) {
				infobar.revealed = true;
				return;
			}
		}

		ssh_host_label.visible = toggle;
		ssh_host_label.no_show_all = !toggle;
		ssh_host_entry.visible = toggle;
		ssh_host_entry.no_show_all = !toggle;

		ssh_username_label.visible = toggle;
		ssh_username_label.no_show_all = !toggle;
		ssh_username_entry.visible = toggle;
		ssh_username_entry.no_show_all = !toggle;

		ssh_password_label.visible = toggle;
		ssh_password_label.no_show_all = !toggle;
		ssh_password_entry.visible = toggle;
		ssh_password_entry.no_show_all = !toggle;

		ssh_port_label.visible = toggle;
		ssh_port_label.no_show_all = !toggle;
		ssh_port_entry.visible = toggle;
		ssh_port_entry.no_show_all = !toggle;

		infobar.revealed = false;
	}

	private void build_actions () {
		var cancel_button = new Sequeler.Partials.ButtonClass (_("Close"), null);
		var save_button = new Sequeler.Partials.ButtonClass (_("Save Connection"), null);

		test_button = new Sequeler.Partials.ButtonClass (_("Test Connection"), null);

		connect_button = new Sequeler.Partials.ButtonClass (_("Connect"), "suggested-action");

		add_action_widget (test_button, Action.TEST);
		add_action_widget (save_button, Action.SAVE);
		add_action_widget (cancel_button, Action.CANCEL);
		add_action_widget (connect_button, Action.CONNECT);
	}

	private void populate_data () {
		if (window.data_manager.data == null || window.data_manager.data.size == 0) {
			return;
		}

		var update_data = window.data_manager.data;

		string? old_password = "";

		var loop = new MainLoop ();
		password_mngr.get_password_async.begin (update_data["id"], (obj, res) => {
			try {
				old_password = password_mngr.get_password_async.end (res);
			} catch (Error e) {
				debug ("Unable to get the password from libsecret");
			}
			loop.quit ();
		});

		loop.run ();

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
		db_password_entry.text = old_password;

		if (update_data["file_path"] != null) {
			db_file_entry.set_uri (update_data["file_path"]);
		}

		if (update_data["type"] == "SQLite" && update_data["file_path"] == null) {
			var update_file_path = update_data["host"] + "/" + update_data["name"] + ".db";

			try {
				db_file_entry.set_file (File.new_for_path (update_file_path));
			} catch (Error e) {
				write_response (e.message);
			}
		}

		if (update_data["port"] != null) {
			db_port_entry.text = update_data["port"];
		}

		if (bool.parse (update_data["has_ssh"]) == true) {
			string? old_ssh_password = "";

			var ssh_loop = new MainLoop ();
			password_mngr.get_password_async.begin (update_data["id"] + "_ssh", (obj, res) => {
				try {
					old_ssh_password = password_mngr.get_password_async.end (res);
				} catch (Error e) {
					debug ("Unable to get the SSH password from libsecret");
				}
				ssh_loop.quit ();
			});

			ssh_loop.run ();

			ssh_switch.active = bool.parse (update_data["has_ssh"]);
			
			ssh_host_entry.text = (update_data["ssh_host"] != null) ? update_data["ssh_host"] : "";
			ssh_username_entry.text = (update_data["ssh_username"] != null) ? update_data["ssh_username"] : "";
			ssh_password_entry.text = old_ssh_password;
			ssh_port_entry.text = (update_data["ssh_port"] != null) ? update_data["ssh_port"] : "";
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

		db_separator.visible = !toggle;
		db_separator.no_show_all = toggle;

		if (toggle) ssh_switch.active = false;

		ssh_separator.visible = !toggle;
		ssh_separator.no_show_all = toggle;
		ssh_switch_container.visible = !toggle;
		ssh_switch_container.no_show_all = toggle;
		ssh_switch_label.visible = !toggle;
		ssh_switch_label.no_show_all = toggle;
	}

	private void change_sensitivity () {
		if (db_type_entry.get_active () != 3 || (db_type_entry.get_active () == 3 && db_file_entry.get_uri () != null)) {
			test_button.sensitive = true;
			connect_button.sensitive = true;
			return;
		}

		test_button.sensitive = false;
		connect_button.sensitive = false;
	}

	private void on_response (Gtk.Dialog source, int response_id) {
		switch (response_id) {
			case Action.TEST:
				if (ssh_switch.active) {
					open_ssh_connection.begin (false);
				} else {
					test_connection.begin ();
				}
				break;
			case Action.SAVE:
				save_connection ();
				break;
			case Action.CANCEL:
				destroy ();
				break;
			case Action.CONNECT:
				debug("init connection");
				if (ssh_switch.active) {
					open_ssh_connection.begin (true);
				} else {
					init_connection.begin ();
				}
				break;
		}
	}

	public void test_connection_callback () {
		test_connection.begin ();
	}

	public void init_connection_callback () {
		init_connection.begin ();
	}

	public async void open_ssh_connection (bool is_real) throws ThreadError {
		toggle_spinner (true);
		write_response (_("Opening SSH Tunnel\u2026"));

		var data = package_data ();
		var connection_manager = new Sequeler.Services.ConnectionManager (window, data);
		if (is_real) {
			connection_manager.ssh_tunnel_ready.connect(init_connection_callback);
		} else {
			connection_manager.ssh_tunnel_ready.connect(test_connection_callback);
		}
		SourceFunc callback = open_ssh_connection.callback;
		
		new Thread <void*> (null, () => {
			try {
				connection_manager.ssh_tunnel_init (is_real);
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

	private async void test_connection (Sequeler.Services.ConnectionManager? connection_manager = null) throws ThreadError {
		toggle_spinner (true);
		write_response (_("Testing Connection\u2026"));

		var cnn_manager = connection_manager != null ? connection_manager : new Sequeler.Services.ConnectionManager (window, package_data ());

		SourceFunc callback = test_connection.callback;

		new Thread <void*> (null, () => {
			try {
				cnn_manager.test ();
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

	private void save_connection () {
		var data = package_data ();

		toggle_spinner (true);
		write_response (_("Saving Connection\u2026"));

		window.main.library.check_add_item (data);

		toggle_spinner (false);
		write_response (_("Connection Saved!"));
	}

	private async void init_connection () {
		var data = package_data ();
		var result = new Gee.HashMap<string, string> ();

		toggle_spinner (true);
		write_response (_("Connecting\u2026"));

		var connection_manager = new Sequeler.Services.ConnectionManager (window, data);

		SourceFunc callback = init_connection.callback;

		new Thread <void*> (null, () => {
			Idle.add ((owned) callback);
			var loop = new MainLoop ();
			connection_manager.init_connection.begin (connection_manager, (obj, res) => {
				try {
					result = connection_manager.init_connection.end (res);
					connection_manager.ssh_tunnel_close (null, -1, -1, -1);
				} catch (ThreadError e) {
					write_response (e.message);
					toggle_spinner (false);
				}
				loop.quit ();
			});

			loop.run ();

			if (result["status"] == "true") {
				destroy ();

				if (settings.save_quick) {
					window.main.library.check_add_item (data);
				}

				window.data_manager.data = data;
				window.main.connection_opened (connection_manager);
			} else {
				write_response (result["msg"]);
				toggle_spinner (false);
			}

			return null;
		});

		yield;
	}

	private Gee.HashMap<string, string> package_data () {
		var packaged_data = new Gee.HashMap<string, string> ();

		packaged_data.set ("id", connection_id.text);
		packaged_data.set ("title", title_entry.text);
		packaged_data.set ("color", color_picker.rgba.to_string ());
		packaged_data.set ("type", db_types[db_type_entry.get_active ()]);
		packaged_data.set ("host", db_host_entry.text);
		packaged_data.set ("name", db_name_entry.text);
		packaged_data.set ("file_path", db_file_entry.get_uri () != null ? db_file_entry.get_uri () : "");
		packaged_data.set ("username", db_username_entry.text);
		packaged_data.set ("password", db_password_entry.text);
		packaged_data.set ("port", db_port_entry.text);

		packaged_data.set ("has_ssh", ssh_switch.active.to_string ());
		packaged_data.set ("ssh_host", ssh_switch.active ? ssh_host_entry.text : "");
		packaged_data.set ("ssh_username", ssh_switch.active ? ssh_username_entry.text : "");
		packaged_data.set ("ssh_password", ssh_switch.active ? ssh_password_entry.text : "");
		packaged_data.set ("ssh_port", ssh_switch.active ? ssh_port_entry.text : "");

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
