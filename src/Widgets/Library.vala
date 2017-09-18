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

public class Sequeler.Library : Gtk.ScrolledWindow {

    private Gtk.FlowBox item_box;
    private Gtk.FlowBoxChild item;
    private Gtk.Box box;

    public Library () {
        hscrollbar_policy = Gtk.PolicyType.NEVER;

        item_box = new Gtk.FlowBox ();

        item_box.valign = Gtk.Align.START;
        item_box.min_children_per_line = 2;
        item_box.max_children_per_line = 2;
        item_box.margin = 12;
        item_box.expand = false;

        add (item_box);
        
        foreach (var conn in settings.saved_connections) {
            add_item (conn);           
            //  stdout.printf ("%s\n", conn);
        }
    }

    public void add_item (string connection) {
        item = new Gtk.FlowBoxChild ();
        box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);

        box.pack_start (new Gtk.Label (connection), false, false, 0);

        item.add (box);
        item_box.add (item);
    }
}