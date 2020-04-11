/*
 * Copyright (c) 2017-2020 Alecaddd (https://alecaddd.com)
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
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

    public Gtk.SourceView query_builder;
    public Gtk.SourceBuffer buffer;
    public Gtk.SourceBuffer buffer_copy;
    public Gtk.SourceStyleSchemeManager style_scheme_manager;
    public Gtk.CssProvider style_provider;
    private Gtk.Revealer error_revealer;
    private Gtk.Label error_message;
    public Gtk.ScrolledWindow scroll_results;
    public Gtk.Spinner spinner;
    public Gtk.Label loading_msg;
    public Gtk.Label result_message;
    public Gtk.Image icon_success;
    public Gtk.Image icon_fail;
    public Gtk.Button run_button;
    public Gtk.MenuButton export_button;
    private string font;
    public string default_font { get; set; }

    GLib.File? file;
    Gda.DataModel? response_data;

    public Gtk.Paned panels;
    public Sequeler.Partials.TreeBuilder result_data;

    public signal void update_tab_indicator (bool status);

    public Query (Sequeler.Window main_window) {
        Object (
            orientation: Gtk.Orientation.VERTICAL,
            window: main_window
        );
    }

    construct {
        default_font = new GLib.Settings ("org.gnome.desktop.interface").get_string ("monospace-font-name");

        panels = new Gtk.Paned (Gtk.Orientation.VERTICAL);
        panels.position = settings.query_area;
        panels.expand = true;

        attach (panels, 0, 0, 1, 1);

        var scroll = new Gtk.ScrolledWindow (null, null);
        scroll.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
        build_query_builder ();
        scroll.add (query_builder);

        panels.pack1 (scroll, false, false);
        panels.pack2 (results_view (), true, false);
    }

    public void use_default_font (bool value) {
        if (!value) {
            return;
        }

        font = default_font;
    }

    public void build_query_builder () {
        var manager = Gtk.SourceLanguageManager.get_default ();
        style_provider = new Gtk.CssProvider ();
        style_scheme_manager = new Gtk.SourceStyleSchemeManager ();

        buffer = new Gtk.SourceBuffer (null);
        buffer.highlight_syntax = true;
        buffer.highlight_matching_brackets = true;
        buffer.language = manager.get_language ("sql");

        query_builder = new Gtk.SourceView.with_buffer (buffer);
        query_builder.show_line_numbers = true;
        query_builder.highlight_current_line = true;
        query_builder.show_right_margin = false;
        query_builder.wrap_mode = Gtk.WrapMode.WORD;
        query_builder.smart_home_end = Gtk.SourceSmartHomeEndType.AFTER;

        Gtk.drag_dest_add_uri_targets (query_builder);

        update_font_style ();
        update_color_style ();
    }

    private string get_current_font_family () {
        return font.substring (0, font.last_index_of (" "));
    }

    private double get_current_font_size () {
        return double.parse (font.substring (font.last_index_of (" ") + 1));
    }

    public void update_font_style () {
        font = Sequeler.settings.font;
        use_default_font (Sequeler.settings.use_system_font);
        var font_family = get_current_font_family ();
        var font_size = get_current_font_size ().to_string ();

        try {
            style_provider.load_from_data ("
                * {
                    font-family: '%s';
                    font-size: %spx;
                }".printf (font_family, font_size), -1);
            query_builder.get_style_context ().add_provider (
                style_provider,
                Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
            );
        } catch (Error e) {
            debug ("Internal error loading session chooser style: %s", e.message);
        }
    }

    public void update_color_style () {
        buffer.style_scheme = style_scheme_manager.get_scheme (Sequeler.settings.style_scheme);
    }

    /**
     * Get the text buffer based on user cursor, selection, and semicolon
     */
    public string get_text () {
        Gtk.TextIter start, end;

        // If a portion of text is selected
        if (buffer.get_selection_bounds (out start, out end)) {
            strip_comments (buffer.get_text (start, end, true).strip ());
            return buffer_copy.text.strip ();
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
            }

            if (!end.ends_line ()) {
                end.forward_to_line_end ();
            }

            end.forward_find_char (is_semicolon, null);

            debug (buffer.get_text (start, end, true).strip ());
            strip_comments (buffer.get_text (start, end, true).strip ());
            return buffer_copy.text.strip ();
        }

        // Return full text
        strip_comments ();
        debug (buffer_copy.text.strip ());
        return buffer_copy.text.strip ();
    }

    /**
     * Remove inline comments (//) and block comments (/*)
     */
    public void strip_comments (string? source_text = null) {
        var text = source_text != null ? source_text : buffer.text;
        buffer_copy = new Gtk.SourceBuffer (null);
        buffer_copy.set_text (text);

        string[] lines = Regex.split_simple ("""[\r\n]""", text);
        if (lines.length != buffer_copy.get_line_count ()) {
            warning ("Mismatch between line counts when stripping trailing spaces, not continuing");
            return;
        }

        MatchInfo info;
        Gtk.TextIter start_delete, end_delete;
        Regex comments;

        try {
            comments = new Regex ("""\/\*[\s\S]*?\*\/|([^:]|^)\/\/.*$""", 0);
        } catch (RegexError e) {
            critical ("Error while building regex to replace trailing whitespace: %s", e.message);
            return;
        }

        // Find comments line by line
        for (int line_no = 0; line_no < lines.length; line_no++) {
            if (comments.match (lines[line_no], 0, out info)) {
                buffer_copy.get_iter_at_line (out start_delete, line_no);
                start_delete.forward_to_line_end ();
                end_delete = start_delete;
                end_delete.backward_chars (info.fetch (0).length);

                buffer_copy.@delete (ref start_delete, ref end_delete);
            }
        }

        int start_pos, end_pos;

        // Find leftover comment blocks
        if (comments.match (text, 0, out info)) {
            info.fetch_pos (0, out start_pos, out end_pos);
            buffer_copy.get_iter_at_offset (out start_delete, start_pos);
            end_delete = start_delete;
            end_delete.forward_chars (info.fetch (0).length);

            buffer_copy.@delete (ref start_delete, ref end_delete);
        }
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

        error_revealer = new Gtk.Revealer ();

        var error_grid = new Gtk.Grid ();
        error_grid.get_style_context ().add_class ("query-error");
        error_grid.hexpand = true;
        error_grid.margin = 6;

        error_message = new Gtk.Label ("");
        error_message.wrap = true;
        error_message.margin = 6;
        error_grid.add (error_message);

        error_revealer.add (error_grid);
        error_revealer.reveal_child = false;

        var info_bar = new Gtk.Grid ();
        info_bar.get_style_context ().add_class ("library-toolbar");
        info_bar.attach (build_results_msg (), 0, 0, 1, 1);
        info_bar.attach (build_export_btn (), 1, 0, 1, 1);

        results_view.attach (action_bar, 0, 0, 1, 1);
        results_view.attach (error_revealer, 0, 1, 1, 1);
        results_view.attach (scroll_results, 0, 2, 1, 1);
        results_view.attach (info_bar, 0, 3, 1, 1);

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
		run_button = new Sequeler.Widgets.RunQueryButton ();
        run_button.action_name = Services.ActionManager.ACTION_PREFIX + Services.ActionManager.ACTION_RUN_QUERY;

        return run_button;
    }

    public Gtk.Grid build_results_msg () {
        var result_box = new Gtk.Grid ();

        icon_success = new Gtk.Image.from_icon_name ("process-completed-symbolic", Gtk.IconSize.BUTTON);
        icon_success.margin_start = 6;
        icon_success.visible = false;
        icon_success.no_show_all = true;

        icon_fail = new Gtk.Image.from_icon_name ("dialog-error-symbolic", Gtk.IconSize.BUTTON);
        icon_fail.margin_start = 6;
        icon_fail.visible = false;
        icon_fail.no_show_all = true;

        result_message = new Gtk.Label (_("No Results Available"));
        result_message.halign = Gtk.Align.START;
        result_message.margin = 6;
        result_message.margin_top = 6;
        result_message.hexpand = true;
        result_message.wrap = true;

        result_box.attach (icon_success, 0, 0, 1, 1);
        result_box.attach (icon_fail, 1, 0, 1, 1);
        result_box.attach (result_message, 2, 0, 1, 1);

        return result_box;
    }

    public void show_result_icon (bool status) {
        update_tab_indicator (status);
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

        var export_csv = new Gtk.ModelButton ();
        export_csv.label = _("Export as CSV");
        export_csv.image = new Gtk.Image.from_icon_name ("x-office-spreadsheet", Gtk.IconSize.BUTTON);
        export_csv.always_show_image = true;
        export_csv.clicked.connect (() => {
            export_results (1);
        });

        var export_text = new Gtk.ModelButton ();
        export_text.label = _("Export as Text");
        export_text.image = new Gtk.Image.from_icon_name ("text-x-generic", Gtk.IconSize.BUTTON);
        export_text.always_show_image = true;
        export_text.clicked.connect (() => {
            export_results (2);
        });

        menu_grid.attach (export_csv, 0, 1, 1, 1);
        menu_grid.attach (export_text, 0, 2, 1, 1);
        menu_grid.show_all ();

        var export_menu = new Gtk.Popover (null);
        export_menu.add (menu_grid);

        export_button.popover = export_menu;
        export_button.direction = Gtk.ArrowType.UP;
        export_button.sensitive = false;

        return export_button;
    }

	public void run_query (string query) {
		Gda.Set params;
		Gda.Statement statement = window.main.connection_manager.parse_sql_string (query, out params);

		if (params != null) {
			for (int i = 0; ; i++) {
				var holder = params.get_nth_holder (i);
				if (holder == null) {
					break;
				}
				debug ("holder #%d is %s type: %s", i, holder.get_id (), holder.get_g_type().name ());
			}
			var params_dialog = new Sequeler.Widgets.QueryParamsDialog (window, this, query, statement, params);
			params_dialog.set_modal (true);
			params_dialog.show_all ();
		}
		else {
			run_query_statement (query, statement, null);
		}
	}

    public void run_query_statement (string query, Gda.Statement statement, Gda.Set? params) {
        toggle_loading_msg (true);
        spinner.start ();

        var select_pos = query.down ().index_of ("select", 0);
        var show_pos = query.down ().index_of ("show", 0);
        var pragma_pos = query.down ().index_of ("pragma", 0);
        var explain_pos = query.down ().index_of ("explain", 0);

		if (select_pos == 0 || show_pos == 0 || pragma_pos == 0 || explain_pos == 0) {
			select_statement.begin (statement, params, (obj, res) => {
				handle_select_response (select_statement.end (res));
			});
		} else {
			non_select_statement.begin (statement, params, (obj, res) => {
				handle_query_response (non_select_statement.end (res));
			});
		}
    }

    private async Gee.HashMap<Gda.DataModel?, string> select_statement (Gda.Statement statement, Gda.Set? params) {
        return yield window.main.connection_manager.init_silent_select_statement (statement, params);
    }

    public async Gee.HashMap<string?, string> non_select_statement (Gda.Statement statement, Gda.Set? params) {
        return yield window.main.connection_manager.init_silent_statement (statement, params);
    }

    public void handle_select_response (Gee.HashMap<Gda.DataModel?, string> response) {
        foreach (var entry in response.entries) {
            response_data = entry.key;
            on_query_error (entry.value);
        }

        if (response_data == null) {
            toggle_loading_msg (false);
            spinner.stop ();

            result_message.label = _("Unable to process Query!");
            show_result_icon (false);

            export_button.sensitive = false;
            return;
        }

        if (error_revealer.get_reveal_child ()) {
            error_revealer.reveal_child = false;
        }

        if (result_data != null) {
            scroll_results.remove (result_data);
            result_data = null;
        }

        result_data = new Sequeler.Partials.TreeBuilder (response_data, window);

        toggle_loading_msg (false);
        spinner.stop ();

        result_message.label = _("%d Total Results").printf (response_data.get_n_rows ());
        show_result_icon (true);

        scroll_results.add (result_data);
        scroll_results.show_all ();

        export_button.sensitive = response_data.get_n_rows () == 0 ? false : true;
    }

    public void handle_query_response (Gee.HashMap<string?, string> data) {
        string? response = null;
        foreach (var entry in data.entries) {
            response = entry.key;
            on_query_error (entry.value);
        }

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

        if (error_revealer.get_reveal_child ()) {
            error_revealer.reveal_child = false;
        }

        if (int.parse (response) > 0) {
            result_message.label = _("Query Successfully Executed! Rows Affected: %s").printf (response);
            show_result_icon (true);
        } else {
            result_message.label = _("Query Executed!");
            show_result_icon (true);
        }

        window.main.database_schema.reload_schema.begin ();

        // Force reset all views to fetch updated data
        window.main.database_view.content.reset.begin ();
        window.main.database_view.relations.reset.begin ();
        window.main.database_view.structure.reset.begin ();
    }

    private void on_query_error (string error) {
        if (error == "") {
            return;
        }

        if (result_data != null) {
            scroll_results.remove (result_data);
            result_data = null;
        }

        error_message.label = error;
        error_revealer.reveal_child = true;
    }

    private bool is_semicolon (unichar semicolon) {
        return semicolon.to_string () == ";";
    }

    private void export_results (int type) {
        file = null;

        var save_dialog = new Gtk.FileChooserNative (_("Pick a file"),
                                                     window,
                                                     Gtk.FileChooserAction.SAVE,
                                                     _("_Save"),
                                                     _("_Cancel"));

        save_dialog.do_overwrite_confirmation = true;
        save_dialog.modal = true;
        save_dialog.response.connect ((dialog, response_id) => {
            switch (response_id) {
                case Gtk.ResponseType.ACCEPT:
                    file = save_dialog.get_file ();
                    save_to_file (type);
                    break;
            }
            dialog.destroy ();
        });

        save_dialog.run ();
    }

    private void save_to_file (int type) {
        var options_list = new GLib.SList<Gda.Holder> ();
        var separator_holder = new Gda.Holder (GLib.Type.STRING);
        var first_line_holder = new Gda.Holder (GLib.Type.BOOLEAN);
        var overwrite_holder = new Gda.Holder (GLib.Type.BOOLEAN);

        separator_holder.id = "SEPARATOR";
        try {
            separator_holder.set_value (",");
        } catch (GLib.Error err) {
            window.main.connection_manager.query_warning (err.message);
        }

        first_line_holder.id = "NAMES_ON_FIRST_LINE";
        try {
            first_line_holder.set_value (true);
        } catch (GLib.Error err) {
            window.main.connection_manager.query_warning (err.message);
        }

        overwrite_holder.id = "OVERWRITE";
        try {
            overwrite_holder.set_value (true);
        } catch (GLib.Error err) {
            window.main.connection_manager.query_warning (err.message);
        }

        options_list.append (separator_holder);
        options_list.append (first_line_holder);
        options_list.append (overwrite_holder);

        var options = new Gda.Set (options_list);

        switch (type) {
            case 1:
                // Export as CSV
                try {
                    response_data.export_to_file (Gda.DataModelIOFormat.TEXT_SEPARATED, file.get_path (), null, null, options);
                }
                catch (GLib.Error err) {
                    window.main.connection_manager.query_warning (err.message);
                }
                break;
            case 2:
                // Export as plain text
                try {
                    response_data.export_to_file (Gda.DataModelIOFormat.TEXT_TABLE, file.get_path (), null, null, options);
                }
                catch (GLib.Error err) {
                    window.main.connection_manager.query_warning (err.message);
                }
                break;
        }
    }
}
