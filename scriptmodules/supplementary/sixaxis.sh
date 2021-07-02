#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="sixaxis"
rp_module_desc="Helper service for official and third-party DualShock controllers (ps3controller replacement)"
rp_module_help="For Shanwan/GASIA third-party controllers, enable third-party support in the configuration options.\n\nTo pair controllers, use the RetroPie Bluetooth menu, choose 'Register and Connect...', then follow the on-screen instructions."
rp_module_licence="GPL2 https://raw.githubusercontent.com/RetroPie/sixaxis/master/COPYING"
rp_module_repo="git https://github.com/RetroPie/sixaxis.git master"
rp_module_section="driver"

function depends_sixaxis() {
    getDepends checkinstall libevdev-tools

    # add special check for presence of sixaxis plugin, and restart bluetooth stack if necessary
    if ! hasPackage "libbluetooth3"; then
        getDepends libbluetooth3
        service bluetooth restart
    fi

    rp_callModule ps3controller remove
}

function sources_sixaxis() {
    gitPullOrClone
}

function build_sixaxis() {
    make clean
    make
    md_ret_require="$md_build/bins/sixaxis-timeout"
}

function gui_sixaxis() {
    local sixaxis_config="$md_conf_root/all/sixaxis_timeout.cfg"
    local cmd=(dialog --backtitle "$__backtitle" --menu "Choose an option." 22 86 16)
    local options=(
        1 "Enable support for third-party controllers"
        2 "Disable support for third-party controllers"
        3 "Configure controller timeout"
    )
    local timeout_options=(
        0 "No timeout"
        300 "5 minutes"
        600 "10 minutes"
        900 "15 minutes"
        1200 "20 minutes"
        1800 "30 minutes"
    )
    while true; do
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            case "$choice" in
                1)
                    rp_callModule "customhidsony"
                    ;;
                2)  rp_callModule "customhidsony" remove
                    rp_callModule "custombluez" remove
                    ;;
                3)
                    local timeout_choice=$("${cmd[@]}" "${timeout_options[@]}" 2>&1 >/dev/tty)
                    if [[ -n "$timeout_choice" ]] && [[ -f "$sixaxis_config" ]]; then
                        case "$timeout_choice" in
                            *)
                                iniConfig "=" "" "$sixaxis_config"
                                iniSet "SIXAXIS_TIMEOUT" "$timeout_choice"
                                systemctl restart sixaxis@/* &>/dev/null
                                ;;
                        esac
                    fi
                    ;;
            esac
        else
            break
        fi
    done
}

function install_sixaxis() {
    checkinstall -y --fstrans=no
}

function configure_sixaxis() {
    [[ "$md_mode" == "remove" ]] && return

    local sixaxis_config="$(mktemp)"

    echo "# Set your preferred controller timeout in seconds (0 to disable)" >"$sixaxis_config"
    iniConfig "=" "" "$sixaxis_config"
    iniSet "SIXAXIS_TIMEOUT" "600"
    copyDefaultConfig "$sixaxis_config" "$md_conf_root/all/sixaxis_timeout.cfg"
    rm "$sixaxis_config"
}

function remove_sixaxis() {
    dpkg --purge sixaxis
}
