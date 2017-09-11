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
        main_grid.attach (main_stackswitcher, 0, 0, 1, 1);
        main_grid.attach (main_stack, 0, 1, 1, 1);

        //  add_button (_("Cancel"), 1);
        //  add_button (_("Test Connection"), 2);
        //  var connect_button = add_button (_("Connect"), 3);
        //  connect_button.get_style_context ().add_class ("suggested-action");
        //  connect_button.sensitive = false;
        //  var save_button = add_button (_("Save Connection"), 4);
        //  save_button.get_style_context ().add_class ("suggested-action");
        //  save_button.sensitive = false;
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
        var grid = new Gtk.Grid ();
        grid.column_spacing = 12;
        grid.row_spacing = 6;

        grid.attach (new DialogHeader (_("Connect to a Local Socket")), 0, 0, 1, 1);

        return grid;
    }

    private Gtk.Widget get_ftp_box () {
        var grid = new Gtk.Grid ();
        grid.column_spacing = 12;
        grid.row_spacing = 6;

        grid.attach (new DialogHeader (_("Connect to a Remote Host")), 0, 0, 1, 1);        

        return grid;
    }

    private Gtk.Widget get_ssh_box () {
        var grid = new Gtk.Grid ();
        grid.column_spacing = 12;
        grid.row_spacing = 6;

        grid.attach (new DialogHeader (_("Connect via SSH")), 0, 0, 1, 1);        

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

    private class DialogHeader : Gtk.Label {
        public DialogHeader (string text) {
            label = text;
            get_style_context ().add_class ("h4");
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
}