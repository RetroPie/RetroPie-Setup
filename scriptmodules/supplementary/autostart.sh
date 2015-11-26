#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="autostart"
rp_module_desc="Auto-start EmulationStation"
rp_module_menus="3+"
rp_module_flags="nobin"

function enable_autostart() {
    if [[ "$__raspbian_ver" -lt "8" ]]; then
        sed -i "s|^1:2345:.*|1:2345:respawn:/bin/login -f $user tty1 </dev/tty1 >/dev/tty1 2>\&1|g" /etc/inittab
        update-rc.d lightdm disable 2 # taken from /usr/bin/raspi-config
        sed -i "/emulationstation/d" /etc/profile
    else
        mkdir -p /etc/systemd/system/getty@tty1.service.d/
        cat >/etc/systemd/system/getty@tty1.service.d/autologin.conf <<_EOF_
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin $user --noclear %I 38400 linux
_EOF_
    fi
    cat >/etc/profile.d/10-emulationstation.sh <<_EOF_
# launch emulationstation (if we are on the correct tty)
[ "\`tty\`" = "/dev/tty1" ] && emulationstation
_EOF_
}

function disable_autostart() {
    if [[ "$__raspbian_ver" -lt "8" ]]; then
        sed -i "s|^1:2345:.*|1:2345:respawn:/sbin/getty --noclear 38400 tty1|g" /etc/inittab
        sed -i "/emulationstation/d" /etc/profile
    else
        rm -f /etc/systemd/system/getty@tty1.service.d/autologin.conf
    fi
    rm -f /etc/profile.d/10-emulationstation.sh
}

function configure_autostart() {
    cmd=(dialog --backtitle "$__backtitle" --menu "Choose the desired boot behaviour." 22 76 16)
    options=(
        1 "Original boot behaviour"
        2 "Start Emulation Station at boot."
    )
    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choices" ]]; then
        case $choices in
            1)
                disable_autostart
                printMsgs "dialog" "Enabled original boot behaviour. ATTENTION: If you still have the custom splash screen enabled (via this script), you need to jump between consoles after booting via Ctrl+Alt+F2 and Ctrl+Alt+F1 to see the login prompt. You can restore the original boot behavior of the RPi by disabling the custom splash screen with this script."
                ;;
            2)
                enable_autostart
                printMsgs "dialog" "Emulation Station is now starting on boot."
                ;;
        esac
    fi
}
