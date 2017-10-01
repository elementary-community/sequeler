/*
* Copyright (c) 2011-2017 Alecaddd (http://alecaddd.com)
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

public class Sequeler.DataBase : Object {
    public string constr { set; get; }
    public string provider { set; get; default = "SQLite"; }
    public string auth_string;
    public Gda.Connection cnn;

    public void set_constr_data (Gee.HashMap<string, string> data) {
        provider = data["type"];

        if (data["type"] == "MariaDB") {
            provider = "MySQL";
        }

        switch (provider) {
            case "MySQL":
                constr = provider + "://" + data["username"] + ":" + data["password"] + "@DB_NAME=" + data["name"] + ";HOST=" + data["host"] + "";
                break;
            case "PostgreSQL":
                constr = provider + "://" + data["username"] + ":" + data["password"] + "@DB_NAME=" + data["name"] + ";HOST=" + data["host"] + "";
                break;
            case "SQLite":
                constr = provider + "://DB_DIR=" + data["host"] + ";DB_NAME=" + data["name"] + "";
                break;
        }
    }

    public void open () throws Error {
        cnn = Gda.Connection.open_from_string (null, constr, null, Gda.ConnectionOptions.NONE);
        cnn.execution_timer = true;
    }

    public int run_query (string query) throws Error requires (cnn.is_opened ()) {
        return cnn.execute_non_select_command (query);
    }

    public Gda.DataModel run_select (string query) throws Error requires (cnn.is_opened ()) {
        return cnn.execute_select_command (query);
    }

    public void close () {
        cnn.close ();
    }
}