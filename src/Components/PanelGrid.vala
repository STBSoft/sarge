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

public class Sarge.PanelGrid : Gtk.Grid {
    public enum Which {
        LEFT, RIGHT;

        public string humanise () {
            switch (this) {
                case LEFT:
                    return _("Left");
                case RIGHT:
                    return _("Right");
            }
            return "Weird";
        }
    }

    private Which which {get; set;}
    private string home {get; set;}
    public bool show_hidden_files {get; set;}

    public PanelGrid (Which which, string home, bool show_hidden_files) {
        this.which = which;
        this.home = home;
        this.show_hidden_files = show_hidden_files;
        var label = new Gtk.Label (this.which.humanise () + " " + this.which.to_string () + " " + this.home);
        add (label);
        expand = true;
        orientation = Gtk.Orientation.VERTICAL;
        set_has_window (false);
        build_contents ();
    }

    public void build_contents () {
        var directory = File.new_for_path (home);

        if (!directory.query_exists ()) {
            directory = File.new_for_path (home);
        }
        try {
            var dir_info = directory.query_info ("standard::*", FileQueryInfoFlags.NOFOLLOW_SYMLINKS, null);
            if (dir_info.get_file_type () != FileType.DIRECTORY) {
                directory = File.new_for_path (home);
            }

            var enumerator = directory.enumerate_children ("standard::*", FileQueryInfoFlags.NOFOLLOW_SYMLINKS, null);
            FileInfo info = null;
            while ((info = enumerator.next_file (null)) != null) {
                if (!show_hidden_files && info.get_is_hidden ()) {
                    continue;
                }
                //  var icon = info.get_icon ();
                var name = info.get_name ();
                var label = new Gtk.Label (name);
                add(label);
            }
        } catch (Error e) {
            stderr.printf ("Error: %s\n", e.message);
        }
    }
}
