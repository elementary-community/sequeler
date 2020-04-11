public class Sequeler.Widgets.CancelQueryButton : Gtk.Button {
	public CancelQueryButton () {
		set_label(_("Close"));
        //get_style_context ().add_class ("suggested-action");
        //get_style_context ().add_class ("notebook-temp-fix");
        always_show_image = true;
        image = new Gtk.Image.from_icon_name ("window-close", Gtk.IconSize.BUTTON);
        image.valign = Gtk.Align.CENTER;
        can_focus = false;
        margin = 10;
        sensitive = false;
        tooltip_markup = Granite.markup_accel_tooltip ({"<Control>Return"}, _("Run Query"));
	}
}
