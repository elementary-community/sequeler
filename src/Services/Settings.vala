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

public class Sequeler.Services.Settings : Granite.Services.Settings {
	public int pos_x { get; set; }
	public int pos_y { get; set; }
	public int window_width { get; set; }
	public int window_height { get; set; }
	public string[] saved_connections { get; set; }
	public int tot_connections { get; set; }
	public int limit_results { get; set; }
	public bool dark_theme { get; set; }
	public bool save_quick { get; set; }
	public string version { get; set; }
	public bool use_system_font { get; set; }
	public string font { get; set; }
	public string style_scheme { get; set; }
	public int query_area { get; set; }

	public Settings () {
		base (Constants.PROJECT_NAME);
	}

	public void add_connection (Gee.HashMap<string, string> data) {
		var current_connections = saved_connections;

		Gee.List<string> existing_connections = new Gee.ArrayList<string> ();
		existing_connections.add_all_array (current_connections);

		if (data["type"] != "SQLite") {
			update_password.begin (data);
			data.unset ("password");
			data.unset ("ssh_password");
		}

		existing_connections.insert (0, stringify_data (data));
		saved_connections = existing_connections.to_array ();
		tot_connections = tot_connections + 1;
	}

	public void edit_connection (Gee.HashMap<string, string> new_data, string old_data) {
		var current_connections = saved_connections;

		Gee.List<string> existing_connections = new Gee.ArrayList<string> ();
		existing_connections.add_all_array (current_connections);

		if (old_data in current_connections) {
			existing_connections.remove (old_data);
		}

		if (new_data["type"] != "SQLite") {
			update_password.begin (new_data);
			new_data.unset ("password");

			if (new_data["has_ssh"] == "true" && new_data["ssh_password"] != null) {
				update_ssh_password.begin (new_data);
				new_data.unset ("ssh_password");
			}
		}

		existing_connections.insert (0, stringify_data (new_data));

		saved_connections = existing_connections.to_array ();
	}

	public void delete_connection (Gee.HashMap<string, string> data) {
		var current_connections = saved_connections;

		Gee.List<string> existing_connections = new Gee.ArrayList<string> ();
		existing_connections.add_all_array (current_connections);

		if (data["type"] != "SQLite") {
			delete_password.begin (data);
		}

		foreach (var conn in saved_connections) {
			var check = arraify_data (conn);
			if (check["id"] == data["id"]) {
				existing_connections.remove (conn);
			}
		}

		saved_connections = existing_connections.to_array ();
	}

	public void clear_connections () {
		Gee.List<string> empty_connection = new Gee.ArrayList<string> ();
		saved_connections = empty_connection.to_array ();
		tot_connections = 0;

		delete_all_passwords.begin ();
	}

	public string stringify_data (Gee.HashMap<string, string> data) {
		string result = "";

		foreach (var entry in data.entries) {
			string values = "%s=%s\n".printf (entry.key, entry.value);
			result = result + values;
		}

		return result;
	}

	public Gee.HashMap<string, string> arraify_data (string connection) {
		var array = new Gee.HashMap<string, string> ();
		var data = connection.split ("\n");

		foreach (var d in data) {
			var d2 = d.split ("=", 2);

			if (d2[0] == null) {
				continue;
			}

			array.set (d2[0], d2[1]);
		}

		return array;
	}

	public async void update_password (Gee.HashMap<string, string> data) throws Error {
		yield password_mngr.store_password_async (data["id"], data["password"]);
	}

	public async void update_ssh_password (Gee.HashMap<string, string> data) throws Error {
		yield password_mngr.store_password_async (data["id"] + "9999", data["ssh_password"]);
	}

	public async void delete_password (Gee.HashMap<string, string> data) throws Error {
		yield password_mngr.clear_password_async (data["id"]);

		if (data["has_ssh"] == "true" && data["ssh_password"] != null) {
			yield password_mngr.clear_password_async (data["id"] + "9999");
		}
	}

	public async void delete_all_passwords () throws Error {
		yield password_mngr.clear_all_passwords_async ();
	}
}
