#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="steamcontroller"
rp_module_desc="User-mode driver for Steam Controller"
rp_module_help="Steam Controller Driver from https://github.com/Ryochan7/sc-controller"
rp_module_licence="GPL2 https://raw.githubusercontent.com/Ryochan7/sc-controller/python3/LICENSE"
rp_module_repo="git https://github.com/Ryochan7/sc-controller python3"
rp_module_section="driver"

function _update_hook_steamcontroller() {
    # remove the start command from the previous scriptmodule version
    if rp_isInstalled "$md_id"; then
        sed -i "/bin\/sc-.*.py/d" /etc/rc.local
    fi
}
function depends_steamcontroller() {
    getDepends python3-virtualenv python3-dev python3-setuptools
}

function sources_steamcontroller() {
    gitPullOrClone
}

function install_steamcontroller() {
    # build the driver in a virtualenv created in $md_inst
    virtualenv -p python3 "$md_inst"
    source "$md_inst/bin/activate"
    pip3 install libusb1 evdev
    pip3 install "sccontroller @ file://$md_build"
    deactivate

    # copy the default controller profiles
    md_ret_files=("default_profiles")
}

function enable_steamcontroller() {
    local profile="$1"
    [[ -z "$profile" ]] && profile="XBox Controller"

    local config="\"$md_inst/bin/scc-daemon\" \"$md_inst/default_profiles/$profile.sccprofile\" start"

    disable_steamcontroller
    sed -i "s|^exit 0$|${config}\\nexit 0|" /etc/rc.local
    printMsgs "dialog" "Steamcontroller enabled in /etc/rc.local with the following profile:\n\n$profile\n\nIt will be started on next boot."
}

function disable_steamcontroller() {
    sed -i "/bin\/sc-.*.py/d" /etc/rc.local           # previous version
    sed -i "/bin\/scc-daemon.*start/d" /etc/rc.local  # current version
    $md_inst/bin/scc-daemon stop
}

function remove_steamcontroller() {
    disable_steamcontroller
    rm -f /etc/udev/rules.d/99-steam-controller.rules
}

function configure_steamcontroller() {
    cat >/etc/udev/rules.d/99-steam-controller.rules <<_EOF_
# Steam controller keyboard/mouse mode
SUBSYSTEM=="usb", ATTRS{idVendor}=="28de", GROUP="input", MODE="0660"

# Valve HID devices over bluetooth hidraw
KERNEL=="hidraw*", KERNELS=="*28de:*", MODE="0660", GROUP="input", TAG+="uaccess"

# Steam controller gamepad mode
KERNEL=="uinput", MODE="0660", GROUP="input", OPTIONS+="static_node=uinput"
_EOF_
}

function gui_steamcontroller() {
    local cmd=(dialog --backtitle "$__backtitle" --menu "Choose an option." 22 86 16)
    local options=(
        1 "Enable Steamcontroller (Xbox controller mode)"
        2 "Enable Steamcontroller (Desktop mouse/keyboard mode)"
        3 "Disable Steamcontroller"
    )
    while true; do
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            case "$choice" in
                1)
                    enable_steamcontroller "XBox Controller"
                    ;;
                2)
                    enable_steamcontroller "Desktop"
                    ;;
                3)
                    disable_steamcontroller
                    printMsgs "dialog" "steamcontroller removed from /etc/rc.local"
                    ;;
            esac
        else
            break
        fi
    done
}
