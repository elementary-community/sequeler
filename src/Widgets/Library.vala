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

public class Sequeler.Library : Gtk.Box {

    public Gtk.FlowBox item_box;
    public Gtk.ScrolledWindow scroll;
    public Gtk.Button delete_all;

    public signal void go_back ();

    public Library () {
        orientation = Gtk.Orientation.VERTICAL;

        width_request = 300;

        var toolbar = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        toolbar.get_style_context ().add_class ("toolbar");
        toolbar.get_style_context ().add_class ("library-toolbar");

        var go_back_button = new Gtk.Button.with_label (_("Go Back"));
        go_back_button.clicked.connect (() => { 
            go_back ();
        });

        go_back_button.get_style_context().add_class ("back-button");
        go_back_button.can_focus = false;
        go_back_button.margin = 12;

        var delete_image = new Gtk.Image.from_icon_name ("user-trash-symbolic", Gtk.IconSize.BUTTON);
        delete_all = new Gtk.Button.with_label (_("Delete All"));
        delete_all.get_style_context ().add_class ("destructive-action");
        delete_all.always_show_image = true;
        delete_all.set_image (delete_image);
        delete_all.clicked.connect (() => {
            confirm_delete_all ();
        });
        delete_all.can_focus = false;
        delete_all.margin = 12;

        if (settings.saved_connections.length == 0) {
            delete_all.sensitive = false;
        }

        if (! settings.show_library) {
            toolbar.pack_start (go_back_button, false, false, 0);
        }
        toolbar.pack_end (delete_all, false, false, 0);
        this.pack_start (toolbar, false, true, 0);

        scroll = new Gtk.ScrolledWindow (null, null);
        scroll.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);

        item_box = new Gtk.FlowBox ();
        
        item_box.valign = Gtk.Align.START;
        item_box.min_children_per_line = 1;
        item_box.max_children_per_line = 6;
        item_box.margin = 12;
        item_box.expand = false;

        scroll.add (item_box);

        foreach (var conn in settings.saved_connections) {
            add_item (conn);
        }

        this.pack_end (scroll, true, true, 0);
    }

    public void add_item (string connection) {
        var data = Sequeler.Settings.arraify_data (connection);

        var item = new Gtk.FlowBoxChild ();
        item.get_style_context ().add_class ("library-box");

        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        box.valign = Gtk.Align.START;
        box.get_style_context ().add_class ("library-card");
        box.margin = 10;

        var color_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        color_box.pack_start (new Gtk.Label (""), true, true, 0);
        color_box.get_style_context ().add_class ("library-colorbar");
        var color = Gdk.RGBA ();
        color.parse (data["color"]);
        color_box.override_background_color (Gtk.StateFlags.NORMAL, color);

        box.pack_start (color_box, true, false, 0);

        var title = new Gtk.Label (data["title"]);
        title.get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);

        box.pack_start (title, true, true, 10);

        var button_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        button_box.margin_left = 10;
        button_box.margin_right = 10;
        button_box.margin_bottom = 10;

        var connect_button = new BoxButton ("go-jump-symbolic", _("Connect"));

        var edit_button = new BoxButton ("applications-office-symbolic", _("Edit Connection"));
        edit_button.margin_right = 10;
        var delete_button = new BoxButton ("user-trash-symbolic", _("Delete Connection"));

        button_box.pack_end (connect_button, false, true, 0);
        button_box.pack_start (delete_button, false, true, 0);
        button_box.pack_start (edit_button, false, true, 0);

        box.pack_end (button_box, true, false, 0);

        item.add (box);
        item_box.add (item);

        delete_button.clicked.connect (() => {
            confirm_delete (item, data);
        });

        delete_all.sensitive = true;
    }

    public void confirm_delete (Gtk.FlowBoxChild item, Gee.HashMap<string, string> data) {
        var message_dialog = new Sequeler.MessageDialog.with_image_from_icon_name ("Are you sure you want to proceed?", "By deleting this connection you won't be able to recover this data.", "dialog-warning", Gtk.ButtonsType.CANCEL);
        message_dialog.transient_for = window;
        
        var suggested_button = new Gtk.Button.with_label ("Yes, Delete!");
        suggested_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
        message_dialog.add_action_widget (suggested_button, Gtk.ResponseType.ACCEPT);

        message_dialog.show_all ();
        if (message_dialog.run () == Gtk.ResponseType.ACCEPT) {
            settings.delete_connection (data);
            item_box.remove (item);
            item_box.show_all ();
            if (settings.saved_connections.length == 0) {
                delete_all.sensitive = false;
            }
        }
        
        message_dialog.destroy ();
    }

    public void confirm_delete_all () {
        var message_dialog = new Sequeler.MessageDialog.with_image_from_icon_name ("Are you sure you want to proceed?", "All the data will be deleted and you won't be able to recover it.", "dialog-warning", Gtk.ButtonsType.CANCEL);
        message_dialog.transient_for = window;
        
        var suggested_button = new Gtk.Button.with_label ("Yes, Delete All!");
        suggested_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
        message_dialog.add_action_widget (suggested_button, Gtk.ResponseType.ACCEPT);

        message_dialog.show_all ();
        if (message_dialog.run () == Gtk.ResponseType.ACCEPT) {
            settings.clear_connections ();
            item_box.forall ((item) => item_box.remove (item));
            item_box.show_all ();
            delete_all.sensitive = false;
        }
        
        message_dialog.destroy ();
    }

    protected class BoxButton : Gtk.Button {
        
        public BoxButton (string icon_name, string tooltip) {
            can_focus = false;

            Gtk.Image image;

            if (icon_name.contains ("/")) {
                image = new Gtk.Image.from_resource (icon_name);
            } else {
                image = new Gtk.Image.from_icon_name (icon_name, Gtk.IconSize.BUTTON);
            }

            image.margin = 3;

            set_tooltip_text (tooltip);
            get_style_context ().add_class ("btn-headerbar");
            this.add (image);
        }
    }
}