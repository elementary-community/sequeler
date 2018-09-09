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

public class Sequeler.Layouts.Views.Query : Gtk.Grid {
	public weak Sequeler.Window window { get; construct; }

	public Gtk.SourceBuffer buffer;
	public Gtk.ScrolledWindow scroll_results;
	public Gtk.Spinner spinner;
	public Gtk.Label loading_msg;
	public Gtk.Label result_message;
	public Gtk.Image icon_success;
	public Gtk.Image icon_fail;
	public Gtk.Button run_button;
	public Gtk.MenuButton export_button;

	public Sequeler.Partials.TreeBuilder result_data;

	public Query (Sequeler.Window main_window) {
		Object (
			orientation: Gtk.Orientation.VERTICAL,
			window: main_window
		);
	}

	construct {
		var panels = new Gtk.Paned (Gtk.Orientation.VERTICAL);
		panels.position = 150;
		panels.expand = true;

		attach (panels, 0, 0, 1, 1);

		var scroll = new Gtk.ScrolledWindow (null, null);
		scroll.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
		scroll.add (query_builder ());

		panels.pack1 (scroll, false, false);
		panels.pack2 (results_view (), true, false);
	}

	public Gtk.SourceView query_builder () {
		var manager = Gtk.SourceLanguageManager.get_default ();
		var style_scheme_manager = new Gtk.SourceStyleSchemeManager ();

		buffer = new Gtk.SourceBuffer (null);
		buffer.highlight_syntax = true;
		buffer.highlight_matching_brackets = true;
		buffer.style_scheme = style_scheme_manager.get_scheme ("oblivion");
		buffer.language = manager.get_language ("sql");

		var query_builder = new Gtk.SourceView.with_buffer (buffer);
		query_builder.show_line_numbers = true;
		query_builder.highlight_current_line = true;
		query_builder.show_right_margin = false;
		query_builder.wrap_mode = Gtk.WrapMode.WORD;
		query_builder.smart_home_end = Gtk.SourceSmartHomeEndType.AFTER;

		Gtk.drag_dest_add_uri_targets (query_builder);

		try
		{
			var style = new Gtk.CssProvider ();
			var font_name = new GLib.Settings ("org.gnome.desktop.interface").get_string ("monospace-font-name");
			style.load_from_data ("* {font-family: '%s';}".printf (font_name), -1);
			query_builder.get_style_context ().add_provider (style, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
		}
		catch (Error e)
		{
			debug ("Internal error loading session chooser style: %s", e.message);
		}

		return query_builder;
	}

	/**
	 * Get the text buffer based on user cursor, selection, and semicolon
	 */
	public string get_text () {
		Gtk.TextIter start, end;

		// If a portion of text is selected
		if (buffer.get_selection_bounds (out start, out end)) {
			debug (buffer.get_text (start, end, true).strip ());
			return buffer.get_text (start, end, true).strip ();
		}

		// If there's a semicolon, return the currently highlighted line
		if (buffer.text.contains (";")) {
			buffer.get_selection_bounds (out start, out end);
			start.set_line_offset (0);
			start.backward_find_char (is_semicolon, null);
			if (! start.starts_line ()) {
				start.forward_char ();
			}

			if (end.starts_line ()) {
				end.backward_char ();
			} else if (!end.ends_line ()) {
				end.forward_to_line_end ();
			}

			debug (buffer.get_text (start, end, true).strip ());
			return buffer.get_text (start, end, true).strip ();
		}

		// Return full text
		debug (buffer.text.strip ());
		return buffer.text.strip ();
	}

	public Gtk.Grid results_view () {
		var results_view = new Gtk.Grid ();

		spinner = new Gtk.Spinner ();
		spinner.hexpand = true;
		spinner.halign = Gtk.Align.END;
		spinner.margin = 10;

		var action_bar = new Gtk.Grid ();
		action_bar.get_style_context ().add_class ("library-titlebar");
		action_bar.attach (build_loading_msg (), 0, 0, 1, 1);
		action_bar.attach (spinner, 1, 0, 1, 1);
		action_bar.attach (build_run_button (), 2, 0, 1, 1);

		scroll_results = new Gtk.ScrolledWindow (null, null);
		scroll_results.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
		scroll_results.expand = true;

		var info_bar = new Gtk.Grid ();
		info_bar.get_style_context ().add_class ("library-toolbar");
		info_bar.attach (build_results_msg (), 0, 0, 1, 1);
		info_bar.attach (build_export_btn (), 1, 0, 1, 1);

		results_view.attach (action_bar, 0, 0, 1, 1);
		results_view.attach (scroll_results, 0, 1, 1, 1);
		results_view.attach (info_bar, 0, 2, 1, 1);

		return results_view;
	}

	public Gtk.Label build_loading_msg () {
		loading_msg = new Gtk.Label (_("Running Query\u2026"));
		loading_msg.halign = Gtk.Align.START;
		loading_msg.margin = 10;
		loading_msg.hexpand = true;
		loading_msg.wrap = true;
		toggle_loading_msg (false);

		return loading_msg;
	}

	public void toggle_loading_msg (bool toggle) {
		loading_msg.visible = toggle;
		loading_msg.no_show_all = !toggle;
	}

	public Gtk.Button build_run_button () {
		var run_image = new Gtk.Image.from_icon_name ("system-run-symbolic", Gtk.IconSize.BUTTON);
		run_button = new Gtk.Button.with_label (_("Run Query"));
		run_button.get_style_context ().add_class ("suggested-action");
		run_button.always_show_image = true;
		run_button.set_image (run_image);
		run_button.can_focus = false;
		run_button.margin = 10;
		run_button.sensitive = false;
		run_button.tooltip_text = "Ctrl+↵";

		run_button.action_name = Sequeler.Services.ActionManager.ACTION_PREFIX + Sequeler.Services.ActionManager.ACTION_RUN_QUERY;

		return run_button;
	}

	public Gtk.Grid build_results_msg () {
		var result_box = new Gtk.Grid ();

		icon_success = new Gtk.Image.from_icon_name ("process-completed-symbolic", Gtk.IconSize.BUTTON);
		icon_success.margin_start = 7;
		icon_success.visible = false;
		icon_success.no_show_all = true;

		icon_fail = new Gtk.Image.from_icon_name ("dialog-error-symbolic", Gtk.IconSize.BUTTON);
		icon_fail.margin_start = 7;
		icon_fail.visible = false;
		icon_fail.no_show_all = true;

		result_message = new Gtk.Label (_("No Results Available"));
		result_message.halign = Gtk.Align.START;
		result_message.margin = 7;
		result_message.margin_top = 6;
		result_message.hexpand = true;
		result_message.wrap = true;

		result_box.attach (icon_success, 0, 0, 1, 1);
		result_box.attach (icon_fail, 1, 0, 1, 1);
		result_box.attach (result_message, 2, 0, 1, 1);

		return result_box;
	}

	public void show_result_icon (bool status) {
		if (status) {
			icon_success.visible = true;
			icon_success.no_show_all = false;
			icon_fail.visible = false;
			icon_fail.no_show_all = true;
			return;
		}

		icon_success.visible = false;
		icon_success.no_show_all = true;
		icon_fail.visible = true;
		icon_fail.no_show_all = false;
	}

	public Gtk.Button build_export_btn () {
		var export_image = new Gtk.Image.from_icon_name ("document-save-symbolic", Gtk.IconSize.BUTTON);
		export_button = new Gtk.MenuButton ();
		export_button.label = _("Export Results");
		export_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
		export_button.always_show_image = true;
		export_button.set_image (export_image);
		export_button.can_focus = false;

		var menu_grid = new Gtk.Grid ();
		menu_grid.expand = true;
		menu_grid.margin_top = 3;
		menu_grid.margin_bottom = 3;
		menu_grid.orientation = Gtk.Orientation.VERTICAL;

		var export_sql = new Gtk.ModelButton ();
		export_sql.image = new Gtk.Image.from_icon_name ("office-database", Gtk.IconSize.BUTTON);
		export_sql.label = (_("Export as SQL"));
		export_sql.always_show_image = true;

		var export_csv = new Gtk.ModelButton ();
		export_csv.label = _("Export as CSV");
		export_csv.image = new Gtk.Image.from_icon_name ("x-office-spreadsheet", Gtk.IconSize.BUTTON);
		export_csv.always_show_image = true;

		var export_text = new Gtk.ModelButton ();
		export_text.label = _("Export as Text");
		export_text.image = new Gtk.Image.from_icon_name ("text-x-generic", Gtk.IconSize.BUTTON);
		export_text.always_show_image = true;

		menu_grid.attach (export_sql, 0, 1, 1, 1);
		menu_grid.attach (export_csv, 0, 2, 1, 1);
		menu_grid.attach (export_text, 0, 3, 1, 1);
		menu_grid.show_all ();

		var export_menu = new Gtk.Popover (null);
		export_menu.add (menu_grid);

		export_button.popover = export_menu;
		export_button.direction = Gtk.ArrowType.UP;
		export_button.sensitive = false;

		return export_button;
	}

	public void run_query (string query) {
		toggle_loading_msg (true);
		spinner.start ();

		var select_pos = query.down ().index_of ("select", 0);
		var show_pos = query.down ().index_of ("show", 0);

		if (select_pos == 0 || show_pos == 0) {
			handle_select_response (select_statement (query));
		} else {
			handle_query_response (non_select_statement (query));
		}
	}

	public Gda.DataModel? select_statement (string query) {
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

		return result;
	}

	public int? non_select_statement (string query) {
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
		}

		if (result == 0 || result == -1) {
			toggle_loading_msg (false);
			spinner.stop ();

			result_message.label = error;
			show_result_icon (false);

			return null;
		}

		return result;
	}

	public void handle_select_response (Gda.DataModel? response) {
		if (response == null) {
			toggle_loading_msg (false);
			spinner.stop ();

			result_message.label = _("Unable to process Query!");
			show_result_icon (false);

			export_button.sensitive = false;
			return;
		}

		if (result_data != null) {
			scroll_results.remove (result_data);
			result_data = null;
		}

		result_data = new Sequeler.Partials.TreeBuilder (response, window);

		toggle_loading_msg (false);
		spinner.stop ();

		result_message.label = _("%d Total Results").printf (response.get_n_rows ());
		show_result_icon (true);

		scroll_results.add (result_data);
		scroll_results.show_all ();

		if (response.get_n_rows () == 0) {
			export_button.sensitive = false;
		} else {
			export_button.sensitive = true;
		}
	}

	public void handle_query_response (int? response) {
		toggle_loading_msg (false);
		spinner.stop ();

		if (result_data != null) {
			scroll_results.remove (result_data);
			result_data = null;
		}

		if (response == null) {
			result_message.label = _("Unable to process Query!");
			show_result_icon (false);
			return;
		}

		if (response > 0) {
			result_message.label = _("Query Successfully Executed! Rows Affected: ") + response.to_string ();
			show_result_icon (true);
		} else {
			result_message.label = _("Query Executed!");
			show_result_icon (true);
		}

		window.main.database_schema.reload_schema ();

		// Force reset all views to fetch updated data
		window.main.database_view.content.reset ();
		window.main.database_view.relations.reset ();
		window.main.database_view.structure.reset ();
	}

	private bool is_semicolon (unichar semicolon) {
		return semicolon.to_string () == ";";
	}
}
