#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-mess"
rp_module_desc="MESS emulator - MESS Port for libretro"
rp_module_help="see wiki for detailed explanation"
rp_module_section="exp"

function sources_lr-mess() {
    gitPullOrClone "$md_build" https://github.com/libretro/MAME.git
}

function build_lr-mess() {
    make -f Makefile.libretro clean
    make -f Makefile.libretro SUBTARGET=mess
    md_ret_require="$md_build/mess_libretro.so"
}

function install_lr-mess() {
    md_ret_files=(
        'mess_libretro.so'
    )
}

function configure_lr-mess() {
    mkRomDir "nes"
    mkRomDir "gameboy"
    mkRomDir "coleco"
    mkRomDir "arcadia"
    mkRomDir "crvision"
    ensureSystemretroconfig "nes"
    ensureSystemretroconfig "gameboy"
    ensureSystemretroconfig "coleco"
    ensureSystemretroconfig "arcadia"
    ensureSystemretroconfig "crvision"

    setRetroArchCoreOption "mame_softlists_enable" "enabled"
    setRetroArchCoreOption "mame_softlists_auto_media" "enabled"
    setRetroArchCoreOption "mame_boot_from_cli" "enabled"

    mkdir "$biosdir/mame"
    cp -rv "$md_build/hash" "$biosdir/mame/"
    chown -R $user:$user "$biosdir/mame"
    addSystem 0 "$md_id" "nes" "$md_inst/mess_libretro.so"
    addSystem 0 "$md_id" "gameboy" "$md_inst/mess_libretro.so"
    addSystem 0 "$md_id" "coleco" "$md_inst/mess_libretro.so"
    addSystem 0 "$md_id" "arcadia" "$md_inst/mess_libretro.so"
    addSystem 0 "$md_id" "crvision" "$md_inst/mess_libretro.so"
}
