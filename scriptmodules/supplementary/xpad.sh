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

function _version_xpad() {
    echo "0.4"
}

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
    applyPatch "$md_data/01_enable_leds_and_trigmapping.diff"
}

function build_xpad() {
    dkmsManager install xpad "$(_version_xpad)"
}

function remove_xpad() {
    dkmsManager remove xpad "$(_version_xpad)"
    rm -f /etc/modprobe.d/xpad.conf
}

function configure_xpad() {
    [[ "$md_mode" == "remove" ]] && return

    if [[ ! -f /etc/modprobe.d/xpad.conf ]]; then
        echo "options xpad triggers_to_buttons=1" >/etc/modprobe.d/xpad.conf
    fi
    dkmsManager reload xpad "$(_version_xpad)"
}
