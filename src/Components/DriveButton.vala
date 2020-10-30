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

public class Sarge.Components.DriveButton : Gtk.Button {

    public Mount mount {get; set;}
    public Volume volume {get; set;}
    
    private DriveButton () {
        can_focus = false;
    }

    public DriveButton.for_mount (Mount mount) {
        this ();
        this.mount = mount;
        this.volume = mount.get_volume ();
        label = mount.get_name ();
    }

    public DriveButton.for_volume (Volume volume) {
        this ();
        sensitive = false; // for now
        this.volume = volume;
        label = volume.get_name (); 
    }
}