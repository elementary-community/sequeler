/*
* Copyright (c) 2011-2018 Alecaddd (http://alecaddd.com)
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

public class Sequeler.Layouts.Welcome : Granite.Widgets.Welcome {
    public unowned Sequeler.Window window { get; construct; }

    public Welcome (Sequeler.Window main_window) {
        Object (
            window: main_window,
            title: _("Welcome to Sequeler"),
            subtitle: _("Connect to any Local or Remote Database.")
        );
    }

    construct {
        valign = Gtk.Align.FILL;
        halign = Gtk.Align.FILL;
        vexpand = true;

        append ("bookmark-new", _("Add a New Database"), _("Connect to a Database and Save it in your Library"));

        activated.connect ( index => {
            switch (index) {
                case 0:
                    Sequeler.Services.ActionManager.action_from_group (Sequeler.Services.ActionManager.ACTION_NEW_CONNECTION, window.get_action_group ("win"));
                break;
            }
        });
    }
}