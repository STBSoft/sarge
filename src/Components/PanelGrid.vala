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

public class Sarge.Components.PanelGrid : Gtk.Grid {
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

    public enum Column {
        NAME, SIZE;

        public string humanise () {
            switch (this) {
                case NAME:
                    return _("Name");
                case SIZE:
                    return _("Size");
            }
            return "Weird!";
        }
    }

    private Which which {get; set;}
    private string home {get; set;}
    public bool show_hidden_files {get; set;}
    private Gtk.TreeView view {get; set;}
    private string dir {get; set;}

    public PanelGrid (Which which, string home, bool show_hidden_files) {
        this.which = which;
        this.home = home;
        this.show_hidden_files = show_hidden_files;
        expand = true;
        orientation = Gtk.Orientation.VERTICAL;
        set_has_window (false);
        dir = home + "/Projects/sarge";  // TODO: dir from saved history in settings
        var label = new Gtk.Label (dir);
        add (label);
        build_contents ();
    }

    private void build_contents () {
        view = create_view ();
        update_view ();
        var scrolled_window = new Gtk.ScrolledWindow (null, null) {
            hscrollbar_policy = Gtk.PolicyType.NEVER
        };
        scrolled_window.add (view);
        add (scrolled_window);
    }

    private Gtk.TreeView create_view () {
        var list = new Gtk.ListStore (2, typeof (string), typeof (string));
        list.set_sort_column_id (0, Gtk.SortType.ASCENDING); // TODO: sort column and direction from settings
        var internal_view = new Gtk.TreeView () {
            expand = true,
            headers_clickable = true,
            enable_grid_lines = Gtk.TreeViewGridLines.VERTICAL,
            model = list
        };

        var name_renderer = new Gtk.CellRendererText () {
            ellipsize = Pango.EllipsizeMode.MIDDLE
        };
        var name_column = new Gtk.TreeViewColumn.with_attributes (
            Column.NAME.humanise (), name_renderer, "text", Column.NAME) {
            expand = true
        };

        internal_view.append_column (name_column);
        internal_view.insert_column_with_attributes (
            -1, Column.SIZE.humanise (), new Gtk.CellRendererText (), "text", Column.SIZE);

        return internal_view;
    }

    private void update_view () {
        var list = (Gtk.ListStore) view.model;
        list.clear ();
        var items = new List<FileItem> ();
        try {
            var directory = File.new_for_path (dir);
            if (!directory.query_exists ()) {
                directory = File.new_for_path (home);
            }
            var dir_info = directory.query_info ("standard::*", FileQueryInfoFlags.NOFOLLOW_SYMLINKS, null);
            if (dir_info.get_file_type () != FileType.DIRECTORY) {
                directory = File.new_for_path (home);
            }
            if (directory.has_parent (null)) {
                items.append (new FileItem.for_parent_of (directory));
            }
            var enumerator = directory.enumerate_children ("standard::*", FileQueryInfoFlags.NOFOLLOW_SYMLINKS, null);
            FileInfo info = null;
            while ((info = enumerator.next_file (null)) != null) {
                if (!show_hidden_files && info.get_is_hidden ()) {
                    continue;
                }
                items.append (new FileItem.for_file_info (info, directory.get_child (info.get_name ())));
            }
        } catch (Error e) {
            stderr.printf ("Error: %s\n", e.message);
            return;
        }

        Gtk.TreeIter iter;
        for (int i = 0; i < items.length (); i++) {
            var item = items.nth_data (i);
            list.insert_with_values (out iter, -1, Column.NAME, item.name, Column.SIZE, item.size);
        }
    }
}
