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
    public Granite.Widgets.OverlayBar overlaybar;
    public Gtk.Stack panels;
    public Sequeler.Welcome welcome;
    public Sequeler.DataBase db;
    public Granite.Widgets.Toast toast_saved;

    public int output_query;
    public Gda.DataModel? output_select;

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
            create_connection (null);
        });

        headerbar.logout.connect (() => {
            db.close ();

            if (! settings.show_library) {
                welcome.welcome_stack.set_visible_child_full ("library", Gtk.StackTransitionType.SLIDE_RIGHT);
                headerbar.logout_button.visible = false;
                headerbar.show_back_button ();
            } else {
                welcome.welcome_stack.set_visible_child_full ("welcome", Gtk.StackTransitionType.SLIDE_RIGHT);
                headerbar.logout_button.visible = false;
            }
        });
        
        set_titlebar (headerbar);
    }

    private void build_panels () {
        welcome = new Sequeler.Welcome ();
        
        welcome.create_connection.connect ((data) => {
            create_connection (data);
        });

        welcome.init_connection.connect ((data, spinner, button) => {
            init_connection (data, spinner, button);
        });

        welcome.execute_query.connect((query) => {
            return run_query (query);
        });

        welcome.execute_select.connect((query) => {
            return run_select (query);
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
                        create_connection (null);
                        handled = true;
                        break;
                    case Gdk.Key.l:
                        if (! settings.show_library && db == null) {
                            show_library ();
                        }
                        handled = true;
                        break;
                    //  case Gdk.Key.f:
                    //      on_show_search ();
                    //      handled = true;
                    //      break;
                    //  case 65293:
                    //      Sequeler.DataBaseOpen.trigger_query ();
                    //      break;
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

    public void create_connection (Gee.HashMap? data) {
        var connection_dialog = new Sequeler.ConnectionDialog (this, settings, data);

        connection_dialog.save_connection.connect ((data, trigger) => {
            welcome.reload (data);
            if (trigger) {
                toast_saved.send_notification ();
            }
        });

        connection_dialog.show_all ();
    }

    public void show_library () {
        welcome.welcome_stack.set_visible_child_full ("library", Gtk.StackTransitionType.SLIDE_LEFT);
        headerbar.show_back_button ();
    }

    public void init_connection (Gee.HashMap<string, string> data, Gtk.Spinner spinner, Gtk.Button button) {
        data.set ("host", Gda.rfc1738_encode (data["host"]));
        data.set ("name", Gda.rfc1738_encode (data["name"]));
        data.set ("username", Gda.rfc1738_encode (data["username"]));
        data.set ("password", Gda.rfc1738_encode (data["password"]));

        db = new Sequeler.DataBase ();
        db.set_constr_data (data);

        GLib.Timeout.add_seconds(1, () => {
            try {
                db.open();
                if (db.cnn.is_opened ()) {
                    open_database_view (data);
                }
            }
            catch (Error e) {
                connection_warning (e, data["title"]);
            }
            spinner.stop ();
            button.sensitive = true;
            return false;
        });

    }

    public void connection_warning (Error e, string title) {
        var message_dialog = new Sequeler.MessageDialog.with_image_from_icon_name ("Unable to Connect to " + title + "", e.message, "dialog-error", Gtk.ButtonsType.NONE);
        message_dialog.transient_for = window;
        
        var suggested_button = new Gtk.Button.with_label ("Close");
        message_dialog.add_action_widget (suggested_button, Gtk.ResponseType.ACCEPT);

        message_dialog.show_all ();
        if (message_dialog.run () == Gtk.ResponseType.ACCEPT) {}
        
        message_dialog.destroy ();
    }

    public int run_query (string query) {
        try
        {
            output_query = db.run_query (query);
        }
        catch (Error e)
        {
            query_error (e);
        }
        return output_query;
    }

    public Gda.DataModel? run_select (string query) {
        try
        {
            output_select = db.run_select (query);
            return output_select;
        }
        catch (Error e)
        {
            query_error (e);
        }
        return null;
    }

    public void query_error (Error e) {
        var message_dialog = new Sequeler.MessageDialog.with_image_from_icon_name ("Unable to Execute Query", e.message, "dialog-error", Gtk.ButtonsType.NONE);
        message_dialog.transient_for = window;
        
        var suggested_button = new Gtk.Button.with_label ("Close");
        message_dialog.add_action_widget (suggested_button, Gtk.ResponseType.ACCEPT);

        message_dialog.show_all ();
        if (message_dialog.run () == Gtk.ResponseType.ACCEPT) {}
        
        message_dialog.destroy ();
    }

    public void open_database_view (Gee.HashMap<string, string> data) {
        welcome.welcome_stack.set_visible_child_full ("database", Gtk.StackTransitionType.SLIDE_LEFT);
        headerbar.title = "Connected to " + data["title"];
        headerbar.subtitle = data["username"] + "@" + data["host"];
        headerbar.go_back_button.visible = false;
        headerbar.show_logout_button ();
        welcome.database.spinner.stop ();
        welcome.database.loading_msg.visible = false;
        welcome.database.query_builder.buffer.text = "";
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