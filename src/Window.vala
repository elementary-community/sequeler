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
    public Gtk.Overlay overlay;
    public Gtk.Stack panels;
    public Sequeler.Welcome welcome;
    public Granite.Widgets.Toast toast_saved;

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

        set_border_width (0);
        destroy.connect (Gtk.main_quit);
    }

    private void build_headerbar () {
        headerbar = Sequeler.HeaderBar.get_instance ();

        headerbar.preferences_selected.connect (() => {
            open_preference ();
        });

        headerbar.quick_connection.connect (() => {
            create_connection ();
        });
        
        set_titlebar (headerbar);
    }

    private void build_panels () {
        welcome = new Sequeler.Welcome ();
        
        welcome.create_connection.connect (() => {
            create_connection ();
        });

        overlay = new Gtk.Overlay ();
        panels = new Gtk.Stack ();
        panels.transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT;
        panels.transition_duration = 300;
        panels.homogeneous = false;

        panels.add_titled (welcome, "welcome", _("Welcome"));

        // add stackswitcher to vertical box
        Gtk.Box vbox = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        vbox.pack_start(panels, true, true, 0);

        toast_saved = new Granite.Widgets.Toast (_("Connection Saved!"));
        overlay.add_overlay (toast_saved);

        overlay.add (vbox);

        add (overlay);
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
                    case Gdk.Key.l:
                        show_library ();
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
        var settings_dialog = new Sequeler.SettingsDialog (this, settings);

        settings_dialog.show_all ();
    }

    public void create_connection () {
        var connection_dialog = new Sequeler.ConnectionDialog (this, settings);

        connection_dialog.save_connection.connect ((data) => {
            welcome.reload (data);
            toast_saved.send_notification ();
        });

        connection_dialog.show_all ();
    }

    public void show_library () {
        welcome.welcome_stack.set_visible_child_full ("library", Gtk.StackTransitionType.SLIDE_LEFT);
        headerbar.show_back_button ();
    }

    public void connect (string data) {
        var connection = Sequeler.Connect.connect (data);

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