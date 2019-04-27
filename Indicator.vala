/*
 * Copyright (c) 2011-2018 elementary, Inc. (https://elementary.io)
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
 * Boston, MA 02110-1301 USA.
 */

using Posix;

/**
 * This small example shows how to use the wingpanel api to create a simple indicator
 * and how to make use of some useful helper widgets.
 */
public class DHPiaVpn.Indicator : Wingpanel.Indicator {
    /* Our display widget, a composited icon */
    // private Wingpanel.Widgets.OverlayIcon display_widget;
    private Gtk.Image display_widget;

    // The switch
    private Wingpanel.Widgets.Switch pia_switch;

    /* The main widget that is displayed in the popover */
    private Gtk.Grid main_widget;

    public Indicator () {
        /* Some information about the indicator */
        Object (
            code_name : "dev.datahjelpen.pia_vpn", /* Unique name */
            display_name : _("DHPiaVpn Indicator"), /* Localised name */
            description: _("Turn on or off PIA VPN") /* Short description */
        );
    }

    construct {
        // Get the icon
        var icon = new Gtk.Image.from_file ("/home/bjornar/.local/share/datahjelpen/pia_vpn/pia-16.png");

        // Scale the icon
        // icon.set_pixel_size(16);

        // Set the icon
        display_widget = icon;

        // Create switch
        pia_switch = new Wingpanel.Widgets.Switch (_("PIA running"));
        pia_switch.active = true;

        // Attach switch to modal
        main_widget = new Gtk.Grid ();
        main_widget.attach (pia_switch, 0, 0);

        /* Indicator should be visible at startup */
        this.visible = true;

        pia_switch.notify["active"].connect (() => {
            if (pia_switch.active) {
                // Turn on
                Posix.system("/opt/piavpn/bin/pia-client --quiet &");
            } else {
                // Turn off
                Posix.system("killall pia-client");
            }
        });
    }

    /* This method is called to get the widget that is displayed in the panel */
    public override Gtk.Widget get_display_widget () {
        return display_widget;
    }

    /* This method is called to get the widget that is displayed in the popover */
    public override Gtk.Widget? get_widget () {
        return main_widget;
    }

    /* This method is called when the indicator popover opened */
    public override void opened () {
        /* Use this method to get some extra information while displaying the indicator */
    }

    /* This method is called when the indicator popover closed */
    public override void closed () {
        /* Your stuff isn't shown anymore, now you can free some RAM, stop timers or anything else... */
    }
}

/*
 * This method is called once after your plugin has been loaded.
 * Create and return your indicator here if it should be displayed on the current server.
 */
public Wingpanel.Indicator? get_indicator (Module module, Wingpanel.IndicatorManager.ServerType server_type) {
    /* A small message for debugging reasons */
    debug ("Activating DHPiaVpn Indicator");

    /* Check which server has loaded the plugin */
    if (server_type != Wingpanel.IndicatorManager.ServerType.SESSION) {
        /* We want to display our indicator only in the "normal" session, not on the login screen, so stop here! */
        return null;
    }

    /* Create the indicator */
    var indicator = new DHPiaVpn.Indicator ();

    /* Return the newly created indicator */
    return indicator;
}
