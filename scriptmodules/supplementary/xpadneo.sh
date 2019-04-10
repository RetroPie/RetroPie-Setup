#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="xpadneo"
rp_module_desc="Linux Driver for Xbox One Wireless Gamepad"
rp_module_help="Enhanced Linux driver for Xbox One Wireless Gamepad (which is shipped with the Xbox One S)."
rp_module_licence="GPL3 https://raw.githubusercontent.com/atar-axis/xpadneo/master/LICENSE"
rp_module_section="driver"
rp_module_flags="noinstclean !mali"

function _version_xpadneo() {
    cat "$md_inst/VERSION"
}

function depends_xpadneo() {
    local depends=(dkms)
    isPlatform "rpi" && depends+=(raspberrypi-kernel-headers)
    isPlatform "x11" && depends+=(linux-headers-generic)
    getDepends "${depends[@]}"
}

function sources_xpadneo() {
    rm -rf "$md_inst"
    gitPullOrClone "$md_inst" https://github.com/atar-axis/xpadneo.git
    cd "$md_inst"
    sed -i 's/PACKAGE_VERSION="@DO_NOT_CHANGE@"/PACKAGE_VERSION="'"$(_version_xpadneo)"'"/g' hid-xpadneo/dkms.conf
    sed -i 's/#define DRV_VER "@DO_NOT_CHANGE@"/#define DRV_VER "'"$(_version_xpadneo)"'"/g' hid-xpadneo/src/hid-xpadneo.c
    cp -R "$md_inst/hid-xpadneo/"* .
}

function build_xpadneo() {
    dkmsManager install hid-xpadneo "$(_version_xpadneo)"
}

function remove_xpadneo() {
    dkmsManager remove hid-xpadneo "$(_version_xpadneo)"
}

function configure_xpadneo() {
    [[ "$md_mode" == "remove" ]] && return

    dkmsManager reload hid-xpadneo "$(_version_xpadneo)"
}
