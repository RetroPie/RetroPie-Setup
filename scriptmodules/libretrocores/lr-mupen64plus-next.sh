#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-mupen64plus-next"
rp_module_desc="N64 emulator - Mupen64Plus + GLideN64 for libretro (next version)"
rp_module_help="ROM Extensions: .z64 .n64 .v64\n\nCopy your N64 roms to $romdir/n64"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/mupen64plus-libretro-nx/master/LICENSE"
rp_module_section="opt kms=main"
rp_module_flags=""

function depends_lr-mupen64plus-next() {
    local depends=()
    isPlatform "x11" && depends+=(libglew-dev libglu1-mesa-dev)
    isPlatform "x86" && depends+=(nasm)
    isPlatform "videocore" && depends+=(libraspberrypi-dev)
    isPlatform "mesa" && depends+=(libgles2-mesa-dev)
    getDepends "${depends[@]}"
}

function sources_lr-mupen64plus-next() {
    gitPullOrClone "$md_build" https://github.com/libretro/mupen64plus-libretro-nx.git develop
}

function build_lr-mupen64plus-next() {
    local params=()
    if isPlatform "arm"; then
        if isPlatform "videocore"; then
            params+=(platform="$__platform")
        elif isPlatform "mesa"; then
            params+=(platform="$__platform-mesa")
        elif isPlatform "mali"; then
            params+=(platform="odroid")
        fi
        isPlatform "neon" && params+=(HAVE_NEON=1)
    fi
    if isPlatform "gles3"; then
        params+=(FORCE_GLES3=1)
    elif isPlatform "gles"; then
        params+=(FORCE_GLES=1)
    fi

    # use a custom core name to avoid core option name clashes with lr-mupen64plus
    params+=(CORE_NAME=mupen64plus-next)
    make "${params[@]}" clean

    # workaround for linkage_arm.S including some armv7 instructions without this
    if isPlatform "armv6"; then
        CFLAGS="$CFLAGS -DARMv5_ONLY" make "${params[@]}"
    else
        make "${params[@]}"
    fi

    md_ret_require="$md_build/mupen64plus_next_libretro.so"
}

function install_lr-mupen64plus-next() {
    md_ret_files=(
        'mupen64plus_next_libretro.so'
        'LICENSE'
        'README.md'
    )
}

function configure_lr-mupen64plus-next() {
    mkRomDir "n64"
    ensureSystemretroconfig "n64"

    if isPlatform "rpi"; then
        # Disable hybrid upscaling filter (needs better GPU)
        setRetroArchCoreOption "mupen64plus-next-HybridFilter" "False"
        # Disable overscan/VI emulation (slight performance drain)
        setRetroArchCoreOption "mupen64plus-next-EnableOverscan" "Disabled"
        # Enable Threaded GL calls
        setRetroArchCoreOption "mupen64plus-next-ThreadedRenderer" "True"
    fi
    setRetroArchCoreOption "mupen64plus-next-EnableNativeResFactor" "1"

    addEmulator 1 "$md_id" "n64" "$md_inst/mupen64plus_next_libretro.so"
    addSystem "n64"
}
