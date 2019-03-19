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
	private bool reloading { get; set; default = false;}

	public Gee.HashMap<int, string> schemas;
	private ulong handler_id;

	public Gtk.Stack stack;
	public Gtk.ScrolledWindow scroll;
	private Gda.DataModel? schema_table;
	public Granite.Widgets.SourceList.ExpandableItem tables_category;
	public Granite.Widgets.SourceList source_list;

	private Gtk.Grid toolbar;
	private Gtk.Spinner spinner;
	public Gtk.Revealer revealer;
	public Gtk.SearchEntry search;
	public string search_text;

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
		dropdown_area.column_homogeneous = false;
		dropdown_area.get_style_context ().add_class ("library-titlebar");

		var cell = new Gtk.CellRendererText ();

		schema_list = new Gtk.ListStore (1, typeof (string));
		schema_list.append (out iter);
		schema_list.set (iter, Column.SCHEMAS, _("- Select Database -"));

		schema_list_combo = new Gtk.ComboBox.with_model (schema_list);
		schema_list_combo.hexpand = true;
		schema_list_combo.pack_start (cell, false);
		schema_list_combo.set_attributes (cell, "text", Column.SCHEMAS);

		schema_list_combo.set_active (0);
		schema_list_combo.margin_top = 10;
		schema_list_combo.margin_bottom = 10;
		schema_list_combo.margin_start = 10;
		schema_list_combo.sensitive = false;

		handler_id = schema_list_combo.changed.connect (() => {
			if (schema_list_combo.get_active () == 0) {
				return;
			}
			start_spinner ();
			init_populate_schema (null);
		});

		var search_btn = new Sequeler.Partials.HeaderBarButton ("system-search-symbolic", _("Search Tables"));
		search_btn.clicked.connect (toggle_search_tables);

		dropdown_area.attach (schema_list_combo, 0, 0, 1, 1);
		dropdown_area.attach (search_btn, 1, 0, 1, 1);

		revealer = new Gtk.Revealer ();
		revealer.hexpand = true;
		revealer.reveal_child = false;

		search = new Gtk.SearchEntry ();
		search.placeholder_text = _("Search Tables\u2026");
		search.hexpand = true;
		search.margin = 10;
		search.search_changed.connect(on_search_tables);
		search.key_press_event.connect (key => {
			if (key.keyval == 65307) {
				search.set_text ("");
				toggle_search_tables ();
				return true;
			}
			return false;
		});
		revealer.add (search);

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
		add_table_btn.sensitive = false;

		spinner = new Gtk.Spinner ();
		spinner.hexpand = true;
		spinner.vexpand = true;
		spinner.halign = Gtk.Align.CENTER;
		spinner.valign = Gtk.Align.CENTER;
		spinner.start ();

		toolbar.attach (add_table_btn, 0, 0, 1, 1);
		toolbar.attach (new Gtk.Separator (Gtk.Orientation.VERTICAL), 1, 0, 1, 1);
		toolbar.attach (reload_btn, 2, 0, 1, 1);

		stack = new Gtk.Stack ();
		stack.hexpand = true;
		stack.vexpand = true;
		stack.add_named (scroll, "list");
		stack.add_named (spinner, "spinner");

		attach (dropdown_area, 0, 0, 1, 1);
		attach (revealer, 0, 1, 1, 1);
		attach (stack, 0, 2, 1, 2);
		attach (toolbar, 0, 4, 1, 1);

		start_spinner ();
	}

	public void start_spinner () {
		stack.visible_child_name = "spinner";
	}

	public void stop_spinner () {
		stack.visible_child_name = "list";
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
			start_spinner ();
			init_populate_schema (null);
		});
	}

	public void init_populate_schema (Gda.DataModel? schema) {
		var database = window.data_manager.data["type"] == "SQLite" ? null : schemas[schema_list_combo.get_active ()];

		populate_schema.begin (database, schema);
	}

	public async void reload_schema () {
		if (reloading) {
			debug ("still loading");
			return;
		}

		Gda.DataModel? schema = null;
		Gda.DataModelIter? _iter = null;
		reloading = true;

		get_schema.begin ((obj, res) => {
			new Thread<void*> ("reload-schema", () => {
				try {
					schema = get_schema.end (res);
				} catch (Error e) {
					reloading = false;
					return null;
				}
				
				Idle.add (() => {
					reset_schema_combo ();
					
					if (schema == null) {
						reloading = false;
						return false;
					}

					if (window.data_manager.data["type"] == "SQLite") {
						init_populate_schema (schema);
						reloading = false;
						return false;
					}
			
					_iter = schema.create_iter ();

					if (_iter == null) {
						debug ("not a valid iter");
						return true;
					}

					schemas = new Gee.HashMap<int, string> ();
					int i = 1;
					while (_iter.move_next ()) {
						schema_list.append (out iter);
						schema_list.set (iter, Column.SCHEMAS, _iter.get_value_at (0).get_string ());
						schemas.set (i,_iter.get_value_at (0).get_string ());
						i++;
					}
					if (window.data_manager.data["type"] != "PostgreSQL") {
						schema_list_combo.sensitive = true;
					}
			
					if (window.data_manager.data["type"] == "PostgreSQL") {
						foreach (var entry in schemas.entries) {
							if ("public" == entry.value) {
								schema_list_combo.set_active (entry.key);
							}
						}
						reloading = false;
						return false;
					}
			
					foreach (var entry in schemas.entries) {
						if (window.data_manager.data["name"] == entry.value) {
							schema_list_combo.set_active (entry.key);
						}
					}

					reloading = false;
					return false;
				});
				return null;
			});
		});
	}

	public async Gda.DataModel? get_schema () throws Error {
		Gda.DataModel? result = null;
		var query = (window.main.connection_manager.db_type as DataBaseType).show_schema ();

		result = yield window.main.connection_manager.init_select_query (query);

		if (result == null) {
			reloading = false;
			reset_schema_combo ();
		}

		return result;
	}

	public async void populate_schema (string? database, Gda.DataModel? schema) {
		yield clear_views ();

		if (database != null && window.data_manager.data["name"] != database && window.data_manager.data["type"] != "PostgreSQL") {
			window.data_manager.data["name"] = database;
			update_connection ();
			return;
		}

		if (database == null && window.data_manager.data["type"] == "SQLite" && schema != null) {
			schema_table = schema;
		} else {
			yield get_schema_table (database);
		}

		if (schema_table == null) {
			stop_spinner ();
			return;
		}

		if (scroll.get_child () != null) {
			scroll.remove (scroll.get_child ());
		}

		source_list = new Granite.Widgets.SourceList ();
		source_list.set_filter_func (source_list_visible_func, true);
		tables_category = new Granite.Widgets.SourceList.ExpandableItem (_("TABLES"));
		tables_category.expand_all ();

		Gda.DataModelIter _iter = schema_table.create_iter ();
		int top = 0;
		while (_iter.move_next ()) {
			var item = new Granite.Widgets.SourceList.Item (_iter.get_value_at (0).get_string ());
			item.editable = true;
			item.icon = new GLib.ThemedIcon ("drive-harddisk");
			item.edited.connect ((new_name) => {
				if (new_name != item.name) {
					edit_table_name (item.name, new_name);
				}
			});
			tables_category.add (item);
			top++;
		}

		source_list.root.add (tables_category);
		scroll.add (source_list);

		source_list.item_selected.connect (item => {
			if (item == null) {
				return;
			}

			if (window.main.database_view.tabs.selected == 0) {
				window.main.database_view.structure.fill (item.name, database);
			}

			if (window.main.database_view.tabs.selected == 1) {
				window.main.database_view.content.fill (item.name, database);
			}

			if (window.main.database_view.tabs.selected == 2) {
				window.main.database_view.relations.fill (item.name, database);
			}
		});

		window.main.database_view.structure.database = database;
		window.main.database_view.content.database = database;
		window.main.database_view.relations.database = database;
		stop_spinner ();
	}

	public async void get_schema_table (string table) {
		var query = (window.main.connection_manager.db_type as DataBaseType).show_table_list (table);

		schema_table = yield window.main.connection_manager.init_select_query (query);
	}

	private void update_connection () {
		if (window.data_manager.data["type"] == "PostgreSQL") {
			return;
		}

		schema_list_combo.sensitive = false;

		if (scroll.get_child () != null) {
			scroll.remove (scroll.get_child ());
		}

		if (window.main.connection_manager.connection != null && window.main.connection_manager.connection.is_opened ()) {
			window.main.connection_manager.connection.clear_events_list ();
			window.main.connection_manager.connection.close ();
		}

		var result = new Gee.HashMap<string, string> ();

		window.main.connection_manager.init_connection.begin ((obj, res) => {
			new Thread<void*> (null, () => {
				try {
					result = window.main.connection_manager.init_connection.end (res);
				} catch (ThreadError e) {
					window.main.connection_manager.query_warning (e.message);
				}

				Idle.add (() => {
					if (result["status"] == "true") {
						reload_schema.begin ();
					} else {
						window.main.connection_manager.query_warning (result["msg"]);
					}
					return false;
				});

				return null;
			});
		});
	}

	private void edit_table_name (string old_name, string new_name) {
		var query = (window.main.connection_manager.db_type as DataBaseType).edit_table_name (old_name, new_name);

		int result = 0;
		var error = "";

		window.main.connection_manager.init_query.begin (query, (obj, res) => {
			new Thread<void*> (null, () => {
				try {
					result = window.main.connection_manager.init_query.end (res);
				} catch (ThreadError e) {
					error = e.message;
					result = 0;
				}

				Idle.add (() => {
					if (error != "") {
						window.main.connection_manager.query_warning (error);
						return false;
					}
					reload_schema.begin ();
					return false;
				});

				return null;
			});
		});
	}

	public void toggle_search_tables () {
		revealer.reveal_child = ! revealer.get_reveal_child ();
		if (revealer.get_reveal_child ()) {
			search.grab_focus_without_selecting ();
		}

		search.text = "";
	}

	public void on_search_tables (Gtk.Entry searchentry) {
		search_text = searchentry.get_text ().down ();
		source_list.refilter ();
		tables_category.expand_all ();
	}

	private bool source_list_visible_func (Granite.Widgets.SourceList.Item item) {
		if (search_text == null || item is Granite.Widgets.SourceList.ExpandableItem) {
			return true;
		}

		return item.name.down ().contains (search_text);
	}

	private async void clear_views () {
		window.main.database_view.content.reset.begin ();
		window.main.database_view.relations.reset.begin ();
		window.main.database_view.structure.reset.begin ();
	}

	public void add_table () {
		
	}
}
