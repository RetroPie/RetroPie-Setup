#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
#

rp_module_id="hotkey"
rp_module_desc="Change hotkey behaviour"
rp_module_menus="3+"
rp_module_flags="nobin"

function configure_hotkey() {
    iniConfig " = " "" "$configdir/all/retroarch.cfg"
    cmd=(dialog --backtitle "$__backtitle" --menu "Choose the desired hotkey behaviour." 22 76 16)
    options=(1 "Hotkeys enabled. (default)"
             2 "Press ALT to enable hotkeys."
             3 "Hotkeys disabled. Press ESCAPE to open RGUI.")
    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choices" ]]; then
        case $choices in
            1) iniSet "input_enable_hotkey" "nul"
               iniSet "input_exit_emulator" "escape"
               iniSet "input_menu_toggle" "F1"
                            ;;
            2) iniSet "input_enable_hotkey" "alt"
               iniSet "input_exit_emulator" "escape"
               iniSet "input_menu_toggle" "F1"
                            ;;
            3) iniSet "input_enable_hotkey" "escape"
               iniSet "input_exit_emulator" "nul"
               iniSet "input_menu_toggle" "escape"
                            ;;
        esac
    fi
}
