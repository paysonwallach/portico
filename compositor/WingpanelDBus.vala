/*
 * Portico
 *
 * Copyright © 2020 Payson Wallach
 *
 * Released under the terms of the GNU General Public License, version 3
 * (https://gnu.org/licenses/gpl.html)
 *
 * This file incorporates work licensed under the following notice:
 *
 *  Copyright (c) 2011-2015 Wingpanel Developers (http://launchpad.net/wingpanel)
 *
 *  This program is free software; you can redistribute it and/or
 *  modify it under the terms of the GNU General Public
 *  License as published by the Free Software Foundation; either
 *  version 2 of the License, or (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *  General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public
 *  License along with this program; if not, write to the
 *  Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 *  Boston, MA 02110-1301 USA.
 */

namespace GreeterCompositor {
    [DBus (name = "org.pantheon.gala.WingpanelInterface")]
    public class DBusServer : Object {
        private WingpanelBackgroundManager background_manager;

        public signal void state_changed (BackgroundState state, uint animation_duration);

        public void initialize (int monitor, int panel_height) throws GLib.Error {
            background_manager = new WingpanelBackgroundManager (monitor, panel_height);
            background_manager.state_changed.connect ((state, animation_duration) => {
                state_changed (state, animation_duration);
            });
        }

    }

    public class WingpanelDBus : Object {
        private const string DBUS_NAME = "org.pantheon.gala.WingpanelInterface";
        private const string DBUS_PATH = "/org/pantheon/gala/WingpanelInterface";
        public static WindowManager wm;
    #if HAS_MUTTER330
        public static Meta.Display display;
    #else
        public static Meta.Screen screen;
    #endif

        private static DBusConnection? dbus_connection = null;

        public static void init (WindowManager _wm) {
            wm = _wm;

    #if HAS_MUTTER330
            display = wm.get_display ();
    #else
            screen = wm.get_screen ();
    #endif

            Bus.own_name (BusType.SESSION,
                          DBUS_NAME,
                          BusNameOwnerFlags.NONE,
                          (connection) => {
                              dbus_connection = connection;

                              try {
                                  var server = new DBusServer ();

                                  dbus_connection.register_object (DBUS_PATH, server);

                                  debug ("DBus service registered.");
                              } catch (Error e) {
                                  warning ("Registering DBus service failed: %s", e.message);
                              }
                            },
                          null,
                          () => warning ("Acquiring \"%s\" failed.", DBUS_NAME));
        }

        private WingpanelDBus () {
        }

        public void destroy () {
            try {
                if (dbus_connection != null) {
                    dbus_connection.close_sync ();
                }
            } catch (Error e) {
                warning ("Closing DBus service failed: %s", e.message);
            }
        }

    }
}
