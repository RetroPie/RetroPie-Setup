#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="dbar4gun"
rp_module_desc="dbar4gun is a Linux userspace driver for the wiimote with DolphinBar support."
rp_module_help="dbar4gun dvr from https://github.com/lowlevel-1989/dbar4gun"
rp_module_licence="MIT https://raw.githubusercontent.com/lowlevel-1989/dbar4gun/master/LICENSE"
rp_module_repo="git https://github.com/lowlevel-1989/dbar4gun master"
rp_module_section="driver"
rp_module_flags="!all rpi3 rpi4 rpi5"

function depends_dbar4gun() {
    getDepends python3 python3-dev python3-setuptools
}

function sources_dbar4gun() {
    gitPullOrClone
}

function install_dbar4gun() {
    python3 -m venv "$md_inst"
    source "$md_inst/bin/activate"
    pip3 install .
    deactivate
}

function enable_dbar4gun() {
    local config="/etc/systemd/system/dbar4gun.service"

    disable_dbar4gun
    cat > "$config" << _EOF_
[Unit]
Description=dbar4gun

[Service]
Type=simple
ExecStart=$md_inst/bin/dbar4gun --width $1 --height $2

[Install]
WantedBy=multi-user.target
_EOF_

    systemctl enable dbar4gun
    systemctl start  dbar4gun
    printMsgs "dialog" "dbar4gun enabled."
}

function disable_dbar4gun() {
    systemctl stop    dbar4gun
    systemctl disable dbar4gun
}

function remove_dbar4gun() {
    disable_dbar4gun
    rm -rf "/etc/systemd/system/dbar4gun.service"
}

function gui_dbar4gun() {
    local cmd=(dialog --backtitle "$__backtitle" --menu "Choose an option." 22 86 16)
    local options=(
        1 "Enable/Restart  dbar4gun (1080p)"
        2 "Enable/Restart  dbar4gun  (720p)"
        3 "Disable dbar4gun"
    )
    while true; do
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            case "$choice" in
                1)
                    enable_dbar4gun "1920" "1080"
                    ;;
                2)
                    enable_dbar4gun "1280" "720"
                    ;;
                3)
                    disable_dbar4gun
                    ;;
            esac
        else
            break
        fi
    done
}
