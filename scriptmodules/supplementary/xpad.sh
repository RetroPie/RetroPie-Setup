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
rp_module_section="driver"
rp_module_flags="!x86 !mali"

function depends_xpad() {
    getDepends dkms raspberrypi-kernel-headers
}

function sources_xpad() {
    gitPullOrClone "$md_inst" https://github.com/paroj/xpad.git
    cd "$md_inst"
    # force LED support (as disabled currently in packaged RPI kernel)
    applyPatch "enable_leds.diff" <<\_EOF_
diff --git a/xpad.c b/xpad.c
index 2ff80cf..df25a77 100644
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
_EOF_
}

function build_xpad() {
    ln -sf "$md_inst" "/usr/src/xpad-0.4"
    dkms install -m xpad -v 0.4
}

function remove_xpad() {
    dkms remove -m xpad -v 0.4 --all
    rm -rf "/usr/src/xpad-0.4"
}
