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

public class Sequeler.Services.Types.PostgreSQL : Object, DataBaseType {
    public string port { set; get; default = "5432"; }
    public string host { set; get; default = "127.0.0.1"; }

    public string connection_string (Gee.HashMap<string, string> data) {
        var username = Gda.rfc1738_encode (data["username"]);
        var password = Gda.rfc1738_encode (data["password"]);
        var name = Gda.rfc1738_encode (data["name"]);
        host = data["host"] != "" ? Gda.rfc1738_encode (data["host"]) : host;
        if (data["has_ssh"] == "true") {
            port = "9000";
        } else {
            port = data["port"] != "" ? data["port"] : port;
        }

        return "PostgreSQL://" + username + ":" + password + "@DB_NAME=" + name + ";HOST=" + host + ";PORT=" + port;
    }

    public string show_schema () {
        return "SELECT schema_name FROM information_schema.schemata";
    }

    public string show_table_list (string name) {
        return "SELECT relname, reltuples FROM pg_class C LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace) WHERE nspname NOT IN ('pg_catalog', 'information_schema') AND relkind='r' ORDER BY relname DESC;";
    }

    public string edit_table_name (string old_table, string new_table) {
        return "ALTER TABLE \"%s\" RENAME TO \"%s\"".printf (old_table, new_table);
    }

    public string show_table_structure (string table, string? sortby = null, string sort = "ASC") {
        var output = "SELECT * FROM information_schema.COLUMNS WHERE table_name='%s'".printf (table);

        if (sortby != null) {
            output += " ORDER BY %s %s".printf (sortby, sort);
        }

        return output;
    }

    public string show_table_content (
        string table, int? count = null, int? page = null,
        string? sortby = null, string sort = "ASC"
    ) {
        var output = "SELECT * FROM  \"%s\"".printf (table);

        if (sortby != null) {
            output += " ORDER BY \"%s\" %s".printf (sortby, sort);
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
        var output = "SELECT ccu.column_name as \"COLUMN_NAME\", tc.constraint_name as \"CONSTRAINT_NAME\", kcu.column_name as \"REFERENCED_COLUMN_NAME\", tc.table_name as \"REFERENCED_TABLE\" FROM information_schema.table_constraints tc JOIN information_schema.key_column_usage kcu ON tc.constraint_name = kcu.constraint_name JOIN information_schema.constraint_column_usage ccu ON ccu.constraint_name = tc.constraint_name WHERE constraint_type = 'FOREIGN KEY' AND ccu.table_name='%s' AND ccu.table_schema = '%s'".printf (table, database);

        if (sortby != null) {
            output += " ORDER BY %s %s".printf (sortby, sort);
        }

        return output;
    }
}
