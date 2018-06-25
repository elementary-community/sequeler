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

public class Sequeler.Services.ConnectionManager : Object {
	public Gee.HashMap<string, string> data { get; construct; }
	private Object _db_type;

	public Object db_type {
		get { return _db_type; }
		set { _db_type = value; }
	}

	public Gda.Connection? connection { get; set; default = null; }
	public Gda.DataModel? output_select;

	public ConnectionManager (Gee.HashMap<string, string> data) {
		Object (
			data: data
		);

		if (data ["password"] == null) {
			data ["password"] = "";

			var loop = new MainLoop ();
			password_mngr.get_password_async.begin (data["id"], (obj, res) => {
				try {
					data ["password"] = password_mngr.get_password_async.end (res);
				} catch (Error e) {
					debug ("Unable to get the password from libsecret");
				}
				loop.quit ();
			});

			loop.run ();
		}

		switch (data ["type"]) {
			case "MySQL":
				db_type = new Sequeler.Services.Types.MySQL ();
			break;
			case "MariaDB":
				db_type = new Sequeler.Services.Types.MySQL ();
			break;
			case "PostgreSQL":
				db_type = new Sequeler.Services.Types.PostgreSQL ();
			break;
			case "SQLite":
				db_type = new Sequeler.Services.Types.SQLite ();
			break;
		}
	}

	public void test () throws Error {
		var connection_string = (db_type as DataBaseType).connection_string (data);

		try {
			connection = Gda.Connection.open_from_string (null, connection_string, null, Gda.ConnectionOptions.NONE);
		} catch ( Error e ) {
			throw e;
		}

		if (connection.is_opened ()) {
			connection.close ();
		}
	}

	public void open () throws Error {
		var connection_string = (db_type as DataBaseType).connection_string (data);

		try {
			connection = Gda.Connection.open_from_string (null, connection_string, null, Gda.ConnectionOptions.NONE);
		} catch ( Error e ) {
			throw e;
		}
	}

	public int run_query (string query) throws Error requires (connection.is_opened ()) {
		return connection.execute_non_select_command (query);
	}

	public Gda.DataModel? run_select (string query) throws Error {
		return connection.execute_select_command (query);
	}

	public async Gee.HashMap<string, string> init_connection (Sequeler.Services.ConnectionManager connection) throws ThreadError {
		var output = new Gee.HashMap<string, string> ();
		output["status"] = "false";
		SourceFunc callback = init_connection.callback;

		new Thread <void*> (null, () => {
			bool result = true;
			string msg = "";

			try {
				connection.open ();
			}
			catch (Error e) {
				result = false;
				msg = e.message;
			}

			Idle.add((owned) callback);
			output["msg"] = msg;
			output["status"] = result.to_string ();

			return null;
		});

		yield;

		return output;
	}

	public async Gda.DataModel? init_select_query (string query) throws ThreadError {
		Gda.DataModel? result = null;
		SourceFunc callback = init_select_query.callback;
		var error = "";

		new Thread <void*> (null, () => {
			try {
				result = run_select (query);
			}
			catch (Error e) {
				error = e.message;
				result = null;
			}
			Idle.add((owned) callback);
			return null;
		});

		yield;

		if (error != "") {
			query_warning (error);
			return null;
		}

		return result;
	}

	public async int init_query (string query) throws ThreadError {
		int output_query = 0;
		SourceFunc callback = init_query.callback;
		var error = "";

		new Thread <void*> (null, () => {
			int result = 0;
			try {
				result = run_query (query);
			}
			catch (Error e) {
				error = e.message;
				result = 0;
			}
			Idle.add((owned) callback);
			output_query = result;
			return null;
		});

		yield;

		if (error != "") {
			query_warning (error);
			return 0;
		}

		return output_query;
	}

	public void query_warning (string message) {
		var message_dialog = new Granite.MessageDialog.with_image_from_icon_name (_("Error!"), message, "dialog-error", Gtk.ButtonsType.NONE);
		// message_dialog.transient_for = Sequeler.Window;
		
		var suggested_button = new Gtk.Button.with_label ("Close");
		message_dialog.add_action_widget (suggested_button, Gtk.ResponseType.ACCEPT);

		message_dialog.show_all ();
		if (message_dialog.run () == Gtk.ResponseType.ACCEPT) {}
		
		message_dialog.destroy ();
	}
}
