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

    private string css_file = "../data/stylesheet.css";

    public Window (Gtk.Application app) {
        // Store the main app to be used
        Object (application: app);

        // Build the UI
        build_ui ();
        build_headerbar ();
        build_test();

        show_app ();
    }

    private void build_ui () {
        // User can decide theme color
        // Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = true;

        var css_provider = new Gtk.CssProvider ();
        try {
            css_provider.load_from_path (css_file);
        } catch (GLib.Error e) {
            warning ("Error loading css styles from %s: %s", css_file, e.message);
        }
        
        Gtk.StyleContext.add_provider_for_screen (
            Gdk.Screen.get_default (), css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        );

        set_border_width(10);
        set_position(Gtk.WindowPosition.CENTER);
        set_default_size (900, 600);
        set_size_request (750, 500);
        destroy.connect (Gtk.main_quit);
    }

    private void build_headerbar () {
        var headerbar = Sequeler.HeaderBar.get_instance ();
        
        set_titlebar (headerbar);
    }

    public void build_test () {
        // create stack
        Gtk.Stack stack = new Gtk.Stack();
        stack.set_transition_type(Gtk.StackTransitionType.SLIDE_LEFT_RIGHT);

        // giving widgets to stack
        Gtk.Label label = new Gtk.Label("");
        label.set_markup("<big>A label</big>");
        stack.add_titled(label, "label", "A label");

        Gtk.Label label2 = new Gtk.Label("");
        label2.set_markup("<big>Another label</big>");
        stack.add_titled(label2, "label2", "Another label");

        // add stack(contains widgets) to stackswitcher widget
        Gtk.StackSwitcher stack_switcher = new Gtk.StackSwitcher();
        stack_switcher.halign = Gtk.Align.CENTER;
        stack_switcher.set_stack(stack);

        // add stackswitcher to vertical box
        Gtk.Box vbox = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
        vbox.pack_start(stack_switcher, false, false, 0);
        vbox.pack_start(stack, false, false, 10);

        add(vbox);
    }

    public void show_app () {
        show_all ();
        show ();
        present ();
    }
}