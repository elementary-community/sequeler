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

public class Sequeler.Widgets.QuickConnectionDialog : Gtk.Dialog {

    public QuickConnectionDialog (Gtk.ApplicationWindow parent, Sequeler.Services.Settings settings) {
        
        Object (
            use_header_bar: 0,
            border_width: 20,
            deletable: false,
            resizable: false,
            title: _("Quick Connection"),
            transient_for: parent
        );

    }

    construct {

        var main_stack = new Gtk.Stack ();
        main_stack.margin = 6;
        main_stack.margin_bottom = 15;
        main_stack.margin_top = 15;

    }
}