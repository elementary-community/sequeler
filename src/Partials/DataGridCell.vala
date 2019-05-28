/*
* Copyright (c) 2019 Alecaddd (http://alecaddd.com)
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

public class Sequeler.Partials.DataGridCell : Gtk.Grid {
	public Sequeler.Models.DataColumn model { get; construct set; }

	public Value raw_value { get; construct set; }
	public int row { get; construct set; }
	public int column {
		get {
            return model.column;
        } set {
            model.column = value;
        }
	}

	public int size {
		get {
            return model.size;
        } set {
			model.size = value;

			update_column_size ();
        }
	}

	public Gtk.Grid button_grid;

	public DataGridCell (Value? raw_value, int row, Sequeler.Models.DataColumn model) {
		Object (
			raw_value: raw_value,
			row: row,
			model: model
		);
	}

	construct {
		width_request = size;
		var class = row % 2 == 0 ? "bg-light" : "bg-dark";
		get_style_context ().add_class (class);

		var title = new Gtk.Label (raw_value.dup_string ());
		title.halign = Gtk.Align.START;
		title.ellipsize = Pango.EllipsizeMode.END;
		title.hexpand = true;
		title.margin = 5;

		add (title);

		show_all ();
	}

	private void update_column_size () {
		width_request = size;
	}
}
