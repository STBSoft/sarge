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

public class Sarge.Components.PanelBox : Gtk.Box {
    public enum Side {
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
        NAME, EXT, SIZE;

        public string humanise () {
            switch (this) {
                case NAME:
                    return _("Name");
                case EXT:
                    return _("Ext");
                case SIZE:
                    return _("Size");
            }
            return "Weird!";
        }
    }

    public Side side {get; set;}
    private string home {get; set;}
    public bool show_hidden_files {get; set;}
    public Gtk.TreeView view {get; set;}
    private string dir {get; set;}
    // TODO: try : https://stackoverflow.com/questions/61263462/how-to-assign-hidden-data-to-gtk-treeview-row-in-order-to-catch-them-with-gtk
    private HashTable<string, FileItem> items {get; set;}
    private string selection {get; set;}
    private string last_dir {get; set;}
    private Gtk.Label top_label {get; set;}
    private Gtk.ButtonBox drive_box {get; set;}

    public PanelBox (Side side, string home, bool show_hidden_files) {
        this.side = side;
        this.home = home;
        this.show_hidden_files = show_hidden_files;
        items = new HashTable<string, FileItem> (str_hash, str_equal);
        expand = true;
        orientation = Gtk.Orientation.VERTICAL;
        set_has_window (false);
        dir = home;  // TODO: dir from saved history in settings
        drive_box = new Gtk.ButtonBox (Gtk.Orientation.HORIZONTAL) {
            halign = Gtk.Align.START
        };
        pack_start (drive_box, false, false, 0);
        top_label = new Gtk.Label (dir);
        pack_start (top_label, false, false, 0);
        view = create_view ();
        var label2 = new Gtk.Label ("Bla");
        pack_end (label2, false, false, 0);
        update_drives ();
        update_view ();
    }

    private Gtk.TreeView create_view () {
        var list = new Gtk.ListStore (3, typeof (string), typeof (string), typeof (string));
        list.set_sort_column_id (0, Gtk.SortType.ASCENDING); // TODO: sort column and direction from settings

        list.set_sort_func (Column.NAME, sort_by_name_func);
        list.set_sort_func (Column.EXT, sort_by_ext_func);
        list.set_sort_func (Column.SIZE, sort_by_size_func);

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
        name_column.set_cell_data_func (name_renderer, name_without_ext_func);
        name_column.set_sort_column_id (Column.NAME);
        internal_view.append_column (name_column);

        var ext_renderer = new Gtk.CellRendererText ();
        var ext_column = new Gtk.TreeViewColumn.with_attributes (
            Column.EXT.humanise (), ext_renderer, "text", Column.EXT
        ) {
            sort_indicator = true
        };
        ext_column.set_cell_data_func (ext_renderer, show_only_ext_func);
        ext_column.set_sort_column_id (Column.EXT);
        internal_view.append_column (ext_column);


        var size_renderer = new Gtk.CellRendererText ();
        var size_column = new Gtk.TreeViewColumn.with_attributes (
            Column.SIZE.humanise (), size_renderer, "text", Column.SIZE
        ) {
            sort_indicator = true
        };
        size_column.set_sort_column_id (Column.SIZE);
        internal_view.append_column (size_column);

        internal_view.row_activated.connect (on_row_activated);
        //  internal_view.cursor_changed.connect (on_cursor_changed);
        internal_view.get_selection ().mode = Gtk.SelectionMode.NONE;

        var scrolled_window = new Gtk.ScrolledWindow (null, null) {
            valign = Gtk.Align.START,
            propagate_natural_height = true,
            hscrollbar_policy = Gtk.PolicyType.NEVER
        };
        scrolled_window.add (internal_view);
        pack_start (scrolled_window, true, true, 0);
        return internal_view;
    }

    private void update_view () {
        top_label.label = dir;
        var list = (Gtk.ListStore) view.model;
        list.clear ();
        items.remove_all ();
        try {
            var directory = File.new_for_path (dir);
            if (!directory.query_exists ()) {
                warning ("directory does notexist: %s\n", dir);
                dir = home;
                directory = File.new_for_path (dir);
            }
            var dir_info = directory.query_info ("standard::*", FileQueryInfoFlags.NOFOLLOW_SYMLINKS, null);
            if (dir_info.get_file_type () != FileType.DIRECTORY) {
                warning ("directory does notexist: %s\n", dir);
                dir = home;
                directory = File.new_for_path (dir);
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
            list.insert_with_values (out iter, -1,
                    Column.NAME, item.name,
                    Column.EXT, item.ext,
                    Column.SIZE, item.size
            );
            if (last_dir != null && item.path == last_dir) {
                var last_dir_path = list.get_path (iter);
                if (last_dir_path != null) {
                    view.set_cursor (last_dir_path, null, false);
                }
            }
        }
    }

    public void update_drives () {
        VolumeMonitor monitor = VolumeMonitor.get ();
        var volumes = monitor.get_volumes ();
        foreach (Volume volume in volumes) {
            var mount = volume.get_mount ();
            if (mount != null) {
                var button = new DriveButton.for_mount (mount);
                button.clicked.connect (on_mount_button_clicked);
                drive_box.pack_start (button, false, false, 0);
            } else {
                var button = new DriveButton.for_volume (volume);
                drive_box.pack_start (button, false, false, 0);
            }
        }
    }

    private void on_mount_button_clicked (Gtk.Button source) {
        var mount = ((DriveButton) source).mount;
        dir = mount.get_default_location ().get_path ();
        update_view ();
    }

    private int sort_by_name_func (Gtk.TreeModel list, Gtk.TreeIter a, Gtk.TreeIter b) {
        var item_a = get_item (list, a);
        var item_b = get_item (list, b);
        var basic_result = dir_compare (item_a, item_b, (Gtk.ListStore) list);
        if (basic_result != 0) {
            return basic_result;
        }
        var name_a = item_a.name.normalize ();
        var name_b = item_b.name.normalize ();
        var numeric_a = 0;
        var numeric_b = 0;
        for (var i = 0; i < name_a.length; i++) {
            if (i == name_b.length) {
                return 1;
            }
            var char_a = name_a.get_char (i);
            var char_b = name_b.get_char (i);
            if (char_a.isdigit () && char_b.isdigit ()) {
                numeric_a *= 10;
                numeric_a += char_a.digit_value ();
                numeric_b *= 10;
                numeric_b += char_b.digit_value ();
                continue;
            }
            if (char_a.isdigit () || char_b.isdigit ()) {
                if (numeric_a == 0) {
                    return char_a.isdigit () ? -1 : 1;
                }
                if (char_a.isdigit ()) {
                    numeric_a *= 10;
                    numeric_a += char_a.digit_value ();
                }
                if (char_b.isdigit ()) {
                    numeric_b *= 10;
                    numeric_b += char_b.digit_value ();
                }
            }
            if (numeric_a != 0 || numeric_b != 0) {
                if (numeric_a != numeric_b) {
                    return numeric_a - numeric_b;
                }
            }
            numeric_a = 0;
            numeric_b = 0;
            char_a = char_a.tolower ();
            char_b = char_b.tolower ();
            if (char_a == char_b) {
                continue;
            }
            if (char_a < char_b) {
                return -1;
            }
            return 1;
        }
        return numeric_a - numeric_b;
    }

    private int sort_by_ext_func (Gtk.TreeModel list, Gtk.TreeIter a, Gtk.TreeIter b) {
        var item_a = get_item (list, a);
        var item_b = get_item (list, b);
        var basic_result = dir_compare (item_a, item_b, (Gtk.ListStore) list);
        if (basic_result != 0) {
            return basic_result;
        }
        var ext_a = item_a.ext;
        var ext_b = item_b.ext;
        if (ext_a < ext_b) {
            return -1;
        }
        if (ext_a > ext_b) {
            return 1;
        }
        return sort_by_name_func (list, a, b);
    }

    private int sort_by_size_func (Gtk.TreeModel list, Gtk.TreeIter a, Gtk.TreeIter b) {
        var item_a = get_item (list, a);
        var item_b = get_item (list, b);
        var basic_result = dir_compare (item_a, item_b, (Gtk.ListStore) list);
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

    private static int dir_compare (FileItem item_a, FileItem item_b, Gtk.ListStore list) {
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

    private void name_without_ext_func (Gtk.CellLayout name_layout, Gtk.CellRenderer name_renderer,
            Gtk.TreeModel list, Gtk.TreeIter iter) {
        name_renderer.set_property ("text", get_item (list, iter).name_without_ext);
    }

    private void show_only_ext_func (Gtk.CellLayout ext_layout, Gtk.CellRenderer ext_renderer,
            Gtk.TreeModel list, Gtk.TreeIter iter) {
        ext_renderer.set_property ("text", get_item (list, iter).ext);
    }

    private void on_row_activated (Gtk.TreePath path, Gtk.TreeViewColumn column) {
        var tree_view = (Gtk.TreeView) column.get_tree_view ();
        var list = tree_view.model;
        Gtk.TreeIter iter;
        if (list.get_iter (out iter, path)) {
            var item = get_item (list, iter);
            if (item.is_dir) {
                last_dir = dir;
                dir = item.path;
                update_view ();
            } else if (item.is_regular) {
                var file = File.new_for_path (item.path);
                if (file.query_exists ()) {
                    try {
                        AppInfo.launch_default_for_uri (file.get_uri (), null);
                    } catch (Error e) {
                        warning ("Unable to launch %s\n", item.path);
                    }
                }
            }
        }
    }

    //  private void on_cursor_changed () {
    //      Gtk.TreePath path;
    //      Gtk.TreeViewColumn column;
    //      view.get_cursor (out path, out column);
    //      if (path != null) {
    //          Gtk.TreeIter iter;
    //          var list = view.model;
    //          if (list.get_iter (out iter, path)) {
    //              var item = get_item (list, iter);
    //              stdout.printf ("cursor: %s\n", item.name);
    //          }
    //      }
    //  }
}
