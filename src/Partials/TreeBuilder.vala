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

public class Sequeler.Partials.TreeBuilder : Gtk.TreeView {
	public weak Sequeler.Window window { get; construct; }
	public Gda.DataModel data { get; construct; }
	public int per_page { get; construct; }
	public int current_page { get; construct; }

	private string bg_light = "rgba(255,255,255,0.05)";
	private string bg_dark = "rgba(0,0,0,0.05)";

	public TreeBuilder (Gda.DataModel response, Sequeler.Window main_window, int per_page = 0, int current_page = 0) {
		Object (
			window: main_window,
			data: response,
			per_page: per_page,
			current_page: current_page
		);
	}

	construct {
		Gtk.TreeViewColumn column;
		var renderer = new Gtk.CellRendererText ();
		renderer.single_paragraph_mode = true;

		var tot_columns = data.get_n_columns ();

		var theTypes = new GLib.Type[tot_columns+1];
		for (int col = 0; col < tot_columns; col++) {
			theTypes[col] = data.describe_column (col).get_g_type ();

			var title = data.get_column_title (col).replace ("_", "__");
			column = new Gtk.TreeViewColumn.with_attributes (title, renderer, "text", col, "background", tot_columns, null);
			column.clickable = true;
			column.resizable = true;
			column.expand = true;
			if (col > 0) {
				column.sizing = Gtk.TreeViewColumnSizing.FIXED;
				column.fixed_width = 150;
			}
			append_column (column);
		}

		theTypes[tot_columns] = typeof (string);

		var store = new Gtk.ListStore.newv (theTypes);
		Gda.DataModelIter _iter = data.create_iter ();
		Gtk.TreeIter iter;
		var error_message = GLib.Value (typeof (string));
		var background = bg_light;

		if (per_page != 0 && data.get_n_rows () > per_page) {
			int counter = 1;
			int offset = (per_page * (current_page - 1));

			if (current_page != 0 && offset != 0) {
				_iter.move_to_row (offset);
			}

			while (counter <= per_page && _iter.move_next ()) {

				if (_iter.get_row () % 2 == 0) {
					background = bg_light;
				} else {
					background = bg_dark;
				}

				store.append (out iter);

				for (int i = 0; i < tot_columns; i++) {
					try {
						store.set_value (iter, i, _iter.get_value_at_e (i));
					} catch (Error e) {
						error_message.set_string ("Error " + e.code.to_string () + " on Column '" + data.get_column_title (i) + "': " + e.message.to_string ());
					}
				}
				store.set_value (iter, tot_columns, background);
				counter++;
			}
		} else {
			while (_iter.move_next ()) {

				if (_iter.get_row () % 2 == 0) {
					background = bg_light;
				} else {
					background = bg_dark;
				}

				store.append (out iter);

				for (int i = 0; i < tot_columns; i++) {
					try {
						store.set_value (iter, i, _iter.get_value_at_e (i));
					} catch (Error e) {
						error_message.set_string ("Error " + e.code.to_string () + " on Column '" + data.get_column_title (i) + "': " + e.message.to_string ());
					}
				}
				store.set_value (iter, tot_columns, background);
			}
		}

		if (error_message.get_string () != null) {
			window.main.connection.query_warning (error_message.get_string ());
			error_message.unset ();
		}

		set_model (store);
	}
}
