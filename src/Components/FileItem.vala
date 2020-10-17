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

    public Icon icon {get; set;}
    public string name {get; set;}
    public string size {get; set;}

    public bool is_dir {get; set;}

    public FileItem (FileInfo info) {
        icon = info.get_icon ();
        name = info.get_name ();

        is_dir = info.get_file_type () == FileType.DIRECTORY;

        if (is_dir) {
            size = "DIR";
        } else {
            size = format_size (info.get_size (), FormatSizeFlags.DEFAULT);
        }
    }

}
