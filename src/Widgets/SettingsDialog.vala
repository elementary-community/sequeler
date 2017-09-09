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

public class Sequeler.Widgets.SettingsDialog : Gtk.Dialog {

    private Gtk.Label dark_theme_label;
    private Gtk.Switch dark_theme;

    public Gtk.Box content_box;
    private Sequeler.Services.Settings settings;

    public SettingsDialog () {

        Object (use_header_bar: 1);

        set_title (_("Preferences"));
        set_border_width (5);
        set_default_size (500, 300);
        
        build_ui ();
    }

    private void build_ui () {
        this.modal = true;
        this.settings = Sequeler.Services.Settings.get_instance ();

        content_box = get_content_area () as Gtk.Box;
        content_box.homogeneous = false;
        content_box.margin = 10;
        
        // dark_theme option
        dark_theme_label = new Gtk.Label (_("Use Dark Theme:"));
        dark_theme_label.justify = Gtk.Justification.LEFT;
        dark_theme_label.set_property ("xalign", 0);
        dark_theme_label.margin_end = 10;
        
        dark_theme = new Gtk.Switch();
        
        dark_theme.set_active(settings.dark_theme);
        dark_theme.notify["active"].connect (() => {
            settings.dark_theme = dark_theme.active;
            Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = settings.dark_theme;
        });
        
        var dark_theme_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        dark_theme_box.margin_bottom = 10;
        dark_theme_box.pack_start(dark_theme_label, true, true, 0);
        dark_theme_box.pack_start(dark_theme, false, false, 0);
        content_box.add(dark_theme_box);
    }

}