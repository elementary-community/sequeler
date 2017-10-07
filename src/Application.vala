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
    public Sequeler.Window window;
    public Sequeler.Settings settings;
    public Sequeler.HeaderBar headerbar; 
}

public class Sequeler.Application : Granite.Application {

    public const string PROGRAM_NAME = "Sequeler";
    public const string ABOUT_STOCK = "About Sequeler";

    // Avoid multiple instances
    public bool running = false;

    construct {
        flags |= ApplicationFlags.HANDLES_OPEN;

        application_id = "com.github.alecaddd.sequeler";
        program_name = PROGRAM_NAME;
        app_years = "2017";
        exec_name = "sequeler";
        app_launcher = "com.github.alecaddd.sequeler";
        exec_name = "com.github.alecaddd.sequeler";
        app_launcher = "com.github.alecaddd.sequeler.desktop";

        build_version = "0.1.5";
        app_icon = "com.github.alecaddd.sequeler";
        main_url = "https://github.com/Alecaddd/sequeler/";
        bug_url = "https://github.com/Alecaddd/sequeler/issues";
        help_url = "https://github.com/Alecaddd/sequeler/";
        translate_url = "https://github.com/Alecaddd/sequeler/tree/master/po";
        about_authors = {"Alessandro Castellani <castellani.ale@gmail.com>", null};
        about_translators = _("translator-credits");

        about_license_type = Gtk.License.GPL_3_0;

    }

    protected override void activate () {

        if (!running) {
            settings = Sequeler.Settings.get_instance ();
            window = new Sequeler.Window (this);
            this.add_window (window);

            running = true;

            return;
        }

        window.show_app ();

    }
}