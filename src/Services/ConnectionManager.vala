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

    public Gda.Connection connection;

    public ConnectionManager (Gee.HashMap<string, string> data) {
        Object (
            data: data
        );

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

        if (connection.is_opened ()) {
            connection.execution_timer = true;
        }
    }

    public int run_query (string query) throws Error requires (connection.is_opened ()) {
        return connection.execute_non_select_command (query);
    }

    public Gda.DataModel? run_select (string query) throws Error requires (connection.is_opened ()) {
        return connection.execute_select_command (query);
    }

    public void close () {
        connection.close ();
    }

    public async Gee.HashMap<string, string> init_connection (Sequeler.Services.ConnectionManager connection) throws ThreadError {
        var output = new Gee.HashMap<string, string> ();
        output["status"] = "false";
        SourceFunc callback = init_connection.callback;

        new Thread <void*> (null, () => {
            bool result = false;
            string msg = "";

            try {
                connection.open ();
                if (connection.connection.is_opened ()) {
                    result = true;
                }
            }
            catch (Error e) {
                result = false;
                msg = e.message;
            }

            Idle.add((owned) callback);
            output["status"] = result.to_string ();
            output["msg"] = msg;

            return null;
        });

        yield;

        return output;
    }
}