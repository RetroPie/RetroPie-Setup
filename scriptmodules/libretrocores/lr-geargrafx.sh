#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-geargrafx"
rp_module_desc="PC Engine/TurboGrafx-16/SuperGrafx/PCE CD-ROM² emulator"
rp_module_help="ROM Extensions: .7z .chd .cue .pce .sgx .zip\n\nCopy your PC Engine roms to $romdir/pcengine\n\nCopy the required BIOS files syscard3.pce and gexpress.pce to $biosdir"
rp_module_licence="GPL3 https://raw.githubusercontent.com/drhelius/Geargrafx/refs/heads/main/LICENSE"
rp_module_repo="git https://github.com/drhelius/Geargrafx.git main"
rp_module_section="opt"

function sources_lr-geargrafx() {
    gitPullOrClone
}

function build_lr-geargrafx() {
    make -C platforms/libretro clean
    make -C platforms/libretro
    md_ret_require="$md_build/platforms/libretro/geargrafx_libretro.so"
}

function install_lr-geargrafx() {
    md_ret_files=(
        'platforms/libretro/geargrafx_libretro.so'
        'LICENSE'
        'README.md'
    )
}

function configure_lr-geargrafx() {
    mkRomDir "pcengine"
    defaultRAConfig "pcengine"

    addEmulator 0 "$md_id" "pcengine" "$md_inst/geargrafx_libretro.so"
    addSystem "pcengine"
}
