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
    
}

public class Sequeler.Application : Granite.Application {

    construct {
        flags |= ApplicationFlags.HANDLES_OPEN;

        application_id = "com.github.alecaddd.sequeler";
        program_name = "Sequeler";
        app_years = "2017";
        exec_name = "sequeler";
        app_launcher = "com.github.alecaddd.sequeler";

        build_version = "0.1";
        app_icon = "com.github.alecaddd.sequeler";
        main_url = "https://github.com/alecaddd/sequeler/";
        bug_url = "https://github.com/alecaddd/sequeler/issues";
        help_url = "https://github.com/alecaddd/sequeler/";
        translate_url = "https://github.com/alecaddd/sequeler/tree/master/po";
        about_authors = {"Alessandro Castellani <castellani.ale@gmail.com>", null};
        about_translators = _("translator-credits");

        about_license_type = Gtk.License.GPL_3_0;
    }

    protected override void activate () {

        var window = new Gtk.ApplicationWindow (this);
        window.title = "Sequeler";
        window.set_border_width(10);
        window.set_position(Gtk.WindowPosition.CENTER);
        window.set_default_size (900, 600);
        window.set_size_request (750, 500);
        //  window.destroy.connect (Gtk.main_quit);

        var headerbar = Sequeler.HeaderBar.get_instance ();

        window.set_titlebar (headerbar);
        window.add (headerbar);

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

        window.add(vbox);

        window.show_all ();
        window.show ();
    }
}