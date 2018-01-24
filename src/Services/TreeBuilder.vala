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
    public class TreeBuilder : Gtk.TreeView {

        public TreeBuilder (Gda.DataModel response) {
            Gtk.TreeViewColumn column;
            var renderer = new Gtk.CellRendererText ();
            var tot_columns = response.get_n_columns ();

            GLib.Type[] theTypes = new GLib.Type[tot_columns];
            for (int col = 0; col < tot_columns; col++) {
                theTypes[col] = response.describe_column (col).get_g_type ();

                var title = response.get_column_title (col).replace ("_", "__");
                column = new Gtk.TreeViewColumn.with_attributes (title, renderer, "text", col, null);
                column.clickable = true;
                column.resizable = true;
                column.expand = true;
                column.min_width = 10;
                if (col > 0) {
                    column.sizing = Gtk.TreeViewColumnSizing.FIXED;
                    column.fixed_width = 150;
                }
                this.append_column (column);
            }

            Gtk.ListStore store = new Gtk.ListStore.newv (theTypes);
            Gda.DataModelIter _iter = response.create_iter ();
            Gtk.TreeIter iter;
            var error_message = GLib.Value (typeof (string));

            while (_iter.move_next ()) {
                store.append (out iter);
                for (int i = 0; i < tot_columns; i++) {
                    try {
                        store.set_value (iter, i, _iter.get_value_at_e (i));
                    } catch (Error e) {
                        error_message.set_string ("Error " + e.code.to_string () + " on Column '" + response.get_column_title (i) + "': " + e.message.to_string ());
                    }
                }
            }

            if (error_message.get_string () != null) {
                window.welcome.database.render_query_error (error_message.get_string ());
                error_message.unset ();
            }
 
            this.set_model (store);
        }
    }
}
