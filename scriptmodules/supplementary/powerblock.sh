#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="powerblock"
rp_module_desc="PowerBlock Driver"
rp_module_section="driver"

function depends_powerblock() {
    local depends=(cmake doxygen)
    isPlatform "rpi" && depends+=(libraspberrypi-dev)

    getDepends "${depends[@]}"
}

function sources_powerblock() {
    gitPullOrClone "$md_build" https://github.com/petrockblog/PowerBlock.git
}

function build_powerblock() {
    mkdir build && cd build
    cmake ..
    make
    md_ret_require="$md_build/build/powerblock"
}

function install_powerblock() {
    mkdir -p "$md_inst/"{src,supplementary,scripts,build,doc}
    cp -r "$md_build"/build/* "$md_inst/build/"
    cp -r "$md_build"/scripts/* "$md_inst/scripts/"
    cp -r "$md_build"/supplementary/* "$md_inst/supplementary/"
    cp -r "$md_build"/src/* "$md_inst/src/"
    cp -r "$md_build"/doc/* "$md_inst/doc/"

    # then install from there to system folders
    pushd "$md_inst/"build
    make install
    popd
}

function gui_powerblock() {
    cmd=(dialog --backtitle "$__backtitle" --menu "Choose an option." 22 86 16)
    options=(
        1 "Disable PowerBlock driver."
        2 "Enable PowerBlok driver"
    )
    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choices" ]]; then
        case $choices in
            1)
                pushd "$md_inst/"build
                make uninstallservice
                popd
                printMsgs "dialog" "Disabled PowerBlock driver."
                ;;
            2)
                pushd "$md_inst/"build
                make installservice
                popd
                printMsgs "dialog" "Enabled PowerBlock driver."
                ;;
        esac
    fi
}

function remove_powerblock() {
    pushd "$md_inst/"build
    make uninstallservice
    make uninstall
    popd
}
