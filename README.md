# ![Sequeler](sequeler-logo-transparent.png)
> Friendly SQL Client

Sequeler is a native Linux SQL client built in Vala and Gtk. It allows you to connect to your local and remote databases, write SQL in a handy text editor with language recognition, and visualize SELECT results in a Gtk.Grid Widget.

![](sequeler-screenshot.png)

## Get it from the elementary OS AppCenter!
Sequeler, is primarly availabe from the AppCenter of elementary OS. Download it from there!

[![Get it on AppCenter](https://appcenter.elementary.io/badge.svg)](https://appcenter.elementary.io/com.github.alecaddd.sequeler)

## Install it from source
You can install Sequeler by compiling from the source, here's the list of dependecies required:
 - `gtk+-3.0>=3.9.10`
 - `granite>=0.4.1`
 - `glib-2.0`
 - `gee-0.8`
 - `gobject-2.0`
 - `libxml-2.0`
 - `libgda-5.0`
 - `libgda-ui-5.0`
 - `gtksourceview-3.0`

## Building
```
mkdir build/ && cd build
cmake ..
make && sudo make install
```

### Donations
Liked Spice-up? Would like to support its development of this app and more? Feel free to [leave a little tip :)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=WYD9ZJK6ZFUDQ) or support my work torwards a new feature over at [Bountysource](https://www.bountysource.com/trackers/44752823-philip-scott-spice-up). I'd really appreciate it :) 
