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
    public class Window : Gtk.ApplicationWindow {
        public Gtk.Box topbar;
        public Gtk.Overlay overlay;
        public Granite.Widgets.OverlayBar overlaybar;
        public Gtk.Stack panels;
        public Welcome welcome;
        public DataBase db;

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
            topbar = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);

            headerbar = HeaderBar.get_instance ();
            toolbar = ToolBar.get_instance ();

            headerbar.preferences_selected.connect (() => {
                open_preference ();
            });

            headerbar.quick_connection.connect (() => {
                create_connection (null);
            });

            headerbar.logout.connect (() => {
                db.close ();
                db = null;
                welcome.welcome_stack.set_visible_child_full ("welcome_box", Gtk.StackTransitionType.SLIDE_RIGHT);
                headerbar.logout_button.visible = false;
                topbar.remove (toolbar);
                topbar.show_all ();
                set_titlebar (topbar);
            });

            toolbar.tabs.mode_changed.connect ((tab) => {
                welcome.database.db_stack.set_visible_child_name (tab.name);
                welcome.database.reload_data (tab.name);
            });

            topbar.add (headerbar);
            
            set_titlebar (topbar);
        }

        private void build_panels () {
            welcome = new Welcome ();
            
            welcome.create_connection.connect ((data) => {
                create_connection (data);
            });

            welcome.init_connection.connect ((data, spinner, button) => {
                db = new DataBase ();
                var encode_data = encode_data (data);
                db.set_constr_data (encode_data);

                var loop = new MainLoop ();
                init_connection.begin (encode_data, spinner, button, (obj, res) => {
                    try {
                        Gee.HashMap<string, string> result = init_connection.end (res);
                        if (result["status"] == "true") {
                            spinner.stop ();
                            button.sensitive = true;
                            open_database_view (encode_data);
                        } else {
                            connection_warning (result["msg"], encode_data["title"]);
                            button.sensitive = true;
                            spinner.stop ();
                        }
                    } catch (ThreadError e) {
                        connection_warning (e.message, encode_data["title"]);
                        button.sensitive = true;
                        spinner.stop ();
                    }
                    loop.quit ();
                });
                loop.run();
            });

            welcome.execute_query.connect((query) => {
                int result = 0;
                var loop = new MainLoop ();
                run_query.begin (query, (obj, res) => {
                    try {
                        result = run_query.end (res);
                    } catch (ThreadError e) {
                        render_error (e.message);
                        result = 0;
                    }
                    loop.quit ();
                });
                loop.run ();
                return result;
            });

            welcome.execute_select.connect((query) => {
                if (query.length == 0) {
                    return null;
                }

                Gda.DataModel? result = null;
                var loop = new MainLoop ();
                run_select.begin (query, (obj, res) => {
                    try {
                        result = run_select.end (res);
                    } catch (ThreadError e) {
                        render_error (e.message);
                        result = null;
                    }
                    loop.quit ();
                });
                loop.run ();
                return result;
            });

            overlay = new Gtk.Overlay ();

            overlay.add (welcome);
            add (overlay);
        }

        public void render_error (string? error) {
            welcome.database.render_query_error (error);
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
                            if (db == null) {
                                create_connection (null);
                                handled = true;
                            }
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
            var settings_dialog = new SettingsDialog (this, settings);
            settings_dialog.show_all ();
        }

        public void create_connection (Gee.HashMap? data) {
            var connection_dialog = new ConnectionDialog (this, settings, data);

            connection_dialog.save_connection.connect ((data, trigger) => {
                welcome.reload (data);
                if (trigger) {
                    connection_dialog.response_msg.label = "Connection Saved!";
                }
            });

            connection_dialog.connect_to.connect ((data, spinner, dialog, response) => {
                db = new DataBase ();
                var encode_data = encode_data (data);
                db.set_constr_data (encode_data);

                var loop = new MainLoop ();
                init_connection_from_dialog.begin (spinner, response, (obj, res) => {
                    try {
                        Gee.HashMap<string, string> result = init_connection_from_dialog.end (res);
                        if (result["status"] == "true") {
                            loop.quit ();
                            dialog.destroy ();
                            open_database_view (encode_data);
                        } else {
                            response.label = result["msg"];
                            spinner.stop ();
                        }
                    } catch (ThreadError e) {
                        response.label = e.message;
                        spinner.stop ();
                    }
                    loop.quit ();
                });
                loop.run();
            });

            connection_dialog.show_all ();
        }

        public Gee.HashMap<string, string> encode_data (Gee.HashMap<string, string> data){
            data.set ("host", Gda.rfc1738_encode (data["host"]));
            data.set ("name", Gda.rfc1738_encode (data["name"]));
            data.set ("username", Gda.rfc1738_encode (data["username"]));
            data.set ("password", Gda.rfc1738_encode (data["password"]));
            return data;
        }

        public async Gee.HashMap<string, string> init_connection_from_dialog (Gtk.Spinner spinner, Gtk.Label response) throws ThreadError {
            var output = new Gee.HashMap<string, string> ();
            output["status"] = "false";
            SourceFunc callback = init_connection_from_dialog.callback;

            new Thread <void*> (null, () => {
                bool result = false;
                string msg = "";
                try {
                    db.open();
                    if (db.cnn.is_opened ()) {
                        result = true;
                    }
                }
                catch (Error e) {
                    result = false;
                    msg = e.message;
                }
                Idle.add((owned) callback);
                output["status"] = result.to_string ();
                output["msg"] = msg;
                return null;
            });

            yield;
            return output;
        }

        public async Gee.HashMap<string, string> init_connection (Gee.HashMap<string, string> data, Gtk.Spinner spinner, Gtk.MenuItem button) throws ThreadError {
            var output = new Gee.HashMap<string, string> ();
            output["status"] = "false";
            SourceFunc callback = init_connection.callback;

            new Thread <void*> (null, () => {
                bool result = false;
                string msg = "";
                try {
                    db.open();
                    if (db.cnn.is_opened ()) {
                        result = true;
                    }
                }
                catch (Error e) {
                    result = false;
                    msg = e.message;
                }
                Idle.add((owned) callback);
                output["status"] = result.to_string ();
                output["msg"] = msg;
                return null;
            });

            yield;
            return output;
        }

        public void connection_warning (string message, string title) {
            var message_dialog = new Granite.MessageDialog.with_image_from_icon_name (_("Unable to Connect to ") + title + "", message, "dialog-error", Gtk.ButtonsType.NONE);
            message_dialog.transient_for = window;
            
            var suggested_button = new Gtk.Button.with_label ("Close");
            message_dialog.add_action_widget (suggested_button, Gtk.ResponseType.ACCEPT);

            message_dialog.show_all ();
            if (message_dialog.run () == Gtk.ResponseType.ACCEPT) {}
            
            message_dialog.destroy ();
        }

        public async int run_query (string query) throws ThreadError {
            output_query = 0;
            SourceFunc callback = run_query.callback;

            new Thread <void*> (null, () => {
                int result = 0;
                try {
                    result = db.run_query (query);
                }
                catch (Error e) {
                    render_error (e.message);
                    result = 0;
                }
                Idle.add((owned) callback);
                output_query = result;
                return null;
            });

            yield;
            return output_query;
        }

        public async Gda.DataModel? run_select (string query) throws ThreadError {
            output_select = null;
            SourceFunc callback = run_select.callback;

            new Thread <void*> (null, () => {
                Gda.DataModel? result = null;
                try {
                    result = db.run_select (query);
                }
                catch (Error e) {
                    render_error (e.message);
                    result = null;
                }
                Idle.add((owned) callback);
                output_select = result;
                return null;
            });

            yield;
            return output_select;
        }

        public void query_error (Error e) {
            var message_dialog = new Granite.MessageDialog.with_image_from_icon_name (_("Unable to Execute Query"), e.message, "dialog-error", Gtk.ButtonsType.NONE);
            message_dialog.transient_for = window;
            
            var suggested_button = new Gtk.Button.with_label ("Close");
            message_dialog.add_action_widget (suggested_button, Gtk.ResponseType.ACCEPT);

            message_dialog.show_all ();
            if (message_dialog.run () == Gtk.ResponseType.ACCEPT) {}
            
            message_dialog.destroy ();
        }

        public void open_database_view (Gee.HashMap<string, string> data) {
            topbar.add (toolbar);
            topbar.show_all ();
            set_titlebar (topbar);
            welcome.welcome_stack.set_visible_child_full ("database", Gtk.StackTransitionType.SLIDE_LEFT);
            headerbar.title = _("Connected to ") + data["title"];
            headerbar.subtitle = data["username"] + "@" + data["host"];
            headerbar.show_logout_button ();
            welcome.database.spinner.stop ();
            welcome.database.loading_msg.visible = false;
            welcome.database.result_message.label = "";
            welcome.database.query_builder.buffer.text = "";
            welcome.database.clear_results ();
            welcome.database.set_database_data (data);
            welcome.database.init_sidebar ();
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
}