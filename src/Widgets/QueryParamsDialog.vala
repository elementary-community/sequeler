/**
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
 * Authored by: Francisco Altoe
 * Authored by: Alessandro "Alecaddd" Castellani <castellani.ale@gmail.com>
 */

/**
 * Dialog subclass used to prompt the user to provide the required query parameters
 */
public class Sequeler.Widgets.QueryParamsDialog : Gtk.Dialog {
    public weak Sequeler.Window window { get; construct; }

    public Sequeler.Layouts.Views.Query parent_view { get; construct; }
    public string query { get; construct; }
    public Gda.Statement statement { get; construct; }
    public Gda.Set params { get; construct; }
    private Gee.ArrayList<Gtk.Widget> entries;

    private Sequeler.Partials.ResponseMessage response_msg;

    enum Action {
        RUN_QUERY,
        CANCEL
    }

    public QueryParamsDialog (
        Sequeler.Window? parent,
        Sequeler.Layouts.Views.Query view,
        string query,
        Gda.Statement statement,
        Gda.Set? @params
    ) {
        Object (
            border_width: 6,
            deletable: false,
            resizable: true,
            title: _("Query parameters"),
            transient_for: parent,
            window: parent,
            parent_view: view,
            query: query,
            statement: statement,
            params: @params
        );
    }

    construct {
        build_content ();
        response.connect (on_response);
    }

    private void build_content () {
        default_width = 500;
        var content = get_content_area ();

        var form_grid = new Gtk.Grid ();
        form_grid.margin = 6;
        form_grid.row_spacing = 12;
        form_grid.column_spacing = 12;

        entries = new Gee.ArrayList<Gtk.Widget> ();

        for (int i = 0; ; i++) {
            Gda.Holder? holder = params.get_nth_holder (i);
            if (holder == null) {
                break;
            }
            var holder_id = holder.get_id ();

            var label = new Gtk.Label (holder_id + ":");
            form_grid.attach (label, 0, i, 1, 1);
            var entry = entry_for_holder (holder);
            form_grid.attach (entry, 1, i, 1, 1);
            entries.add (entry);
        }

        var scrolled_window = new Gtk.ScrolledWindow (null, null);
        scrolled_window.add (form_grid);

        int main_window_width, main_window_height;
        parent_view.window.get_size (out main_window_width, out main_window_height);

        // Prevent the scrolled window from growing bigger than the main window itself.
        scrolled_window.set_max_content_height (main_window_height / 2);
        scrolled_window.set_max_content_width (main_window_width);
        scrolled_window.set_propagate_natural_width (true);
        scrolled_window.set_propagate_natural_height (true);

        response_msg = new Sequeler.Partials.ResponseMessage ();

        content.add (scrolled_window);
        content.add (response_msg);

        var cancel_button = new Gtk.Button.with_label (_("Cancel"));
        add_action_widget (cancel_button, Action.CANCEL);

        var run_button = new Sequeler.Partials.RunQueryButton ();
        add_action_widget (run_button, Action.RUN_QUERY);
    }

    private Gtk.Widget entry_for_holder (Gda.Holder holder) {
        Type holder_g_type = holder.get_g_type ();
        switch (holder_g_type) {
            case Type.BOOLEAN:
                return new Gtk.Switch ();
            case Type.INT:
            case Type.UINT:
                var widget = new Partials.ParamEntry (this, Gtk.InputPurpose.DIGITS);
                return widget;
            case Type.FLOAT:
            case Type.DOUBLE:
                var widget = new Partials.ParamEntry (this, Gtk.InputPurpose.NUMBER);
                return widget;
            default:
                return new Partials.ParamEntry (this);
        }
    }

    /**
     * Takes the parse result and update the widgets style and the holder value.
     */
    private bool store_parsed_value (
        bool parse_result,
        Value parsed_value,
        Gda.Holder holder,
        Gtk.Entry entry
    ) {
        entry.get_style_context ().remove_class ("error");

        if (!parse_result) {
            entry.get_style_context ().add_class ("error");
            return false;
        }

        try {
            holder.set_value (parsed_value);
        } catch (Error e) {
            write_response (e.message);
            entry.get_style_context ().add_class ("error");
            return false;
        }

        return true;
    }

    private bool set_value_for_holder (Gda.Holder holder, Gtk.Widget widget) {
        Type holder_g_type = holder.get_g_type ();
        if (holder_g_type == Type.BOOLEAN) {
            Gtk.Switch switch = widget as Gtk.Switch;
            if (switch == null) {
                return false;
            }

            try {
                holder.set_value (switch.get_active ());
            } catch (Error ex) {
                return false;
            }

            return true;
        } else {
            Gtk.Entry entry = widget as Gtk.Entry;
            string text = entry.get_text ();

            bool parse_result = true;
            Value parsed_value;

            if (holder_g_type == Type.INT) {
                // TODO: replace this with the following once we upgrade to a newer valac
                // parse_result = int.try_parse (text, out parsed_value);
                parsed_value = int.parse (text);
            } else if (holder_g_type == Type.UINT) {
                // TODO: replace this with the following once we upgrade to a newer valac
                // parse_result = uint.try_parse (text, out parsed_value);
                parsed_value = int.parse (text);
            } else if (holder_g_type == Type.FLOAT) {
                // TODO: replace this with the following once we upgrade to a newer valac
                //  parse_result = float.try_parse (text, out parsed_value);
                parsed_value = float.parse (text);
            } else if (holder_g_type == Type.DOUBLE) {
                // TODO: replace this with the following once we upgrade to a newer valac
                //  parse_result = double.try_parse (text, out parsed_value);
                parsed_value = double.parse (text);
            } else {
                parsed_value = text;
            }

            return store_parsed_value (parse_result, parsed_value, holder, entry);
        }
    }

    private bool get_param_values () {
        bool validation_result = true;
        for (int i = 0; ; i++) {
            Gda.Holder? holder = params.get_nth_holder (i);
            if (holder == null) {
                break;
            }
            validation_result &= set_value_for_holder (holder, entries[i]);
        }

        return validation_result;
    }

    private void on_response (Gtk.Dialog source, int response_id) {
        switch (response_id) {
            case Action.RUN_QUERY:
                run_query ();
                break;
            case Action.CANCEL:
                destroy ();
                break;
        }
    }

    public void run_query () {
        if (!get_param_values ()) {
            return;
        }

        parent_view.run_query_statement (query, statement, params);
        destroy ();
    }

    private void write_response (string? response_text) {
        response_msg.label = response_text;
    }
}
