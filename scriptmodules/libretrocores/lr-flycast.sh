#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-flycast"
rp_module_desc="Dreamcast emulator - Reicast port for libretro"
rp_module_help="Previously named lr-reicast then lr-beetle-dc\n\nDreamcast ROM Extensions: .cdi .gdi .chd, Naomi/Atomiswave ROM Extension: .zip\n\nCopy your Dreamcast/Naomi roms to $romdir/dreamcast\n\nCopy the required Dreamcast BIOS files dc_boot.bin and dc_flash.bin to $biosdir/dc\n\nCopy the required Naomi/Atomiswave BIOS files naomi.zip and awbios.zip to $biosdir/dc"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/flycast/master/LICENSE"
rp_module_section="opt"
rp_module_flags="!mali !armv6"

function _update_hook_lr-flycast() {
    renameModule "lr-reicast" "lr-beetle-dc"
    renameModule "lr-beetle-dc" "lr-flycast"
}

function sources_lr-flycast() {
    # build from an older commit due to current broken upstream
    gitPullOrClone "$md_build" https://github.com/libretro/flycast.git "" "c59eac0"
    # don't override our C/CXXFLAGS and set LDFLAGS to CFLAGS to avoid warnings on linking
    applyPatch "$md_data/01_flags_fix.diff"
}

function build_lr-flycast() {
    local params=()
    make clean
    if isPlatform "rpi"; then
        if isPlatform "rpi4"; then
            params+=("platform=rpi4")
        elif isPlatform "mesa"; then
            params+=("platform=rpi-mesa")
        else
            params+=("platform=rpi")
        fi
    fi
    # temporarily disable distcc due to segfaults with cross compiler and lto
    DISTCC_HOSTS="" make "${params[@]}"
    md_ret_require="$md_build/flycast_libretro.so"
}

function install_lr-flycast() {
    md_ret_files=(
        'flycast_libretro.so'
        'LICENSE'
    )
}

function configure_lr-flycast() {
    mkRomDir "dreamcast"
    ensureSystemretroconfig "dreamcast"

    mkUserDir "$biosdir/dc"

    # system-specific
    iniConfig " = " "" "$configdir/dreamcast/retroarch.cfg"
    iniSet "video_shared_context" "true"

    local def=0
    isPlatform "kms" && def=1
    # segfaults on the rpi without redirecting stdin from </dev/null
    addEmulator $def "$md_id" "dreamcast" "$md_inst/flycast_libretro.so </dev/null"
    addSystem "dreamcast"
}
