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
    public string constr { set; get; default = "SQLite://DB_DIR=.;DB_NAME=test"; } 
    public Gda.Connection cnn;

    public void set_data (Gee.HashMap<string, string> data) {
        var type = data["type"];

        if (data["type"] == "MariaDB") {
                type = "MySQL";
        }
        this.constr = type + "://DB_NAME=" + data["name"] +";HOST=" + data["host"] +";USERNAME=" + data["username"] +";PASSWORD=" + data["password"];
    }

    public void open () throws Error {
        this.cnn = Gda.Connection.open_from_string (null, this.constr, null, Gda.ConnectionOptions.NONE);
    }

    public int run_query (string query) throws Error requires (this.cnn.is_opened()) {
        stdout.printf("Executing query: [%s]\n", query);
        return this.cnn.execute_non_select_command (query);
    }
}