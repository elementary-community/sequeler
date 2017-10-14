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
    public abstract class SimpleSettingsPage : Gtk.ScrolledWindow {
        private Gtk.Image header_icon;
        private Gtk.Label description_label;
        private Gtk.Label title_label;
        private string _description;
        private string _icon_name;
        private string _title;

        /**
         * A #Gtk.ButtonBox used as the action area for #this
         */
        public Gtk.ButtonBox action_area { get; construct; }

        /**
         * A #Gtk.Grid used as the content area for #this
         */
        public Gtk.Grid content_area { get; construct; }

        /**
         * A #Gtk.Switch that appears in the header area when #this.activatable is #true. #status_switch will be #null when #this.activatable is #false
         */
        public Gtk.Switch? status_switch { get; construct; }

        /**
         * Creates a #Gtk.Switch #status_switch in the header of #this
         */
        public bool activatable { get; construct; }

        /**
         * Creates a #Gtk.Label with a page description in the header of #this
         */
        public string description {
            get {
                return _description;
            } 
            construct set {
                if (description_label != null) {
                    description_label.label = value;
                }
                _description = value;
            }
        }

        /**
         * An icon name associated with #this
         */
        public string icon_name {
            get {
                return _icon_name;
            } 
            construct set {
                if (header_icon != null) {
                    header_icon.icon_name = value;
                }
                _icon_name = value;
            }
        }

        /**
         * A title associated with #this
         */
        public string title {
            get {
                return _title;
            } 
            construct set {
                if (title_label != null) {
                    title_label.label = value;
                }
                _title = value;
            }
        }

        /**
         * Creates a new SimpleSettingsPage
         */
        public SimpleSettingsPage () {
            Object (activatable: activatable,
                    icon_name: icon_name,
                    description: description,
                    title: title);
        }

        construct {
            header_icon = new Gtk.Image.from_icon_name (icon_name, Gtk.IconSize.DIALOG);
            header_icon.pixel_size = 48;
            header_icon.valign = Gtk.Align.START;

            title_label = new Gtk.Label (title);
            title_label.xalign = 0;
            title_label.get_style_context ().add_class ("h2");

            var header_area = new Gtk.Grid ();
            header_area.column_spacing = 12;
            header_area.row_spacing = 3;
            header_area.attach (header_icon, 0, 0, 1, 2);
            header_area.attach (title_label, 1, 0, 1, 1);

            if (description != null) {
                description_label = new Gtk.Label (description);
                description_label.xalign = 0;
                description_label.wrap = true;

                header_area.attach (description_label, 1, 1, 1, 1);
            }

            if (activatable) {
                status_switch = new Gtk.Switch ();
                status_switch.hexpand = true;
                status_switch.halign = Gtk.Align.END;
                status_switch.valign = Gtk.Align.CENTER;
                header_area.attach (status_switch, 2, 0, 1, 1);
            }

            content_area = new Gtk.Grid ();
            content_area.column_spacing = 12;
            content_area.row_spacing = 12;
            content_area.vexpand = true;

            action_area = new Gtk.ButtonBox (Gtk.Orientation.HORIZONTAL);
            action_area.set_layout (Gtk.ButtonBoxStyle.END);
            action_area.spacing = 6;

            var grid = new Gtk.Grid ();
            grid.margin = 12;
            grid.orientation = Gtk.Orientation.VERTICAL;
            grid.row_spacing = 24;
            grid.add (header_area);
            grid.add (content_area);
            grid.add (action_area);

            add (grid);
        }
    }
}