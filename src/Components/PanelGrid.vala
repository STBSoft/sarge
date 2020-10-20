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
    private HashTable<string, FileItem> items {get; set;}

    public PanelGrid (Which which, string home, bool show_hidden_files) {
        this.which = which;
        this.home = home;
        this.show_hidden_files = show_hidden_files;
        items = new HashTable<string, FileItem> (str_hash, str_equal);
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

        list.set_sort_func (Column.NAME, sort_by_name);
        list.set_sort_func (Column.SIZE, sort_by_size);

        var internal_view = new Gtk.TreeView () {
            expand = true,
            enable_grid_lines = Gtk.TreeViewGridLines.VERTICAL,
            model = list
        };

        var name_renderer = new Gtk.CellRendererText () {
            ellipsize = Pango.EllipsizeMode.MIDDLE
        };
        var name_column = new Gtk.TreeViewColumn.with_attributes (
            Column.NAME.humanise (), name_renderer, "text", Column.NAME
        ) {
            expand = true,
            sort_indicator = true
        };
        name_column.set_sort_column_id (Column.NAME);
        internal_view.append_column (name_column);

        var size_renderer = new Gtk.CellRendererText ();
        var size_column = new Gtk.TreeViewColumn.with_attributes (
            Column.SIZE.humanise (), size_renderer, "text", Column.SIZE
        ) {
            sort_indicator = true
        };
        size_column.set_sort_column_id (Column.SIZE);
        internal_view.append_column (size_column);

        //  internal_view.headers_clickable = true;
        return internal_view;
    }

    private void update_view () {
        var list = (Gtk.ListStore) view.model;
        list.clear ();
        items.remove_all ();
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
                var item = new FileItem.for_parent_of (directory);
                items.insert (item.name, item);
            }
            var enumerator = directory.enumerate_children ("standard::*", FileQueryInfoFlags.NOFOLLOW_SYMLINKS, null);
            FileInfo info = null;
            while ((info = enumerator.next_file (null)) != null) {
                if (!show_hidden_files && info.get_is_hidden ()) {
                    continue;
                }
                var item = new FileItem.for_file_info (info, directory.get_child (info.get_name ()));
                items.insert (item.name, item);
            }
        } catch (Error e) {
            stderr.printf ("Error: %s\n", e.message);
            return;
        }

        Gtk.TreeIter iter;
        var values = items.get_values ();
        for (int i = 0; i < values.length (); i++) {
            var item = values.nth_data (i);
            list.insert_with_values (out iter, -1, Column.NAME, item.name, Column.SIZE, item.size);
        }
    }

    private int sort_by_name (Gtk.TreeModel list, Gtk.TreeIter a, Gtk.TreeIter b) {
        var item_a = get_item (list, a);
        var item_b = get_item (list, b);
        var basic_result = basic_compare (item_a, item_b, (Gtk.ListStore) list);
        if (basic_result != 0) {
            return basic_result;
        }
        var name_a = item_a.name.normalize ();
        var name_b = item_b.name.normalize ();
        if (name_a < name_b) {
            return -1;
        }
        return 1;
    }

    private int sort_by_size (Gtk.TreeModel list, Gtk.TreeIter a, Gtk.TreeIter b) {
        var item_a = get_item (list, a);
        var item_b = get_item (list, b);
        var basic_result = basic_compare (item_a, item_b, (Gtk.ListStore) list);
        if (basic_result != 0) {
            return basic_result;
        }
        var size_a = item_a.numeric_size;
        var size_b = item_b.numeric_size;
        if (size_a < size_b) {
            return -1;
        }
        if (size_a > size_b) {
            return 1;
        }
        return 0;
    }

    private static int basic_compare (FileItem item_a, FileItem item_b, Gtk.ListStore list) {
        var reverse = 1;
        int sort_column;
        Gtk.SortType sort_type;
        list.get_sort_column_id (out sort_column, out sort_type);
        if (sort_type == Gtk.SortType.DESCENDING) {
            reverse = -1;
        }
        if (item_a.is_parent) {
            return reverse * -1;
        }
        if (item_b.is_parent) {
            return reverse * 1;
        }
        if (item_a.is_dir && !item_b.is_dir) {
            return reverse * -1;
        }
        if (!item_a.is_dir && item_b.is_dir) {
            return reverse * 1;
        }
        return 0;
    }

    private FileItem get_item (Gtk.TreeModel model, Gtk.TreeIter iter) {
        Value name;
        model.get_value (iter, Column.NAME, out name);
        var item = items.get ((string) name);
        return item;
    }
}
