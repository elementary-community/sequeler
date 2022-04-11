/*
* Copyright (c) 2022 Alecaddd (https://alecaddd.com)
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
    private Settings settings;
    private Gtk.Paned paned;
    // public Sequeler.Layouts.Main main;
    // public Sequeler.Layouts.HeaderBar headerbar;
    // public Sequeler.Services.ActionManager action_manager;
    // public Sequeler.Services.DataManager data_manager;
    // public Sequeler.Widgets.ConnectionDialog? connection_dialog = null;

    // public Gtk.AccelGroup accel_group { get; construct; }

    public Window (Sequeler.Application app) {
        Object (
            application: app,
            icon_name: Constants.PROJECT_NAME
        );
    }

    construct {
        settings = new Settings (Constants.PROJECT_NAME);

        title = "Sequeler"; // Non translatable.
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
            hexpand = true
        };
        end_window_controls.add_css_class ("titlebar");
        end_window_controls.add_css_class (Granite.STYLE_CLASS_FLAT);
        end_window_controls.add_css_class (Granite.STYLE_CLASS_DEFAULT_DECORATION);

        var sidebar_header = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
            valign = Gtk.Align.START
        };
        sidebar_header.add_css_class ("titlebar");
        sidebar_header.add_css_class (Granite.STYLE_CLASS_FLAT);
        sidebar_header.add_css_class (Granite.STYLE_CLASS_DEFAULT_DECORATION);
        sidebar_header.append (start_window_controls);

        var sidebar = new Gtk.Grid ();
        sidebar.add_css_class (Granite.STYLE_CLASS_VIEW);
        sidebar.attach (sidebar_header, 0, 0);

        var sidebar_handle = new Gtk.WindowHandle () {
            child = sidebar
        };

        var main_header = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
            valign = Gtk.Align.START,
            halign = Gtk.Align.END
        };
        main_header.append (end_window_controls);

        var main = new Gtk.Grid ();
        main.attach (main_header, 0, 0);

        var main_handle = new Gtk.WindowHandle () {
            child = main
        };

        paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL) {
            position = settings.get_int ("sidebar-width"),
            start_child = sidebar_handle,
            end_child = main_handle,
            resize_end_child = true,
            shrink_end_child = false,
            shrink_start_child = false,
            resize_start_child = false
        };
        child = paned;

        close_request.connect (on_before_close);

        // accel_group = new Gtk.AccelGroup ();
        // add_accel_group (accel_group);

        // action_manager = new Sequeler.Services.ActionManager (app, this);
        // main = new Sequeler.Layouts.Main (this);
        // headerbar = new Sequeler.Layouts.HeaderBar (this);
        // data_manager = new Sequeler.Services.DataManager ();

        // build_ui ();
    }

    // public Sequeler.Window get_instance () {
    //     return this;
    // }

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

    public bool on_before_close () {
        update_status ();
        // app.get_active_window ().destroy ();
        return false;
    }

    private void update_status () {
        settings.set_int ("sidebar-width", paned.get_position ());
        // if (main.database_view.query.n_tabs > 0) {
        //     settings.query_area =
        //         (main.database_view.query.current.page as Layouts.Views.Query)
        //         .panels.get_position ();
        // }
    }
}
