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

public class Sequeler.Services.Types.MySQL : Object, DataBaseType {
    public string port { set; get; default = "3306"; }
    public string host { set; get; default = "127.0.0.1"; }

    public string connection_string (Gee.HashMap<string, string> data) {
        var username = Gda.rfc1738_encode (data["username"]);
        var password = Gda.rfc1738_encode (data["password"]);
        var use_ssl = Gda.rfc1738_encode (data["use_ssl"] ?? "false");
        var name = Gda.rfc1738_encode (data["name"]);
        if (data["has_ssh"] == "true") {
            port = "9000";
            host = "127.0.0.1";
        } else {
            port = data["port"] != "" ? data["port"] : port;
            host = data["host"] != "" ? Gda.rfc1738_encode (data["host"]) : host;
        }

        return "MySQL://" + username + ":" + password + "@DB_NAME=" + name + ";HOST=" + host + ";PORT=" + port + ";USE_SSL=" + use_ssl;
    }

    public string show_schema () {
        return "SHOW SCHEMAS";
    }

    public string show_table_list (string name) {
        return "SELECT table_name, table_rows FROM information_schema.TABLES WHERE TABLE_SCHEMA = '%s' ORDER BY table_name ASC".printf (name);
    }

    public string edit_table_name (string old_table, string new_table) {
        return "RENAME TABLE %s TO %s".printf (old_table, new_table);
    }

    public string transfer_table (string old_database, string table, string new_database) {
        return "RENAME TABLE %s.%s TO %s.%s".printf (old_database, table, new_database, table);
    }

    public string show_table_structure (string table, string? sortby = null, string sort = "ASC") {
        var output = "SELECT COLUMN_NAME, ORDINAL_POSITION, COLUMN_DEFAULT, IS_NULLABLE, CHARACTER_SET_NAME, COLLATION_NAME, COLUMN_TYPE, COLUMN_KEY, EXTRA, COLUMN_COMMENT FROM information_schema.COLUMNS WHERE table_name = '%s' AND table_schema = DATABASE()".printf (table);

        if (sortby != null) {
            output += " ORDER BY %s %s".printf (sortby, sort);
        }

        return output;
    }

    public string show_table_content (
        string table, int? count = null, int? page = null,
        string? sortby = null, string sort = "ASC"
    ) {
        var output = "SELECT * FROM %s".printf (table);

        if (sortby != null) {
            output += " ORDER BY %s %s".printf (sortby, sort);
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
        var output = "SELECT COLUMN_NAME, CONSTRAINT_NAME, REFERENCED_COLUMN_NAME, REFERENCED_TABLE_NAME FROM information_schema.KEY_COLUMN_USAGE WHERE TABLE_NAME = '%s' AND TABLE_SCHEMA = '%s'".printf (table, database);

        if (sortby != null) {
            output += " ORDER BY %s %s".printf (sortby, sort);
        }

        return output;
    }

    public string create_database (string name) {
        return "CREATE DATABASE %s".printf (name);
    }

    public string delete_database (string name) {
        return "DROP DATABASE %s".printf (name);
    }
}
