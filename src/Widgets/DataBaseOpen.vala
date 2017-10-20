/*
* Copyright (c) 2011-2017 Alecaddd (http://alecaddd.com)
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
namespace Sequeler { 
    public class DataBaseOpen : Gtk.Box {

        public Gtk.Paned main_pane;
        public Gtk.Paned pane;
        public Gtk.Box toolbar;
        public Gtk.Box sidebar;
        public Gtk.Button run_button;
        public Gtk.Spinner spinner;
        public Gtk.Label result_message;
        public Gtk.Label loading_msg;
        public Gtk.ScrolledWindow scroll_results;
        public Gtk.ScrolledWindow scroll_sidebar;
        public Gtk.TreeView results_view;
        public Gtk.ListStore store;
        public QueryBuilder query_builder;
        public int column_pos;

        public string db_name;

        public signal int execute_query (string query);
        public signal Gda.DataModel? execute_select (string query);

        public DataBaseOpen () {
            orientation = Gtk.Orientation.VERTICAL;

            main_pane = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
            main_pane.wide_handle = true;
            main_pane.set_position (240);

            build_sidebar ();

            pane = new Gtk.Paned (Gtk.Orientation.VERTICAL);
            pane.wide_handle = true;
            
            this.pack_start (main_pane, true, true, 0);

            build_editor ();

            build_toolbar ();

            build_treeview ();

            connect_signals ();

            handle_shortcuts ();

            main_pane.add2 (pane);
        }

        public void build_sidebar () {
            sidebar = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            sidebar.width_request = 240;

            var sidebar_title = new TitleBar (_("TABLES"));
            sidebar.pack_start (sidebar_title, false, true, 0);

            main_pane.pack1 (sidebar, true, false);
        }

        public void init_sidebar (string db_name) {
            this.db_name = db_name;
            var table_query = "SELECT table_name FROM information_schema.TABLES WHERE table_schema = '" + db_name + "' ORDER BY table_name DESC";

            sidebar_table (execute_select (table_query));
        }

        public void sidebar_table (Gda.DataModel? response) {
            if (response == null) {
                return;
            }

            if (scroll_sidebar != null) {
                sidebar.remove (scroll_sidebar);
                scroll_sidebar = null;
            }

            scroll_sidebar = new Gtk.ScrolledWindow (null, null);
            scroll_sidebar.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);

            Gtk.Grid grid = new Gtk.Grid ();
            grid.column_spacing = 0;
            grid.row_spacing = 0;
            grid.column_homogeneous = true;

            Gda.DataModelIter _iter = response.create_iter ();
            int top = 0;
            while (_iter.move_next ()) {
                grid.attach (new TableRow (_iter.get_value_at (0).get_string (), top), 0, top, 1, 1);             
                top++;
            }

            scroll_sidebar.add (grid);
            grid.show_all ();

            sidebar.pack_start (scroll_sidebar, true, true, 0);

            sidebar.show_all ();
        }

        public void build_editor () {
            var scroll = new Gtk.ScrolledWindow (null, null);
            scroll.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);

            query_builder = new QueryBuilder ();
            query_builder.update_run_button.connect ((status) => {
                run_button.sensitive = status;
            });

            scroll.add (query_builder);

            var editor = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            editor.height_request = 100;

            editor.pack_start (scroll, true, true, 0);

            pane.pack1 (editor, true, false);
        }

        public void build_toolbar () {
            toolbar = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            toolbar.get_style_context ().add_class ("toolbar");
            toolbar.get_style_context ().add_class ("library-toolbar");

            var run_image = new Gtk.Image.from_icon_name ("system-run-symbolic", Gtk.IconSize.BUTTON);
            run_button = new Gtk.Button.with_label (_("Run Query"));
            run_button.get_style_context ().add_class ("suggested-action");
            run_button.always_show_image = true;
            run_button.set_image (run_image);
            run_button.can_focus = false;
            run_button.margin = 10;
            run_button.sensitive = false;

            spinner = new Gtk.Spinner ();

            loading_msg = new Gtk.Label (_("Running Query..."));
            loading_msg.visible = false;
            loading_msg.no_show_all = true;

            result_message = new Gtk.Label (_("No Results Available"));
            result_message.visible = false;
            result_message.no_show_all = true;

            toolbar.pack_start (loading_msg, false, false, 10);
            toolbar.pack_start (result_message, false, false, 10);
            toolbar.pack_start (spinner, false, false, 10);
            toolbar.pack_end (run_button, false, false, 0);
        }

        public void build_treeview () {
            var results = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            results.height_request = 100;

            results.add (toolbar);

            scroll_results = new Gtk.ScrolledWindow (null, null);
            scroll_results.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);

            results.pack_start (scroll_results, true, true, 0);

            pane.pack2 (results, true, false);
        }

        public void connect_signals () {
            run_button.clicked.connect (() => {
                init_query ();
            });
        }

        private void handle_shortcuts () {
            query_builder.key_press_event.connect ( (e) => {
                bool handled = false;
                if((e.state & Gdk.ModifierType.CONTROL_MASK) != 0) {
                    switch (e.keyval) {
                        case 65293:
                            init_query ();
                            handled = true;
                            break;
                        default:
                            break;
                    }
                }

                return handled;
            });
        }

        public void init_query () {
            show_loading ();
            
            if (results_view != null) {
                scroll_results.remove (results_view);
                results_view = null;
            }

            GLib.Timeout.add_seconds(0, () => {
                var query = query_builder.get_text ();

                if ("select" in query.down ()) {
                    handle_select_response (execute_select (query));
                } else {
                    handle_query_response (execute_query (query));
                }
                return false; 
            });
        }

        public void handle_query_response (int response) {
            hide_loading ();

            if (response == 0) {
                result_message.label = _("Unable to process Query!");
            } else if (response < 0) {
                result_message.label = _("Query Executed!");
            } else {
                result_message.label = _("Query Successfully Executed! Rows affected: ") + response.to_string ();
            }
        }

        public void handle_select_response (Gda.DataModel? response) {
            hide_loading ();

            if (response == null) {
                result_message.label = _("Unable to process Query!");
                return;
            }

            var tot_columns = response.get_n_columns ();

            // generate ListStore with proper amount of type based on columns
            GLib.Type[] theTypes = new GLib.Type[tot_columns];
            for (int col = 0; col < tot_columns; col++) {
                theTypes[col] = typeof (string);
            }
            store = new Gtk.ListStore.newv (theTypes);

            Gtk.TreeIter iter;
            Gda.DataModelIter _iter = response.create_iter ();
            while (_iter.move_next ()) {
                store.append (out iter);
                for (int i = 0; i < tot_columns; i++) {
                    store.set_value (iter, i, _iter.get_value_at (i));
                }
            }

            results_view = new Gtk.TreeView ();
            
            // generate columns
            for (int i = 0; i < tot_columns; i++) {
                var title = response.get_column_title (i).replace ("_", "__");
                var column = new Gtk.TreeViewColumn.with_attributes (title, new Gtk.CellRendererText (), "text", i, null);
                column.clickable = true;
                column.resizable = true;
                column.expand = true;
                column.min_width = 10;
                if (i > 0) {
                    column.sizing = Gtk.TreeViewColumnSizing.FIXED;
                    column.fixed_width = 150;
                }
                results_view.append_column (column);
            }

            results_view.set_model (store);

            scroll_results.add (results_view);

            scroll_results.show_all ();

            result_message.label = _("Query Successfully Executed!");
        }

        public void hide_loading () {
            spinner.stop ();
            loading_msg.visible = false;
            loading_msg.no_show_all = true;

            result_message.visible = true;
            result_message.no_show_all = false;
        }

        public void show_loading () {
            spinner.start ();
            loading_msg.visible = true;
            loading_msg.no_show_all = false;

            result_message.visible = false;
            result_message.no_show_all = true;
        }

        public void clear_results () {
            if (results_view != null) {
                scroll_results.remove (results_view);
                results_view = null;
            }
        }

        //  protected class TableLabel : Gtk.Label {
        //      public TableLabel (string text, int type) {
        //          label = text;
        //          if (type % 2 == 0) {
        //              get_style_context ().add_class ("row-odd");
        //          } else {
        //              get_style_context ().add_class ("row-even");
        //          }
        //          halign = Gtk.Align.START;
        //          margin = 6;
        //      }
        //  }
    }
}