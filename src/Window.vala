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

public class Sequeler.Window : Gtk.ApplicationWindow {

    /* Core Componenets */
    private Gtk.Stack panels;
    private Granite.Widgets.Welcome welcome;

    public Window (Gtk.Application app) {
        // Store the main app to be used
        Object (application: app);

        // Build the UI
        build_ui ();
        build_headerbar ();
        build_panels ();
        handle_shortcuts ();

        // Update UI based on user settings
        move (settings.pos_x, settings.pos_y);
        resize (settings.window_width, settings.window_height);

        // Show the app
        show_app ();
    }

    private void build_ui () {
        // User can decide theme color
        Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = settings.dark_theme;

        var css_provider = new Gtk.CssProvider ();
        css_provider.load_from_resource ("/com/github/alecaddd/sequeler/stylesheet.css");
        
        Gtk.StyleContext.add_provider_for_screen (
            Gdk.Screen.get_default (), css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        );

        set_border_width (10);
        destroy.connect (Gtk.main_quit);
    }

    private void build_headerbar () {
        var headerbar = Sequeler.HeaderBar.get_instance ();

        headerbar.preferences_selected.connect (() => {
            open_preference ();
        });

        headerbar.quick_connection.connect (() => {
            create_connection ();
        });
        
        set_titlebar (headerbar);
    }

    private void build_panels () {
        welcome = new Granite.Widgets.Welcome (_("Welcome to Sequeler"), _("Connect to any Local or Remote Database"));
        welcome.append ("bookmark-new", _("Add New Database"), _("Connect to a Database and save it in your Library."));
        welcome.append ("preferences-system-network", _("Browse Library"), _("Browse through all your saved Databases."));
        //  welcome.activated.connect(on_welcome);

        welcome.activated.connect ((index) => {
            switch (index) {
                case 0:
                    create_connection ();
                    break;
                case 1:
                    break;
             }
        });

        panels = new Gtk.Stack();
        panels.transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT;
        panels.transition_duration = 300;

        panels.add_titled(welcome, "welcome", _("Welcome"));

        // add stackswitcher to vertical box
        Gtk.Box vbox = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
        vbox.pack_start(panels, true, true, 0);

        add(vbox);
    }

    private void handle_shortcuts () {
        this.key_press_event.connect ( (e) => {
            bool handled = false;

            // Was the control key pressed?
            if((e.state & Gdk.ModifierType.CONTROL_MASK) != 0) {
                switch (e.keyval) {
                    case Gdk.Key.q:
                        this.destroy();
                        handled = true;
                        break;
                    case Gdk.Key.n:
                        create_connection ();
                        handled = true;
                        break;
                    case Gdk.Key.f:
                        //  on_show_search ();
                        handled = true;
                        break;
                    case Gdk.Key.comma:
                        open_preference ();
                        handled = true;
                        break;
                    default:
                        break;
                }
            }

            return handled;
        });
    }

    public void open_preference () {
        var settings_dialog = new Sequeler.Widgets.SettingsDialog (this, settings);
        settings_dialog.show_all ();
    }

    public void create_connection () {
        var connection_dialog = new Sequeler.Widgets.ConnectionDialog (this, settings);

        connection_dialog.save_connection.connect ((data) => {
            save_connection (data);
        });
        
        connection_dialog.show_all ();
    }

    public void save_connection (Gee.HashMap<string, string> data) {
        settings.add_connection (data);
    }

    public void connect (string data) {
        var connection = Sequeler.Services.Connect.connect (data);

        if (connection != null) {
            //  panels.set_visible_child_full ("database", Gtk.StackTransitionType.SLIDE_RIGHT);
        }
    }

    protected override bool delete_event (Gdk.EventAny event) {
        int width, height, x, y;

        get_size (out width, out height);
        get_position (out x, out y);

        settings.pos_x = x;
        settings.pos_y = y;
        settings.window_width = width;
        settings.window_height = height;

        return false;
    }

    public void show_app () {
        show_all ();
        show ();
        present ();
    }
}