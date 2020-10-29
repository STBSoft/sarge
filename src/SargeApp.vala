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
    private GLib.Settings settings = new GLib.Settings (APPLICATION_ID);

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
        var home = GLib.Environment.get_home_dir ();

        var width = settings.get_int ("width");
        var height = settings.get_int ("height");
        var show_hidden_files = settings.get_boolean ("show-hidden-files");

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

        left = new PanelBox (PanelBox.Side.LEFT, home, show_hidden_files);
        right = new PanelBox (PanelBox.Side.RIGHT, home, show_hidden_files);
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
