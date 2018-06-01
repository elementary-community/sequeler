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

namespace Sequeler {
    public Sequeler.Services.Settings settings;
    public Secret.Schema schema;
}

public class Sequeler.Application : Gtk.Application {
    public GLib.List <Window> windows;

    construct {
        application_id = Constants.PROJECT_NAME;
        flags |= ApplicationFlags.HANDLES_OPEN;

        settings = new Sequeler.Services.Settings ();
        schema = new Secret.Schema ("com.github.alecaddd.sequler", Secret.SchemaFlags.NONE,
                                 "id", Secret.SchemaAttributeType.INTEGER,
                                 "host", Secret.SchemaAttributeType.STRING,
                                 "username", Secret.SchemaAttributeType.STRING);

        windows = new GLib.List <Window> ();
    }

    public void new_window () {
        new Sequeler.Window (this).present ();
    }

    public override void window_added (Gtk.Window window) {
        windows.append (window as Window);
        base.window_added (window);
    }

    public override void window_removed (Gtk.Window window) {
        windows.remove (window as Window);
        base.window_removed (window);
    }

    protected override void activate () {
        var window = new Sequeler.Window (this);
        this.add_window (window);
    }
}
