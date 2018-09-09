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

public class Sequeler.Layouts.HeaderBar : Gtk.HeaderBar {
	public weak Sequeler.Window window { get; construct; }

	private Gtk.Button logout_button;
	private ModeSwitch mode_switch;
	//  public const Gdk.RGBA light_header = { 0.58, 0.63, 0.67, 1.0 };
	//  public const Gdk.RGBA dark_header = { 0.28, 0.35, 0.42, 1.0 };
	public Gdk.RGBA light_header;
	public Gdk.RGBA dark_header;

	public bool logged_out { get; set; }

	public HeaderBar (Sequeler.Window main_window) {
		Object (
			window: main_window,
			logged_out: true
		);

		set_title (APP_NAME);
		set_show_close_button (true);

		build_ui ();
		toggle_logout ();
	}

	private void build_ui () {
		var eject_image = new Gtk.Image.from_icon_name ("media-eject-symbolic", Gtk.IconSize.BUTTON);
		logout_button = new Gtk.Button.with_label (_("Logout"));
		logout_button.get_style_context ().add_class ("back-button");
		logout_button.always_show_image = true;
		logout_button.set_image (eject_image);
		logout_button.can_focus = false;
		logout_button.action_name = Sequeler.Services.ActionManager.ACTION_PREFIX + Sequeler.Services.ActionManager.ACTION_LOGOUT;

		light_header = Gdk.RGBA ();
		light_header.parse ("#95a3ab");
		dark_header = Gdk.RGBA ();
		dark_header.parse ("#485a6c");

		Granite.Widgets.Utils.set_color_primary (window, light_header);

		mode_switch = new ModeSwitch ("display-brightness-symbolic", "weather-clear-night-symbolic");
        mode_switch.primary_icon_tooltip_text = _("Light background");
        mode_switch.secondary_icon_tooltip_text = _("Dark background");
        mode_switch.valign = Gtk.Align.CENTER;
		mode_switch.bind_property ("active", settings, "dark-theme");
		mode_switch.notify.connect (() => {
			Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = settings.dark_theme;
			
			if (settings.dark_theme) {
				Granite.Widgets.Utils.set_color_primary (window, dark_header);
			} else {
				Granite.Widgets.Utils.set_color_primary (window, light_header);
			}
		});
		
		if (settings.dark_theme) {
			mode_switch.active = true;
		}

		var new_window_item = new Gtk.ModelButton ();
		new_window_item.text = _("New Window");
		new_window_item.action_name = Sequeler.Services.ActionManager.ACTION_PREFIX + Sequeler.Services.ActionManager.ACTION_NEW_WINDOW;
		new_window_item.add_accelerator ("activate", window.accel_group, Gdk.keyval_from_name("N"), Gdk.ModifierType.CONTROL_MASK, Gtk.AccelFlags.VISIBLE);

		var new_connection_item = new Gtk.ModelButton ();
		new_connection_item.text = _("New Connection");
		new_connection_item.action_name = Sequeler.Services.ActionManager.ACTION_PREFIX + Sequeler.Services.ActionManager.ACTION_NEW_CONNECTION;
		new_connection_item.add_accelerator ("activate", window.accel_group, Gdk.keyval_from_name("N"), Gdk.ModifierType.CONTROL_MASK + Gdk.ModifierType.SHIFT_MASK, Gtk.AccelFlags.VISIBLE);

		var quit_item = new Gtk.ModelButton ();
		quit_item.text = _("Quit");
		quit_item.action_name = Sequeler.Services.ActionManager.ACTION_PREFIX + Sequeler.Services.ActionManager.ACTION_QUIT;
		quit_item.add_accelerator ("activate", window.accel_group, Gdk.keyval_from_name("Q"), Gdk.ModifierType.CONTROL_MASK, Gtk.AccelFlags.VISIBLE);		

		var menu_separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
		menu_separator.margin_top = 6;
		menu_separator.margin_bottom = 6;

		var menu_grid = new Gtk.Grid ();
		menu_grid.expand = true;
		menu_grid.margin_top = 3;
		menu_grid.margin_bottom = 3;
		menu_grid.orientation = Gtk.Orientation.VERTICAL;

		menu_grid.attach (new_window_item, 0, 1, 1, 1);
		menu_grid.attach (new_connection_item, 0, 2, 1, 1);
		menu_grid.attach (menu_separator, 0, 3, 1, 1);
		menu_grid.attach (quit_item, 0, 4, 1, 1);
		menu_grid.show_all ();
		
		var open_menu = new Gtk.MenuButton ();
		open_menu.set_image (new Gtk.Image.from_icon_name ("open-menu-symbolic", Gtk.IconSize.BUTTON));
		open_menu.tooltip_text = _("Menu");

		var menu_popover = new Gtk.Popover (null);
		menu_popover.add (menu_grid);

		open_menu.popover = menu_popover;
		open_menu.relief = Gtk.ReliefStyle.NONE;
		open_menu.valign = Gtk.Align.CENTER;

		pack_start (logout_button);
		pack_end (open_menu);

		var separator = new Gtk.Separator (Gtk.Orientation.VERTICAL);
		separator.get_style_context ().add_class ("headerbar-separator");

		pack_end (separator);
		pack_end (mode_switch);
	}

	public void toggle_logout () {
		logged_out = !logged_out;
		logout_button.visible = logged_out;
		logout_button.no_show_all = !logged_out;
	}
}