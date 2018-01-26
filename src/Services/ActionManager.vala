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

public class Sequeler.Services.ActionManager : Object {
    public weak Sequeler.Application app { get; construct; }
    public weak Sequeler.Window window { get; construct; }

    public SimpleActionGroup actions { get; construct; }

    public const string ACTION_PREFIX = "win.";
    public const string ACTION_NEW_WINDOW = "action_new_window";
    public const string ACTION_NEW_CONNECTION = "action_new_connection";
    public const string ACTION_LOGOUT = "action_logout";
    public const string ACTION_QUIT = "action_quit";

    public static Gee.MultiMap<string, string> action_accelerators = new Gee.HashMultiMap<string, string> ();

    private const ActionEntry[] action_entries = {
        { ACTION_NEW_WINDOW, action_new_window },
        { ACTION_NEW_CONNECTION, action_new_connection },
        { ACTION_LOGOUT, action_logout },
        { ACTION_QUIT, action_quit }
    };

    public ActionManager (Sequeler.Application sequeler_app, Sequeler.Window main_window) {
        Object (
            app: sequeler_app,
            window: main_window
        );
    }

    static construct {
        action_accelerators.set (ACTION_NEW_WINDOW, "<Control>n");
        action_accelerators.set (ACTION_NEW_CONNECTION, "<Control><Shift>n");
        action_accelerators.set (ACTION_LOGOUT, "<Control>Escape");
        action_accelerators.set (ACTION_QUIT, "<Control>q");
    }

    construct {
        actions = new SimpleActionGroup ();
        actions.add_action_entries (action_entries, this);
        window.insert_action_group ("win", actions);

        foreach (var action in action_accelerators.get_keys ()) {
            app.set_accels_for_action (ACTION_PREFIX + action, action_accelerators[action].to_array ());
        }
    }

    private void action_quit () {
        window.before_destroy ();
    }

    private void action_logout () {
        window.headerbar.toggle_logout ();
        window.headerbar.title = APP_NAME;
        window.headerbar.subtitle = null;
    }

    private void action_new_window () {
        app.new_window ();
    }

    private void action_new_connection () {

    }
}