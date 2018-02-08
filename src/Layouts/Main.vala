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

public class Sequeler.Layouts.Main : Gtk.Paned {
    public weak Sequeler.Window window { get; construct; }
    private Sequeler.Services.ConnectionManager? _connection { get; set; default = null; }

    public Sequeler.Services.ConnectionManager? connection {
        get { return _connection; }
        set { _connection = value; }
    }

    public Sequeler.Layouts.Library library;
    public Sequeler.Layouts.DataBaseSchema database_schema;
    public Sequeler.Layouts.Welcome welcome;
    public Sequeler.Layouts.DataBaseView database_view;

    public Gtk.Stack sidebar_stack;
    public Gtk.Stack main_stack;

    public Main (Sequeler.Window main_window) {
        Object (
            orientation: Gtk.Orientation.HORIZONTAL,
            window: main_window
        );
    }

    construct {
        position = 240;

        sidebar_stack = new Gtk.Stack ();
        library = new Sequeler.Layouts.Library (window);
        database_schema = new Sequeler.Layouts.DataBaseSchema ();
        sidebar_stack.add_named (library, "library");
        sidebar_stack.add_named (database_schema, "database_schema");

        main_stack = new Gtk.Stack ();
        welcome = new Sequeler.Layouts.Welcome (window);
        database_view = new Sequeler.Layouts.DataBaseView ();
        main_stack.add_named (welcome, "welcome");
        main_stack.add_named (database_view, "database_view");

        build_sidebar ();
        build_main ();
    }

    public void build_sidebar () {
        pack1 (sidebar_stack, false, false);
    }

    public void build_main () {
		pack2 (main_stack, true, false);
    }

    public void connection_opened (Sequeler.Services.ConnectionManager connection) {
        window.headerbar.toggle_logout ();
        this.connection = connection;
        sidebar_stack.set_visible_child_full ("database_schema", Gtk.StackTransitionType.CROSSFADE);
        main_stack.set_visible_child_full ("database_view", Gtk.StackTransitionType.OVER_LEFT_RIGHT);
    }

    public void connection_closed () {
        _connection.close ();
        this.connection = null;
        sidebar_stack.set_visible_child_full ("library", Gtk.StackTransitionType.CROSSFADE);
        main_stack.set_visible_child_full ("welcome", Gtk.StackTransitionType.OVER_LEFT_RIGHT);
    }
}