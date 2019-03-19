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

public class Sequeler.Services.Types.SQLite : Object, DataBaseType {

	public string connection_string (Gee.HashMap<string, string> data) {
		var file_path = data["file_path"].replace ("file://", "");
		var last_slash = file_path.last_index_of ("/", 0) + 1;

		var dir = Gda.rfc1738_encode (file_path.substring (0, last_slash));
		var name = Gda.rfc1738_encode (file_path.substring (last_slash, -1));

		return "SQLite://DB_DIR=" + dir + ";DB_NAME=" + name;
	}

	public string show_schema () {
		return "SELECT name, sql FROM sqlite_master WHERE type='table' ORDER BY name;";
	}

	public string show_table_list (string name) {
		return "SELECT name, sql FROM sqlite_master WHERE type='table' ORDER BY name;";
	}

	public string edit_table_name (string old_table, string new_table) {
		return "ALTER TABLE %s RENAME TO %s".printf (old_table, new_table);
	}

	public string show_table_structure (string table) {
		return "PRAGMA table_info('%s')".printf (table);
	}

	public string show_table_content (string table) {
		return "SELECT * FROM %s".printf (table);
	}

	public string show_table_relations (string table, string? database) {
		return "PRAGMA foreign_key_list('%s')".printf (table);
	}
}
