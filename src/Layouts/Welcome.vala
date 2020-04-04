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

public class Sequeler.Layouts.Welcome : Granite.Widgets.Welcome {
    public unowned Sequeler.Window window { get; construct; }

    public Welcome (Sequeler.Window main_window) {
        Object (
            window: main_window,
            title: _("Welcome to Sequeler"),
            subtitle: _("Connect to Any Local or Remote Database.")
        );
    }

    construct {
        valign = Gtk.Align.FILL;
        halign = Gtk.Align.FILL;
        vexpand = true;

        append ("bookmark-new", _("Add a New Database"), _("Connect to a Database and Save It in Your Library"));
        append ("window-new", _("New Window"), _("Open a New Sequeler Window"));
        append ("folder-download", _("Import Connections"), _("Import Previously Exported Sequeler Connections"));

        activated.connect ( index => {
            switch (index) {
                case 0:
                    Sequeler.Services.ActionManager.action_from_group (Sequeler.Services.ActionManager.ACTION_NEW_CONNECTION, window.get_action_group ("win"));
                break;
                case 1:
                    Sequeler.Services.ActionManager.action_from_group (Sequeler.Services.ActionManager.ACTION_NEW_WINDOW, window.get_action_group ("win"));
                break;
                case 2:
                    import_file ();
                break;
            }
        });
    }

    private void import_file () {
        var open_dialog = new Gtk.FileChooserNative (_("Select a file"),
                                                     window,
                                                     Gtk.FileChooserAction.OPEN,
                                                     _("_Open"),
                                                     _("_Cancel"));

        open_dialog.local_only = true;
        open_dialog.modal = true;
        open_dialog.response.connect (open_file);
        open_dialog.run ();
    }

    private void open_file (Gtk.NativeDialog dialog, int response_id) {
        var open_dialog = dialog as Gtk.FileChooserNative;

        switch (response_id) {
            case Gtk.ResponseType.ACCEPT:
                var file = open_dialog.get_file ();
                uint8[] file_contents;

                try {
                    file.load_contents (null, out file_contents, null);
                }
                catch (GLib.Error err) {
                    import_warning (err.message);
                }
                var imported_connections = (string) file_contents;
                var data = imported_connections.split ("---\n");
                foreach (var import in data) {
                    if (import == "") {
                        continue;
                    }
                    var array = settings.arraify_data (import);
                    array["id"] = settings.tot_connections.to_string ();
                    settings.add_connection (array);
                }

                window.main.library.reload_library.begin ();

            break;

            case Gtk.ResponseType.CANCEL:
            break;
        }

        open_dialog.destroy ();
    }

    private void import_warning (string message) {
        var message_dialog = new Granite.MessageDialog.with_image_from_icon_name (_("Unable to Import Library "), message, "dialog-error", Gtk.ButtonsType.NONE);
        message_dialog.transient_for = window;

        var suggested_button = new Gtk.Button.with_label ("Close");
        message_dialog.add_action_widget (suggested_button, Gtk.ResponseType.ACCEPT);

        message_dialog.show_all ();
        if (message_dialog.run () == Gtk.ResponseType.ACCEPT) {}

        message_dialog.destroy ();
    }
}
