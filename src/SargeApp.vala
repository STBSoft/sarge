/*
* Copyright (c) 2011-2018 STBSoft (https://github.com/orgs/STBSoft)
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

public class Sarge.SargeApp : Gtk.Application {

    public const string APPLICATION_ID = "com.github.stbsoft.sarge";
    private GLib.Settings settings = new GLib.Settings (APPLICATION_ID);

    public SargeApp () {
        Object (
            application_id: APPLICATION_ID,
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    protected override void activate () {
        var home = GLib.Environment.get_home_dir ();

        var width = settings.get_int ("width");
        var height = settings.get_int ("height");

        var main_window = new Gtk.ApplicationWindow (this) {
            default_width = width,
            default_height = height,
            title = "Sarge"
        };

        var main_grid = new Gtk.Grid ();
        main_grid.orientation = Gtk.Orientation.VERTICAL;
        var panel_grid = new Gtk.Grid () {
            column_homogeneous = true
        };

        var left = new Sarge.PanelGrid (Sarge.PanelGrid.Which.LEFT, home);
        stdout.printf ("%s\n", left.get_state ().to_string ());
        var blue = new Gdk.RGBA ();
        blue.blue = 1;
        blue.red = 0;
        blue.green = 0;
        blue.alpha = 1;
        left.override_background_color (Gtk.StateFlags.NORMAL, blue);
        var right = new Sarge.PanelGrid (Sarge.PanelGrid.Which.RIGHT, home);
        panel_grid.attach (left, 0, 0, 1, 1);
        panel_grid.attach_next_to (right, left, Gtk.PositionType.RIGHT, 1, 1);

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
        main_window.show_all ();

        main_window.size_allocate.connect (on_size_allocate);
    }

    public static int main (string[] args) {
        return new SargeApp ().run (args);
    }

    private void on_size_allocate (Gtk.Widget widget, Gtk.Allocation allocation) {
        int new_width, new_height;

        ((Gtk.ApplicationWindow) widget).get_size (out new_width, out new_height);
        settings.set_int ("width", new_width);
        settings.set_int ("height", new_height);
    }
}
