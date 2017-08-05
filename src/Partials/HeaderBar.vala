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

public class Sequeler.HeaderBar : Gtk.HeaderBar {

    private static HeaderBar? instance = null;

    private HeaderBarButton new_connection;
    private HeaderBarButton search;
    private HeaderBarButton terminal;
    private HeaderBarButton open_menu;

    private HeaderBar () {
        set_title (APP_NAME);
        set_show_close_button (true);

        build_ui ();
    }

    public static HeaderBar get_instance () {
        if (instance == null) {
            instance = new HeaderBar ();
        }

        return instance;
    }

    private void build_ui () {
        // Add some widgets here
        new_connection = new HeaderBarButton ("star-new-symbolic", _("New Connection"));
        search = new HeaderBarButton ("system-search-symbolic", _("Search Connection"));
        terminal = new HeaderBarButton ("utilities-terminal-symbolic", _("Connection in Terminal"));
        open_menu = new HeaderBarButton ("open-menu-symbolic", _("Settings"));

        terminal.sensitive = false;

        // add button to headerbar
        pack_start(new_connection);
        pack_end(open_menu);
        pack_end(search);
        pack_end(terminal);
    }

    protected class HeaderBarButton : Gtk.Button {

        public HeaderBarButton (string icon_name, string tooltip) {
            can_focus = false;

            Gtk.Image image;

            if (icon_name.contains ("/")) {
                image = new Gtk.Image.from_resource (icon_name);
            } else {
                image = new Gtk.Image.from_icon_name (icon_name, Gtk.IconSize.BUTTON);
            }

            image.margin = 3;

            get_style_context ().add_class ("btn-headerbar");
            set_tooltip_text (tooltip);
            this.add (image);
        }
    }
}