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
rp_module_help="Dinothawr game assets are automatically installed to $romdir/ports/dinothawr/"
rp_module_section="exp"

function sources_lr-dinothawr() {
    gitPullOrClone "$md_build" https://github.com/libretro/Dinothawr.git
}

function build_lr-dinothawr() {
    make clean
    # we need -U__GCC_HAVE_SYNC_COMPARE_AND_SWAP_2 on armv7/armv8 due to armv6 userland on Raspbian
    # as with PPSSPP https://github.com/hrydgard/ppsspp/pull/8117
    if isPlatform "arm" && ! isPlatform "armv6"; then
        CXXFLAGS+=" -U__GCC_HAVE_SYNC_COMPARE_AND_SWAP_2" make
    else
        make
    fi
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

    addPort "$md_id" "dinothawr" "Dinothawr" "$emudir/retroarch/bin/retroarch -L $md_inst/dinothawr_libretro.so --config $md_conf_root/dinothawr/retroarch.cfg $romdir/ports/dinothawr/dinothawr.game"

    mkRomDir "ports/dinothawr"
    ensureSystemretroconfig "ports/dinothawr"

    cp -Rv "$md_inst/dinothawr" "$romdir/ports"

    chown $user:$user -R "$romdir/ports/dinothawr"
}
