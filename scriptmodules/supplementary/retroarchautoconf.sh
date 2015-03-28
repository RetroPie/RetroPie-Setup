#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
#

rp_module_id="retroarchautoconf"
rp_module_desc="RetroArch-AutoConfigs"
rp_module_menus="2+"
rp_module_flags="nobin"

function sources_retroarchautoconf() {
    gitPullOrClone "$md_build" https://github.com/libretro/retroarch-joypad-autoconfig
}

function install_retroarchautoconf() {
    mkdir -p "$emudir/retroarch/configs/"
    # strip CR's from the files
    cd "$md_build/udev/"
    for file in *; do
        tr -d '\015' <"$file" >"$emudir/retroarch/configs/$file"
        chown $user:$user "$emudir/retroarch/configs/$file"
    done
}

function remap_hotkeys_retroarchautoconf() {
    local file="$1"
    local ini_value

    [[ -z "$file" || ! -f "$file" ]] && return 1

    iniConfig " = " "\""
    local mappings=(
        'input_enable_hotkey input_select'
        'input_exit_emulator input_start'
        'input_menu_toggle input_x'
        'input_load_state input_l'
        'input_save_state input_r'
        'input_reset input_b'
        'input_state_slot_increase input_right'
        'input_state_slot_decrease input_left'
    )

    printMsgs "console" "Processing $file"

    for mapping in "${mappings[@]}"; do
        mapping=($mapping)
        for suffix in axis btn; do
            iniGet "${mapping[1]}_${suffix}" "$file"
            if [[ -n "$ini_value" ]]; then
                iniSet "${mapping[0]}_${suffix}" "$ini_value" "$file" >/dev/null
            fi
        done
    done
}

function configure_retroarchautoconf() {
    printMsgs "console" "Remapping controller hotkeys"

    for file in "$emudir/retroarch/configs/"*; do
        remap_hotkeys_retroarchautoconf "$file"
    done
}
