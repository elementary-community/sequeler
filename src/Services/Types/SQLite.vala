/*
* Copyright (c) 2011-2019 Alecaddd (https://alecaddd.com)
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
        return "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name;";
    }

    public string show_table_list (string name) {
        return "SELECT COUNT(*) FROM %s".printf (name);
    }

    public string edit_table_name (string old_table, string new_table) {
        return "ALTER TABLE %s RENAME TO %s".printf (old_table, new_table);
    }

    public string transfer_table (string old_database, string table, string new_database) {
        // Temporary placeholder methods. No current support for database
        // operations in SQLite.
        return "";
    }

    public string show_table_structure (string table, string? sortby = null, string sort = "ASC") {
        return "PRAGMA table_info('%s')".printf (table);
    }

    public string show_table_content (
        string table, int? count = null, int? page = null,
        string? sortby = null, string sort = "ASC"
    ) {
        var output = "SELECT * FROM %s".printf (table);

        if (sortby != null) {
            output += " ORDER BY `%s` %s".printf (sortby, sort);
        }

        if (count != null && count > settings.limit_results) {
            output += " LIMIT %i".printf (settings.limit_results);
        }

        if (page != null && page > 1) {
            output += " OFFSET %i".printf (settings.limit_results * (page - 1));
        }

        return output;
    }

    public string show_table_relations (
        string table, string? database,
        string? sortby = null, string sort = "ASC"
    ) {
        return "PRAGMA foreign_key_list('%s')".printf (table);
    }

    public string create_database (string name) {
        // Temporary placeholder methods. No current support for database
        // operations in SQLite.
        return "";
    }

    public string delete_database (string name) {
        // Temporary placeholder methods. No current support for database
        // operations in SQLite.
        return "";
    }
}
