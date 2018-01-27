/*
* Copyright (c) 2011-2018 Alecaddd (http://alecaddd.com)
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

public class Sequeler.Partials.LibraryItem : Gtk.FlowBoxChild {
    public Gee.HashMap<string, string> data;

    public Gtk.MenuItem connect_button;
    public Gtk.Spinner spinner;

    public signal void edit_dialog (Gee.HashMap data);
    public signal void confirm_delete (Gtk.FlowBoxChild item, Gee.HashMap data);
    public signal void connect_to (Gee.HashMap data, Gtk.Spinner spinner, Gtk.MenuItem button);

    public LibraryItem (Gee.HashMap<string, string> data) {
        this.data = data;
        get_style_context ().add_class ("library-box");
        expand = true;

        var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        box.get_style_context ().add_class ("library-inner-box");
        box.margin = 4;

        var color_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        color_box.get_style_context ().add_class ("library-colorbox");
        color_box.set_size_request (12, 12);
        color_box.margin = 10;

        var color = Gdk.RGBA ();
        color.parse (data["color"]);
        try
        {
            var style = new Gtk.CssProvider ();
            style.load_from_data ("* {background-color: %s;}".printf (color.to_string ()), -1);
            color_box.get_style_context ().add_provider (style, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
        }
        catch (Error e)
        {
            debug ("Internal error loading session chooser style: %s", e.message);
        }

        var title = new Gtk.Label (data["title"]);
        title.get_style_context ().add_class ("text-bold");
        title.halign = Gtk.Align.START;
        title.margin_end = 10;
        title.set_line_wrap (true);

        box.pack_start (color_box, false, false, 0);
        box.pack_start (title, true, true, 0);

        // Create the Menu
        var menu = new Gtk.Menu ();
        
        connect_button = new Gtk.MenuItem.with_label (_("Connect"));
        menu.add (connect_button);

        var edit_button = new Gtk.MenuItem.with_label (_("Edit Connection"));
        menu.add (edit_button);

        menu.add (new Gtk.SeparatorMenuItem ());

        var delete_button = new Gtk.MenuItem.with_label (_("Delete Connection"));
        menu.add (delete_button);

        menu.show_all  ();
        
        // Create the AppMenu
        var open_menu = new Gtk.MenuButton ();
        open_menu.set_image (new Gtk.Image.from_icon_name ("view-more-symbolic", Gtk.IconSize.SMALL_TOOLBAR));
        open_menu.get_style_context ().add_class ("library-btn");
        open_menu.set_tooltip_text ("Options");

        open_menu.popup = menu;
        open_menu.relief = Gtk.ReliefStyle.NONE;
        open_menu.valign = Gtk.Align.CENTER;

        spinner = new Gtk.Spinner ();

        box.pack_end (open_menu, false, false, 0);
        box.pack_end (spinner, false, false, 0);

        var event_box = new Gtk.EventBox ();
        event_box.add (box);
        this.add (event_box);

        delete_button.activate.connect (() => {
            confirm_delete (this, data);
        });

        edit_button.activate.connect (() => {
            edit_dialog (data);
        });

        connect_button.activate.connect (() => {
            spinner.start ();
            connect_button.sensitive = false;
            connect_to (data, spinner, connect_button);
        });

        event_box.enter_notify_event.connect ((event) => {
            box.set_state_flags (Gtk.StateFlags.PRELIGHT, true);
            return false;
        });

        event_box.leave_notify_event.connect ((event) => {
            if (event.detail != Gdk.NotifyType.INFERIOR) {
                box.set_state_flags (Gtk.StateFlags.NORMAL, true);
            }
            return false;
        });
    }
}