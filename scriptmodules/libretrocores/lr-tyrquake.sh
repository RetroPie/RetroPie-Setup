#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
#

rp_module_id="lr-tyrquake"
rp_module_desc="Quake 1 engine - Tyrquake port for libretro"
rp_module_menus="2+"

function depends_lr-tyrquake() {
    getDepends lhasa
}

function sources_lr-tyrquake() {
    gitPullOrClone "$md_build" git://github.com/libretro/tyrquake.git
}

function build_lr-tyrquake() {
    make clean
    make 
    md_ret_require="$md_build/tyrquake_libretro.so"
}

function install_lr-tyrquake() {
    md_ret_files=(
        'gnu.txt'
        'readme-id.txt'
        'readme.txt'
        'tyrquake_libretro.so'
    )
}

function configure_lr-tyrquake() {
    # remove old install folder
    rm -rf "$rootdir/$md_type/tyrquake"

    mkRomDir "ports/quake"
    ensureSystemretroconfig "quake"

    if [[ ! -f "$romdir/ports/quake/id1/pak0.pak" ]]; then
        # download / unpack / install quake shareware files
        wget "http://downloads.petrockblock.com/retropiearchives/quake106.zip" -O quake106.zip
        unzip -o quake106.zip -d "quake106"
        rm quake106.zip
        pushd quake106
        lhasa ef resource.1
        cp -rf id1 "$romdir/ports/quake/"
        popd
        rm -rf quake106
        chown -R $user:$user "$romdir/ports/quake"
    fi

    ensureSystemretroconfig "quake"

    # Create startup script
    cat > "$romdir/ports/Quake.sh" << _EOF_
#!/bin/bash
$rootdir/supplementary/runcommand/runcommand.sh 0 "$emudir/retroarch/bin/retroarch -L $md_inst/tyrquake_libretro.so --config $configdir/all/retroarch.cfg $romdir/ports/quake/id1/pak0.pak" "$md_id"
_EOF_

    chmod +x "$romdir/ports/Quake.sh"

    setESSystem 'Ports' 'ports' '~/RetroPie/roms/ports' '.sh .SH' '%ROM%' 'pc' 'ports'
}
