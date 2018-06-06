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

public class Sequeler.Services.UpgradeManager : Object {
	construct {
		string version = settings.version;

		switch (version) {
			case "":
				upgrade_passwords_to_libsecret.begin ();
			case Constants.VERSION:
				debug ("Current Version");
		}

		settings.version = Constants.VERSION;
	}

	public virtual async void upgrade_passwords_to_libsecret () throws Error {
		var current_connections = settings.saved_connections;

		Gee.List<string> existing_connections = new Gee.ArrayList<string> ();
		existing_connections.add_all_array (current_connections);

		foreach (var conn in settings.saved_connections) {
			var check = settings.arraify_data (conn);

			if (check["type"] != "SQLite" && check.has_key ("password")) {
				settings.update_password.begin (check);
				check.unset ("password");

				existing_connections.remove (conn);
				existing_connections.insert (0, settings.stringify_data (check));
			}
		}

		settings.saved_connections = existing_connections.to_array ();
	}
}
