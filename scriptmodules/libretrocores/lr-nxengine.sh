#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-nxengine"
rp_module_desc="Cave Story engine clone - NxEngine port for libretro"
rp_module_menus="2+"

function sources_lr-nxengine() {
    gitPullOrClone "$md_build" https://github.com/libretro/nxengine-libretro.git
}

function build_lr-nxengine() {
    make clean
    make
    md_ret_require="$md_build/nxengine_libretro.so"
}

function install_lr-nxengine() {
    md_ret_files=(
        'nxengine_libretro.so'
    )
}

function configure_lr-nxengine() {
    setConfigRoot "ports"

    addPort "$md_id" "cavestory" "Cave Story" "$emudir/retroarch/bin/retroarch -L $md_inst/nxengine_libretro.so --config $md_conf_root/cavestory/retroarch.cfg $romdir/ports/CaveStory/Doukutsu.exe" << _EOF_
#!/bin/bash
if [[ ! -f "$romdir/ports/CaveStory/Doukutsu.exe" ]]; then
    dialog --msgbox "$msg" 22 76
else
    "$rootdir/supplementary/runcommand/runcommand.sh" 0 _PORT_ cavestory
fi
_EOF_

    ensureSystemretroconfig "ports/cavestory"

    local msg="You need the original Cave Story game files to use $md_id. Please unpack the game to $romdir/ports/CaveStory so you have the file $romdir/ports/CaveStory/Doukutsu.exe present."

    __INFMSGS+=("$msg")

    # remove old install folder
    rm -rf "$rootdir/$md_type/cavestory"
}
