/*
* Copyright (c) 2011-2020 STBSoft (https://github.com/orgs/STBSoft)
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
* Authored by: Tibor Sandor <sandort84@gmail.com>
*/

using Sarge.Components;

public class Sarge.SargeApp : Gtk.Application {

    public const string APPLICATION_ID = "com.github.stbsoft.sarge";

    public bool show_hidden_files {get; set;}
    public string[] left_history {get; set;}
    private Array<string> left_history_backing_array {get; set;}
    public string[] right_history {get; set;}
    private Array<string> right_history_backing_array {get; set;}

    private Settings settings = new Settings (APPLICATION_ID);
    private const string SETTING_KEY_SHOW_HIDDEN_FILES = "show-hidden-files";
    private const string SETTING_KEY_WIDTH = "width";
    private const string SETTING_KEY_HEIGHT = "height";
    private const string SETTING_KEY_LEFT_HISTORY = "left-history";
    private const string SETTING_KEY_RIGHT_HISTORY = "right-history";
    private const uint MAX_HISTORY_LENGTH = 100;
    private PanelBox left {get; set;}
    private PanelBox right {get; set;}
    private PanelBox.Side active_panel {get; set;}


    public SargeApp () {
        Object (
            application_id: APPLICATION_ID,
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    protected override void activate () {
        var home = Environment.get_home_dir ();

        var width = settings.get_int (SETTING_KEY_WIDTH);
        var height = settings.get_int (SETTING_KEY_HEIGHT);
        settings.bind (
            SETTING_KEY_SHOW_HIDDEN_FILES,
            this,
            "show_hidden_files",
            SettingsBindFlags.DEFAULT
        );
        settings.bind (
            SETTING_KEY_LEFT_HISTORY,
            this,
            "left_history",
            SettingsBindFlags.DEFAULT
        );
        settings.bind (
            SETTING_KEY_RIGHT_HISTORY,
            this,
            "right_history",
            SettingsBindFlags.DEFAULT
        );
        left_history_backing_array = new Array<string> ();
        right_history_backing_array = new Array<string> ();
        for (var i = 0; i < left_history.length; i++) {
            left_history_backing_array.append_val (left_history[i]);
        }
        for (var i = 0; i < right_history.length; i++) {
            right_history_backing_array.append_val (right_history[i]);
        }
        settings.changed.connect (on_settings_changed);

        var main_window = new Gtk.ApplicationWindow (this) {
            default_width = width,
            default_height = height,
            title = "Sarge"
        };

        var main_grid = new Gtk.Grid () {
            orientation = Gtk.Orientation.VERTICAL
        };
        var panel_grid = new Gtk.Grid () {
            column_homogeneous = true
        };
        left = new PanelBox (PanelBox.Side.LEFT, home, this);
        right = new PanelBox (PanelBox.Side.RIGHT, home, this);
        panel_grid.attach (left, 0, 0, 1, 1);
        panel_grid.attach_next_to (right, left, Gtk.PositionType.RIGHT, 1, 1);
        var focus_chain = new List<Gtk.Widget> ();
        focus_chain.append (left.view);
        focus_chain.append (right.view);
        main_window.set_focus_chain (focus_chain);

        var button_grid = new Gtk.Grid () {
            column_homogeneous = true
        };
        var label_1 = new Gtk.Label ("View") {
            hexpand = true
        };
        var label_2 = new Gtk.Label ("Edit") {
            hexpand = true
        };
        var label_3 = new Gtk.Label ("Copy") {
            hexpand = true
        };
        var label_4 = new Gtk.Label ("Move") {
            hexpand = true
        };
        var label_5 = new Gtk.Label ("New Folder") {
            hexpand = true
        };
        var label_6 = new Gtk.Label ("Delete") {
            hexpand = true
        };
        button_grid.add (label_1);
        button_grid.add (label_2);
        button_grid.add (label_3);
        button_grid.add (label_4);
        button_grid.add (label_5);
        button_grid.add (label_6);

        main_grid.add (panel_grid);
        main_grid.add (button_grid);

        main_window.add (main_grid);

        var css_provider = new Gtk.CssProvider ();
        css_provider.load_from_resource ("/com/github/stbsoft/sarge/style.css");
        Gtk.StyleContext.add_provider_for_screen (
            Gdk.Screen.get_default (),
            css_provider,
            Gtk.STYLE_PROVIDER_PRIORITY_USER
        );

        main_window.show_all ();

        main_window.size_allocate.connect (on_size_allocate);
        main_window.set_focus.connect_after ((widget) => {
            if (widget == null) {
                left.view.grab_focus ();
            }
        });

        VolumeMonitor monitor = VolumeMonitor.get ();
        monitor.mount_added.connect (() => {
            left.update_volumes (monitor.get_volumes ());
            right.update_volumes (monitor.get_volumes ());
        });
        monitor.mount_changed.connect (() => {
            left.update_volumes (monitor.get_volumes ());
            right.update_volumes (monitor.get_volumes ());
        });
        monitor.mount_pre_unmount.connect (() => {
            left.update_volumes (monitor.get_volumes ());
            right.update_volumes (monitor.get_volumes ());
        });
        monitor.mount_removed.connect (() => {
            left.update_volumes (monitor.get_volumes ());
            right.update_volumes (monitor.get_volumes ());
        });
        monitor.volume_added.connect (() => {
            left.update_volumes (monitor.get_volumes ());
            right.update_volumes (monitor.get_volumes ());
        });
        monitor.volume_changed.connect (() => {
            left.update_volumes (monitor.get_volumes ());
            right.update_volumes (monitor.get_volumes ());
        });
        monitor.volume_removed.connect (() => {
            left.update_volumes (monitor.get_volumes ());
            right.update_volumes (monitor.get_volumes ());
        });

        left.update_volumes (monitor.get_volumes ());
        right.update_volumes (monitor.get_volumes ());
    }

    private void on_size_allocate (Gtk.Widget widget, Gtk.Allocation allocation) {
        int new_width, new_height;

        ((Gtk.ApplicationWindow) widget).get_size (out new_width, out new_height);
        settings.set_int (SETTING_KEY_WIDTH, new_width);
        settings.set_int (SETTING_KEY_HEIGHT, new_height);
    }

    private void on_settings_changed (string key) {
        switch (key) {
            case SETTING_KEY_SHOW_HIDDEN_FILES:
                left.refresh_view ();
                right.refresh_view ();
                break;
            case SETTING_KEY_WIDTH:
                // ignore this
                break;
            case SETTING_KEY_HEIGHT:
                // ignore this
                break;
            case SETTING_KEY_LEFT_HISTORY:
                // ignore this
                break;
            case SETTING_KEY_RIGHT_HISTORY:
                // ignore this
                break;
            default:
                warning ("unknown setting: %s", key);
                break;
        }
    }

    public void push_history (PanelBox.Side side, string dir) {
        if (new Granite.Services.System ().history_is_enabled ()) {
            if (side == PanelBox.Side.LEFT) {
                left_history = push_to_history (left_history_backing_array, dir);
            } else {
                right_history = push_to_history (right_history_backing_array, dir);
            }
        } else {
            clear_history ();
        }
    }

    private string[] push_to_history (Array<string> backing_array, string dir) {
        backing_array.append_val (dir);
        return backing_array.data;
    }

    public string? get_last_dir (PanelBox.Side side, string? mount_point = null) {
        if (new Granite.Services.System ().history_is_enabled ()) {
            if (side == PanelBox.Side.LEFT) {
                return get_last_dir_of_side (left_history, mount_point);
            } else {
                return get_last_dir_of_side (right_history, mount_point);
            }
        } else {
            clear_history ();
        }
        return null;
    }

    private string? get_last_dir_of_side (string[] history, string? mount_point = null) {
        if (history.length > 0) {
            if (mount_point != null) {
                for (var i = history.length - 1; i > 0; i--) {
                    if (history[i].index_of (mount_point) == 0) {
                        return history[i];
                    }
                }
                return null;
            }
            return history[history.length - 1];
        }
        return null;
    }

    private void clear_history () {
        left_history = new string [0];
        right_history = new string [0];
    }

    public static int main (string[] args) {
        return new SargeApp ().run (args);
    }

}
