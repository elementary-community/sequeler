/*
* Copyright (c) 2022 Alecaddd (https://alecaddd.com)
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

// namespace Sequeler {
//     public Sequeler.Services.Settings settings;
//     public Sequeler.Services.PasswordManager password_mngr;
//     public Sequeler.Services.UpgradeManager upgrade_mngr;
//     public Secret.Schema schema;
// }

public class Sequeler.Application : Gtk.Application {
    // public GLib.List <Sequeler.Window> windows;

    public Application () {
        Object (
            application_id: Constants.PROJECT_NAME,
            flags: ApplicationFlags.HANDLES_OPEN
        );
    }

    construct {
        // schema = new Secret.Schema (
        //     Constants.PROJECT_NAME,
        //     Secret.SchemaFlags.NONE,
        //     "id", Secret.SchemaAttributeType.INTEGER,
        //     "schema", Secret.SchemaAttributeType.STRING
        // );

        // settings = new Sequeler.Services.Settings ();
        // password_mngr = new Sequeler.Services.PasswordManager ();
        // upgrade_mngr = new Sequeler.Services.UpgradeManager ();
        // windows = new GLib.List <Sequeler.Window> ();
    }

    protected override void activate () {
        var main_window = new Gtk.ApplicationWindow (this) {
            default_height = 300,
            default_width = 300,
            title = "Hello World"
        };

        add_window (main_window);

        var granite_settings = Granite.Settings.get_default ();
        var gtk_settings = Gtk.Settings.get_default ();

        gtk_settings.gtk_application_prefer_dark_theme = (
            granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK
        );

        granite_settings.notify["prefers-color-scheme"].connect (() => {
            gtk_settings.gtk_application_prefer_dark_theme = (
                granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK
            );
        });

         active_window.present_with_time (Gdk.CURRENT_TIME);
    }

    public static int main (string[] args) {
        return new Sequeler.Application ().run (args);
    }

    // public void new_window () {
    //     new Sequeler.Window (this).present ();
    // }

    // public override void window_added (Gtk.Window window) {
    //     windows.append (window as Sequeler.Window);
    //     base.window_added (window);
    // }

    // protected override void open (File[] files, string hint) {
    //     foreach (var file in files) {
    //         var type = file.query_file_type (FileQueryInfoFlags.NONE);

    //         switch (type) {
    //             case FileType.DIRECTORY: // File handle represents a directory.
    //                 critical (_("Directories are not supported"));
    //                 continue;

    //             case FileType.UNKNOWN:   // File's type is unknown
    //             case FileType.SPECIAL:   // File is a "special" file, such as a socket, fifo, block device, or character device.
    //             case FileType.MOUNTABLE: // File is a mountable location.
    //                 critical (_("Don't know what to do"));
    //                 continue;

    //             case FileType.REGULAR:       // File handle represents a regular file.
    //             case FileType.SYMBOLIC_LINK: // File handle represents a symbolic link (Unix systems).
    //             case FileType.SHORTCUT:      // File is a shortcut (Windows systems).
    //                 var window = this.add_new_window ();

    //                 window.main.library.check_open_sqlite_file (file.get_uri (), file.get_basename ());
    //                 break;

    //             default:
    //                 error (_("Something completely unexpected happened"));
    //         }
    //     }
    // }

    // public override void window_removed (Gtk.Window window) {
    //     windows.remove (window as Sequeler.Window);
    //     base.window_removed (window);
    // }

    // private Sequeler.Window add_new_window () {
    //     var window = new Sequeler.Window (this);
    //     this.add_window (window);

    //     return window;
    // }

    // protected override void activate () {
    //     this.add_new_window ();
    // }
}
