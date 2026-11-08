#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-fake08"
rp_module_desc="PICO-8 compatible engine - port of FAKE-08 for libretro"
rp_module_help="ROM Extensions: .p8 .p8.png\n\nCopy your roms to $romdir/pico8"
rp_module_licence="MIT https://raw.githubusercontent.com/jtothebell/fake-08/master/LICENSE.MD"
rp_module_repo="git https://github.com/jtothebell/fake-08.git master"
rp_module_section="exp"
rp_module_flags="!:\$__gcc_version:-lt:7"

function sources_lr-fake08() {
    gitPullOrClone
}

function build_lr-fake08() {
    make -C platform/libretro clean
    make -C platform/libretro
    md_ret_require="$md_build/platform/libretro/fake08_libretro.so"
}

function install_lr-fake08() {
    md_ret_files=(
        'platform/libretro/fake08_libretro.so'
        'LICENSE.MD'
        'README.md'
    )
}

function configure_lr-fake08() {
    mkRomDir "pico8"

    addEmulator 1 "$md_id" "pico8" "$md_inst/fake08_libretro.so"
    addSystem "pico8"

    [[ "$md_mode" == "remove" ]] && return

    # disable retroarch built-in imageviewer so we can run .p8.png files
    defaultRAConfig "pico8" "builtin_imageviewer_enable" "false"
}
