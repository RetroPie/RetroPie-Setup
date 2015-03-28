#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
#

rp_module_id="lr-nxengine"
rp_module_desc="Cave Story engine clone - NxEngine port for libretro"
rp_module_menus="2+"

function sources_lr-nxengine() {
    gitPullOrClone "$md_build" git://github.com/libretro/nxengine-libretro.git
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
    # remove old install folder
    rm -rf "$rootdir/$md_type/cavestory"

    mkRomDir "ports"
    ensureSystemretroconfig "cavestory"

    local msg="You need the original Cave Story game files to use $md_id. Please unpack the game to $romdir/ports/CaveStory so you have the file $romdir/ports/CaveStory/Doukutsu.exe present."

    cat > "$romdir/ports/Cave Story.sh" << _EOF_
#!/bin/bash
if [[ -f "$romdir/ports/CaveStory/Doukutsu.exe" ]]; then
    $rootdir/supplementary/runcommand/runcommand.sh 0 "$emudir/retroarch/bin/retroarch -L $md_inst/nxengine_libretro.so --config $configdir/cavestory/retroarch.cfg $romdir/ports/CaveStory/Doukutsu.exe" "$md_id"
else
    dialog --msgbox "$msg" 22 76
fi
_EOF_
    chmod +x "$romdir/ports/Cave Story.sh"

    setESSystem 'Ports' 'ports' '~/RetroPie/roms/ports' '.sh .SH' '%ROM%' 'pc' 'ports'

    __INFMSGS+=("$msg")
}
