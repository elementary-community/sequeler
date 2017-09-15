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
    private static Settings? instance = null;

    public int pos_x { get; set; }
    public int pos_y { get; set; }
    public int window_width { get; set; }
    public int window_height { get; set; }
    public string[] saved_connections { get; set; }
    public bool dark_theme { get; set; }
    public bool save_quick { get; set; }
    public bool show_recent { get; set; }
    public bool show_library { get; set; }
    public bool reconnect { get; set; }

    public static Settings get_instance () {
        if (instance == null) {
            instance = new Settings ();
        }

        return instance;
    }

    private Settings () {
        base ("com.github.alecaddd.sequeler");
    }

    public void add_connection (string connection) {
        var current_connections = saved_connections;

        Gee.List<string> existing_connections = new Gee.ArrayList<string> ();
        existing_connections.add_all_array (current_connections);

        if (connection in current_connections) {
            existing_connections.remove (connection);
        }

        existing_connections.insert (0, connection);
        if (existing_connections.size > 10) {
            existing_connections = existing_connections.slice (0, 10);
        }

        saved_connections = existing_connections.to_array ();
    }
}
