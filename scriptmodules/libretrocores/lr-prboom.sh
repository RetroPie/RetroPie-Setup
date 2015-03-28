#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
#

rp_module_id="lr-prboom"
rp_module_desc="Doom/Doom II engine - PrBoom port for libretro"
rp_module_menus="2+"

function sources_lr-prboom() {
    gitPullOrClone "$md_build" git://github.com/libretro/libretro-prboom.git
}

function build_lr-prboom() {
    make clean
    make
    md_ret_require="$md_build/prboom_libretro.so"
}

function install_lr-prboom() {
    md_ret_files=(
        'prboom_libretro.so'
        'prboom.wad'
    )
}

function configure_lr-prboom() {
    # remove old install folder
    rm -rf "$rootdir/$md_type/doom"

    mkRomDir "ports/doom"
    ensureSystemretroconfig "doom"

    cp prboom.wad "$romdir/ports/doom/"

    # download doom 1 shareware
    wget "http://downloads.petrockblock.com/retropiearchives/doom1.wad" -O "$romdir/ports/doom/doom1.wad"

    chown $user:$user "$romdir/ports/doom/"*

    cat > "$romdir/ports/Doom 1 Shareware.sh" << _EOF_
#!/bin/bash
$rootdir/supplementary/runcommand/runcommand.sh 0 "$emudir/retroarch/bin/retroarch -L $md_inst/prboom_libretro.so --config $configdir/doom/retroarch.cfg $romdir/ports/doom/doom1.wad" "$md_id"
_EOF_
    chmod +x "$romdir/ports/Doom 1 Shareware.sh"

    setESSystem 'Ports' 'ports' '~/RetroPie/roms/ports' '.sh .SH' '%ROM%' 'pc' 'ports'    
}
