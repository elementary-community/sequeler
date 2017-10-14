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
    public class SettingsDialog : Gtk.Dialog {
        private Gtk.Stack main_stack;
        private Gtk.Switch dark_theme_switch;
        public Gtk.Box content_box;

        public signal void welcome_library ();

        public SettingsDialog (Gtk.ApplicationWindow parent, Settings settings) {
            Object (
                use_header_bar: 0,
                border_width: 20,
                modal: true,
                deletable: false,
                resizable: false,
                title: _("Preferences"),
                transient_for: parent
            );
        }

        construct {
            main_stack = new Gtk.Stack ();
            main_stack.margin = 6;
            main_stack.margin_bottom = 15;
            main_stack.margin_top = 15;
            main_stack.add_titled (get_general_box (), "general", _("General"));
            main_stack.add_titled (get_interface_box (), "interface", _("Interface"));

            var main_stackswitcher = new Gtk.StackSwitcher ();
            main_stackswitcher.set_stack (main_stack);
            main_stackswitcher.halign = Gtk.Align.CENTER;

            var main_grid = new Gtk.Grid ();
            main_grid.halign = Gtk.Align.CENTER;
            main_grid.attach (main_stackswitcher, 1, 1, 1, 1);
            main_grid.attach (main_stack, 1, 2, 1, 1);

            get_content_area ().add (main_grid);

            var close_button = new SettingsButton (_("Close"));
            
            close_button.clicked.connect (() => {
                destroy ();
            });

            add_action_widget (close_button, 0);
        }

        private Gtk.Widget get_general_box () {
            var general_grid = new Gtk.Grid ();
            general_grid.column_spacing = 12;
            general_grid.row_spacing = 6;

            general_grid.attach (new SettingsHeader (_("General")), 0, 0, 2, 1);

            general_grid.attach (new SettingsLabel (_("Automatically Save New Connections:")), 0, 1, 1, 1);
            general_grid.attach (new SettingsSwitch ("save-quick"), 1, 1, 1, 1);

            general_grid.attach (new SettingsHeader (_("Welcome Screen")), 0, 2, 2, 1);

            general_grid.attach (new SettingsLabel (_("Show Library (needs reload):")), 0, 3, 1, 1);
            general_grid.attach (new SettingsSwitch ("show-library"), 1, 3, 1, 1);

            return general_grid;
        }

        private Gtk.Widget get_interface_box () {
            var content = new Gtk.Grid ();
            content.row_spacing = 6;
            content.column_spacing = 12;

            content.attach (new SettingsHeader (_("Theme")), 0, 0, 2, 1);

            content.attach (new SettingsLabel (_("Use Dark Theme:")), 0, 1, 1, 1);
            dark_theme_switch = new SettingsSwitch (_("dark-theme"));
            content.attach (dark_theme_switch, 1, 1, 1, 1);

            dark_theme_switch.notify.connect (() => {
                Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = settings.dark_theme;
            });

            return content;
        }

        private class SettingsHeader : Gtk.Label {
            public SettingsHeader (string text) {
                label = text;
                get_style_context ().add_class ("h4");
                halign = Gtk.Align.START;
            }
        }

        private class SettingsLabel : Gtk.Label {
            public SettingsLabel (string text) {
                label = text;
                halign = Gtk.Align.START;
                margin_end = 10;
            }
        }

        private class SettingsSwitch : Gtk.Switch {
            public SettingsSwitch (string setting) {
                halign = Gtk.Align.START;
                settings.schema.bind (setting, this, "active", SettingsBindFlags.DEFAULT);
            }
        }

        private class SettingsButton : Gtk.Button {
            public SettingsButton (string text) {
                label = text;
                valign = Gtk.Align.END;
                var style_context = this.get_style_context ();
                style_context.add_class ("suggested-action");
            }
        }
    }
}