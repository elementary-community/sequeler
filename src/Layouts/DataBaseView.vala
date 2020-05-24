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

public class Sequeler.Layouts.DataBaseView : Gtk.Grid {
    public weak Sequeler.Window window { get; construct; }

    public Granite.Widgets.ModeButton tabs;
    public Gtk.Stack stack;
    public Sequeler.Layouts.Views.Structure structure;
    public Sequeler.Layouts.Views.Content content;
    public Sequeler.Layouts.Views.Relations relations;
    public Granite.Widgets.DynamicNotebook query;

    private Sequeler.Layouts.Views.Query tab_to_restore;

    public Gtk.MenuButton font_style;

    public DataBaseView (Sequeler.Window main_window) {
        Object (
            orientation: Gtk.Orientation.VERTICAL,
            window: main_window,
            column_homogeneous: true
        );
    }

    construct {
        var toolbar = new Gtk.Grid ();
        toolbar.get_style_context ().add_class ("library-titlebar");

        tabs = new Granite.Widgets.ModeButton ();
        tabs.append (new Sequeler.Partials.ToolBarButton ("x-office-spreadsheet-template", "Structure", _("Structure")));
        tabs.append (new Sequeler.Partials.ToolBarButton ("x-office-document", "Content", _("Content")));
        tabs.append (new Sequeler.Partials.ToolBarButton ("preferences-system-windows", "Relations", _("Relations")));
        tabs.append (new Sequeler.Partials.ToolBarButton ("accessories-text-editor", "Query", _("Query")));
        tabs.set_active (0);
        tabs.margin = 9;

        tabs.mode_changed.connect ((tab) => {
            stack.set_visible_child_name (tab.name);

            if (tab.name == "Query") {
                font_style.visible = true;
                font_style.no_show_all = false;
            } else {
                font_style.visible = false;
                font_style.no_show_all = true;
            }

            if (window.main.database_schema.source_list == null) {
                return;
            }

            var item_selected = window.main.database_schema.source_list.selected;

            if (item_selected == null) {
                return;
            }

            if (tab.name == "Structure") {
                window.main.database_view.structure.fill (item_selected.name, window.main.database_view.structure.database);
            }

            if (tab.name == "Content") {
                window.main.database_view.content.fill (item_selected.name, window.main.database_view.content.database, item_selected.badge);
            }

            if (tab.name == "Relations") {
                window.main.database_view.relations.fill (item_selected.name, window.main.database_view.relations.database);
            }
        });

        toolbar.attach (tabs, 0, 0, 1, 1);

        var view_options = new Gtk.Grid ();
        view_options.hexpand = true;
        view_options.halign = Gtk.Align.END;
        view_options.valign = Gtk.Align.CENTER;

        // Query View buttons
        var zoom_out_button = new Gtk.Button.from_icon_name ("zoom-out-symbolic", Gtk.IconSize.MENU);
        zoom_out_button.action_name = Sequeler.Services.ActionManager.ACTION_PREFIX + Sequeler.Services.ActionManager.ACTION_ZOOM_OUT;
        zoom_out_button.tooltip_markup = Granite.markup_accel_tooltip ({"<Control>minus"}, _("Zoom Out"));

        var zoom_default_button = new Gtk.Button.with_label (
            "%.0f%%".printf (window.action_manager.get_current_font_size () * 10)
        );
        zoom_default_button.action_name = Sequeler.Services.ActionManager.ACTION_PREFIX + Sequeler.Services.ActionManager.ACTION_ZOOM_DEFAULT;
        zoom_default_button.tooltip_markup = Granite.markup_accel_tooltip ({"<Control>0"}, _("Zoom 1:1"));

        var zoom_in_button = new Gtk.Button.from_icon_name ("zoom-in-symbolic", Gtk.IconSize.MENU);
        zoom_in_button.action_name = Sequeler.Services.ActionManager.ACTION_PREFIX + Sequeler.Services.ActionManager.ACTION_ZOOM_IN;
        zoom_in_button.tooltip_markup = Granite.markup_accel_tooltip ({"<Control>plus"}, _("Zoom In"));

        var font_size_grid = new Gtk.Grid ();
        font_size_grid.column_homogeneous = true;
        font_size_grid.hexpand = true;
        font_size_grid.margin = 12;
        font_size_grid.get_style_context ().add_class (Gtk.STYLE_CLASS_LINKED);
        font_size_grid.add (zoom_out_button);
        font_size_grid.add (zoom_default_button);
        font_size_grid.add (zoom_in_button);

        var color_button_white = new Gtk.RadioButton (null);
        color_button_white.halign = Gtk.Align.CENTER;
        color_button_white.tooltip_text = _("High Contrast");

        var color_button_white_context = color_button_white.get_style_context ();
        color_button_white_context.add_class ("color-button");
        color_button_white_context.add_class ("color-white");

        var color_button_light = new Gtk.RadioButton.from_widget (color_button_white);
        color_button_light.halign = Gtk.Align.CENTER;
        color_button_light.tooltip_text = _("Solarized Light");

        var color_button_light_context = color_button_light.get_style_context ();
        color_button_light_context.add_class ("color-button");
        color_button_light_context.add_class ("color-light");

        var color_button_dark = new Gtk.RadioButton.from_widget (color_button_white);
        color_button_dark.halign = Gtk.Align.CENTER;
        color_button_dark.tooltip_text = _("Solarized Dark");

        var color_button_dark_context = color_button_dark.get_style_context ();
        color_button_dark_context.add_class ("color-button");
        color_button_dark_context.add_class ("color-dark");

        var menu_grid = new Gtk.Grid ();
        menu_grid.margin_bottom = 12;
        menu_grid.orientation = Gtk.Orientation.VERTICAL;
        menu_grid.width_request = 200;
        menu_grid.attach (font_size_grid, 0, 0, 3, 1);
        menu_grid.attach (color_button_white, 0, 1, 1, 1);
        menu_grid.attach (color_button_light, 1, 1, 1, 1);
        menu_grid.attach (color_button_dark, 2, 1, 1, 1);
        menu_grid.show_all ();

        var menu = new Gtk.Popover (null);
        menu.add (menu_grid);

        font_style = new Gtk.MenuButton ();
        font_style.margin_end = 9;
        font_style.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        font_style.set_image (new Gtk.Image.from_icon_name ("font-select-symbolic", Gtk.IconSize.LARGE_TOOLBAR));
        font_style.tooltip_text = _("Change Text Style");
        font_style.popover = menu;
        font_style.can_focus = false;
        font_style.visible = false;
        font_style.no_show_all = true;

        view_options.add (font_style);

        toolbar.attach (view_options, 1, 0, 1, 1);

        stack = new Gtk.Stack ();
        structure = new Sequeler.Layouts.Views.Structure (window);
        content = new Sequeler.Layouts.Views.Content (window);
        relations = new Sequeler.Layouts.Views.Relations (window);
        query = get_query_notebook ();

        stack.add_named (structure, "Structure");
        stack.add_named (content, "Content");
        stack.add_named (relations, "Relations");
        stack.add_named (query, "Query");
        stack.expand = true;

        attach (toolbar, 0, 0, 1, 1);
        attach (stack, 0, 1, 1, 1);

        settings.changed.connect (() => {
            zoom_default_button.label = "%.0f%%".printf (window.action_manager.get_current_font_size () * 10);
        });

        switch (Sequeler.settings.style_scheme) {
            case "high-contrast":
                color_button_white.active = true;
                break;
            case "solarized-light":
                color_button_light.active = true;
                break;
            case "solarized-dark":
                color_button_dark.active = true;
                break;
        }

        color_button_dark.clicked.connect (() => {
            Sequeler.settings.style_scheme = "solarized-dark";
            (query.current.page as Layouts.Views.Query).update_color_style ();
        });

        color_button_light.clicked.connect (() => {
            Sequeler.settings.style_scheme = "solarized-light";
            (query.current.page as Layouts.Views.Query).update_color_style ();
        });

        color_button_white.clicked.connect (() => {
            Sequeler.settings.style_scheme = "classic";
            (query.current.page as Layouts.Views.Query).update_color_style ();
        });
    }

    private Granite.Widgets.DynamicNotebook get_query_notebook () {
        var notebook = new Granite.Widgets.DynamicNotebook ();
        notebook.add_button_tooltip = _("Create a new Query Tab");
        notebook.expand = true;
        notebook.allow_restoring = true;
        notebook.max_restorable_tabs = 1;

        var first_page = new Sequeler.Layouts.Views.Query (window);
        var first_tab = new Granite.Widgets.Tab (
            _("Query"), null, first_page
        );
        first_page.update_tab_indicator.connect ((status) => {
            var icon = status
                ? new ThemedIcon ("process-completed")
                : new ThemedIcon ("process-stop");
            first_tab.icon = icon;
        });
        notebook.insert_tab (first_tab, 0);

        notebook.new_tab_requested.connect (() => {
            var new_page = new Sequeler.Layouts.Views.Query (window);
            var new_tab = new Granite.Widgets.Tab (
                _("Query %i").printf (notebook.n_tabs), null, new_page
            );
            new_page.update_tab_indicator.connect ((status) => {
                var icon = status
                    ? new ThemedIcon ("process-completed")
                    : new ThemedIcon ("process-stop");
                new_tab.icon = icon;
            });
            notebook.insert_tab (new_tab, notebook.n_tabs - 1);
        });

        notebook.close_tab_requested.connect ((tab) => {
            if (notebook.n_tabs == 1) {
                var new_page = new Sequeler.Layouts.Views.Query (window);
                var new_tab = new Granite.Widgets.Tab (
                    _("Query"), null, new_page
                );
                notebook.insert_tab (new_tab, notebook.n_tabs - 1);
            }
            tab_to_restore = tab.page as Sequeler.Layouts.Views.Query;
            tab.restore_data = tab.label;
            return true;
        });

        notebook.tab_restored.connect ((label, data, icon) => {
            var tab = new Granite.Widgets.Tab (label, icon, tab_to_restore);
            tab_to_restore.update_tab_indicator.connect ((status) => {
                var update_icon = status
                    ? new ThemedIcon ("process-completed")
                    : new ThemedIcon ("process-stop");
                tab.icon = update_icon;
            });
            notebook.insert_tab (tab, notebook.n_tabs - 1);
        });

        return notebook;
    }
}
