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
        private Granite.Widgets.Welcome welcome;
        public Library? library = null;
        public DataBaseOpen database;

        private Gtk.Separator separator;
        public Gtk.Stack welcome_stack;

        public signal void create_connection (Gee.HashMap? data);
        public signal void init_connection (Gee.HashMap? data , Gtk.Spinner spinner, Gtk.Button button);
        public signal int execute_query (string query);
        public signal Gda.DataModel? execute_select (string query);

        public Welcome () {
            orientation = Gtk.Orientation.HORIZONTAL;

            width_request = 950;
            height_request = 500;

            welcome = new Granite.Widgets.Welcome (_("Welcome to Sequeler"), _("Connect to any Local or Remote Database"));
            welcome.hexpand = true;

            welcome.append ("bookmark-new", _("Add New Database"), _("Connect to a Database and save it in your Library."));

            if (! settings.show_library) {
                welcome.append ("preferences-system-network", _("Browse Library"), _("Browse through all your saved Databases."));
            }

            separator = new Gtk.Separator (Gtk.Orientation.VERTICAL);
            separator.visible = false;
            separator.no_show_all = true;

            library = new Library ();

            welcome_stack = new Gtk.Stack ();
            welcome_stack.add_named (welcome, "welcome");

            if (! settings.show_library) {
                welcome_stack.add_named (library, "library");
            }

            database = new DataBaseOpen ();
            welcome_stack.add_named (database, "database");

            welcome_stack.set_visible_child (welcome);

            if (settings.saved_connections.length > 0 && settings.show_library && library != null) {
                add (library);
                separator.visible = true;
                separator.no_show_all = false;
            }

            add (separator);
            add (welcome_stack);

            welcome.activated.connect ((index) => {
                switch (index) {
                    case 0:
                        create_connection (null);
                        break;
                    case 1:
                        welcome_stack.set_visible_child_full ("library", Gtk.StackTransitionType.SLIDE_LEFT);
                        headerbar.show_back_button ();
                        break;
                    }
            });

            connect_signals ();
        }

        public void connect_signals () {
            headerbar.go_back.connect (() => {
                welcome_stack.set_visible_child_full ("welcome", Gtk.StackTransitionType.SLIDE_RIGHT);
                headerbar.go_back_button.visible = false;
            });

            library.edit_dialog.connect ((data) => {
                create_connection (data);
            });

            library.connect_to.connect ((data, spinner, button) => {
                init_connection (data, spinner, button);
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
        }
    }
}