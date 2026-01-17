#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="mkarcadejoystick"
rp_module_desc="Raspberry Pi GPIO Joystick Driver"
rp_module_help="Installs the GPIO driver from https://github.com/cmitu/mk_arcade_joystick_rpi"
rp_module_licence="GPL2 https://raw.githubusercontent.com/recalbox/mk_arcade_joystick_rpi/master/LICENSE"
rp_module_repo="git https://github.com/cmitu/mk_arcade_joystick_rpi retropie"
rp_module_section="driver"
rp_module_flags="noinstclean !all rpi !rpi5"

function _version_mkarcadejoystick() {
    echo "0.1.7"
}

function depends_mkarcadejoystick() {
    depends_gamecondriver
}

function sources_mkarcadejoystick() {
    gitPullOrClone "$md_inst"
    pushd "$md_inst"
    sed -i "s/\$MKVERSION/$(_version_mkarcadejoystick)/" "$md_inst/dkms.conf"
    popd
}

function build_mkarcadejoystick() {
    dkmsManager install mk_arcade_joystick_rpi "$(_version_mkarcadejoystick)"
}

function remove_mkarcadejoystick() {
    dkmsManager remove mk_arcade_joystick_rpi
    rm -f /etc/modprobe.d/mk_arcade_joystick_rpi.conf
    sed -i "/mk_arcade_joystick_rpi/d" /etc/modules
}

function configure_mkarcadejoystick() {
    [[ "$md_mode" == "remove" ]] && return

    if ! grep -q "mk_arcade_joystick_rpi" /etc/modules; then
        addLineToFile "mk_arcade_joystick_rpi" /etc/modules
    fi

    if [[ ! -f /etc/modprobe.d/mk_arcade_joystick_rpi.conf ]]; then
        echo "options mk_arcade_joystick_rpi map=1" >/etc/modprobe.d/mk_arcade_joystick_rpi.conf
    fi

    dkmsManager reload mk_arcade_joystick_rpi
}
