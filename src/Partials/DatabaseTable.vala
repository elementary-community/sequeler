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

public class Sequeler.Partials.DataBaseTable : Granite.Widgets.SourceList.Item {
    private Gtk.Menu menu;
    private Granite.Widgets.SourceList source_list;

    public DataBaseTable (string table_name = "", Granite.Widgets.SourceList list) {
        name = table_name;
        source_list = list;
        editable = true;
        build_context_menu ();
    }

    public override Gtk.Menu? get_context_menu () {
        return menu;
    }

    private void build_context_menu () {
        menu = new Gtk.Menu ();
        Gtk.MenuItem copy_item = new Gtk.MenuItem.with_label (_("Copy table name"));
        Gtk.MenuItem edit_item = new Gtk.MenuItem.with_label (_("Edit table name"));

        copy_item.activate.connect (() => {
            Gdk.Display display = Gdk.Display.get_default ();
            Gtk.Clipboard clipboard = Gtk.Clipboard.get_default (display);

            clipboard.set_text (name, -1);
        });
        copy_item.show ();

        edit_item.activate.connect (() => {
            source_list.start_editing_item (this);
        });
        edit_item.show ();

        menu.append (copy_item);
        menu.append (edit_item);

        /* Wayland complains if not set */
        menu.realize.connect (() => {
            Gdk.Window child = menu.get_window ();
            child.set_type_hint (Gdk.WindowTypeHint.POPUP_MENU);
        });
    }
}
