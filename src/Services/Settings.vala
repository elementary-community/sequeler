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

public class Sequeler.Settings : Granite.Services.Settings {
    private static Settings? instance = null;

    public int pos_x { get; set; }
    public int pos_y { get; set; }
    public int window_width { get; set; }
    public int window_height { get; set; }
    public string[] saved_connections { get; set; }
    public bool dark_theme { get; set; }
    public bool save_quick { get; set; }
    public bool show_library { get; set; }
    public bool reconnect { get; set; }

    public static Settings get_instance () {
        if (instance == null) {
            instance = new Settings ();
        }

        //  foreach (Gee.HashMap<string, string> conn in instance.saved_connections) {
        //      foreach (var entry in conn.entries) {
        //          stdout.printf ("%s=> %s\n", entry.key.to_string (), entry.value);
        //      }
        //  }

        return instance;
    }

    private Settings () {
        base ("com.github.alecaddd.sequeler");
    }

    public void add_connection (Gee.HashMap<string, string> data) {
        var current_connections = saved_connections;
        var connection = stringify_data (data);
        
        Gee.List<string> existing_connections = new Gee.ArrayList<string> ();
        existing_connections.add_all_array (current_connections);

        if (connection in current_connections) {
            existing_connections.remove (connection);
        }

        existing_connections.add (connection);

        saved_connections = existing_connections.to_array ();
    }

    public static string stringify_data (Gee.HashMap<string, string> data) {
        string result = "";

        foreach (var entry in data.entries) {
            string values = "%s=%s\n".printf (entry.key, entry.value);
            result = result + values;
        }

        return result;

    }

    public void delete_connection (Gee.HashMap<string, string> data) {
        var current_connections = saved_connections;
        var connection = stringify_data (data);

        Gee.List<string> existing_connections = new Gee.ArrayList<string> ();
        existing_connections.add_all_array (current_connections);

        if (connection in current_connections) {
            existing_connections.remove (connection);
        }

        saved_connections = existing_connections.to_array ();
    }

    public void clear_connections () {
        Gee.List<string> empty_connection = new Gee.ArrayList<string> ();
        saved_connections = empty_connection.to_array ();
    }
}
