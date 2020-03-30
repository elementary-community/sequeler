/*
* Copyright (c) 2017-2020 Alecaddd (https://alecaddd.com)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Alessandro "Alecaddd" Castellani <castellani.ale@gmail.com>
*/

public class Sequeler.Partials.LibraryItem : Gtk.ListBoxRow {
	public Gee.HashMap<string, string> data { get; set; }
	public Gtk.Label title;
	public Gdk.RGBA color;

	public Gtk.Revealer main_revealer;
	private Gtk.Revealer motion_revealer;
	public Gtk.ModelButton connect_button;
	public Gtk.Spinner spinner;

	public Gtk.ScrolledWindow scrolled { get; set; }
	private bool scroll_up = false;
    private bool scrolling = false;
    private bool should_scroll = false;
	public Gtk.Adjustment vadjustment;

	private const int SCROLL_STEP_SIZE = 5;
    private const int SCROLL_DISTANCE = 30;
    private const int SCROLL_DELAY = 50;

	public signal void edit_dialog (Gee.HashMap data);
	public signal void confirm_delete (
		Gtk.ListBoxRow item,
		Gee.HashMap data
	);
	public signal void connect_to (
		Gee.HashMap data,
		Gtk.Spinner spinner,
		Gtk.ModelButton button
	);

	// Datatype restrictions on DnD (Gtk.TargetFlags).
	const Gtk.TargetEntry[] TARGET_ENTRIES_LABEL = {
		{ "LIBRARYITEM", Gtk.TargetFlags.SAME_APP, 0 }
	};

	public LibraryItem (Gee.HashMap<string, string> data) {
		Object (
			data: data
		);

		get_style_context ().add_class ("library-box");
		expand = true;

		var box = new Gtk.Grid ();
		box.get_style_context ().add_class ("library-inner-box");
		box.margin = 3;

		var color_box = new Gtk.Grid ();
		color_box.get_style_context ().add_class ("library-colorbox");
		color_box.set_size_request (12, 12);
		color_box.margin = 9;

		color = Gdk.RGBA ();
		color.parse (data["color"]);
		try {
			var style = new Gtk.CssProvider ();
			style.load_from_data (
				"* {background-color: %s;}".printf (color.to_string ()),
				-1
			);
			color_box.get_style_context ().add_provider (
				style,
				Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
			);
		} catch (Error e) {
			debug (
				"Internal error loading session chooser style: %s",
				e.message
			);
		}

		title = new Gtk.Label (data["title"]);
		title.get_style_context ().add_class ("text-bold");
		title.halign = Gtk.Align.START;
		title.ellipsize = Pango.EllipsizeMode.END;
		title.margin_end = 9;
		title.set_line_wrap (true);
		title.hexpand = true;

		box.attach (color_box, 0, 0, 1, 1);
		box.attach (title, 1, 0, 1, 1);

		connect_button = new Gtk.ModelButton ();
		connect_button.text = _("Connect");

		var edit_button = new Gtk.ModelButton ();
		edit_button.text = _("Edit Connection");

		var delete_button = new Gtk.ModelButton ();
		delete_button.text = _("Delete Connection");

		var open_menu = new Gtk.MenuButton ();
		open_menu.set_image (
			new Gtk.Image.from_icon_name (
				"view-more-symbolic",
				Gtk.IconSize.SMALL_TOOLBAR
			)
		);
		open_menu.get_style_context ().add_class ("library-btn");
		open_menu.tooltip_text = _("Options");

		var menu_separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
		menu_separator.margin_top = 6;
		menu_separator.margin_bottom = 6;

		var menu_grid = new Gtk.Grid ();
		menu_grid.expand = true;
		menu_grid.margin_top = 3;
		menu_grid.margin_bottom = 3;
		menu_grid.orientation = Gtk.Orientation.VERTICAL;

		menu_grid.attach (connect_button, 0, 1, 1, 1);
		menu_grid.attach (edit_button, 0, 2, 1, 1);
		menu_grid.attach (menu_separator, 0, 3, 1, 1);
		menu_grid.attach (delete_button, 0, 4, 1, 1);
		menu_grid.show_all ();

		var menu_popover = new Gtk.Popover (null);
		menu_popover.add (menu_grid);

		open_menu.popover = menu_popover;
		open_menu.relief = Gtk.ReliefStyle.NONE;
		open_menu.valign = Gtk.Align.CENTER;

		spinner = new Gtk.Spinner ();

		box.attach (spinner, 2, 0, 1, 1);
		box.attach (open_menu, 3, 0, 1, 1);

		var motion_grid = new Gtk.Grid ();
        motion_grid.margin = 6;
        motion_grid.get_style_context ().add_class ("grid-motion");
        motion_grid.height_request = 18;

        motion_revealer = new Gtk.Revealer ();
        motion_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN;
		motion_revealer.add (motion_grid);

		box.attach (motion_revealer, 0, 2, 4, 1);

		var event_box = new Gtk.EventBox ();
		event_box.add (box);

		main_revealer = new Gtk.Revealer ();
        main_revealer.reveal_child = true;
        main_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN;
        main_revealer.add (event_box);

        add (main_revealer);

		delete_button.clicked.connect (() => {
			confirm_delete (this, data);
		});

		edit_button.clicked.connect (() => {
			edit_dialog (data);
		});

		connect_button.clicked.connect (() => {
			spinner.start ();
			connect_button.sensitive = false;
			connect_to (data, spinner, connect_button);
		});

		event_box.enter_notify_event.connect (event => {
			box.set_state_flags (Gtk.StateFlags.PRELIGHT, true);
			return false;
		});

		event_box.leave_notify_event.connect (event => {
			if (event.detail != Gdk.NotifyType.INFERIOR) {
				box.set_state_flags (Gtk.StateFlags.NORMAL, true);
			}
			return false;
		});

		open_menu.clicked.connect (event => {
			box.set_state_flags (Gtk.StateFlags.PRELIGHT, true);
		});

		menu_popover.closed.connect (event => {
			box.set_state_flags (Gtk.StateFlags.NORMAL, true);
		});

		build_drag_and_drop ();
	}

	private void build_drag_and_drop () {
		// Make this a draggable widget
		Gtk.drag_source_set (
			this,
			Gdk.ModifierType.BUTTON1_MASK,
			TARGET_ENTRIES_LABEL,
			Gdk.DragAction.MOVE
		);

		drag_begin.connect (on_drag_begin);
		drag_data_get.connect (on_drag_data_get);

		// Make this widget a DnD destination.
        Gtk.drag_dest_set (
			this,
			Gtk.DestDefaults.MOTION,
			TARGET_ENTRIES_LABEL,
			Gdk.DragAction.MOVE
		);

		drag_motion.connect (on_drag_motion);
        drag_leave.connect (on_drag_leave);
        drag_end.connect (clear_indicator);
	}

	private void on_drag_begin (Gtk.Widget widget, Gdk.DragContext context) {
        var row = (Partials.LibraryItem) widget;

        Gtk.Allocation alloc;
        row.get_allocation (out alloc);

        var surface = new Cairo.ImageSurface (Cairo.Format.ARGB32, alloc.width, alloc.height);
        var cr = new Cairo.Context (surface);
        cr.set_source_rgba (0, 0, 0, 0.3);
        cr.set_line_width (1);

        cr.move_to (0, 0);
        cr.line_to (alloc.width, 0);
        cr.line_to (alloc.width, alloc.height);
        cr.line_to (0, alloc.height);
        cr.line_to (0, 0);
        cr.stroke ();

        cr.set_source_rgba (255, 255, 255, 0.5);
        cr.rectangle (0, 0, alloc.width, alloc.height);
        cr.fill ();

        row.draw (cr);
        Gtk.drag_set_icon_surface (context, surface);
        main_revealer.reveal_child = false;
	}

	private void on_drag_data_get (Gtk.Widget widget, Gdk.DragContext context,
        Gtk.SelectionData selection_data, uint target_type, uint time) {
        uchar[] data = new uchar[(sizeof (Partials.LibraryItem))];
        ((Gtk.Widget[])data)[0] = widget;

        selection_data.set (
            Gdk.Atom.intern_static_string ("LIBRARYITEM"), 32, data
        );
	}

	public void clear_indicator (Gdk.DragContext context) {
        main_revealer.reveal_child = true;
	}

	public bool on_drag_motion (Gdk.DragContext context, int x, int y, uint time) {
		debug ("here");
        motion_revealer.reveal_child = true;

        int index = get_index ();
        Gtk.Allocation alloc;
        get_allocation (out alloc);

        int real_y = (index * alloc.height) - alloc.height + y;
        check_scroll (real_y);

        if (should_scroll && !scrolling) {
            scrolling = true;
            Timeout.add (SCROLL_DELAY, scroll);
        }

        return true;
    }

    private void check_scroll (int y) {
        vadjustment = scrolled.vadjustment;

        if (vadjustment == null) {
            return;
        }

        double vadjustment_min = vadjustment.value;
        double vadjustment_max = vadjustment.page_size + vadjustment_min;
        double show_min = double.max (0, y - SCROLL_DISTANCE);
        double show_max = double.min (vadjustment.upper, y + SCROLL_DISTANCE);

        if (vadjustment_min > show_min) {
            should_scroll = true;
            scroll_up = true;
        } else if (vadjustment_max < show_max) {
            should_scroll = true;
            scroll_up = false;
        } else {
            should_scroll = false;
        }
    }

    private bool scroll () {
        if (should_scroll) {
            if (scroll_up) {
                vadjustment.value -= SCROLL_STEP_SIZE;
            } else {
                vadjustment.value += SCROLL_STEP_SIZE;
            }
        } else {
            scrolling = false;
        }

        return should_scroll;
    }

    public void on_drag_leave (Gdk.DragContext context, uint time) {
        motion_revealer.reveal_child = false;
        should_scroll = false;
    }
}
