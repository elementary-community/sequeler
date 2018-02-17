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

public class Sequeler.Layouts.DataBaseView : Gtk.Grid {
	public weak Sequeler.Window window { get; construct; }

	public Granite.Widgets.ModeButton tabs;
	public Gtk.Stack stack;
	public Gtk.Grid structure;
	public Gtk.Grid content;
	public Gtk.Grid relations;
	public Gtk.Grid query;

	public DataBaseView (Sequeler.Window main_window) {
		Object (
			orientation: Gtk.Orientation.VERTICAL,
			window: main_window,
			column_homogeneous: true
		);
	}

	construct {
		var toolbar = new Gtk.Grid ();
		toolbar.get_style_context ().add_class ("library-titlebar");

		tabs = new Granite.Widgets.ModeButton ();
		tabs.append (new Sequeler.Partials.ToolBarButton ("x-office-spreadsheet-template", "Structure"));
		tabs.append (new Sequeler.Partials.ToolBarButton ("x-office-document", "Content"));
		tabs.append (new Sequeler.Partials.ToolBarButton ("preferences-system-windows", "Relations"));
		tabs.append (new Sequeler.Partials.ToolBarButton ("accessories-text-editor", "Query"));
		tabs.set_active (0);
		tabs.margin = 10;
		tabs.margin_bottom = 9;

		tabs.mode_changed.connect ((tab) => {
			stack.set_visible_child_name (tab.name);
		});

		toolbar.attach (tabs, 0, 0, 1, 1);

		stack = new Gtk.Stack ();
		structure = new Gtk.Grid ();
		content = new Gtk.Grid ();
		relations = new Gtk.Grid ();
		query = new Gtk.Grid ();

		stack.add_named (structure, "Structure");
		stack.add_named (content, "Content");
		stack.add_named (relations, "Relations");
		stack.add_named (query, "Query");
		stack.expand = true;

		attach (toolbar, 0, 0, 1, 1);
		attach (stack, 0, 1, 1, 1);
	}
}