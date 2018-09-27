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
	private Gtk.Popover menu_popover;

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
		logout_button.valign = Gtk.Align.CENTER;
		logout_button.always_show_image = true;
		logout_button.set_image (eject_image);
		logout_button.can_focus = false;
		logout_button.action_name = Sequeler.Services.ActionManager.ACTION_PREFIX + Sequeler.Services.ActionManager.ACTION_LOGOUT;
		logout_button.has_tooltip = true;
		logout_button.tooltip_text = "Ctrl + Esc";

		mode_switch = new ModeSwitch ("display-brightness-symbolic", "weather-clear-night-symbolic");
        mode_switch.primary_icon_tooltip_text = _("Light background");
        mode_switch.secondary_icon_tooltip_text = _("Dark background");
        mode_switch.valign = Gtk.Align.CENTER;
		mode_switch.bind_property ("active", settings, "dark-theme");
		mode_switch.notify.connect (() => {
			Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = settings.dark_theme;
		});
		
		if (settings.dark_theme) {
			mode_switch.active = true;
		}

		//  var new_window_item = new Gtk.ModelButton ();
		//  new_window_item.text = _("New Window");
		//  new_window_item.action_name = Sequeler.Services.ActionManager.ACTION_PREFIX + Sequeler.Services.ActionManager.ACTION_NEW_WINDOW;
		//  new_window_item.add_accelerator ("activate", window.accel_group, Gdk.keyval_from_name("N"), Gdk.ModifierType.CONTROL_MASK, Gtk.AccelFlags.VISIBLE);

		var new_window_item = new Gtk.MenuItem.with_label (_("New Window"));
		new_window_item.action_name = Sequeler.Services.ActionManager.ACTION_PREFIX + Sequeler.Services.ActionManager.ACTION_NEW_WINDOW;
		new_window_item.add_accelerator ("activate", window.accel_group, Gdk.keyval_from_name("N"), Gdk.ModifierType.CONTROL_MASK, Gtk.AccelFlags.VISIBLE);
		new_window_item.get_style_context ().add_class ("popover-item");
		new_window_item.expand = true;
		new_window_item.button_press_event.connect (event => {
			new_window_item.activate ();
			menu_popover.closed ();
			return false;
		});

		new_window_item.enter_notify_event.connect (event => {
			new_window_item.set_state_flags (Gtk.StateFlags.PRELIGHT, true);
			return false;
		});

		new_window_item.leave_notify_event.connect (event => {
			new_window_item.set_state_flags (Gtk.StateFlags.NORMAL, true);
			return false;
		});

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
		menu_grid.halign = Gtk.Align.FILL;
		menu_grid.expand = true;
		menu_grid.margin_top = 3;
		menu_grid.margin_bottom = 3;
		menu_grid.orientation = Gtk.Orientation.VERTICAL;

		menu_grid.attach (new_window_item, 0, 1, 1, 1);
		menu_grid.attach (new_connection_item, 0, 2, 1, 1);
		menu_grid.attach (menu_separator, 0, 3, 1, 1);
		menu_grid.attach (quit_item, 0, 4, 1, 1);
		menu_grid.width_request = 240;
		menu_grid.show_all ();
		
		var open_menu = new Gtk.MenuButton ();
		open_menu.set_image (new Gtk.Image.from_icon_name ("open-menu-symbolic", Gtk.IconSize.BUTTON));
		open_menu.tooltip_text = _("Menu");

		menu_popover = new Gtk.Popover (null);
		menu_popover.width_request = 240;
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

	public void show_menuitem_accel_labels(Gtk.Widget widget) {
		Gtk.MenuItem? item = widget as Gtk.MenuItem;
		if (item == null) {
			debug ("no model button");
			return;
		}
		
		string? path = item.get_accel_path ();
		if (path == null) {
			debug ("no accel path");
			return;
		}
		Gtk.AccelKey? key = null;
		Gtk.AccelMap.lookup_entry (path, out key);
		if (key == null) {
			return;
		}
		item.foreach (
			(widget) => { add_accel_to_label (widget, key); }
		);
	}

	private void add_accel_to_label(Gtk.Widget widget, Gtk.AccelKey key) {
		Gtk.AccelLabel? label = widget as Gtk.AccelLabel;
		if (label == null) {
			return;
		}

		label.set_accel (key.accel_key, key.accel_mods);
		label.refetch ();
	}

	public void toggle_logout () {
		logged_out = !logged_out;
		logout_button.visible = logged_out;
		logout_button.no_show_all = !logged_out;
	}
}