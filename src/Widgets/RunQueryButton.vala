public class Sequeler.Widgets.RunQueryButton : Gtk.Button {
    public RunQueryButton () {
        set_label (_("Run Query"));
        get_style_context ().add_class ("suggested-action");
        get_style_context ().add_class ("notebook-temp-fix");
        always_show_image = true;
        image = new Gtk.Image.from_icon_name ("media-playback-start-symbolic", Gtk.IconSize.BUTTON);
        image.valign = Gtk.Align.CENTER;
        can_focus = false;
        margin = 10;
        sensitive = false;
        tooltip_markup = Granite.markup_accel_tooltip ({"<Control>Return"}, _("Run Query"));
    }
}
