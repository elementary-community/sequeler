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

public class Sequeler.Widgets.ConnectionDialog : Gtk.Dialog {
    private Gtk.Stack main_stack;

    public Sequeler.Partials.ButtonClass test_button;
    public Sequeler.Partials.ButtonClass connect_button;

    public ConnectionDialog (Gtk.Window? parent) {
        Object (
            border_width: 5,
            deletable: false,
            resizable: false,
            title: _("Preferences"),
            transient_for: parent
        );
    }

    construct {
        main_stack = new Gtk.Stack ();
        main_stack.margin = 6;
        main_stack.margin_bottom = 15;
        main_stack.margin_top = 15;

        var cancel_button = new Sequeler.Partials.ButtonClass (_("Close"), null);
        var save_button = new Sequeler.Partials.ButtonClass (_("Save Connection"), null);

        test_button = new Sequeler.Partials.ButtonClass (_("Test Connection"), null);
        test_button.sensitive = false;

        connect_button = new Sequeler.Partials.ButtonClass (_("Connect"), "suggested-action");
        connect_button.sensitive = false;

        add_action_widget (test_button, 1);
        add_action_widget (save_button, 2);
        add_action_widget (cancel_button, 3);
        add_action_widget (connect_button, 4);

        response.connect (on_response);
    }

    private void on_response (Gtk.Dialog source, int response_id) {
        switch (response_id) {
            case 1:
                //  test_connection ();
                break;
            case 2:
                //  save_data (true);
                break;
            case 3:
                destroy ();
                break;
            case 4:
                //  init_connection ();
                break;
        }
    }
}