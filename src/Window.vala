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

public class Sequeler.Window : Gtk.ApplicationWindow {
    // public Sequeler.Layouts.Main main;
    // public Sequeler.Layouts.HeaderBar headerbar;
    // public Sequeler.Services.ActionManager action_manager;
    // public Sequeler.Services.DataManager data_manager;
    // public Sequeler.Widgets.ConnectionDialog? connection_dialog = null;

    // public Gtk.AccelGroup accel_group { get; construct; }

    // public Window (Sequeler.Application sequeler_app) {
    //     Object (
    //         application: sequeler_app,
    //         app: sequeler_app,
    //         icon_name: Constants.PROJECT_NAME
    //     );
    // }

    construct {
        title = "Sequeler";
        default_height = 500;
        default_width = 800;

        var css_provider = new Gtk.CssProvider ();
        css_provider.load_from_data ("@define-color accent_color @MINT_500;".data);

        Gtk.StyleContext.add_provider_for_display (
            Gdk.Display.get_default (),
            css_provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        );

        // We need to hide the title area for the split headerbar.
        var null_title = new Gtk.Grid () {
            visible = false
        };
        set_titlebar (null_title);

        var start_window_controls = new Gtk.WindowControls (Gtk.PackType.START) {
            hexpand = true
        };

        var end_window_controls = new Gtk.WindowControls (Gtk.PackType.END) {
            hexpand = true,
            halign = Gtk.Align.END
        };
        end_window_controls.add_css_class ("titlebar");
        end_window_controls.add_css_class (Granite.STYLE_CLASS_FLAT);
        end_window_controls.add_css_class (Granite.STYLE_CLASS_DEFAULT_DECORATION);

        var sidebar = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
            valign = Gtk.Align.START
        };
        sidebar.add_css_class ("titlebar");
        sidebar.add_css_class (Granite.STYLE_CLASS_FLAT);
        sidebar.add_css_class (Granite.STYLE_CLASS_DEFAULT_DECORATION);
        sidebar.append (start_window_controls);

        var main_view = new Gtk.Grid ();
        main_view.add_css_class (Granite.STYLE_CLASS_VIEW);
        main_view.attach (end_window_controls, 0, 0);

        var paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL) {
            position = 250,
            start_child = sidebar,
            end_child = main_view,
            resize_end_child = false,
            shrink_end_child = false,
            shrink_start_child = false
        };

        child = paned;

        // accel_group = new Gtk.AccelGroup ();
        // add_accel_group (accel_group);

        // action_manager = new Sequeler.Services.ActionManager (app, this);
        // main = new Sequeler.Layouts.Main (this);
        // headerbar = new Sequeler.Layouts.HeaderBar (this);
        // data_manager = new Sequeler.Services.DataManager ();

        // build_ui ();

        // move (settings.pos_x, settings.pos_y);
        // resize (settings.window_width, settings.window_height);

        // show_app ();
    }

    public Sequeler.Window get_instance () {
        return this;
    }

    // private void build_ui () {
    //     Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = settings.dark_theme;

    //     var css_provider = new Gtk.CssProvider ();
    //     css_provider.load_from_resource ("/com/github/alecaddd/sequeler/stylesheet.css");

    //     Gtk.StyleContext.add_provider_for_screen (
    //         Gdk.Screen.get_default (), css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
    //     );

    //     set_titlebar (headerbar);
    //     set_border_width (0);

    //     delete_event.connect (before_destroy);

    //     add (main);
    // }

    // public bool before_destroy () {
    //     update_status ();
    //     app.get_active_window ().destroy ();
    //     return true;
    // }

    // private void update_status () {
    //     int width, height, x, y;

    //     get_size (out width, out height);
    //     get_position (out x, out y);

    //     settings.pos_x = x;
    //     settings.pos_y = y;
    //     settings.window_width = width;
    //     settings.window_height = height;
    //     settings.sidebar_width = main.get_position ();
    //     if (main.database_view.query.n_tabs > 0) {
    //         settings.query_area =
    //             (main.database_view.query.current.page as Layouts.Views.Query)
    //             .panels.get_position ();
    //     }
    // }

    // public void show_app () {
    //     show_all ();
    //     show ();
    //     present ();
    // }
}
