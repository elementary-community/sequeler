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

public class Sequeler.QueryBuilder : Gtk.SourceView {
    public new Gtk.SourceBuffer buffer;
    public Gtk.TextMark mark;
    public Gtk.SourceLanguageManager manager;
    public Gtk.SourceStyleSchemeManager style_scheme_manager;
    public Gtk.TextTag warning_tag;
    public Gtk.TextTag error_tag;

    private string font { set; get; default = "Droid Sans Mono 11"; }

    public signal void update_run_button (bool status);

    private Gtk.SourceLanguage? language {
        set {
            buffer.language = value;
        }
    }

    public QueryBuilder () {
        Object (
            show_line_numbers: true,
            highlight_current_line: false,
            show_right_margin: false,
            wrap_mode: Gtk.WrapMode.WORD
        );
    }

    construct {
        manager = Gtk.SourceLanguageManager.get_default ();
        style_scheme_manager = new Gtk.SourceStyleSchemeManager ();

        buffer = new Gtk.SourceBuffer (null);
        buffer.highlight_syntax = true;
        buffer.highlight_matching_brackets = true;

        buffer.mark_set.connect (() => {
            if (get_text ().length > 0) {
                update_run_button (true);
            } else {
                update_run_button (false);
            }
        });

        set_buffer (buffer);
        smart_home_end = Gtk.SourceSmartHomeEndType.AFTER;

        // Create common tags
        warning_tag = new Gtk.TextTag ("warning_bg");
        warning_tag.background_rgba = Gdk.RGBA () { red = 1.0, green = 1.0, blue = 0, alpha = 0.8 };

        error_tag = new Gtk.TextTag ("error_bg");
        error_tag.underline = Pango.Underline.ERROR;

        Gtk.drag_dest_add_uri_targets (this);

        override_font (Pango.FontDescription.from_string (font));
        buffer.style_scheme = style_scheme_manager.get_scheme ("oblivion");

        language = manager.get_language ("sql");
    }

    public string get_text () {
        return buffer.text;
    }
}