#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-dosbox-pure"
rp_module_desc="DOS emulator"
rp_module_help="ROM Extensions: .bat .com .cue .dosz .exe .ins .ima .img .iso .m3u .m3u8 .vhd .zip\n\nCopy your DOS games to $ROMDIR/pc"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/dosbox-pure/main/LICENSE"
rp_module_repo="git https://github.com/libretro/dosbox-pure.git main"
rp_module_section="exp"
rp_module_flags=""

function sources_lr-dosbox-pure() {
    gitPullOrClone
}

function build_lr-dosbox-pure() {
    make clean
    make
    md_ret_require="$md_build/dosbox_pure_libretro.so"
}

function install_lr-dosbox-pure() {
    md_ret_files=(
        'LICENSE'
        'dosbox_pure_libretro.so'
        'README.md'
    )
}

function configure_lr-dosbox-pure() {
    mkRomDir "pc"
    defaultRAConfig "pc"

    addEmulator 0 "$md_id" "pc" "$md_inst/dosbox_pure_libretro.so"
    addSystem "pc"
}
