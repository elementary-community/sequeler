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

    private Gtk.Menu menu;
    private HeaderBarButton new_connection;
    private HeaderBarButton search;
    private HeaderBarButton terminal;
    private Gtk.MenuButton open_menu;

    public signal void preferences_selected();
    public signal void quick_connection();

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

        // Add some buttons in the HeaderBar
        new_connection = new HeaderBarButton ("star-new-symbolic", _("New Connection"));
        new_connection.clicked.connect (() => {
            quick_connection ();
        });
        
        search = new HeaderBarButton ("system-search-symbolic", _("Search Connection"));
        terminal = new HeaderBarButton ("utilities-terminal-symbolic", _("Connection in Terminal"));

        // Create the Menu
        menu = new Gtk.Menu ();

        var about_item = new Gtk.MenuItem.with_label (_("About"));
        about_item.activate.connect (() => {
            try {
                Gtk.show_uri (null, "https://github.com/alecaddd/sequeler", 0);
            } catch (Error error) {}
        });
        menu.add (about_item);

        var report_problem_item = new Gtk.MenuItem.with_label (_("Report a Problem…"));
        report_problem_item.activate.connect (() => {
            try {
                Gtk.show_uri (null, "https://github.com/alecaddd/sequeler/issues", 0);
            } catch (Error error) {}
        });
        menu.add (report_problem_item);

        menu.add (new Gtk.SeparatorMenuItem ());

        var preferences_item = new Gtk.MenuItem.with_label (_("Preferences"));
        preferences_item.activate.connect (() => {
            preferences_selected ();
        });
        menu.add (preferences_item);

        menu.show_all  ();
        
        // Create the AppMenu
        open_menu = new Gtk.MenuButton ();
        open_menu.set_image (new Gtk.Image.from_icon_name ("open-menu-symbolic", Gtk.IconSize.BUTTON));
        open_menu.set_tooltip_text ("Settings");

        open_menu.popup = menu;
        open_menu.relief = Gtk.ReliefStyle.NONE;
        open_menu.valign = Gtk.Align.CENTER;

        terminal.sensitive = false;

        // add button to headerbar
        pack_start (new_connection);
        pack_end (open_menu);
        pack_end (search);
        pack_end (terminal);
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