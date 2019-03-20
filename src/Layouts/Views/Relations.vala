/*
* Copyright (c) 2011-2019 Alecaddd (http://alecaddd.com)
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

public class Sequeler.Layouts.Views.Relations : Gtk.Grid {
	public weak Sequeler.Window window { get; construct; }

	public Gtk.Stack stack;
	public Gtk.Grid scroll_grid;
	public Gtk.ScrolledWindow scroll;
	public Gtk.Label result_message;
	private Gtk.Spinner spinner;

	private bool reloading { get; set; default = false; }

	private string _table_name = "";

	public string table_name {
		get { return _table_name; }
		set { _table_name = value; }
	}

	private string _database = "";

	public string database {
		get { return _database; }
		set { _database = value; }
	}

	public Relations (Sequeler.Window main_window) {
		Object (
			orientation: Gtk.Orientation.VERTICAL,
			window: main_window
		);
	}

	construct {
		scroll_grid = new Gtk.Grid ();
		scroll_grid.expand = true;

		scroll = new Gtk.ScrolledWindow (null, null);
		scroll.hscrollbar_policy = Gtk.PolicyType.AUTOMATIC;
		scroll.vscrollbar_policy = Gtk.PolicyType.AUTOMATIC;
		scroll.expand = true;

		var info_bar = new Gtk.Grid ();
		info_bar.get_style_context ().add_class ("library-toolbar");
		info_bar.attach (build_results_msg (), 0, 0, 1, 1);
		info_bar.attach (build_reload_btn (), 1, 0, 1, 1);

		spinner = new Gtk.Spinner ();
		spinner.hexpand = true;
		spinner.vexpand = true;
		spinner.halign = Gtk.Align.CENTER;
		spinner.valign = Gtk.Align.CENTER;
		spinner.start ();

		var welcome = new Granite.Widgets.Welcome (_("Select Table"), _("Select a table from the left sidebar to activate this view."));

		stack = new Gtk.Stack ();
		stack.hexpand = true;
		stack.vexpand = true;
		stack.add_named (welcome, "welcome");
		stack.add_named (spinner, "spinner");
		stack.add_named (scroll_grid, "list");

		attach (stack, 0, 0, 1, 1);
		attach (info_bar, 0, 1, 1, 1);

		placeholder ();
	}

	public void placeholder () {
		stack.visible_child_name = "welcome";
	}

	public void start_spinner () {
		stack.visible_child_name = "spinner";
	}

	public void stop_spinner () {
		stack.visible_child_name = "list";
	}

	public Gtk.Label build_results_msg () {
		result_message = new Gtk.Label (_("No Results Available"));
		result_message.halign = Gtk.Align.START;
		result_message.margin = 7;
		result_message.margin_top = 6;
		result_message.hexpand = true;
		result_message.wrap = true;

		return result_message;
	}

	private Gtk.Button build_reload_btn () {
		var reload_btn = new Sequeler.Partials.HeaderBarButton ("view-refresh-symbolic", _("Reload Results"));
		reload_btn.clicked.connect (reload_results);
		reload_btn.halign = Gtk.Align.END;

		return reload_btn;
	}

	public async void clear () {
		if (scroll == null) {
			return;
		}

		scroll.destroy ();

		scroll = new Gtk.ScrolledWindow (null, null);
		scroll.hscrollbar_policy = Gtk.PolicyType.AUTOMATIC;
		scroll.vscrollbar_policy = Gtk.PolicyType.AUTOMATIC;
		scroll.expand = true;

		scroll_grid.add (scroll);
	}

	public async void reset () {
		if (scroll.get_child () != null) {
			scroll.remove (scroll.get_child ());
		}

		result_message.label = _("No Results Available");
		table_name = "";
		database = "";
		placeholder ();
	}

	public void fill (string? table, string? db_name = null) {
		if (table == null) {
			return;
		}

		if (table == _table_name && db_name == _database) {
			return;
		}

		table_name = table;
		database = db_name;

		get_content_and_fill.begin ();
	}

	public void reload_results () {
		if (table_name == "") {
			return;
		}

		get_content_and_fill.begin ();
	}

	public async void get_content_and_fill () {
		if (reloading) {
			debug ("still loading");
			return;
		}

		start_spinner ();
		var query = (window.main.connection_manager.db_type as DataBaseType).show_table_relations (table_name, database);
		reloading = true;

		var table_relations = yield get_table_relations (query);

		if (table_relations == null) {
			return;
		}

		var result_data = new Sequeler.Partials.TreeBuilder (table_relations, window);
		result_message.label = table_relations.get_n_rows ().to_string () + _(" Constraints");

		yield clear ();

		scroll.add (result_data);
		scroll.show_all ();
		reloading = false;

		stop_spinner ();
	}

	private async Gda.DataModel? get_table_relations (string query) {
		Gda.DataModel? result = null;

		result = yield window.main.connection_manager.init_select_query (query);

		if (result == null) {
			reloading = false;
			yield reset ();
		}

		return result;
	}
}
