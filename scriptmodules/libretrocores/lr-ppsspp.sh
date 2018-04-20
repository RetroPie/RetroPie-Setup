#!/bin/bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-ppsspp"
rp_module_desc="PlayStation Portable emu - PPSSPP port for libretro"
rp_module_help="ROM Extensions: .iso .pbp .cso\n\nCopy your PlayStation Portable roms to $romdir/psp"
rp_module_licence="GPL2 https://raw.githubusercontent.com/RetroPie/ppsspp/master/LICENSE.TXT"
rp_module_section="opt"
rp_module_flags="!aarch64"

function depends_lr-ppsspp() {
    local depends=()
    isPlatform "rpi" && depends+=(libraspberrypi-dev)
    getDepends "${depends[@]}"
}

function sources_lr-ppsspp() {
    local branch="libretro"
    isPlatform "rpi" && branch="libretro_rpi_fix"
    gitPullOrClone "$md_build" https://github.com/RetroPie/ppsspp.git "$branch"

    # remove the lines that trigger the ffmpeg build script functions - we will just use the variables from it
    sed -i "/^build_ARMv6$/,$ d" ffmpeg/linux_arm.sh
}

function build_lr-ppsspp() {
    build_ffmpeg_ppsspp "$md_build/ffmpeg"
    cd "$md_build"

    make -C libretro clean
    local params=()
    if isPlatform "rpi"; then
        if isPlatform "rpi1"; then
            params+=("platform=rpi1")
        else
            params+=("platform=rpi2")
        fi
    elif isPlatform "mali"; then
        params+=("platform=armvglesneon")
    fi
    make -C libretro "${params[@]}"
    md_ret_require="$md_build/libretro/ppsspp_libretro.so"
}

function install_lr-ppsspp() {
    md_ret_files=(
        'libretro/ppsspp_libretro.so'
        'assets'
        'flash0'
    )
}

function configure_lr-ppsspp() {
    mkRomDir "psp"
    ensureSystemretroconfig "psp"

    if [[ "$md_mode" == "install" ]]; then
        mkUserDir "$biosdir/PPSSPP"
        cp -Rv "$md_inst/assets/"* "$biosdir/PPSSPP/"
        cp -Rv "$md_inst/flash0" "$biosdir/PPSSPP/"
        chown -R $user:$user "$biosdir/PPSSPP"
    fi

    addEmulator 1 "$md_id" "psp" "$md_inst/ppsspp_libretro.so"
    addSystem "psp"
}
