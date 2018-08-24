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

public class Sequeler.Partials.LibraryItem : Gtk.FlowBoxChild {
	public Gee.HashMap<string, string> data { get; set; }
	public Gtk.Label title;
	public Gdk.RGBA color;

	public Gtk.ModelButton connect_button;
	public Gtk.Spinner spinner;

	public signal void edit_dialog (Gee.HashMap data);
	public signal void confirm_delete (Gtk.FlowBoxChild item, Gee.HashMap data);
	public signal void connect_to (Gee.HashMap data, Gtk.Spinner spinner, Gtk.ModelButton button);

	public LibraryItem (Gee.HashMap<string, string> data) {
		Object (
			data: data
		);

		get_style_context ().add_class ("library-box");
		expand = true;

		var box = new Gtk.Grid ();
		box.get_style_context ().add_class ("library-inner-box");
		box.margin = 4;

		var color_box = new Gtk.Grid ();
		color_box.get_style_context ().add_class ("library-colorbox");
		color_box.set_size_request (12, 12);
		color_box.margin = 10;

		color = Gdk.RGBA ();
		color.parse (data["color"]);
		try
		{
			var style = new Gtk.CssProvider ();
			style.load_from_data ("* {background-color: %s;}".printf (color.to_string ()), -1);
			color_box.get_style_context ().add_provider (style, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
		}
		catch (Error e)
		{
			debug ("Internal error loading session chooser style: %s", e.message);
		}

		title = new Gtk.Label (data["title"]);
		title.get_style_context ().add_class ("text-bold");
		title.halign = Gtk.Align.START;
		title.margin_end = 10;
		title.set_line_wrap (true);
		title.hexpand = true;

		box.attach (color_box, 0, 0, 1, 1);
		box.attach (title, 1, 0, 1, 1);

		connect_button = new Gtk.ModelButton ();
		connect_button.text = _("Connect");

		var edit_button = new Gtk.ModelButton ();
		edit_button.text = _("Edit Connection");

		var delete_button = new Gtk.ModelButton ();
		delete_button.text = _("Delete Connection");

		var open_menu = new Gtk.MenuButton ();
		open_menu.set_image (new Gtk.Image.from_icon_name ("view-more-symbolic", Gtk.IconSize.SMALL_TOOLBAR));
		open_menu.get_style_context ().add_class ("library-btn");
		open_menu.tooltip_text = _("Options");

		var menu_separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
		menu_separator.margin_top = 6;
		menu_separator.margin_bottom = 6;

		var menu_grid = new Gtk.Grid ();
		menu_grid.expand = true;
		menu_grid.margin_top = 3;
		menu_grid.margin_bottom = 3;
		menu_grid.orientation = Gtk.Orientation.VERTICAL;

		menu_grid.attach (connect_button, 0, 1, 1, 1);
		menu_grid.attach (edit_button, 0, 2, 1, 1);
		menu_grid.attach (menu_separator, 0, 3, 1, 1);
		menu_grid.attach (delete_button, 0, 4, 1, 1);
		menu_grid.show_all ();

		var menu_popover = new Gtk.Popover (null);
		menu_popover.add (menu_grid);

		open_menu.popover = menu_popover;
		open_menu.relief = Gtk.ReliefStyle.NONE;
		open_menu.valign = Gtk.Align.CENTER;

		spinner = new Gtk.Spinner ();

		box.attach (spinner, 2, 0, 1, 1);
		box.attach (open_menu, 3, 0, 1, 1);

		var event_box = new Gtk.EventBox ();
		event_box.add (box);
		this.add (event_box);

		delete_button.clicked.connect (() => {
			confirm_delete (this, data);
		});

		edit_button.clicked.connect (() => {
			edit_dialog (data);
		});

		connect_button.clicked.connect (() => {
			spinner.start ();
			connect_button.sensitive = false;
			connect_to (data, spinner, connect_button);
		});

		event_box.enter_notify_event.connect ((event) => {
			box.set_state_flags (Gtk.StateFlags.PRELIGHT, true);
			return false;
		});

		event_box.leave_notify_event.connect ((event) => {
			if (event.detail != Gdk.NotifyType.INFERIOR) {
				box.set_state_flags (Gtk.StateFlags.NORMAL, true);
			}
			return false;
		});
	}
}