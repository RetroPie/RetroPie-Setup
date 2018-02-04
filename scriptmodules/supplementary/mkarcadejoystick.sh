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
rp_module_help="Installs the GPIO driver from https://github.com/recalbox/mk_arcade_joystick_rpi"
rp_module_licence="GPL2 https://raw.githubusercontent.com/recalbox/mk_arcade_joystick_rpi/master/LICENSE"
rp_module_section="driver"
rp_module_flags="noinstclean !x86 !mali"

function _dkms_remove_mkarcadejoystick() {
    dkms remove -m mk_arcade_joystick_rpi -v 0.1.5 --all
}

function depends_mkarcadejoystick() {
    depends_gamecondriver
}

function sources_mkarcadejoystick() {
    gitPullOrClone "$md_inst" https://github.com/recalbox/mk_arcade_joystick_rpi
    sed -i "s/MKVERSION/0.1.5/" "$md_inst/dkms.conf"
}

function build_mkarcadejoystick() {
    ln -sf "$md_inst" "/usr/src/mk_arcade_joystick_rpi-0.1.5"
    if dkms status | grep -q "^mk_arcade_joystick"; then
        _dkms_remove_mkarcadejoystick
    fi
    local kernel
    if [[ "$__chroot" -eq 1 ]]; then
        kernel="$(ls -1 /lib/modules | tail -n -1)"
    else
        kernel="$(uname -r)"
    fi
    dkms install -m mk_arcade_joystick_rpi -v 0.1.5 -k "$kernel"
    if dkms status | grep -q "^mk_arcade_joystick"; then
        md_ret_error+=("Failed to install $md_id")
        return 1
    fi
}

function remove_mkarcadejoystick() {
    [[ -n "$(lsmod | grep mk_arcade_joystick_rpi)" ]] && rmmod mk_arcade_joystick_rpi
    _dkms_remove_mkarcadejoystick
    rm -rf /usr/src/mk_arcade_joystick_rpi-0.1.5
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

    [[ -n "$(lsmod | grep mk_arcade_joystick_rpi)" ]] && rmmod mk_arcade_joystick_rpi
    modprobe mk_arcade_joystick_rpi
} 
