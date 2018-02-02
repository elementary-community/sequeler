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
    public Gee.HashMap? data { get; set; default = null; }

    public Sequeler.Partials.ButtonClass test_button;
    public Sequeler.Partials.ButtonClass connect_button;

    private Gtk.Label header_title;
    private Gtk.ColorButton color_picker;

    private Gtk.Spinner spinner;
    private Sequeler.Partials.ResponseMessage response_msg;

    public ConnectionDialog (Gtk.Window? parent) {
        Object (
            border_width: 5,
            deletable: false,
            resizable: false,
            title: _("Connection"),
            transient_for: parent
        );
    }

    construct {
        build_content ();
        build_actions ();

        response.connect (on_response);
    }

    private void build_content () {
        var header_grid = new Gtk.Grid ();
        header_grid.margin_start = 5;
        header_grid.margin_end = 5;
        header_grid.margin_bottom = 20;

        var image = new Gtk.Image.from_icon_name ("drive-multidisk", Gtk.IconSize.DIALOG);
        image.margin_end = 10;

        header_title = new Gtk.Label (_("New Connection"));
        header_title.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);
        header_title.halign = Gtk.Align.START;
        header_title.margin_end = 10;
        header_title.set_line_wrap (true);
        header_title.hexpand = true;

        color_picker = new Gtk.ColorButton.with_rgba ({ 222, 222, 222, 255 });
        color_picker.set_use_alpha (true);
        color_picker.get_style_context ().add_class ("color-picker");
        color_picker.can_focus = false;

        header_grid.attach (image, 0, 0, 1, 2);
        header_grid.attach (header_title, 1, 0, 1, 2);
        header_grid.attach (color_picker, 2, 0, 1, 1);

        get_content_area ().add (header_grid);

        spinner = new Gtk.Spinner ();
        response_msg = new Sequeler.Partials.ResponseMessage ();

        get_content_area ().add (spinner);
        get_content_area ().add (response_msg);
    }

    private void build_actions () {
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

    public void toggle_spinner (bool type) {
        if (type == true) {
            spinner.start ();
            return;
        }

        spinner.stop ();
    }

    public void write_response (string? response_text) {
        response_msg.label = response_text;
    }
}