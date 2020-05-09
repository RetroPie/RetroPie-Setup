#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-yabasanshiro"
rp_module_desc="Saturn & ST-V emulator - Yabasanshiro port for libretro"
rp_module_help="ROM Extensions: .iso .cue .zip .ccd .mds\n\nCopy your Sega Saturn & ST-V roms to $romdir/saturn\n\nCopy the required BIOS file saturn_bios.bin / stvbios.zip to $biosdir/yabasanshiro"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/yabause/yabasanshiro/LICENSE"
rp_module_repo="git https://github.com/libretro/yabause.git yabasanshiro 73c67668"
rp_module_section="exp"
rp_module_flags="!all rpi4"

function sources_lr-yabasanshiro() {
    gitPullOrClone
    isPlatform "rpi4" && applyPatch "$md_data/01_shader_hack_rpi4.diff"
}

function build_lr-yabasanshiro() {
    local params=()
    ! isPlatform "x86" && params+=(HAVE_SSE=0)
    if isPlatform "arm"; then
        params+=(USE_ARM_DRC=1 DYNAREC_DEVMIYAX=1 ARCH_IS_LINUX=1)
        isPlatform "neon" && params+=(HAVE_NEON=1)
    elif isPlatform "aarch64"; then
        params+=(USE_AARCH64_DRC=1 DYNAREC_DEVMIYAX=1)
    fi
    isPlatform "gles" && params+=(FORCE_GLES=1)

    cd yabause/src/libretro
    make clean
    make "${params[@]}"
    md_ret_require="$md_build/yabause/src/libretro/yabasanshiro_libretro.so"
}

function install_lr-yabasanshiro() {
    md_ret_files=(
        'yabause/src/libretro/yabasanshiro_libretro.so'
        'LICENSE'
        'README.md'
    )
}

function configure_lr-yabasanshiro() {
    mkRomDir "saturn"
    ensureSystemretroconfig "saturn"

    addEmulator 1 "$md_id" "saturn" "$md_inst/yabasanshiro_libretro.so"
    addSystem "saturn"
}
