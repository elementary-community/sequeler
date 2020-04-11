public class Sequeler.Widgets.QueryParamsDialog : Gtk.Dialog {
    public weak Sequeler.Window window { get; construct; }

    public Sequeler.Layouts.Views.Query parent_view;
    public string query;
    public Gda.Statement statement;
    public Gda.Set params;
    private Gee.ArrayList<Gtk.Widget> entries;

    public QueryParamsDialog (Sequeler.Window? parent, Sequeler.Layouts.Views.Query view, string query, Gda.Statement statement, Gda.Set? @params) {
        Object (
            border_width: 5,
            deletable: false,
            resizable: false,
            title: _("Query parameters"),
            transient_for: parent,
            window: parent
        );
        this.parent_view = view;
        this.query = query;
        this.statement = statement;
        this.params = @params;

        build_content ();
    }

    construct {
        response.connect (on_response);
    }

    enum Action {
        RUN_QUERY,
        CANCEL
    }

    private Gtk.Widget entry_for_holder (Gda.Holder holder) {
        GLib.Type holder_g_type = holder.get_g_type ();
        switch (holder_g_type) {
            case GLib.Type.BOOLEAN:
                debug ("Detected bool param");
                return new Gtk.Switch ();
            case GLib.Type.INT:
            case GLib.Type.UINT:
                debug ("Detected int param");
                var widget = new Gtk.Entry ();
                widget.set_input_purpose (Gtk.InputPurpose.DIGITS);
                return widget;
            case GLib.Type.FLOAT:
            case GLib.Type.DOUBLE:
                debug ("Detected float param");
                var widget = new Gtk.Entry ();
                widget.set_input_purpose (Gtk.InputPurpose.NUMBER);
                return widget;
            default:
                debug ("Detected string param");
                return new Gtk.Entry ();
        }
    }

    // takes the parse result and update the widgets style and the holder value
    private bool store_parsed_value (bool parse_result, GLib.Value parsed_value, Gda.Holder holder, Gtk.Entry entry) {
        entry.get_style_context ().add_class ("error");
        if (parse_result) {
            try {
                holder.set_value (parsed_value);
            }
            catch (GLib.Error ex) {
                return false;
            }
            entry.get_style_context ().remove_class ("error");
            return true;
        }   
        return false;
    }

    private bool set_value_for_holder (Gda.Holder holder, Gtk.Widget widget) {
        GLib.Type holder_g_type = holder.get_g_type ();
        if (holder_g_type == GLib.Type.BOOLEAN) {
            Gtk.Switch switch = widget as Gtk.Switch;
            if (switch == null) {
                return false;
            }
            try {
                holder.set_value (switch.get_active ());
            }
            catch (GLib.Error ex) {
                return false;
            }
            return true;
        }
        else {
            Gtk.Entry entry = widget as Gtk.Entry;
            string text = entry.get_text ();

            bool parse_result = false;
            GLib.Value parsed_value;

            if (holder_g_type == GLib.Type.INT) {
                parse_result = int.try_parse (text, out parsed_value);
            }
            else if (holder_g_type == GLib.Type.UINT) {
                parse_result = uint.try_parse (text, out parsed_value);
            }
            else if (holder_g_type == GLib.Type.FLOAT) {
                parse_result = float.try_parse (text, out parsed_value);
            }
            else if (holder_g_type == GLib.Type.DOUBLE) {
                parse_result = double.try_parse (text, out parsed_value);
            }
            else {
                parse_result = true;
                parsed_value = text;
            }
            return store_parsed_value (parse_result, parsed_value, holder, entry);
        }
    }

    private void build_content () {
        var content = get_content_area ();

        var form_grid = new Gtk.Grid ();
        form_grid.margin = 15;
        form_grid.row_spacing = 12;
        form_grid.column_spacing = 20;

        entries = new Gee.ArrayList<Gtk.Widget> ();

        for (int i = 0; ; i++) {
            Gda.Holder? holder = params.get_nth_holder (i);
            if (holder == null) {
                break;
            }
            var holder_id = holder.get_id ();

            var label = new Gtk.Label (holder_id);
            form_grid.attach (label, 0, i, 1, 1);
            var entry = entry_for_holder (holder);
            form_grid.attach (entry, 1, i, 1, 1);
            entries.add (entry);
        }

        content.add (form_grid);

        var run_button = new Sequeler.Widgets.RunQueryButton ();
        run_button.set_sensitive (true);
        add_action_widget (run_button, Action.RUN_QUERY);

        // TODO: cancel_button should keep a consistent style
        var cancel_button = new Sequeler.Widgets.CancelQueryButton ();
        cancel_button.set_sensitive (true);
        add_action_widget (cancel_button, Action.CANCEL);
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
                if (get_param_values ()) {
                    parent_view.run_query_statement (query, statement, params);
                    destroy ();
                }
                break;
            case Action.CANCEL:
                destroy ();
                break;
            default:
                break;
        }
    }
}
