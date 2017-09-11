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

public class Sequeler.Widgets.ConnectionDialog : Gtk.Dialog {

    public ConnectionDialog (Gtk.ApplicationWindow parent, Sequeler.Services.Settings settings) {
        
        Object (
            use_header_bar: 0,
            border_width: 20,
            modal: true,
            deletable: false,
            resizable: false,
            title: _("Quick Connection"),
            transient_for: parent
        );

    }

    construct {

        var main_stack = new Gtk.Stack ();
        main_stack.set_transition_type(Gtk.StackTransitionType.SLIDE_LEFT_RIGHT);
        main_stack.set_transition_duration(320);
        main_stack.halign = Gtk.Align.CENTER;
        main_stack.margin = 6;
        main_stack.margin_bottom = 25;
        main_stack.margin_top = 15;

        main_stack.add_titled (get_socket_box (), "socket", _("Socket"));
        main_stack.add_titled (get_ftp_box (), "ftp", _("FTP"));
        main_stack.add_titled (get_ssh_box (), "ssh", _("SSH"));

        var main_stackswitcher = new Gtk.StackSwitcher ();
        main_stackswitcher.set_stack (main_stack);
        main_stackswitcher.halign = Gtk.Align.CENTER;

        var main_grid = new Gtk.Grid ();
        main_grid.halign = Gtk.Align.CENTER;
        main_grid.attach (main_stackswitcher, 1, 1, 1, 1);
        main_grid.attach (main_stack, 1, 2, 1, 1);

        var cancel_button = new DialogButton (_("Cancel"));

        var test_button = new DialogButton (_("Test Connection"));
        test_button.sensitive = false;

        var save_button = new DialogButton (_("Save Connection"));
        save_button.sensitive = false;

        var connect_button = new PrimaryButton (_("Connect"));
        connect_button.sensitive = false;

        add_action_widget (cancel_button, 1);
        add_action_widget (test_button, 0);
        add_action_widget (save_button, 0);
        add_action_widget (connect_button, 0);

        get_content_area ().add (main_grid);

        connect_signals ();

    }

    private Gtk.Widget get_socket_box () {
        var grid = new DialogGrid ();        

        grid.attach (new DialogHeader (_("Connect to a Local Socket")), 1, 1, 1, 1);
        grid.attach (new SettingsView(), 0, 2, 20, 40);

        return grid;
    }

    private Gtk.Widget get_ftp_box () {
        var grid = new DialogGrid ();        

        grid.attach (new DialogHeader (_("Connect to a Remote Host")), 1, 1, 1, 1);        

        return grid;
    }

    private Gtk.Widget get_ssh_box () {
        var grid = new DialogGrid ();

        grid.attach (new DialogHeader (_("Connect via SSH")), 1, 1, 1, 1);        

        return grid;
    }

    private void connect_signals () {
        this.response.connect (on_response);
    }

    private void on_response (Gtk.Dialog source, int response_id) {
        switch (response_id) {
        case 1:
            destroy ();
            break;
        }
    }

    private class DialogGrid : Gtk.Grid {
        public DialogGrid () {
            column_spacing = 12;
            row_spacing = 6;
            halign = Gtk.Align.CENTER;
        }
    }

    private class DialogHeader : Gtk.Label {
        public DialogHeader (string text) {
            label = text;
            get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);
            halign = Gtk.Align.CENTER;
        }
    }

    private class DialogButton : Gtk.Button {
        public DialogButton (string text) {
            label = text;
        }
    }

    private class PrimaryButton : Gtk.Button {
        public PrimaryButton (string text) {
            label = text;
            var style_context = this.get_style_context ();
            style_context.add_class ("suggested-action");
        }
    }

    public class SettingsView : Granite.SimpleSettingsPage {
        public SettingsView () {
            Object (
                activatable: false,
                description: "This is a demo of Granite's SimpleSettingsPage",
                icon_name: "preferences-system",
                title: "SimpleSettingsPage"
            );
    
            var icon_label = new Gtk.Label ("Icon Name:");
            icon_label.xalign = 1;
    
            var icon_entry = new Gtk.Entry ();
            icon_entry.hexpand = true;
            icon_entry.placeholder_text = "This page's icon name";
            icon_entry.text = icon_name;
    
            var title_label = new Gtk.Label ("Title:");
            title_label.xalign = 1;
    
            var title_entry = new Gtk.Entry ();
            title_entry.hexpand = true;
            title_entry.placeholder_text = "This page's title";
    
            var description_label = new Gtk.Label ("Description:");
            description_label.xalign = 1;
    
            var description_entry = new Gtk.Entry ();
            description_entry.hexpand = true;
            description_entry.placeholder_text = "This page's description";
    
            content_area.attach (icon_label, 0, 0, 1, 1);
            content_area.attach (icon_entry, 1, 0, 1, 1);
            content_area.attach (title_label, 0, 1, 1, 1);
            content_area.attach (title_entry, 1, 1, 1, 1);
            content_area.attach (description_label, 0, 2, 1, 1);
            content_area.attach (description_entry, 1, 2, 1, 1);
    
        }
    }
}