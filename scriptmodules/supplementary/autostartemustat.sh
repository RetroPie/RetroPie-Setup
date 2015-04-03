#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
#

rp_module_id="autostartemustat"
rp_module_desc="Auto-start EmulationStation"
rp_module_menus="3+"
rp_module_flags="nobin"

function configure_autostartemustat() {
    cmd=(dialog --backtitle "$__backtitle" --menu "Choose the desired boot behaviour." 22 76 16)
    options=(
        1 "Original boot behaviour"
        2 "Start Emulation Station at boot."
    )
    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choices" ]]; then
        case $choices in
            1)
                sed /etc/inittab -i -e "s|1:2345:respawn:/bin/login -f $user tty1 </dev/tty1 >/dev/tty1 2>&1|1:2345:respawn:/sbin/getty --noclear 38400 tty1|g"
                sed /etc/profile -i -e "/emulationstation/d"
                rm -f /etc/profile.d/10-emulationstation.sh
                printMsgs "dialog" "Enabled original boot behaviour. ATTENTION: If you still have the custom splash screen enabled (via this script), you need to jump between consoles after booting via Ctrl+Alt+F2 and Ctrl+Alt+F1 to see the login prompt. You can restore the original boot behavior of the RPi by disabling the custom splash screen with this script."
                ;;
            2)
                sed /etc/inittab -i -e "s|1:2345:respawn:/sbin/getty --noclear 38400 tty1|1:2345:respawn:\/bin\/login -f $user tty1 \<\/dev\/tty1 \>\/dev\/tty1 2\>\&1|g"
                update-rc.d lightdm disable 2 # taken from /usr/bin/raspi-config
                sed -i "/emulationstation/d" /etc/profile
                echo '[ "`tty`" = "/dev/tty1" ] && emulationstation' >/etc/profile.d/10-emulationstation.sh
                printMsgs "dialog" "Emulation Station is now starting on boot."
                ;;
        esac
    fi
}
