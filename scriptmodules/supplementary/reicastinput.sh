#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="reicastinput"
rp_module_desc="Configure input devices for Reicast"
rp_module_section="config"

function configure_reicastinput() {
    clear
    local temp_file="/tmp/temp.cfg"
    cd /opt/retropie/emulators/reicast/bin/
    ./reicast-joyconfig -f "$temp_file" > /dev/tty
    iniConfig " = " "" "$temp_file"
    iniGet "mapping_name"
    local mapping_file="$configdir/dreamcast/mappings/controller_${ini_value// /}.cfg"
    mv "$temp_file" "$mapping_file"
    chown $user:$user "$mapping_file"
}
