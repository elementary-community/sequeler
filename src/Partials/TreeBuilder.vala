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

	public TreeBuilder (Gda.DataModel response, Sequeler.Window main_window) {
		Object (
			window: main_window,
			data: response,
			rubber_banding: true,
			rules_hint: true
		);
	}

	construct {
		Gtk.TreeViewColumn column;
		var renderer = new Gtk.CellRendererText ();
		var tot_columns = data.get_n_columns ();

		var theTypes = new GLib.Type[tot_columns];
		for (int col = 0; col < tot_columns; col++) {
			theTypes[col] = data.describe_column (col).get_g_type ();

			var title = data.get_column_title (col).replace ("_", "__");
			column = new Gtk.TreeViewColumn.with_attributes (title, renderer, "text", col, null);
			column.clickable = true;
			column.resizable = true;
			column.expand = true;
			column.min_width = 10;
			if (col > 0) {
				column.sizing = Gtk.TreeViewColumnSizing.FIXED;
				column.fixed_width = 150;
			}
			this.append_column (column);
		}

		var store = new Gtk.ListStore.newv (theTypes);
		Gda.DataModelIter _iter = data.create_iter ();
		Gtk.TreeIter iter;
		var error_message = GLib.Value (typeof (string));

		while (_iter.move_next ()) {
			store.append (out iter);
			for (int i = 0; i < tot_columns; i++) {
				try {
					store.set_value (iter, i, _iter.get_value_at_e (i));
				} catch (Error e) {
					error_message.set_string ("Error " + e.code.to_string () + " on Column '" + data.get_column_title (i) + "': " + e.message.to_string ());
				}
			}
		}

		if (error_message.get_string () != null) {
			window.main.connection.query_warning (error_message.get_string ());
			error_message.unset ();
		}

		this.set_model (store);
	}
}
