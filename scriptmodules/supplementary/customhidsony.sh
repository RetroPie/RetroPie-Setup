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

function _update_hook_customhidsony() {
    if rp_isInstalled "$md_idx"; then
        if [[ ! "$(dkms status hid-sony/$(_version_customhidsony))" ]]; then
            rp_callModule "$md_idx"
        fi
    fi
}

function _version_customhidsony() {
    echo "0.1.1"
}

function _dkms_remove_customhidsony() {
    dkms remove -m hid-sony -v "$(_version_customhidsony)" --all
}

function depends_customhidsony() {
    depends_gamecondriver
}

function sources_customhidsony() {
    mkdir -p "$md_inst/patches"
    pushd "$md_inst"

    cat > "$md_inst/Makefile" << _EOF_
obj-m := drivers/hid/hid-sony.o
_EOF_

    cat > "$md_inst/dkms.conf" << _EOF_
PACKAGE_NAME="hid-sony"
PACKAGE_VERSION="$(_version_customhidsony)"
PRE_BUILD="hidsony_source.sh"
BUILT_MODULE_LOCATION="drivers/hid"
BUILT_MODULE_NAME="\$PACKAGE_NAME"
DEST_MODULE_LOCATION="/updates/dkms"
AUTOINSTALL="yes"
_EOF_

    cat > "$md_inst/hidsony_source.sh" << _EOF_
#!/bin/bash
rpi_kernel_ver="rpi-4.15.y"
mkdir -p "drivers/hid/" "patches"
wget https://raw.githubusercontent.com/raspberrypi/linux/"\$rpi_kernel_ver"/drivers/hid/hid-sony.c -O "drivers/hid/hid-sony.c"
wget https://raw.githubusercontent.com/raspberrypi/linux/"\$rpi_kernel_ver"/drivers/hid/hid-ids.h -O "drivers/hid/hid-ids.h"
patch -p1 <"patches/0001-hidsony-nomotionsensors.diff"
_EOF_
    chmod +x "$md_inst/hidsony_source.sh"

    cp "$md_data/0001-hidsony-nomotionsensors.diff" "patches/"

    popd
}

function build_customhidsony() {
    ln -sf "$md_inst" "/usr/src/hid-sony-$(_version_customhidsony)"
    if dkms status | grep -q "^hid-sony"; then
        _dkms_remove_customhidsony
    fi
    local kernel
    if [[ "$__chroot" -eq 1 ]]; then
        kernel="$(ls -1 /lib/modules | tail -n -1)"
    else
        kernel="$(uname -r)"
    fi
    dkms install --force -m hid-sony -v "$(_version_customhidsony)" -k "$kernel"
    if dkms status | grep -q "^hid-sony"; then
        md_ret_error+=("Failed to install $md_id")
        return 1
    fi
}

function remove_customhidsony() {
    [[ -n "$(lsmod | grep hid_sony)" ]] && rmmod hid-sony
    _dkms_remove_customhidsony
    rm -rf /usr/src/hid-sony-"$(_version_customhidsony)"
}

function configure_customhidsony() {
    [[ -n "$(lsmod | grep hid_sony)" ]] && rmmod hid-sony
    modprobe hid-sony
}
