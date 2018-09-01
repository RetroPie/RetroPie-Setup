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

function _update_hook_autostart() {
    if [[ -f /etc/profile.d/10-emulationstation.sh ]]; then
        enable_autostart
    fi
}

function _autostart_script_autostart() {
    local mode="$1"
    # delete old startup script
    rm -f /etc/profile.d/10-emulationstation.sh

    local script="$configdir/all/autostart.sh"

    cat >/etc/profile.d/10-retropie.sh <<_EOF_
# launch our autostart apps (if we are on the correct tty)
if [ "\`tty\`" = "/dev/tty1" ] && [ "\$USER" = "$user" ]; then
    bash "$script"
fi
_EOF_

    touch "$script"
    # delete any previous entries for emulationstation / kodi in autostart.sh
    sed -i '/#auto/d' "$script"
    # make sure there is a newline
    sed -i '$a\' "$script"
    case "$mode" in
        kodi)
            echo -e "kodi #auto\nemulationstation #auto" >>"$script"
            ;;
        es|*)
            echo "#!/bin/sh

while pgrep fbi &>/dev/null;
do sleep 1;
done
while pgrep mplayer &>/dev/null;
do sleep 1;
done
while pgrep vlc >/dev/null; do sleep 1; done
if [ -a /home/pigaming/scripts/bgm/start.sc ];  then
(mpg123 -f 18000 -Z /home/pi/bgm/*.mp3 >/dev/null 2>&1) &
fi
emulationstation #auto" >>"$script"
            ;;
    esac
    chown $user:$user "$script"
}

function enable_autostart() {
    local mode="$1"

    if isPlatform "x11"; then
        mkUserDir "$home/.config/autostart"
        ln -sf "/usr/local/share/applications/retropie.desktop" "$home/.config/autostart/"
    else
        if [[ "$__os_id" == "Raspbian" ]]; then
            if [[ "$__chroot" -eq 1 ]]; then
                mkdir -p /etc/systemd/system/getty@tty1.service.d
                systemctl set-default multi-user.target
                ln -fs /etc/systemd/system/autologin@.service /etc/systemd/system/getty.target.wants/getty@tty1.service
            else
                # remove any old autologin.conf - we use raspi-config now
                rm -f /etc/systemd/system/getty@tty1.service.d/autologin.conf
                raspi-config nonint do_boot_behaviour B2
            fi
        elif [[ "$(cat /proc/1/comm)" == "systemd" ]]; then
            mkdir -p /etc/systemd/system/getty@tty1.service.d/
            cat >/etc/systemd/system/getty@tty1.service.d/autologin.conf <<_EOF_
[Service]
ExecStart=
ExecStart=-/sbin/agetty --skip-login --noclear --noissue --login-options "-f pigaming" %I $TERM
_EOF_
        fi

        _autostart_script_autostart "$mode"
    fi
}

function disable_autostart() {
    local login_type="$1"
    [[ -z "$login_type" ]] && login_type="B2"
    if isPlatform "x11"; then
        rm "$home/.config/autostart/retropie.desktop"
    else
        if [[ "$__os_id" == "Raspbian" ]]; then
            if [[ "$__chroot" -eq 1 ]]; then
                systemctl set-default graphical.target
                ln -fs /lib/systemd/system/getty@.service /etc/systemd/system/getty.target.wants/getty@tty1.service
            else
                raspi-config nonint do_boot_behaviour "$login_type"
            fi
        elif [[ "$(cat /proc/1/comm)" == "systemd" ]]; then
            rm -f /etc/systemd/system/getty@tty1.service.d/autologin.conf
            systemctl set-default graphical.target
            systemctl enable lightdm.service
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
                E "Manually edit $configdir/autostart.sh"
            )
            if [[ "$__os_id" == "Raspbian" ]]; then
                options+=(
                    CL "Boot to text console (require login)"
                    CA "Boot to text console (auto login as $user)"
                )
            fi
            options+=(DL "Boot to desktop (require login)")
            if [[ "$__os_id" == "Raspbian" ]]; then
                options+=(DA "Boot to desktop (auto login as $user)")
            fi
        fi
        choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            case "$choice" in
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
                        enable_autostart
                        printMsgs "dialog" "Emulation Station is set to launch at boot."
                    fi
                    ;;
                2)
                    enable_autostart kodi
                    printMsgs "dialog" "Kodi is set to launch at boot."
                    ;;
                E)
                    editFile "$configdir/all/autostart.sh"
                    ;;
                CL)
                    disable_autostart B1
                    printMsgs "dialog" "Booting to text console (require login)."
                    ;;
                CA)
                    disable_autostart B2
                    printMsgs "dialog" "Booting to text console (auto login as $user)."
                    ;;
                DL)
                    disable_autostart B3
                    printMsgs "dialog" "Booting to desktop (require login)."
                    ;;
                DA)
                    disable_autostart B4
                    printMsgs "dialog" "Booting to desktop (auto login as $user)."
                    ;;
            esac
        else
            break
        fi
    done
}
