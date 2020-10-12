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

public class Sarge.PanelGrid : Gtk.Grid {
    public enum Which {
        LEFT, RIGHT;

        public string to_string () {
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

    public PanelGrid (Which which, string home) {
        this.which = which;
        this.home = home;
        var label = new Gtk.Label (this.which.to_string () + " " + this.home);
        add (label);
        expand = true;
        set_has_window (false);
    }

}
