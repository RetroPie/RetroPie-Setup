#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="customhidsony"
rp_module_desc="Custom hid-sony driver backported from kernel 4.15"
rp_module_help="Fixes eternal vibrating bug with Shanwan DS3 controllers.\n\nWarning: the new driver has a different button layout, so you may need to remap your controller."
rp_module_section="driver"
rp_module_flags="noinstclean"

function _version_customhidsony() {
    echo "0.1.1"
}

function _update_hook_customhidsony() {
    dkmsManager update_hook hid-sony "$(_version_customhidsony)"
}

function depends_customhidsony() {
    depends_xpad
}

function sources_customhidsony() {
    mkdir -p "$md_inst/patches"
    pushd "$md_inst"

    cat > "Makefile" << _EOF_
obj-m := drivers/hid/hid-sony.o
_EOF_

    cat > "dkms.conf" << _EOF_
PACKAGE_NAME="hid-sony"
PACKAGE_VERSION="$(_version_customhidsony)"
PRE_BUILD="hidsony_source.sh"
BUILT_MODULE_LOCATION="drivers/hid"
BUILT_MODULE_NAME="\$PACKAGE_NAME"
DEST_MODULE_LOCATION="/updates/dkms"
AUTOINSTALL="yes"
_EOF_

    cat > "hidsony_source.sh" << _EOF_
#!/bin/bash
rpi_kernel_ver="rpi-4.15.y"
mkdir -p "drivers/hid/" "patches"
wget https://raw.githubusercontent.com/raspberrypi/linux/"\$rpi_kernel_ver"/drivers/hid/hid-sony.c -O "drivers/hid/hid-sony.c"
wget https://raw.githubusercontent.com/raspberrypi/linux/"\$rpi_kernel_ver"/drivers/hid/hid-ids.h -O "drivers/hid/hid-ids.h"
patch -p1 <"patches/0001-hidsony-nomotionsensors.diff"
_EOF_
    chmod +x "hidsony_source.sh"

    cp "$md_data/0001-hidsony-nomotionsensors.diff" "patches/"

    popd
}

function build_customhidsony() {
    dkmsManager install hid-sony "$(_version_customhidsony)"
}

function remove_customhidsony() {
    dkmsManager remove hid-sony "$(_version_customhidsony)"
}

function configure_customhidsony() {
    [[ "$md_mode" == "remove" ]] && return

    dkmsManager reload hid-sony "$(_version_customhidsony)"
}
