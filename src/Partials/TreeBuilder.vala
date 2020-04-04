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

public class Sequeler.Partials.TreeBuilder : Gtk.TreeView {
    public weak Sequeler.Window window { get; construct; }
    public Gda.DataModel data { get; construct; }
    public int per_page { get; construct; }
    public int current_page { get; construct; }
    public string? sortby { get; set construct; }
    public string sort { get; set construct; }

    public Gtk.ListStore store;
    public string? error_message { get; set; default = null; }
    public string background;
    public int tot_columns;

    private string bg_light = "rgba(255,255,255,0.05)";
    private string bg_dark = "rgba(0,0,0,0.05)";

    public signal void sortby_column (string column, string direction);

    public TreeBuilder (
        Gda.DataModel response, Sequeler.Window main_window, int per_page = 0, int current_page = 0,
        string? sortby = null, string sort = "ASC"
    ) {
        Object (
            window: main_window,
            data: response,
            per_page: per_page,
            current_page: current_page,
            sortby: sortby,
            sort: sort
        );
    }

    construct {
        Gtk.TreeViewColumn column;
        var renderer = new Gtk.CellRendererText ();
        renderer.single_paragraph_mode = true;

        tot_columns = data.get_n_columns ();

        var the_types = new GLib.Type [tot_columns + 1];
        for (int col = 0; col < tot_columns; col++) {
            the_types[col] = data.describe_column (col).get_g_type ();

            var title = data.get_column_title (col).replace ("_", "__");
            column = new Gtk.TreeViewColumn.with_attributes (title, renderer, "text", col, "background", tot_columns, null);
            column.clickable = true;
            column.resizable = true;
            column.expand = true;

            if (col > 0) {
                column.sizing = Gtk.TreeViewColumnSizing.FIXED;
                column.fixed_width = 150;
            }

            if (sortby != null && sortby.replace ("_", "__") == title) {
                column.sort_indicator = true;
                column.sort_order = sort == "ASC" ? Gtk.SortType.ASCENDING : Gtk.SortType.DESCENDING;
            }

            column.clicked.connect (init_sortby_column);
            append_column (column);
        }

        the_types[tot_columns] = typeof (string);

        store = new Gtk.ListStore.newv (the_types);
        Gda.DataModelIter _iter = data.create_iter ();
        Gtk.TreeIter iter;

        if (per_page != 0 && data.get_n_rows () > per_page) {
            int counter = 1;
            int offset = (per_page * (current_page - 1));

            if (current_page != 0 && offset != 0) {
                _iter.move_to_row ((offset - 1));
            }

            while (counter <= per_page && _iter.move_next ()) {
                append_value (_iter, iter);
                counter++;
            }
        } else {
            while (_iter.move_next ()) {
                append_value (_iter, iter);
            }
        }

        if (error_message != null) {
            window.main.connection_manager.query_warning (error_message);
            error_message = null;
        }

        set_model (store);
    }

    private void append_value (Gda.DataModelIter _iter, Gtk.TreeIter iter) {
        background = _iter.get_row () % 2 == 0 ? bg_light : bg_dark;
        store.append (out iter);

        for (int i = 0; i < tot_columns; i++) {
            var placeholder_type = data.describe_column (i).get_g_type ();

            try {
                var raw_value = _iter.get_value_at_e (i);
                var sanitized_value = raw_value.strdup_contents () != "NULL" ?
                                      raw_value : GLib.Value (placeholder_type);

                store.set_value (iter, i, sanitized_value);
            } catch (Error e) {
                error_message = "%s %s %s %s: %s".printf (_("Error"), e.code.to_string (), _("on Column"), data.get_column_title (i), e.message.to_string ());
            }
        }
        store.set_value (iter, tot_columns, background);
    }

    public void init_sortby_column (Gtk.TreeViewColumn column) {
        // Detect sort order.
        sort = "ASC";
        if (column.sort_order == Gtk.SortType.ASCENDING) {
            sort = "DESC";
        }

        sortby_column (column.title.replace ("__", "_"), sort);
    }

    private void copy_column_data (Gdk.EventButton event, Gtk.TreePath path, Gtk.TreeViewColumn column) {
        if (path == null || column == null) {
            return;
        }

        Value val;
        Gtk.TreeIter iter;

        Gdk.Display display = Gdk.Display.get_default ();
        Gtk.Clipboard clipboard = Gtk.Clipboard.get_default (display);
        model.get_iter (out iter, path);
        model.get_value (iter, column.get_sort_column_id (), out val);

        Gda.DataHandler handler = Gda.DataHandler.get_default (val.type ());
        string? column_data = handler.get_str_from_value (val);

        if (column_data == null) {
            column_data = "";
        }

        clipboard.set_text (column_data, -1);
    }

    private Gtk.Menu create_context_menu (Gdk.EventButton event, Gtk.TreePath path, Gtk.TreeViewColumn column) {
        Gtk.Menu menu = new Gtk.Menu ();
        Gtk.MenuItem item = new Gtk.MenuItem.with_label (_("Copy %s").printf (column.get_title ()));
        item.activate.connect (() => { copy_column_data (event, path, column); });
        item.show ();
        menu.append (item);

        /* Wayland complains if not set */
        menu.realize.connect (() => {
            Gdk.Window child = menu.get_window ();
            child.set_type_hint (Gdk.WindowTypeHint.POPUP_MENU);
        });

        return menu;
    }

    public override bool button_press_event (Gdk.EventButton event) {
        if (event.triggers_context_menu () && event.type == Gdk.EventType.BUTTON_PRESS) {
            Gtk.TreePath path;
            Gtk.TreeViewColumn column;
            get_path_at_pos ((int) event.x, (int) event.y, out path, out column, null, null);
            var menu = create_context_menu (event, path, column);
            menu.popup_at_pointer (event);

            return true;
        }

        return base.button_press_event (event);
    }
}
