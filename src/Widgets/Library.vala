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

namespace Sequeler {
    public class Library : Gtk.Box {
        public Gtk.FlowBox item_box;
        public Gtk.ScrolledWindow scroll;
        public Gtk.Button delete_all;

        public signal void reload_ui ();
        public signal void edit_dialog (Gee.HashMap data);
        public signal void connect_to (Gee.HashMap data, Gtk.Spinner spinner, Gtk.Button button);

        public Library () {
            orientation = Gtk.Orientation.VERTICAL;

            width_request = 220;

            var toolbar = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            toolbar.get_style_context ().add_class ("toolbar");
            toolbar.get_style_context ().add_class ("library-toolbar");

            var delete_image = new Gtk.Image.from_icon_name ("user-trash-symbolic", Gtk.IconSize.BUTTON);
            delete_all = new Gtk.Button.with_label (_("Delete All"));
            delete_all.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            delete_all.always_show_image = true;
            delete_all.image = delete_image;
            delete_all.clicked.connect (() => {
                confirm_delete_all ();
            });
            delete_all.can_focus = false;
            delete_all.margin = 6;
            delete_all.sensitive = false;

            toolbar.pack_start (delete_all, false, false, 0);
            this.pack_end (toolbar, false, true, 0);

            scroll = new Gtk.ScrolledWindow (null, null);
            scroll.hscrollbar_policy = Gtk.PolicyType.AUTOMATIC;
            scroll.vscrollbar_policy = Gtk.PolicyType.AUTOMATIC;

            item_box = new Gtk.FlowBox ();
            item_box.activate_on_single_click = false;
            
            item_box.valign = Gtk.Align.START;
            item_box.min_children_per_line = 1;
            item_box.max_children_per_line = 1;
            item_box.margin = 6;
            item_box.expand = false;

            scroll.add (item_box);

            foreach (var conn in settings.saved_connections) {
                add_item (Settings.arraify_data (conn));
                //  var item = new LibraryItem (Settings.arraify_data (conn));
                //  item_box.add (item);
            }

            item_box.child_activated.connect ((child) => {
                stdout.printf ("Clicked\n");
            });

            this.pack_end (scroll, true, true, 0);
        }

        public void add_item (Gee.HashMap<string, string> data) {
            var item = new Gtk.FlowBoxChild ();
            item.get_style_context ().add_class ("library-box");
            item.expand = true;

            var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            box.get_style_context ().add_class ("library-inner-box");
            box.margin = 4;

            var color = Gdk.RGBA ();
            color.parse (data["color"]);
            try
            {
                var style = new Gtk.CssProvider ();
                style.load_from_data ("* {background-color: %s;}".printf (color.to_string ()), -1);
                box.get_style_context ().add_provider (style, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
            }
            catch (Error e)
            {
                debug ("Internal error loading session chooser style: %s", e.message);
            }

            var title = new Gtk.Label (data["title"]);
            title.get_style_context ().add_class ("text-bold");
            title.halign = Gtk.Align.START;
            title.margin_start = 10;
            title.margin_end = 10;
            title.set_line_wrap (true);

            box.pack_start (title, true, true, 10);

            var button_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            button_box.get_style_context ().add_class ("button-box");

            var edit_button = new BoxButton ("applications-office-symbolic", _("Edit Connection"));
            var delete_button = new BoxButton ("user-trash-symbolic", _("Delete Connection"));
            var connect_button = new BoxButton ("go-next-symbolic", _("Connect"));
            var spinner = new Gtk.Spinner ();

            button_box.pack_start (delete_button, false, true, 0);
            button_box.pack_start (edit_button, false, true, 0);
            button_box.pack_end (connect_button, false, true, 0);
            button_box.pack_end (spinner, false, true, 0);

            box.pack_end (button_box, true, false, 0);

            item.add (box);
            item_box.add (item);

            delete_button.clicked.connect (() => {
                confirm_delete (item, data);
            });

            edit_button.clicked.connect (() => {
                edit_dialog (data);
            });

            connect_button.clicked.connect (() => {
                spinner.start ();
                connect_button.sensitive = false;
                connect_to (data, spinner, connect_button);
            });

            delete_all.sensitive = true;
        }

        public void confirm_delete (Gtk.FlowBoxChild item, Gee.HashMap<string, string> data) {
            var message_dialog = new MessageDialog.with_image_from_icon_name ("Are you sure you want to proceed?", "By deleting this connection you won't be able to recover this data.", "dialog-warning", Gtk.ButtonsType.CANCEL);
            message_dialog.transient_for = window;
            
            var suggested_button = new Gtk.Button.with_label ("Yes, Delete!");
            suggested_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
            message_dialog.add_action_widget (suggested_button, Gtk.ResponseType.ACCEPT);

            message_dialog.show_all ();
            if (message_dialog.run () == Gtk.ResponseType.ACCEPT) {
                settings.delete_connection (data);
                item_box.remove (item);
                reload_library ();
            }
            
            message_dialog.destroy ();
        }

        public void confirm_delete_all () {
            var message_dialog = new MessageDialog.with_image_from_icon_name ("Are you sure you want to proceed?", "All the data will be deleted and you won't be able to recover it.", "dialog-warning", Gtk.ButtonsType.CANCEL);
            message_dialog.transient_for = window;
            
            var suggested_button = new Gtk.Button.with_label ("Yes, Delete All!");
            suggested_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
            message_dialog.add_action_widget (suggested_button, Gtk.ResponseType.ACCEPT);

            message_dialog.show_all ();
            if (message_dialog.run () == Gtk.ResponseType.ACCEPT) {
                settings.clear_connections ();
                item_box.forall ((item) => item_box.remove (item));
                reload_library ();
            }
            
            message_dialog.destroy ();
        }

        public void reload_library () {
            item_box.show_all ();
            reload_ui ();
        }

        public void check_add_item (Gee.HashMap<string, string> data) {
            foreach (var conn in settings.saved_connections) {
                var check = Settings.arraify_data (conn);
                if (check["id"] == data["id"]) {
                    settings.edit_connection (data, conn);
                    item_box.forall ((item) => item_box.remove (item));
                    foreach (var new_conn in settings.saved_connections) {
                        add_item (Settings.arraify_data (new_conn));
                    }
                    return;
                }
            }
            settings.add_connection (data);

            add_item (data);
        }

        protected class BoxButton : Gtk.Button {         
            public BoxButton (string icon_name, string tooltip) {
                can_focus = false;

                Gtk.Image image;

                if (icon_name.contains ("/")) {
                    image = new Gtk.Image.from_resource (icon_name);
                } else {
                    image = new Gtk.Image.from_icon_name (icon_name, Gtk.IconSize.SMALL_TOOLBAR);
                }

                image.margin = 3;

                tooltip_text = tooltip;
                get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
                this.add (image);
            }
        }
    }
}