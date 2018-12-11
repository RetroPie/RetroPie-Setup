#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="retropie-manager"
rp_module_desc="Web Based Manager for RetroPie files and configs based on the Recalbox Manager"
rp_module_help="Open your browser and go to http://your_retropie_ip:8000/"
rp_module_licence="MIT https://raw.githubusercontent.com/botolo78/RetroPie-Manager/retropie/ORIGINAL%20LICENCE.txt"
rp_module_section="exp"
rp_module_flags="noinstclean"

function depends_retropie-manager() {
    local depends=(python-dev virtualenv)
    getDepends "${depends[@]}"
}

function sources_retropie-manager() {
    gitPullOrClone "$md_inst" "https://github.com/botolo78/RetroPie-Manager.git" retropie
}

function install_retropie-manager() {
    cd "$md_inst"
    chown -R $user:$user "$md_inst"
    sudo -u $user make install
}

function _is_enabled_retropie-manager() {
    grep -q 'rpmanager\.sh.*--start' /etc/rc.local
    return $?
}

function enable_retropie-manager() {
    local config="\"$md_inst/rpmanager.sh\" --start --user $user 2>\&1 > /dev/shm/rpmanager.log \&"

    if _is_enabled_retropie-manager; then
        dialog \
          --yesno "RetroPie-Manager is already enabled in /etc/rc.local with the following config.\n\n$(grep "rpmanager\.sh" /etc/rc.local)\n\nDo you want to update it?" \
          22 76 2>&1 >/dev/tty || return
    fi

    sed -i "/rpmanager\.sh.*--start/d" /etc/rc.local
    sed -i "s|^exit 0$|${config}\\nexit 0|" /etc/rc.local
    printMsgs "dialog" "RetroPie-Manager enabled in /etc/rc.local\n\nIt will be started on next boot."
}

function disable_retropie-manager() {
    if _is_enabled_retropie-manager; then
        dialog \
          --yesno "Are you sure you want to disable RetroPie-Manager on boot?" \
          22 76 2>&1 >/dev/tty || return

        sed -i "/rpmanager\.sh.*--start/d" /etc/rc.local
        printMsgs "dialog" "RetroPie-Manager configuration in /etc/rc.local has been removed."
    else
        printMsgs "dialog" "RetroPie-Manager was already disabled in /etc/rc.local."
    fi
}

function remove_retropie-manager() {
    sed -i "/rpmanager\.sh.*--start/d" /etc/rc.local
}

function gui_retropie-manager() {
    local cmd=()
    local options=(
        1 "Start RetroPie-Manager now"
        2 "Stop RetroPie-Manager now"
        3 "Enable RetroPie-Manager on Boot"
        4 "Disable RetroPie-Manager on Boot"
    )
    local choice
    local rpmanager_status
    local error_msg

    while true; do
        if [[ -f "$md_inst/rpmanager.sh" ]]; then
            rpmanager_status="$($md_inst/rpmanager.sh --isrunning)\n\n"
        fi
        if _is_enabled_retropie-manager; then
            rpmanager_status+="RetroPie-Manager is currently enabled on boot"
        else
            rpmanager_status+="RetroPie-Manager is currently disabled on boot"
        fi
        cmd=(dialog --backtitle "$__backtitle" --menu "$rpmanager_status\n\nChoose an option." 22 86 16)
        choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            case "$choice" in
                1)
                    dialog --infobox "Starting RetroPie-Manager" 4 30 2>&1 >/dev/tty
                    error_msg="$("$md_inst/rpmanager.sh" --start 2>&1 >/dev/null)" \
                    || printMsgs "dialog" "$error_msg"
                    ;;

                2)
                    dialog --infobox "Stopping RetroPie-Manager" 4 30 2>&1 >/dev/tty
                    error_msg="$("$md_inst/rpmanager.sh" --stop 2>&1 >/dev/null)" \
                    || printMsgs "dialog" "$error_msg"
                    ;;

                3)  enable_retropie-manager
                    ;;

                4)  disable_retropie-manager
                    ;;
            esac
        else
            break
        fi
    done
}
