#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
#

rp_module_id="audiosettings"
rp_module_desc="Configure audio settings"
rp_module_menus="3+"
rp_module_flags="nobin"

function configure_audiosettings() {
    cmd=(dialog --backtitle "$__backtitle" --menu "Set audio output." 22 86 16)
    options=(
        1 "Auto"
        2 "Headphones - 3.5mm jack"
        3 "HDMI"
        4 "Mixer - adjust output volume"
        R "Reset to default"
    )
    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choices" ]]; then
        case $choices in
            1)
                amixer cset numid=3 0
                alsactl store
                printMsgs "dialog" "Set audio output to auto"
                ;;
            2)
                amixer cset numid=3 1
                alsactl store
                printMsgs "dialog" "Set audio output to headphones / 3.5mm jack"
                ;;
            3)
                amixer cset numid=3 2
                alsactl store
                printMsgs "dialog" "Set audio output to HDMI"
                ;;
            4)
                alsamixer >/dev/tty </dev/tty
                alsactl store
                ;;
            R)
                /etc/init.d/alsa-utils reset
                alsactl store
                printMsgs "dialog" "Audio settings reset to defaults"
                ;;
        esac
    fi
}
