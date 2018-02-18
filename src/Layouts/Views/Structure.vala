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

public class Sequeler.Layouts.Views.Structure : Gtk.Grid {
	public weak Sequeler.Window window { get; construct; }

	public Gtk.ScrolledWindow scroll;

	public Structure (Sequeler.Window main_window) {
		Object (
			orientation: Gtk.Orientation.VERTICAL,
			window: main_window
		);
	}

	construct {
		scroll = new Gtk.ScrolledWindow (null, null);
		scroll.hscrollbar_policy = Gtk.PolicyType.AUTOMATIC;
		scroll.vscrollbar_policy = Gtk.PolicyType.AUTOMATIC;
		scroll.expand = true;

		attach (scroll, 0, 0, 1, 1);

		placeholder ();
	}

	public void placeholder () {
		var intro = new Granite.Widgets.Welcome (_("Select Table"), _("Select a table from the left sidebar to activate this view."));
		scroll.add (intro);
	}

	public void clear () {
		if (scroll.get_child () != null) {
			scroll.remove (scroll.get_child ());
		}
	}

	public void reset () {
		if (scroll.get_child () != null) {
			scroll.remove (scroll.get_child ());
		}

		placeholder ();

		scroll.show_all ();
	}

	public void fill (string table) {
		var query = (window.main.connection.db_type as DataBaseType).show_table_structure (table);

		var table_schema = get_table_schema (query);

		if (table_schema == null) {
			return;
		}

		var result_data = new Sequeler.Partials.TreeBuilder (table_schema, window);

		clear ();

		scroll.add (result_data);
		scroll.show_all ();
	}

	private Gda.DataModel? get_table_schema (string query) {
		Gda.DataModel? result = null;
		var error = "";

		var loop = new MainLoop ();
		window.main.connection.init_select_query.begin (query, (obj, res) => {
			try {
				result = window.main.connection.init_select_query.end (res);
			} catch (ThreadError e) {
				error = e.message;
				result = null;
			}
			loop.quit ();
		});

		loop.run ();

		if (error != "") {
			window.main.connection.query_warning (error);
			return null;
		}

		return result;
	}
}