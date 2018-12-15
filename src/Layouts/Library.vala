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

public class Sequeler.Layouts.Library : Gtk.Grid {
	public weak Sequeler.Window window { get; construct; }

	GLib.File? file;
	Gtk.TextBuffer buffer;

	public Gtk.FlowBox item_box;
	public Gtk.ScrolledWindow scroll;
	public Sequeler.Partials.HeaderBarButton delete_all;

	public Gee.HashMap<string, string> real_data;
	public Gtk.Spinner real_spinner;
	public Gtk.ModelButton real_button;
	public Sequeler.Services.ConnectionManager connection_manager;

	public signal void edit_dialog (Gee.HashMap data);

	public Library (Sequeler.Window main_window) {
		Object(
			orientation: Gtk.Orientation.VERTICAL,
			window: main_window,
			width_request: 240,
			column_homogeneous: true
		);
	}

	construct {
		var titlebar = new Sequeler.Partials.TitleBar (_("SAVED CONNECTIONS"));

		var toolbar = new Gtk.Grid ();
		toolbar.get_style_context ().add_class ("library-toolbar");

		delete_all = new Sequeler.Partials.HeaderBarButton ("user-trash-symbolic", _("Delete All"));
		delete_all.halign = Gtk.Align.END;
		delete_all.hexpand = true;
		delete_all.clicked.connect (() => {
			confirm_delete_all ();
		});

		var reload_btn = new Sequeler.Partials.HeaderBarButton ("view-refresh-symbolic", _("Reload Library"));
		reload_btn.clicked.connect (reload_library);

		var export_btn = new Sequeler.Partials.HeaderBarButton ("document-save-symbolic", _("Export Library"));
		export_btn.clicked.connect (export_library);

		toolbar.attach (reload_btn, 0, 0, 1, 1);
		toolbar.attach (new Gtk.Separator (Gtk.Orientation.VERTICAL), 1, 0, 1, 1);
		toolbar.attach (export_btn, 2, 0, 1, 1);
		toolbar.attach (new Gtk.Separator (Gtk.Orientation.VERTICAL), 3, 0, 1, 1);
		toolbar.attach (delete_all, 4, 0, 1, 1);

		scroll = new Gtk.ScrolledWindow (null, null);
		scroll.hscrollbar_policy = Gtk.PolicyType.AUTOMATIC;
		scroll.vscrollbar_policy = Gtk.PolicyType.AUTOMATIC;

		item_box = new Gtk.FlowBox ();
		item_box.activate_on_single_click = false;
		item_box.valign = Gtk.Align.START;
		item_box.min_children_per_line = 1;
		item_box.max_children_per_line = 1;
		item_box.margin = 6;
		item_box.expand = false;

		scroll.add (item_box);

		foreach (var conn in settings.saved_connections) {
			add_item (settings.arraify_data (conn));
		}

		if (settings.saved_connections.length > 0) {
			delete_all.sensitive = true;
		}

		item_box.child_activated.connect ((child) => {
			var item = child as Sequeler.Partials.LibraryItem;
			item.spinner.start ();
			item.connect_button.sensitive = false;
			window.data_manager.data = item.data;
			init_connection_begin (item.data, item.spinner, item.connect_button);
		});

		attach (titlebar, 0, 0, 1, 1);
		scroll.expand = true;
		attach (scroll, 0, 1, 1, 2);
		attach (toolbar, 0, 3, 1, 1);
	}

	public void add_item (Gee.HashMap<string, string> data) {
		var item = new Sequeler.Partials.LibraryItem (data);
		item_box.add (item);

		item.confirm_delete.connect ((item, data) => {
			confirm_delete (item, data);
		});

		item.edit_dialog.connect ((data) => {
			window.data_manager.data = data;

			if (window.connection_dialog == null) {
				window.connection_dialog = new Sequeler.Widgets.ConnectionDialog (window);
				window.connection_dialog.show_all ();

				window.connection_dialog.destroy.connect (() => {
					window.connection_dialog = null;
				});
			}

			window.connection_dialog.present ();
		});

		item.connect_to.connect ((data, spinner, connect_button) => {
			window.data_manager.data = data;
			init_connection_begin (data, spinner, connect_button);
		});
	}

	public void confirm_delete (Gtk.FlowBoxChild item, Gee.HashMap<string, string> data) {
		var message_dialog = new Granite.MessageDialog.with_image_from_icon_name (_("Are you sure you want to proceed?"), _("By deleting this connection you won’t be able to recover this data."), "dialog-warning", Gtk.ButtonsType.CANCEL);
		message_dialog.transient_for = window;

		var suggested_button = new Gtk.Button.with_label (_("Yes, Delete!"));
		suggested_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
		message_dialog.add_action_widget (suggested_button, Gtk.ResponseType.ACCEPT);

		message_dialog.show_all ();
		if (message_dialog.run () == Gtk.ResponseType.ACCEPT) {
			settings.delete_connection (data);
			item_box.remove (item);
			reload_library ();
		}

		message_dialog.destroy ();
	}

	public void confirm_delete_all () {
		var message_dialog = new Granite.MessageDialog.with_image_from_icon_name (_("Are you sure you want to proceed?"), _("All the data will be deleted and you won’t be able to recover it."), "dialog-warning", Gtk.ButtonsType.CANCEL);
		message_dialog.transient_for = window;

		var suggested_button = new Gtk.Button.with_label (_("Yes, Delete All!"));
		suggested_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
		message_dialog.add_action_widget (suggested_button, Gtk.ResponseType.ACCEPT);

		message_dialog.show_all ();
		if (message_dialog.run () == Gtk.ResponseType.ACCEPT) {
			settings.clear_connections ();
			item_box.forall ((item) => item_box.remove (item));
			reload_library ();
		}

		message_dialog.destroy ();
	}

	public void reload_library () {
		item_box.forall ((item) => item_box.remove (item));
		foreach (var new_conn in settings.saved_connections) {
			var array = settings.arraify_data (new_conn);
			add_item (array);
		}
		item_box.show_all ();

		if (settings.saved_connections.length > 0) {
			delete_all.sensitive = true;
		} else {
			delete_all.sensitive = false;
		}
	}

	public void check_add_item (Gee.HashMap<string, string> data) {
		foreach (var conn in settings.saved_connections) {
			var check = settings.arraify_data (conn);
			if (check["id"] == data["id"]) {
				settings.edit_connection (data, conn);
				reload_library ();
				return;
			}
		}

		settings.add_connection (data);
		add_item (data);

		reload_library ();
	}

	public void check_open_sqlite_file (string path, string name) {
		foreach (var conn in settings.saved_connections) {
			var check = settings.arraify_data (conn);
			if (check["file_path"] == path) {
				settings.edit_connection (check, conn);
				reload_library ();
				// open connection
				item_box.get_child_at_index (0).activate ();
				return;
			}
		}

		var data = new Gee.HashMap<string, string> ();

		data.set ("id", settings.tot_connections.to_string ());
		data.set ("title", name);
		data.set ("color", "rgb(222,222,222)");
		data.set ("type", "SQLite");
		data.set ("host", "");
		data.set ("name", "");
		data.set ("file_path", path);
		data.set ("username", "");
		data.set ("password", "");
		data.set ("port", "");

		settings.add_connection (data);
		add_item (data);

		reload_library ();
		// open connection
		item_box.get_child_at_index (0).activate ();
	}

	private void init_connection_begin (Gee.HashMap<string, string> data, Gtk.Spinner spinner, Gtk.ModelButton button) {
		connection_manager = new Sequeler.Services.ConnectionManager (window, data);

		if (data["has_ssh"] == "true") {
			real_data = data;
			real_spinner = spinner;
			real_button = button;
			connection_manager.ssh_tunnel_ready.connect (init_real_connection_begin_callback);

			new Thread <void*> (null, () => {
				try {
					connection_manager.ssh_tunnel_init (true);
				}
				catch (Error e) {
					connection_warning (e.message, data["name"]);
				}
				return null;
			});

			yield;
		} else {
			init_real_connection_begin (data, spinner, button);
		}
	}

	public void init_real_connection_begin_callback () {
		init_real_connection_begin (real_data, real_spinner, real_button);
	}

	private void init_real_connection_begin (Gee.HashMap<string, string> data, Gtk.Spinner spinner, Gtk.ModelButton button) {
		var loop = new MainLoop ();
		connection_manager.init_connection.begin (connection_manager, (obj, res) => {
			try {
				Gee.HashMap<string, string> result = connection_manager.init_connection.end (res);
				if (result["status"] == "true") {
					loop.quit ();
					spinner.stop ();
					button.sensitive = true;

					if (settings.save_quick) {
						window.main.library.check_add_item (data);
					}

					window.main.connection_opened (connection_manager);
				} else {
					connection_warning (result["msg"], data["name"]);
					spinner.stop ();
					button.sensitive = true;
				}
			} catch (ThreadError e) {
				connection_warning (e.message, data["name"]);
				spinner.stop ();
				button.sensitive = true;
			}
			loop.quit ();
		});

		loop.run ();
	}

	private void export_library () {
		file = null;
		buffer = new Gtk.TextBuffer (null);

		var save_dialog = new Gtk.FileChooserNative (_("Pick a file"),
													 window,
													 Gtk.FileChooserAction.SAVE,
													 _("_Save"),
													 _("_Cancel"));

		save_dialog.set_do_overwrite_confirmation (true);
		save_dialog.set_modal (true);
		save_dialog.response.connect ((dialog, response_id) => {
			switch (response_id) {
				case Gtk.ResponseType.ACCEPT:
					file = save_dialog.get_file ();
					save_to_file ();
					break;
				default:
					break;
			}
			dialog.destroy ();
		});

		save_dialog.run ();
	}

	private void save_to_file () {
		var buffer_content = "";
		var library = settings.saved_connections;

		foreach (var lib in library) {
			var array = settings.arraify_data (lib);

			array["password"] = "";

			var loop = new MainLoop ();
			password_mngr.get_password_async.begin (array["id"], (obj, res) => {
				try {
					array["password"] = password_mngr.get_password_async.end (res);
				} catch (Error e) {
					debug ("Unable to get the password from libsecret");
				}
				loop.quit ();
			});

			loop.run ();

			if (array["has_ssh"] == "true") {
				array["ssh_password"] = "";

				var ssh_loop = new MainLoop ();
				password_mngr.get_password_async.begin (array["id"] + "9999", (obj, res) => {
					try {
						array["ssh_password"] = password_mngr.get_password_async.end (res);
					} catch (Error e) {
						debug ("Unable to get the SSH password from libsecret");
					}
					ssh_loop.quit ();
				});

				ssh_loop.run ();
			}
	
			buffer_content += settings.stringify_data (array) + "---\n";
		}

		buffer.set_text (buffer_content);

		Gtk.TextIter start;
		Gtk.TextIter end;

		buffer.get_bounds (out start, out end);
		string current_contents = buffer.get_text (start, end, false);
		try {
			file.replace_contents (current_contents.data, null, false, GLib.FileCreateFlags.NONE, null, null);
		}
		catch (GLib.Error err) {
			export_warning (err.message);
		}
	}

	private void connection_warning (string message, string title) {
		var message_dialog = new Granite.MessageDialog.with_image_from_icon_name (_("Unable to Connect to %s").printf (title), message, "dialog-error", Gtk.ButtonsType.NONE);
		message_dialog.transient_for = window;

		var suggested_button = new Gtk.Button.with_label ("Close");
		message_dialog.add_action_widget (suggested_button, Gtk.ResponseType.ACCEPT);

		message_dialog.show_all ();
		if (message_dialog.run () == Gtk.ResponseType.ACCEPT) {}

		message_dialog.destroy ();
	}
	
	private void export_warning (string message) {
		var message_dialog = new Granite.MessageDialog.with_image_from_icon_name (_("Unable to Export Library "), message, "dialog-error", Gtk.ButtonsType.NONE);
		message_dialog.transient_for = window;

		var suggested_button = new Gtk.Button.with_label ("Close");
		message_dialog.add_action_widget (suggested_button, Gtk.ResponseType.ACCEPT);

		message_dialog.show_all ();
		if (message_dialog.run () == Gtk.ResponseType.ACCEPT) {}

		message_dialog.destroy ();
	}
}
