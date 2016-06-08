#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-dinothawr"
rp_module_desc="Dinothawr - standalone libretro puzzle game"
rp_module_section="exp"

function sources_lr-dinothawr() {
    gitPullOrClone "$md_build" https://github.com/libretro/Dinothawr.git
}

function build_lr-dinothawr() {
    make clean
    make
    md_ret_require="$md_build/dinothawr_libretro.so"
}

function install_lr-dinothawr() {
    md_ret_files=(
        'dinothawr_libretro.so'
        'dinothawr'
    )
}


function configure_lr-dinothawr() {
    setConfigRoot "ports"

    addPort "$md_id" "dinothawr" "Dinothawr" "$emudir/retroarch/bin/retroarch -L $md_inst/dinothawr_libretro.so --config $md_conf_root/dinothawr/retroarch.cfg $romdir/ports/dinothawr/dinothawr/dinothawr.game"

    mkRomDir "ports/dinothawr"
    ensureSystemretroconfig "ports/dinothawr"

    cp -R "$md_inst/dinothawr/" "$romdir/ports/dinothawr/"

    chown $user:$user -R "$romdir/ports/dinothawr/"

}


