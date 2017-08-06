#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="xpad"
rp_module_desc="Updated Xpad Linux Kernel driver"
rp_module_help="This is the latest Xpad driver from https://github.com/paroj/xpad\n\nThe driver has been patched to allow the triggers to map to buttons for any controller and this has been enabled by default.\n\nThis fixes mapping the triggers in Emulation Station.\n\nIf you want the previous trigger behaviour please edit /etc/modprobe.d/xpad.conf and set triggers_to_buttons=0"
rp_module_licence="GPL2 https://www.kernel.org/pub/linux/kernel/COPYING"
rp_module_section="driver"
rp_module_flags="noinstclean !mali"

function depends_xpad() {
    local depends=(dkms)
    isPlatform "rpi" && depends+=(raspberrypi-kernel-headers)
    isPlatform "x11" && depends+=(linux-headers-generic)
    getDepends "${depends[@]}"
}

function sources_xpad() {
    rm -rf "$md_inst"
    gitPullOrClone "$md_inst" https://github.com/paroj/xpad.git
    cd "$md_inst"
    # LED support (as disabled currently in packaged RPI kernel) and allow forcing MAP_TRIGGERS_TO_BUTTONS
    applyPatch "retropie.diff" <<\_EOF_
diff --git a/xpad.c b/xpad.c
index 2ff80cf..8c8ea54 100644
--- a/xpad.c
+++ b/xpad.c
@@ -75,6 +75,7 @@
  * Later changes can be tracked in SCM.
  */
 #define DEBUG
+#define CONFIG_JOYSTICK_XPAD_LEDS 1
 #include <linux/kernel.h>
 #include <linux/input.h>
 #include <linux/rcupdate.h>
@@ -1505,12 +1506,13 @@ static int xpad_probe(struct usb_interface *intf, const struct usb_device_id *id
 
 		if (dpad_to_buttons)
 			xpad->mapping |= MAP_DPAD_TO_BUTTONS;
-		if (triggers_to_buttons)
-			xpad->mapping |= MAP_TRIGGERS_TO_BUTTONS;
 		if (sticks_to_null)
 			xpad->mapping |= MAP_STICKS_TO_NULL;
 	}
 
+	if (triggers_to_buttons)
+		xpad->mapping |= MAP_TRIGGERS_TO_BUTTONS;
+
 	if (xpad->xtype == XTYPE_XBOXONE &&
 	    intf->cur_altsetting->desc.bInterfaceNumber != 0) {
 		/*
_EOF_
}

function build_xpad() {
    ln -sf "$md_inst" "/usr/src/xpad-0.4"
    if dkms status | grep -q "^xpad"; then
        dkms remove -m xpad -v 0.4 --all
    fi
    dkms install -m xpad -v 0.4 -k "$(ls -1 /lib/modules | tail -n -1)"
}

function remove_xpad() {
    dkms remove -m xpad -v 0.4 --all
    rm -rf /usr/src/xpad-0.4
    rm -f /etc/modprobe.d/xpad.conf
}

function configure_xpad() {
    if [[ ! -f /etc/modprobe.d/xpad.conf ]]; then
        echo "options xpad triggers_to_buttons=1" >/etc/modprobe.d/xpad.conf
    fi
}
