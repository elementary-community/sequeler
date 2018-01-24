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

public class Sequeler.Services.Settings : Granite.Services.Settings {
    public int pos_x { get; set; }
    public int pos_y { get; set; }
    public int window_width { get; set; }
    public int window_height { get; set; }
    public string[] saved_connections { get; set; }
    public int tot_connections { get; set; }
    public bool dark_theme { get; set; }
    public bool save_quick { get; set; }

    public Settings () {
        base ("com.github.alecaddd.sequeler");
    }

    public void add_connection (Gee.HashMap<string, string> data) {
        Gee.List<string> existing_connections = new Gee.ArrayList<string> ();
        existing_connections.add_all_array (saved_connections);

        existing_connections.insert (0, stringify_data (data));
        saved_connections = existing_connections.to_array ();
        tot_connections = tot_connections + 1;
    }

    public void edit_connection (Gee.HashMap<string, string> new_data, string old_data) {  
        Gee.List<string> existing_connections = new Gee.ArrayList<string> ();
        existing_connections.add_all_array (saved_connections);

        existing_connections.remove (old_data);
        existing_connections.insert (0, stringify_data (new_data));

        saved_connections = existing_connections.to_array ();
    }

    public void delete_connection (Gee.HashMap<string, string> data) {
        Gee.List<string> existing_connections = new Gee.ArrayList<string> ();
        existing_connections.add_all_array (saved_connections);

        foreach (var conn in saved_connections) {
            var check = arraify_data (conn);
            if (check["id"] == data["id"]) {
                existing_connections.remove (conn);
            }
        }

        saved_connections = existing_connections.to_array ();
    }

    public void clear_connections () {
        Gee.List<string> empty_connection = new Gee.ArrayList<string> ();
        saved_connections = empty_connection.to_array ();
        tot_connections = 0;
    }

    public static string stringify_data (Gee.HashMap<string, string> data) {
        string result = "";

        foreach (var entry in data.entries) {
            string values = "%s=%s\n".printf (entry.key, entry.value);
            result = result + values;
        }

        return result;

    }

    public static Gee.HashMap<string, string> arraify_data (string connection) {
        var array = new Gee.HashMap<string, string> ();
        var data = connection.split ("\n");

        foreach (var d in data) {
            var d2 = d.split ("=", 2);

            if (d2[0] == null) {
                continue;
            }

            array.set (d2[0], d2[1]);
        }

        return array;
    }
}