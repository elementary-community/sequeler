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
        sidebar_stack.add_named (library, "library");

        main_stack = new Gtk.Stack ();
        welcome = new Sequeler.Layouts.Welcome (window);
        main_stack.add_named (welcome, "welcome");

        build_sidebar ();
        build_main ();
    }

    public void build_sidebar () {
        pack1 (sidebar_stack, false, false);
    }

    public void build_main () {
		pack2 (main_stack, true, false);
    }
}