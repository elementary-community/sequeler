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

public class Sequeler.Layouts.DataBaseSchema : Gtk.Grid {
	public weak Sequeler.Window window { get; construct; }

	public Gtk.ListStore schema_list;
	public Gtk.ComboBox schema_list_combo;
	public Gtk.TreeIter iter;

	public Gee.HashMap<int, string> schemas;
	private ulong handler_id;

	private Gtk.ScrolledWindow scroll;
	private Gda.DataModel? schema_table;
	public Granite.Widgets.SourceList source_list;

	private Gtk.Grid toolbar;
	private Gtk.Spinner toolbar_spinner;

	enum Column {
		SCHEMAS
	}

	public DataBaseSchema (Sequeler.Window main_window) {
		Object (
			orientation: Gtk.Orientation.VERTICAL,
			window: main_window,
			column_homogeneous: true
		);
	}

	construct {
		var dropdown_area = new Gtk.Grid ();
		dropdown_area.column_homogeneous = true;
		dropdown_area.get_style_context ().add_class ("library-titlebar");

		var cell = new Gtk.CellRendererText ();

		schema_list = new Gtk.ListStore (1, typeof (string));
		schema_list.append (out iter);
		schema_list.set (iter, Column.SCHEMAS, _("- Select Database -"));

		schema_list_combo = new Gtk.ComboBox.with_model (schema_list);
		schema_list_combo.pack_start (cell, false);
		schema_list_combo.set_attributes (cell, "text", Column.SCHEMAS);

		schema_list_combo.set_active (0);
		schema_list_combo.margin = 10;
		schema_list_combo.sensitive = false;

		handler_id = schema_list_combo.changed.connect (() => {
			if (schema_list_combo.get_active () == 0) {
				return;
			}
			populate_schema (schemas[schema_list_combo.get_active ()], null);
		});

		dropdown_area.attach (schema_list_combo, 0, 0, 1, 1);

		scroll = new Gtk.ScrolledWindow (null, null);
		scroll.hscrollbar_policy = Gtk.PolicyType.AUTOMATIC;
		scroll.vscrollbar_policy = Gtk.PolicyType.AUTOMATIC;
		scroll.vexpand = true;

		toolbar = new Gtk.Grid ();
		toolbar.get_style_context ().add_class ("library-toolbar");

		var reload_btn = new Sequeler.Partials.HeaderBarButton ("view-refresh-symbolic", _("Reload Tables"));
		reload_btn.clicked.connect (reload_schema);
		reload_btn.hexpand = true;
		reload_btn.halign = Gtk.Align.START;

		var add_table_btn = new Sequeler.Partials.HeaderBarButton ("list-add-symbolic", _("Add Table"));
		add_table_btn.clicked.connect (add_table);

		toolbar_spinner = new Gtk.Spinner ();
		toolbar_spinner.margin = 3;

		toolbar.attach (add_table_btn, 0, 0, 1, 1);
		toolbar.attach (new Gtk.Separator (Gtk.Orientation.VERTICAL), 1, 0, 1, 1);
		toolbar.attach (reload_btn, 2, 0, 1, 1);
		toolbar.attach (toolbar_spinner, 3, 0, 1, 1);

		attach (dropdown_area, 0, 0, 1, 1);
		attach (scroll, 0, 1, 1, 2);
		attach (toolbar, 0, 3, 1, 1);
	}

	private void reset_schema_combo () {
		schema_list_combo.disconnect (handler_id);

		schema_list.clear ();
		schema_list.append (out iter);
		schema_list.set (iter, Column.SCHEMAS, _("- Select Database -"));
		schema_list_combo.set_active (0);
		schema_list_combo.sensitive = false;

		handler_id = schema_list_combo.changed.connect (() => {
			if (schema_list_combo.get_active () == 0) {
				return;
			}
			populate_schema (schemas[schema_list_combo.get_active ()], null);
		});
	}

	public void reload_schema () {
		var schema = get_schema ();
		reset_schema_combo ();
		
		if (schema == null) {
			return;
		}

		if (window.data_manager.data["type"] == "SQLite") {
			populate_schema (null, schema);
			return;
		}

		Gda.DataModelIter _iter = schema.create_iter ();
		schemas = new Gee.HashMap<int, string> ();
		int i = 1;
		while (_iter.move_next ()) {
			schema_list.append (out iter);
			schema_list.set (iter, Column.SCHEMAS, _iter.get_value_at (0).get_string ());
			schemas.set (i,_iter.get_value_at (0).get_string ());
			i++;
		}

		schema_list_combo.sensitive = true;

		foreach (var entry in schemas.entries) {
			if (window.data_manager.data["name"] == entry.value) {
				schema_list_combo.set_active (entry.key);
			}
		}
	}

	public Gda.DataModel? get_schema () {
		var query = (window.main.connection.db_type as DataBaseType).show_schema ();

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

	public void populate_schema (string? database, Gda.DataModel? schema) {
		if (database != null && window.data_manager.data["name"] != database) {
			window.data_manager.data["name"] = database;
			update_connection ();
			return;
		}

		if (database == null && window.data_manager.data["type"] == "SQLite" && schema != null) {
			schema_table = schema;
		} else {
			schema_table = get_schema_table (database);
		}

		if (schema_table == null) {
			return;
		}

		if (scroll.get_child () != null) {
			scroll.remove (scroll.get_child ());
		}

		source_list = new Granite.Widgets.SourceList ();
		var tables_category = new Granite.Widgets.SourceList.ExpandableItem (_("TABLES"));
		tables_category.expand_all ();

		Gda.DataModelIter _iter = schema_table.create_iter ();
		int top = 0;
		while (_iter.move_next ()) {
			var item = new Granite.Widgets.SourceList.Item (_iter.get_value_at (0).get_string ());
			item.editable = true;
			item.edited.connect ((new_name) => { 
				edit_table_name (item.name, new_name);
			});
			tables_category.add (item);      
			top++;
		}

		source_list.root.add (tables_category);
		scroll.add (source_list);

		source_list.item_selected.connect ((item) => {
			if (item == null) {
				return;
			}
			
		});
	}

	public Gda.DataModel? get_schema_table (string table) {
		var query = (window.main.connection.db_type as DataBaseType).show_table_list (table);

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

	private void update_connection () {
		schema_list_combo.sensitive = false;

		if (scroll.get_child () != null) {
			scroll.remove (scroll.get_child ());
		}

		toolbar_spinner.start ();

		window.main.connection.close ();
		var new_connection = new Sequeler.Services.ConnectionManager (window.data_manager.data);

		var loop = new MainLoop ();
		new_connection.init_connection.begin (new_connection, (obj, res) => {
			try {
				Gee.HashMap<string, string> result = new_connection.init_connection.end (res);
				if (result["status"] == "true") {
					window.main.connection = new_connection;
					reload_schema ();
				} else {
					window.main.connection.query_warning (result["msg"]);
				}
			} catch (ThreadError e) {
				window.main.connection.query_warning (e.message);
			}
			loop.quit ();
		});

		loop.run();
		toolbar_spinner.stop ();
	}

	private void edit_table_name (string old_name, string new_name) {
		var query = (window.main.connection.db_type as DataBaseType).edit_table_name (old_name, new_name);

		int result = 0;
		var error = "";

		var loop = new MainLoop ();
		window.main.connection.init_query.begin (query, (obj, res) => {
			try {
				result = window.main.connection.init_query.end (res);
			} catch (ThreadError e) {
				error = e.message;
				result = 0;
			}
			loop.quit ();
		});

		loop.run ();

		if (error != "") {
			window.main.connection.query_warning (error);
			return;
		}

		reload_schema ();
	}

	public void add_table () {

	}
}