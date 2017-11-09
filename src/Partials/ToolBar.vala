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
        public Gtk.Box tab_box;
        public Granite.Widgets.ModeButton tabs;
        public Gtk.ComboBox schema_list_combo;
        public Gtk.ListStore schema_list;
        public Gtk.TreeIter iter;
        public Gee.HashMap<int, string> schemas;

        enum Column {
            SCHEMAS
        }

        private ToolBar () {
            margin_start = 10;
            margin_end = 10;
            margin_bottom = 6;

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
            var schema_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            schema_box.margin_end = 10;
            schema_list = new Gtk.ListStore (1, typeof (string));

            schema_list.append (out iter);
            schema_list.set (iter, Column.SCHEMAS, _("- Select Database -"));

            schema_list_combo = new Gtk.ComboBox.with_model (schema_list);
            Gtk.CellRendererText cell = new Gtk.CellRendererText ();
            schema_list_combo.pack_start (cell, false);
            schema_list_combo.set_attributes (cell, "text", Column.SCHEMAS);

            schema_list_combo.set_active (0);

            schema_box.pack_start (schema_list_combo, true, false, 0);
            toolbar_pane.pack1 (schema_box, true, false);
        }

        private void build_tabs () {
            tab_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            tab_box.margin_start = 10;

            tabs = new Granite.Widgets.ModeButton ();
            tabs.append (new ToolBarButton ("x-office-spreadsheet-template", "Table Structure"));
            tabs.append (new ToolBarButton ("x-office-document", "Table Data"));
            tabs.append (new ToolBarButton ("accessories-text-editor", "Write Query"));
            tabs.sensitive = false;

            tab_box.add (tabs);

            toolbar_pane.pack2 (tab_box, false, false);
        }

        public void set_table_schema (Gda.DataModel? response) {
            if (response == null) {
                return;
            }

            schema_list.clear ();
            schema_list.append (out iter);
            schema_list.set (iter, Column.SCHEMAS, _("- Select Database -"));

            Gda.DataModelIter _iter = response.create_iter ();
            schemas = new Gee.HashMap<int, string> ();
            int i = 1;
            while (_iter.move_next ()) {
                schema_list.append (out iter);
                schema_list.set (iter, Column.SCHEMAS, _iter.get_value_at (0).get_string ());
                schemas.set (i,_iter.get_value_at (0).get_string ());
                i++;
            }

            schema_list_combo.set_active (0);
        }

        protected class ToolBarButton : Gtk.Box {
            public ToolBarButton (string icon_name, string tooltip) {
                Gtk.Label label;
                Gtk.Image image;

                orientation = Gtk.Orientation.VERTICAL;
                margin = 0;

                if (icon_name.contains ("/")) {
                    image = new Gtk.Image.from_resource (icon_name);
                } else {
                    image = new Gtk.Image.from_icon_name (icon_name, Gtk.IconSize.LARGE_TOOLBAR);
                }
                image.margin = 0;

                label = new Gtk.Label(tooltip);

                pack_start(image, false, false, 0);
                pack_start(label, false, false, 0);

                image.show();
                label.show();
            }
        }
    }
}