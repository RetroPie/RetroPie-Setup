#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
#

rp_module_id="snesdev"
rp_module_desc="SNESDev (Driver for the RetroPie GPIO-Adapter)"
rp_module_menus="3+configure"

function sources_snesdev() {
    gitPullOrClone "$md_build" git://github.com/petrockblog/SNESDev-RPi.git
}

function build_snesdev() {
    make clean
    make
    md_ret_require="$md_build/src/SNESDev"
}

function install_snesdev() {
    # if we have built it, copy files to install location
    if [[ -d "$md_build" ]]; then
        mkdir -p "$md_inst/"{src,supplementary,scripts}
        cp -v 'src/SNESDev' "$md_inst/src/"
        cp -v 'src/Makefile' "$md_inst/src/"
        cp -v 'Makefile' "$md_inst"
        cp -v 'scripts/Makefile' "$md_inst/scripts/"
        cp -v 'scripts/SNESDev' "$md_inst/scripts/"
        cp -v 'supplementary/snesdev.cfg' "$md_inst/supplementary/"
    fi
    # then install from there to system folders
    pushd "$md_inst"
    make install
    popd
}

function install_bin_snesdev() {
    rp_callModule snesdev install
}

function sup_checkInstallSNESDev() {
    if [[ ! -d "$md_inst" ]]; then
        sources_snesdev
        build_snesdev
        install_snesdev
    fi
}

# start SNESDev on boot and configure RetroArch input settings
function sup_enableSNESDevAtStart() {
    iniConfig "=" "" "/etc/snesdev.cfg"
    clear
    printHeading "Enabling SNESDev on boot."

    case $1 in
        1)
            iniSet "button_enabled" "0" 
            iniSet "gamepad1_enabled" "1"
            iniSet "gamepad2_enabled" "1"
            ;;
        2)
            iniSet "button_enabled" "1"
            iniSet "gamepad1_enabled" "0"
            iniSet "gamepad2_enabled" "0"
            ;;
        3)
            iniSet "button_enabled" "1"
            iniSet "gamepad1_enabled" "1"
            iniSet "gamepad2_enabled" "1"
            ;;
        *)
            echo "[sup_enableSNESDevAtStart] I do not understand what is going on here."
            ;;
    esac

}

function sup_snesdevAdapterversion() {
    iniConfig "=" "" "/etc/snesdev.cfg"
    if [[ $1 -eq 1 ]]; then
        iniSet "adapter_version" "1x"
    elif [[ $1 -eq 2 ]]; then
        iniSet "adapter_version" "2x"
    else
        iniSet "adapter_version" "2x"
    fi
}

function configure_snesdev() {
    cmd=(dialog --backtitle "$__backtitle" --menu "Choose the desired boot behaviour." 22 86 16)
    options=(
        1 "Disable SNESDev on boot and SNESDev keyboard mapping."
        2 "Enable SNESDev on boot and SNESDev keyboard mapping (polling pads and button)."
        3 "Enable SNESDev on boot and SNESDev keyboard mapping (polling only pads)."
        4 "Enable SNESDev on boot and SNESDev keyboard mapping (polling only button)."
        5 "Switch to adapter version 1.X."
        6 "Switch to adapter version 2.X."
    )
    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choices" ]]; then
        case $choices in
            1)
                sup_checkInstallSNESDev
                make uninstallservice
                printMsgs "dialog" "Disabled SNESDev on boot."
                ;;
            2)
                sup_checkInstallSNESDev
                sup_enableSNESDevAtStart 3
                make installservice
                printMsgs "dialog" "Enabled SNESDev on boot (polling pads and button)."
                ;;
            3)
                sup_checkInstallSNESDev
                sup_enableSNESDevAtStart 1
                make installservice
                printMsgs "dialog" "Enabled SNESDev on boot (polling only pads)."
                ;;
            4)
                sup_checkInstallSNESDev
                sup_enableSNESDevAtStart 2
                make installservice
                printMsgs "dialog" "Enabled SNESDev on boot (polling only button)."
                ;;
            5)
                sup_snesdevAdapterversion 1
                printMsgs "dialog" "Switched to adapter version 1.X."
                ;;
            6)
                sup_snesdevAdapterversion 2
                printMsgs "dialog" "Switched to adapter version 2.X."
                ;;
        esac
    else
        break
    fi
}
