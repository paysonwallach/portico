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
    public enum BackgroundState {
        LIGHT,
        DARK
    }

    public class WingpanelBackgroundManager : Object {
        private const int MINIMIZE_DURATION = 200;
        private const int SNAP_DURATION = 250;
        private const int WALLPAPER_TRANSITION_DURATION = 150;
        private const int WORKSPACE_SWITCH_DURATION = 300;
        private const double LUMINANCE_THRESHOLD = 180;

        public signal void state_changed (BackgroundState state, uint animation_duration);

        public int monitor { private get; construct; }
        public int panel_height { private get; construct; }

        private ulong wallpaper_hook_id;

        private Meta.Workspace? current_workspace = null;

        private BackgroundState current_state = BackgroundState.LIGHT;

        private WingpanelUtils.ColorInformation? bk_color_info = null;

        public WingpanelBackgroundManager (int monitor, int panel_height) {
            Object (monitor: monitor, panel_height: panel_height);

            connect_signals ();
            update_bk_color_info.begin ((obj, res) => {
                update_bk_color_info.end (res);
                update_current_workspace ();
            });
        }

        ~WingpanelBackgroundManager () {
            var signal_id = GLib.Signal.lookup ("changed", WingpanelDBus.wm.background_group.get_type ());
            GLib.Signal.remove_emission_hook (signal_id, wallpaper_hook_id);
        }

        private void connect_signals () {
    #if HAS_MUTTER330
            unowned Meta.WorkspaceManager manager = WingpanelDBus.display.get_workspace_manager ();
            manager.workspace_switched.connect (() => {
                update_current_workspace ();
            });
    #else
            WingpanelDBus.screen.workspace_switched.connect (() => {
                update_current_workspace ();
            });
    #endif

            var signal_id = GLib.Signal.lookup ("changed", WingpanelDBus.wm.background_group.get_type ());

            wallpaper_hook_id = GLib.Signal.add_emission_hook (signal_id, 0, (ihint, param_values) => {
                update_bk_color_info.begin ((obj, res) => {
                    update_bk_color_info.end (res);
                    check_for_state_change (WALLPAPER_TRANSITION_DURATION);
                });

                return true;
    #if VALA_0_42
            });
    #else
            }, null);
    #endif
        }

        private void update_current_workspace () {
    #if HAS_MUTTER330
            unowned Meta.WorkspaceManager manager = WingpanelDBus.display.get_workspace_manager ();
            var workspace = manager.get_active_workspace ();
    #else
            var workspace = WingpanelDBus.screen.get_workspace_by_index (WingpanelDBus.screen.get_active_workspace_index ());
    #endif

            if (workspace == null) {
                warning ("Cannot get active workspace");

                return;
            }

            if (current_workspace != null) {
                current_workspace.window_added.disconnect (on_window_added);
                current_workspace.window_removed.disconnect (on_window_removed);
            }

            current_workspace = workspace;

            foreach (Meta.Window window in current_workspace.list_windows ()) {
                if (window.is_on_primary_monitor ()) {
                    register_window (window);
                }
            }

            current_workspace.window_added.connect (on_window_added);
            current_workspace.window_removed.connect (on_window_removed);

            check_for_state_change (WORKSPACE_SWITCH_DURATION);
        }

        private void register_window (Meta.Window window) {
            window.notify["maximized-vertically"].connect (() => {
                check_for_state_change (SNAP_DURATION);
            });

            window.notify["minimized"].connect (() => {
                check_for_state_change (MINIMIZE_DURATION);
            });

            window.workspace_changed.connect (() => {
                check_for_state_change (WORKSPACE_SWITCH_DURATION);
            });
        }

        private void on_window_added (Meta.Window window) {
            register_window (window);

            check_for_state_change (SNAP_DURATION);
        }

        private void on_window_removed (Meta.Window window) {
            check_for_state_change (SNAP_DURATION);
        }

        public async void update_bk_color_info () {
            SourceFunc callback = update_bk_color_info.callback;
            Gdk.Rectangle monitor_geometry;

            Gdk.Screen.get_default ().get_monitor_geometry (monitor, out monitor_geometry);

            WingpanelUtils.get_background_color_information.begin (WingpanelDBus.wm, monitor, 0, 0, monitor_geometry.width, panel_height, (obj, res) => {
                try {
                    bk_color_info = WingpanelUtils.get_background_color_information.end (res);
                } catch (Error e) {
                    warning (e.message);
                } finally {
                    callback ();
                }
            });

            yield;
        }

        private void check_for_state_change (uint animation_duration) {
            var new_state = BackgroundState.LIGHT;

            if (bk_color_info != null) {
                if (bk_color_info.mean_luminance > LUMINANCE_THRESHOLD) {
                    new_state = BackgroundState.DARK;
                }
            }

            if (new_state != current_state) {
                state_changed (current_state = new_state, animation_duration);
            }
        }

    }
}
