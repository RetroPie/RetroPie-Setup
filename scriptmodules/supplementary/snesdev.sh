#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="snesdev"
rp_module_desc="SNESDev (Driver for the RetroPie GPIO-Adapter)"
rp_module_section="driver"
rp_module_repo="git https://github.com/MonsterJoysticks/SNESDev-RPi-Wiring-Pi.git master"
rp_module_flags="noinstclean !all rpi"

# install the latest version of WiringPi
function _wiringpi_snesdev() {
    pushd "$md_build"
    gitPullOrClone wiringpi https://github.com/WiringPi/WiringPi.git
    cd wiringpi
    applyPatch "$md_data/001-wiringpi-static.diff"
    make -C wiringPi libwiringPi.a
    popd
}

function depends_snesdev() {
    getDepends libconfuse-dev
}

function sources_snesdev() {
    gitPullOrClone
}

function build_snesdev() {
    local wiringpi_version
    wiringpi_version="$(dpkg-query -f='${Version} ${Status}' -W wiringpi 2>/dev/null | grep installed | cut -f1 -d' ')"

    CFLAGS+=" -Wno-incompatible-pointer-types"
    if [[ -z "$wiringpi_version" ]] || compareVersions "$wiringpi_version" lt 3.14; then
        # when there's no WiringPi installed or there's an old version, build a static version and use it
        printMsgs console "Using locally built WiringPi library"
        _wiringpi_snesdev
        make LDFLAGS=" -L"$md_build/wiringpi/wiringPi"" CFLAGS="$CFLAGS -I"$md_build/wiringpi/wiringPi""
    else
        make
    fi
    md_ret_require="$md_build/src/SNESDev"
}

function install_snesdev() {
    md_ret_files=(
        "src/SNESDev"
        "README.md"
        "supplementary/snesdev.cfg"
    )
}

function configure_snesdev() {
    if [[ "$md_mode" == "install" ]]; then
        install -m 0755 "$md_inst/snesdev.cfg" "/etc/snesdev.cfg"
        # remove old drivers and service
        [[ -f "/usr/local/bin/SNESDev" ]] && rm -f "/usr/local/bin/SNESDev"
        update-rc.d SNESDev remove
        rm -f /etc/init.d/SNESDev
    fi
}

function _systemd_install_snesdev() {
cat > /etc/systemd/system/snesdev.service << _EOF_
[Unit]
Description=Userspace SNES GPIO Driver

[Service]
ExecStart=$md_inst/SNESDev

[Install]
WantedBy=multi-user.target
_EOF_

    systemctl daemon-reload
    systemctl -q enable snesdev.service
}

function _systemd_uninstall_snesdev() {
    if systemctl -q is-enabled snesdev.service 2>/dev/null; then
        systemctl stop snesdev.service
        systemctl -q disable snesdev.service
    fi
    [[ -f "/etc/systemd/system/snesdev.service" ]] && rm "/etc/systemd/system/snesdev.service"
}
# start SNESDev on boot and configure RetroArch input settings
function enable_at_start_snesdev() {
    local mode="$1"
    iniConfig "=" "" "/etc/snesdev.cfg"
    clear
    printHeading "Enabling SNESDev on boot."

    case "$mode" in
        1)
            iniSet "button_enabled" "0"
            iniSet "gamepad1_enabled" "1"
            iniSet "gamepad2_enabled" "1"
            _systemd_install_snesdev
            ;;
        2)
            iniSet "button_enabled" "1"
            iniSet "gamepad1_enabled" "0"
            iniSet "gamepad2_enabled" "0"
            _systemd_install_snesdev
            ;;
        3)
            iniSet "button_enabled" "1"
            iniSet "gamepad1_enabled" "1"
            iniSet "gamepad2_enabled" "1"
            _systemd_install_snesdev
            ;;
        *)
            echo "[enable_at_start_snesdev] I do not understand what is going on here."
            ;;
    esac

}

function set_adapter_version_snesdev() {
    local ver="$1"
    iniConfig "=" "" "/etc/snesdev.cfg"
    if [[ "$ver" -eq 1 ]]; then
        iniSet "adapter_version" "1x"
    else
        iniSet "adapter_version" "2x"
    fi
}

function remove_snesdev() {
    _systemd_uninstall_snesdev
    # remove old versions if found
    [[ -f "/usr/local/bin/SNESDev" ]] && rm -f "/usr/local/bin/SNESDev"
}

function gui_snesdev() {
    local cmd=(dialog --backtitle "$__backtitle" --menu "Choose an option." 22 86 16)
    local options=(
        1 "Enable SNESDev on boot and SNESDev keyboard mapping (polling pads and button)"
        2 "Enable SNESDev on boot and SNESDev keyboard mapping (polling only pads)"
        3 "Enable SNESDev on boot and SNESDev keyboard mapping (polling only button)"
        4 "Switch to adapter version 1.X"
        5 "Switch to adapter version 2.X"
        D "Disable SNESDev on boot and SNESDev keyboard mapping"
    )
    local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choice" ]]; then
        case "$choice" in
            1)
                enable_at_start_snesdev 3
                printMsgs "dialog" "Enabled SNESDev on boot (polling pads and button)."
                ;;
            2)
                enable_at_start_snesdev 1
                printMsgs "dialog" "Enabled SNESDev on boot (polling only pads)."
                ;;
            3)
                enable_at_start_snesdev 2
                printMsgs "dialog" "Enabled SNESDev on boot (polling only button)."
                ;;
            4)
                set_adapter_version_snesdev 1
                printMsgs "dialog" "Switched to adapter version 1.X."
                ;;
            5)
                set_adapter_version_snesdev 2
                printMsgs "dialog" "Switched to adapter version 2.X."
                ;;
            D)
                _systemd_uninstall_snesdev
                printMsgs "dialog" "Disabled SNESDev on boot."
                ;;
        esac
    fi
}
