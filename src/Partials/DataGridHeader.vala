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

public class Sequeler.Partials.DataGridHeader : Gtk.Grid {
	public Sequeler.Models.DataColumn model { get; construct set; }

	public string title { get; construct set; }
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

	public DataGridHeader (string title, Sequeler.Models.DataColumn model) {
		Object (
			title: title,
			model: model
		);
	}

	construct {
		var button = new Gtk.Button ();
		button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
		button.can_focus = false;
		button.hexpand = true;

		var icon = new Gtk.Image.from_icon_name ("pan-down-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
		icon.valign = Gtk.Align.CENTER;

		var title = new Gtk.Label (title);
		title.halign = Gtk.Align.START;
		title.ellipsize = Pango.EllipsizeMode.END;
		title.hexpand = true;

		button_grid = new Gtk.Grid ();
		button_grid.width_request = size;
		button_grid.column_spacing = 5;
		button_grid.add (title);
		button_grid.add (icon);

		button.add (button_grid);
		button.clicked.connect (() => {
			// to-do
		});

		var resizer = new Gtk.Button ();
		resizer.can_focus = false;
		resizer.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
		resizer.get_style_context ().add_class ("column-resizer");
		resizer.add (new Gtk.Separator (Gtk.Orientation.VERTICAL));

		resizer.enter_notify_event.connect (event => {
			set_cursor (Gdk.CursorType.RIGHT_SIDE);
			return false;
		});

		resizer.leave_notify_event.connect (event => {
			set_cursor (Gdk.CursorType.ARROW);
			return false;
		});

		add (button);
		add (resizer);
	}

	private void set_cursor (Gdk.CursorType cursor_type) {
        var cursor = new Gdk.Cursor.for_display (Gdk.Display.get_default (), cursor_type);
        get_window ().set_cursor (cursor);
	}

	private void update_column_size () {
		button_grid.width_request = size;
	}
}
