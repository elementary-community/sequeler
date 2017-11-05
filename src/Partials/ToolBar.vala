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
    public class ToolBar : Gtk.Box {
        private static ToolBar? instance = null;
        public Gtk.Paned toolbar_pane;
        public Gtk.ListStore schema_list;

        enum Column {
            SCHEMAS
        }

        private ToolBar () {
            margin = 5;

            build_ui ();
            build_dropdown ();
            build_tabs ();
        }

        public static ToolBar get_instance () {
            if (instance == null) {
                instance = new ToolBar ();
            }

            return instance;
        }

        private void build_ui () {
            toolbar_pane = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
            toolbar_pane.wide_handle = true;
            toolbar_pane.set_position (230);

            this.pack_start (toolbar_pane, true, true, 0);
        }

        private void build_dropdown () {
            schema_list = new Gtk.ListStore (1, typeof (string));

            for (int i = 0; i < 2; i++){
                Gtk.TreeIter iter;
                schema_list.append (out iter);
                schema_list.set (iter, Column.SCHEMAS, "Table Schema");
            }

            var schema_list_combo = new Gtk.ComboBox.with_model (schema_list);
            Gtk.CellRendererText cell = new Gtk.CellRendererText ();
            schema_list_combo.pack_start (cell, false);

            schema_list_combo.set_attributes (cell, "text", Column.SCHEMAS);
            schema_list_combo.set_active (0);

            toolbar_pane.pack1 (schema_list_combo, true, false);
        }

        private void build_tabs () {
            var tab_pane = new Granite.Widgets.ModeButton ();
            tab_pane.append_icon ("view-grid-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
            tab_pane.append_icon ("view-list-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
            tab_pane.append_icon ("view-column-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
            tab_pane.append_icon ("view-grid-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
            tab_pane.append_icon ("view-list-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
            tab_pane.append_icon ("view-column-symbolic", Gtk.IconSize.LARGE_TOOLBAR);

            toolbar_pane.pack2 (tab_pane, true, false);
        }
    }
}