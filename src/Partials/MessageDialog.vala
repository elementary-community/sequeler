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
    public class MessageDialog : Gtk.Dialog {
        /**
         * The primary text, title of the dialog.
         */
        public string primary_text { 
            get {
                return primary_label.label;
            }

            set {
                primary_label.label = value;
            }
        }

        /**
         * The secondary text, body of the dialog.
         */
        public string secondary_text { 
            get {
                return secondary_label.label;
            }

            set {
                secondary_label.label = value; 
            }
        }

        /**
         * The {@link GLib.Icon} that is used to display the image
         * on the left side of the dialog.
         */
        public GLib.Icon image_icon { 
            owned get {
                return image.gicon;
            }
            
            set {
                image.set_from_gicon (value, Gtk.IconSize.DIALOG);
            }
        }

        /**
         * The {@link Gtk.Label} that displays the {@link Granite.MessageDialog.primary_text}.
         * 
         * Most of the times, you will only want to modify the {@link Granite.MessageDialog.primary_text} string, 
         * this is available to set additional properites like {@link Gtk.Label.use_markup} if you wish to do so.
         */
        public Gtk.Label primary_label { get; construct; }

        /**
         * The {@link Gtk.Label} that displays the {@link Granite.MessageDialog.secondary_text}.
         *
         * Most of the times, you will only want to modify the {@link Granite.MessageDialog.secondary_text} string, 
         * this is available to set additional properites like {@link Gtk.Label.use_markup} if you wish to do so.
         */
        public Gtk.Label secondary_label { get; construct; }

        /**
         * The {@link Gtk.ButtonsType} value to display a set of buttons
         * in the dialog.
         * 
         * By design, some actions are not acceptable and such action values will not be added to the dialog, these include:
         *
         *  * {@link Gtk.ButtonsType.OK}
         *  * {@link Gtk.ButtonsType.YES_NO}
         *  * {@link Gtk.ButtonsType.OK_CANCEL}
         *
         * If you wish to provide more specific actions for your dialog
         * pass a {@link Gtk.ButtonsType.NONE} to {@link Granite.MessageDialog.MessageDialog} and manually
         * add those actions with {@link Gtk.Dialog.add_buttons} or {@link Gtk.Dialog.add_action_widget}.
         */
        public Gtk.ButtonsType buttons { 
            construct {
                switch (value) {
                    case Gtk.ButtonsType.NONE:
                        break;
                    case Gtk.ButtonsType.CLOSE:
                        add_button (_("_Close"), Gtk.ResponseType.CLOSE);
                        break;
                    case Gtk.ButtonsType.CANCEL:
                        add_button (_("_Cancel"), Gtk.ResponseType.CANCEL);
                        break;
                    case Gtk.ButtonsType.OK:
                    case Gtk.ButtonsType.YES_NO:
                    case Gtk.ButtonsType.OK_CANCEL:
                        warning ("Unsupported GtkButtonsType value");
                        break;
                    default:
                        warning ("Unknown GtkButtonsType value");
                        break;
                }
            }
        }

        /**
         * The custom area to add custom widgets.
         * 
         * This bin can be used to add any custom widget to the message area such as a {@link Gtk.ComboBox} or {@link Gtk.CheckButton}.
         * Note that after adding such widget you will need to call {@link Gtk.Widget.show} or {@link Gtk.Widget.show_all} on the widget itself for it to appear in the dialog.
         * 
         * If you want to add multiple widgets to this area, create a new container such as {@link Gtk.Grid} or {@link Gtk.Box} and then add it to the custom bin.
         * 
         * When adding a custom widget to the custom bin, the {@link Granite.MessageDialog.secondary_label}'s bottom margin will be expanded automatically
         * to compensate for the additional widget in the dialog.
         * Removing the previously added widget will remove the bottom margin.
         * 
         * If you don't want to have any margin between your custom widget and the {@link Granite.MessageDialog.secondary_label}, simply add your custom widget
         * and then set the {@link Gtk.Label.margin_bottom} of {@link Granite.MessageDialog.secondary_label} to 0.
         */
        public Gtk.Bin custom_bin { get; construct; }

        /**
         * The image that's displayed in the dialog.
         */
        private Gtk.Image image;

        /**
         * SingleWidgetBin is only used within this class for creating a Bin that
         * holds only one widget.
         */
        private class SingleWidgetBin : Gtk.Bin {}

        /**
         * Constructs a new {@link Granite.MessageDialog}.
         * See {@link Gtk.Dialog} for more details.
         * 
         * @param primary_text the title of the dialog
         * @param secondary_text the body of the dialog
         * @param image_icon the {@link GLib.Icon} that is displayed on the left side of the dialog
         * @param buttons the {@link Gtk.ButtonsType} value that decides what buttons to use, defaults to {@link Gtk.ButtonsType.CLOSE},
         *        see {@link Granite.MessageDialog.buttons} on details and what values are accepted
         */
        public MessageDialog (string primary_text, string secondary_text, GLib.Icon image_icon, Gtk.ButtonsType buttons = Gtk.ButtonsType.CLOSE) {
            Object (
                resizable: false,
                deletable: false,
                skip_taskbar_hint: true,
                transient_for: null,
                primary_text: primary_text,
                secondary_text: secondary_text,
                image_icon: image_icon,
                buttons: buttons
            );
        }

        /**
         * Constructs a new {@link Granite.MessageDialog} with an icon name as it's icon displayed in the image.
         * This constructor is same as the main one but with a difference that 
         * you can pass an icon name string instead of manually creating the {@link GLib.Icon}.
         * 
         * The {@link Granite.MessageDialog.image_icon} will store the created icon
         * so you can retrieve it later with {@link GLib.Icon.to_string}.
         * 
         * See {@link Gtk.Dialog} for more details.
         * 
         * @param primary_text the title of the dialog
         * @param secondary_text the body of the dialog
         * @param image_icon_name the icon name to create the dialog image with
         * @param buttons the {@link Gtk.ButtonsType} value that decides what buttons to use, defaults to {@link Gtk.ButtonsType.CLOSE},
         *        see {@link Granite.MessageDialog.buttons} on details and what values are accepted
         */
        public MessageDialog.with_image_from_icon_name (string primary_text, string secondary_text, string image_icon_name = "dialog-information", Gtk.ButtonsType buttons = Gtk.ButtonsType.CLOSE) {
            Object (
                resizable: false,
                deletable: false,
                skip_taskbar_hint: true,
                transient_for: null,
                primary_text: primary_text,
                secondary_text: secondary_text,
                image_icon: new ThemedIcon (image_icon_name),
                buttons: buttons
            );
        }

        construct {
            image = new Gtk.Image ();
            image.valign = Gtk.Align.START;

            primary_label = new Gtk.Label (null);
            primary_label.get_style_context ().add_class ("h4");
            primary_label.selectable = true;
            primary_label.max_width_chars = 50;
            primary_label.wrap = true;
            primary_label.xalign = 0;

            secondary_label = new Gtk.Label (null);
            secondary_label.use_markup = true;
            secondary_label.selectable = true;
            secondary_label.max_width_chars = 50;
            secondary_label.wrap = true;
            secondary_label.xalign = 0;

            custom_bin = new SingleWidgetBin ();
            custom_bin.add.connect (() => secondary_label.margin_bottom = 18);
            custom_bin.remove.connect (() => secondary_label.margin_bottom = 0);

            var message_grid = new Gtk.Grid ();
            message_grid.column_spacing = 12;
            message_grid.row_spacing = 6;
            message_grid.margin_left = message_grid.margin_right = 12;
            message_grid.attach (image, 0, 0, 1, 2);
            message_grid.attach (primary_label, 1, 0, 1, 1);
            message_grid.attach (secondary_label, 1, 1, 1, 1);
            message_grid.attach (custom_bin, 1, 2, 1, 1);
            message_grid.show_all ();

            get_content_area ().add (message_grid);

            var action_area = get_action_area ();
            action_area.margin_right = 6;
            action_area.margin_bottom = 6;
            action_area.margin_top = 14;
        }
    }
}