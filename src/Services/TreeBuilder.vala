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
            var tot_columns = response.get_n_columns ();

            GLib.Type[] theTypes = new GLib.Type[tot_columns];
            for (int col = 0; col < tot_columns; col++) {
                theTypes[col] = typeof (string);
            }
            Gtk.ListStore store = new Gtk.ListStore.newv (theTypes);

            Gtk.TreeIter iter;
            Gda.DataModelIter _iter = response.create_iter ();
            while (_iter.move_next ()) {
                store.append (out iter);
                for (int i = 0; i < tot_columns; i++) {
                    store.set_value (iter, i, _iter.get_value_at (i));
                }
            }
            
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
                this.append_column (column);
            }

            this.set_model (store);
        }
    }
}