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
    public class Welcome : Gtk.Box {
        private Granite.Widgets.Welcome welcome_widget;
        private Gtk.Box welcome_box;
        public Library? library = null;
        public DataBaseOpen database;

        private Gtk.Separator separator;
        public Gtk.Stack welcome_stack;

        public signal void create_connection (Gee.HashMap? data);
        public signal void init_connection (Gee.HashMap? data , Gtk.Spinner spinner, Gtk.MenuItem button);
        public signal int execute_query (string query);
        public signal Gda.DataModel? execute_select (string query);

        public Welcome () {
            orientation = Gtk.Orientation.HORIZONTAL;

            width_request = 950;
            height_request = 500;

            welcome_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            welcome_widget = new Granite.Widgets.Welcome (_("Welcome to Sequeler"), _("Connect to any Local or Remote Database"));
            welcome_widget.hexpand = true;

            welcome_widget.append ("bookmark-new", _("Add New Database"), _("Connect to a Database and save it in your Library."));

            separator = new Gtk.Separator (Gtk.Orientation.VERTICAL);
            separator.visible = false;
            separator.no_show_all = true;;

            library = new Library ();
            library.visible = false;
            library.no_show_all = true;

            welcome_box.add (library);
            welcome_box.add (separator);
            welcome_box.add (welcome_widget);

            welcome_stack = new Gtk.Stack ();
            welcome_stack.add_named (welcome_box, "welcome_box");

            database = new DataBaseOpen ();
            welcome_stack.add_named (database, "database");

            welcome_stack.set_visible_child (welcome_box);

            add (welcome_stack);

            load_library ();

            welcome_widget.activated.connect ((index) => {
                switch (index) {
                    case 0:
                        create_connection (null);
                        break;
                    }
            });

            connect_signals ();
        }

        public void connect_signals () {
            library.edit_dialog.connect ((data) => {
                create_connection (data);
            });

            library.connect_to.connect ((data, spinner, button) => {
                init_connection (data, spinner, button);
            });

            library.reload_ui.connect (() => {
                load_library ();
            });

            database.execute_query.connect((query) => {
                return execute_query (query);
            });

            database.execute_select.connect((query) => {
                return execute_select (query);
            });
        }

        public void reload (Gee.HashMap<string, string> data) {
            library.check_add_item (data);
            library.show_all ();
            load_library ();
        }

        public void load_library () {
            if (settings.saved_connections.length > 0) {
                separator.visible = true;
                separator.no_show_all = false;
                library.visible = true;
                library.no_show_all = false;
            } else {
                separator.visible = false;
                separator.no_show_all = true;
                library.visible = false;
                library.no_show_all = true;
            }

            this.show_all ();
        }
    }
}