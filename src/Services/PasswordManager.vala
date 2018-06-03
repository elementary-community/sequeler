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

public class Sequeler.Services.PasswordManager : Object {

	// Store Password Async
	public virtual async void store_password_async (string id, string host, string username, string password) throws Error {

		var attributes = new GLib.HashTable<string, string> (str_hash, str_equal);
		attributes["id"] = id;
		attributes["host"] = host;
		attributes["username"] = username;

		var key_name = host + "." + id;

		bool result = yield Secret.password_storev (schema, attributes,
                                         Secret.COLLECTION_DEFAULT,
                                         key_name, password,
                                         null);

		if (!result)
			debug("Unable to store password for \"%s\" in libsecret keyring", key_name);
	}

	// Get Password Async
	public virtual async string? get_password_async (string id, string host, string username) throws Error {
		var attributes = new GLib.HashTable<string, string> (str_hash, str_equal);
		attributes["id"] = id;
		attributes["host"] = host;
		attributes["username"] = username;

		var key_name = host + "-" + id;

		string? password = yield Secret.password_lookupv (schema, attributes, null);

		if (password == null)
			debug("Unable to fetch password in libsecret keyring for %s", key_name);

		return password;
	}

	// Delete Password Async
	public virtual async void clear_password_async (string id, string host, string username) throws Error {
		var attributes = new GLib.HashTable<string, string> (str_hash, str_equal);
		attributes["id"] = id;
		attributes["host"] = host;
		attributes["username"] = username;

		var key_name = host + "-" + id;

		bool removed = yield Secret.password_clearv (schema, attributes, null);

		if (removed)
			debug("Unable to clear password in libsecret keyring for %s", key_name);
	}
}
