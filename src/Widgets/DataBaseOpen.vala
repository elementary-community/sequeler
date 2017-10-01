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

public class Sequeler.DataBaseOpen : Gtk.Box {

    public Gtk.Paned pane;
    public Gtk.Box toolbar;
    public Gtk.Button run_button;
    public Gtk.Spinner spinner;
    public Gtk.Label result_message;
    public Gtk.Label loading_msg;
    public Gtk.ScrolledWindow scroll_results;
    public Gtk.TreeView results_view;
    public Sequeler.QueryBuilder query_builder;

    public signal int execute_query (string query);
    public signal Gda.DataModel execute_select (string query);

    public DataBaseOpen () {
        orientation = Gtk.Orientation.VERTICAL;

        pane = new Gtk.Paned (Gtk.Orientation.VERTICAL);
        pane.wide_handle = true;
        this.pack_start (pane, true, true, 0);

        build_editor ();

        build_toolbar ();

        build_treeview ();

        connect_signals ();
    }

    public void build_editor () {
        var scroll = new Gtk.ScrolledWindow (null, null);
        scroll.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);

        query_builder = new Sequeler.QueryBuilder ();
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

        var run_image = new Gtk.Image.from_icon_name ("application-x-executable-symbolic", Gtk.IconSize.BUTTON);
        run_button = new Gtk.Button.with_label (_("Run Query"));
        run_button.get_style_context ().add_class ("suggested-action");
        run_button.always_show_image = true;
        run_button.set_image (run_image);
        run_button.can_focus = false;
        run_button.margin = 10;
        run_button.sensitive = false;

        spinner = new Gtk.Spinner ();

        loading_msg = new Gtk.Label ("running query...");
        loading_msg.visible = false;
        loading_msg.no_show_all = true;

        toolbar.pack_start (spinner, false, false, 10);
        toolbar.pack_start (loading_msg, false, false, 10);
        toolbar.pack_end (run_button, false, false, 0);
    }

    public void build_treeview () {
        var results = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        results.height_request = 100;

        results.add (toolbar);

        result_message = new Gtk.Label (_("No Results Available"));
        result_message.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);
        result_message.margin_top = 30;
        result_message.valign = Gtk.Align.CENTER;

        //  results.add (result_message);

        scroll_results = new Gtk.ScrolledWindow (null, null);
        scroll_results.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);

        //  results_view = new ResultsView ();

        //  scroll_results.add (results_view);

        results.pack_start (scroll_results, true, true, 0);

        pane.pack2 (results, true, false);
    }

    public void connect_signals () {
        run_button.clicked.connect (() => {

            spinner.start ();
            loading_msg.visible = true;
            result_message.visible = false;
            result_message.no_show_all = true;

            GLib.Timeout.add_seconds(0, () => {                 
                var query = query_builder.get_text ();

                if ("select" in query.down ()) {
                    var response = execute_select (query);
                    spinner.stop ();
                    loading_msg.visible = false;
                    handle_select_response (response);
                } else {
                    var response = execute_query (query);
                    spinner.stop ();
                    loading_msg.visible = false;
                    handle_query_response (response);
                }
                return false; 
            });
        });
    }

    public void handle_query_response (int response) {
        if (response == 0) {
            result_message.visible = false;
            result_message.no_show_all = true;
        } else if (response == 1) {
            result_message.visible = true;
            result_message.no_show_all = false;
            result_message.label = _("Query Successfully Executed!");
        }
    }

    public void handle_select_response (Gda.DataModel response) {
        if (results_view != null) {
            scroll_results.remove (results_view);
            results_view = null;
        }

        Gtk.TreeModel data_model = Gdaui.DataStore.new (response);

        //  Gda.DataModelIter _iter = response.create_iter ();
        
        //  while (_iter.move_next ()) {
            //  stdout.printf ("%s\n",_iter.get_value_at (2).get_string ());
            //  data_model.append (out _iter);
        //  }

        results_view = new Gtk.TreeView.with_model (data_model);

        for (int i = 0; i < response.get_n_columns (); i++) {
            results_view.insert_column_with_attributes (-1, response.get_column_name (i), new Gtk.CellRendererText ());
        }

        scroll_results.add (results_view);

        scroll_results.show_all ();

        //  Gtk.TreeView view = new Gtk.TreeView.with_model (model);
        //  Gda.DataModelIter _iter = response.create_iter ();

        //  setup_tree_view (response, _iter);

        //  while (_iter.move_next ()) {
        //      stdout.printf ("%s\n",_iter.get_row ().to_string ());
        //  }

        //  stdout.printf ("%s\n",response.dump_as_string ());
        //  stdout.printf ("Rows: %s\n",response.get_n_rows ().to_string ());
        //  stdout.printf ("Columns: %s\n",response.get_n_columns ().to_string ());
    }

    //  public Gda.DataModelIter create_data_iterator (Gda.DataModel model) {
    //      this.iter = model.create_iter ();
    //      this._current_pos = -1;
    //      this.pos_init = 0;
    //      this.maxpos = this.iter.data_model.get_n_columns () * this.iter.data_model.get_n_rows ();
    //      this.filtered = false;
    //  }

    public void setup_tree_view (Gda.DataModel data, Gda.DataModelIter _iter) {
        //  var listmodel = new Gtk.ListStore (data.get_n_columns ());
        //  results_view.set_model (listmodel);

        //  for (int i = 0; i < data.get_n_columns (); i++) {
        //      results_view.insert_column_with_attributes (-1, data.get_column_name (i), new Gtk.CellRendererText (), "text", i);
        //  }

        //  while (_iter.move_next ()) {
        //      results_view.insert_column_with_attributes (-1, "Account Name", new Gtk.CellRendererText (), "text", _iter.get_row ());
        //  }

        //  results_view.insert_column_with_attributes (-1, "Account Name", new Gtk.CellRendererText (), "text", 0);
        //  results_view.insert_column_with_attributes (-1, "Type", new Gtk.CellRendererText (), "text", 1);
        //  results_view.insert_column_with_attributes (-1, "Balance", new Gtk.CellRendererText (), "text", 2, "foreground", 3);

        //  Gtk.TreeIter iter;
        //  listmodel.append (out iter);
        //  listmodel.set (iter, 0, "My Visacard", 1, "card", 2, "102,10", 3, "red");

        //  listmodel.append (out iter);
        //  listmodel.set (iter, 0, "My Mastercard", 1, "card", 2, "10,20", 3, "red");

        //  listmodel.append (out iter);
        //  listmodel.set (iter, 0, "My Mastercard", 1, "card", 2, "10,20", 3, "red");

        //  listmodel.append (out iter);
        //  listmodel.set (iter, 0, "My Mastercard", 1, "card", 2, "10,20", 3, "red");

        //  listmodel.append (out iter);
        //  listmodel.set (iter, 0, "My Mastercard", 1, "card", 2, "10,20", 3, "red");

        //  listmodel.append (out iter);
        //  listmodel.set (iter, 0, "My Mastercard", 1, "card", 2, "10,20", 3, "red");

        //  listmodel.append (out iter);
        //  listmodel.set (iter, 0, "My Mastercard", 1, "card", 2, "10,20", 3, "red");
    }

}