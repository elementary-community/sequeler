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
    public class LibraryItem : Gtk.FlowBoxChild {
        public Gee.HashMap<string, string> data;

        public BoxButton connect_button;
        public Gtk.Spinner spinner;

        public signal void edit_dialog (Gee.HashMap data);
        public signal void confirm_delete (Gtk.FlowBoxChild item, Gee.HashMap data);
        public signal void connect_to (Gee.HashMap data, Gtk.Spinner spinner, Gtk.Button button);

        public LibraryItem (Gee.HashMap<string, string> data) {
            this.data = data;
            get_style_context ().add_class ("library-box");
            expand = true;

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
            connect_button = new BoxButton ("go-next-symbolic", _("Connect"));
            spinner = new Gtk.Spinner ();

            button_box.pack_start (delete_button, false, true, 0);
            button_box.pack_start (edit_button, false, true, 0);
            button_box.pack_end (connect_button, false, true, 0);
            button_box.pack_end (spinner, false, true, 0);

            box.pack_end (button_box, true, false, 0);

            this.add (box);

            delete_button.clicked.connect (() => {
                confirm_delete (this, data);
            });

            edit_button.clicked.connect (() => {
                edit_dialog (data);
            });

            connect_button.clicked.connect (() => {
                spinner.start ();
                connect_button.sensitive = false;
                connect_to (data, spinner, connect_button);
            });
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