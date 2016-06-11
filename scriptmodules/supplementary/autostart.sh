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
rp_module_desc="Auto-start Emulation Station / Kodi on boot"
rp_module_section="config"

function enable_autostart() {
    local mode="$1"
    if isPlatform x11; then
        mkUserDir "$home/.config/autostart"
        ln -sf "/usr/local/share/applications/retropie.desktop" "$home/.config/autostart/"
    else
        if [[ "$__raspbian_ver" -lt "8" ]]; then
            sed -i "s|^1:2345:.*|1:2345:respawn:/bin/login -f $user tty1 </dev/tty1 >/dev/tty1 2>\&1|g" /etc/inittab
            update-rc.d lightdm disable 2 # taken from /usr/bin/raspi-config
            sed -i "/emulationstation/d" /etc/profile
        else
            raspi-config nonint do_boot_behaviour B2
        fi

        # delete old startup script
        rm -f /etc/profile.d/10-emulationstation.sh

        local script="$configdir/all/autostart.sh"

        cat >/etc/profile.d/10-retropie.sh <<_EOF_
# launch our autostart apps (if we are on the correct tty)
if [ "\`tty\`" = "/dev/tty1" ]; then
    bash "$script"
fi
_EOF_

        touch "$script"
        # delete any previous entries for emulationstation / kodi in autostart.sh
        sed -i '/#auto/d' "$script"
        # make sure there is a newline
        sed -i -e '$a\' "$script"
        case "$mode" in
            es)
                echo >> "emulationstation #auto" >>"$script"
                ;;
            kodi)
                echo -e "kodi #auto\nemulationstation #auto" >>"$script"
                ;;
        esac
        chown $user:$user "$script"
    fi
}

function disable_autostart() {
    local login_type="$1"
    [[ -z "$login_type" ]] && login_type="B2"
    if isPlatform "x11"; then
        rm "$home/.config/autostart/retropie.desktop"
    else
        if [[ "$__raspbian_ver" -lt "8" ]]; then
            sed -i "s|^1:2345:.*|1:2345:respawn:/sbin/getty --noclear 38400 tty1|g" /etc/inittab
            sed -i "/emulationstation/d" /etc/profile
        else
            # remove any old autologin.conf - we use raspi-config now
            rm -f /etc/systemd/system/getty@tty1.service.d/autologin.conf
            raspi-config nonint do_boot_behaviour "$login_type"
        fi
        rm -f /etc/profile.d/10-emulationstation.sh
        rm -f /etc/profile.d/10-retropie.sh
    fi
}

function remove_autostart() {
    disable_autostart
}

function gui_autostart() {
    cmd=(dialog --backtitle "$__backtitle" --menu "Choose the desired boot behaviour." 22 76 16)
    while true; do
        if isPlatform "x11"; then
            local x11_autostart
            if [[ -f "$home/.config/autostart/retropie.desktop" ]]; then
                options=(1 "Autostart Emulation Station after login (Enabled)")
                x11_autostart=1
            else
                options=(1 "Autostart Emulation Station after login (Disabled)")
                x11_autostart=0
            fi
        else
            options=(
                1 "Start Emulation Station at boot"
                2 "Start Kodi at boot (exit for Emulation Station)"
                C "Boot to text console (auto login)"
            )
            if [[ "$__raspbian_ver" -gt "7" ]]; then
                options+=(D "Boot to desktop (auto login)")
            fi
        fi
        choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choices" ]]; then
            case $choices in
                1)
                    if isPlatform "x11"; then
                        if [[ "$x11_autostart" -eq 0 ]]; then
                            enable_autostart
                            printMsgs "dialog" "Emulation Station is set to autostart after login."
                        else
                            disable_autostart
                            printMsgs "dialog" "Autostarting of Emulation Station is disabled."
                        fi
                        x11_autostart=$((x11_autostart ^ 1))
                    else
                        enable_autostart es
                        printMsgs "dialog" "Emulation Station is set to launch at boot."
                    fi
                    ;;
                2)
                    enable_autostart kodi
                    printMsgs "dialog" "Kodi is set to launch at boot."
                    ;;
                C)
                    disable_autostart
                    printMsgs "dialog" "Booting to text console."
                    ;;
                D)
                    disable_autostart B4
                    printMsgs "dialog" "Booting to desktop."
                    ;;
            esac
        else
            break
        fi
    done
}
