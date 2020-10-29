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

public class Sarge.Components.FileItem : Object {

    // display attributes
    public Icon icon {get; set;}
    public string name {get; set;}
    public string size {get; set;}
    public string ext {get; set;}

    // internal attributes
    public string path {get; set;}
    public bool is_dir {get; set;}
    public bool is_parent {get; set;}
    public int64 numeric_size {get; set;}
    public string name_without_ext {get; set;}
    public bool is_regular {get; set;}

    private FileItem () {
    }

    public FileItem.for_file_info (FileInfo info, File file) {
        icon = info.get_icon ();
        name = info.get_name ();
        ext = "";
        is_dir = info.get_file_type () == FileType.DIRECTORY;
        is_regular = info.get_file_type () == FileType.REGULAR;
        is_parent = false;
        path = file.get_path ();
        name_without_ext = name;

        if (is_dir) {
            size = "DIR";
            numeric_size = -1;
        } else {
            numeric_size = info.get_size ();
            size = format_size (numeric_size, FormatSizeFlags.DEFAULT);
            if (name != null && name.last_index_of_char ('.') > 0) {
                name_without_ext = name.substring (0, name.last_index_of_char ('.'));
                ext = name.substring (name.last_index_of_char ('.') + 1);
            }
        }
    }

    public FileItem.for_parent_of (File directory) {
        var parent_dir = directory.get_parent ();
        name = "..";
        is_dir = true;
        is_regular = false;
        is_parent = true;
        size = "DIR";
        path = parent_dir.get_path ();
        numeric_size = -1;
        name_without_ext = name;
        ext = "";
    }
}
