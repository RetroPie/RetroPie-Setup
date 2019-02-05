#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-hatari"
rp_module_desc="Atari emulator - Hatari port for libretro"
rp_module_help="ROM Extensions: .st .stx .img .rom .raw .ipf .ctr\n\nCopy your Atari ST games to $romdir/atarist"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/hatari/master/gpl.txt"
rp_module_section="exp"

function depends_lr-hatari() {
    getDepends zlib1g-dev
}

function sources_lr-hatari() {
    gitPullOrClone "$md_build" https://github.com/libretro/hatari.git
    applyPatch "$md_data/01_libcapsimage.diff"
    _sources_libcapsimage_hatari
}

function build_lr-hatari() {
    _build_libcapsimage_hatari

    cd "$md_build"
    CFLAGS+=" -D__cdecl='' -DHAVE_CAPSIMAGE=1 -DCAPSIMAGE_VERSION=5" LDFLAGS+="-L./lib -l:libcapsimage.so.5.1" make -f Makefile.libretro
    md_ret_require="$md_build/hatari_libretro.so"
}

function install_lr-hatari() {
    _install_libcapsimage_hatari
    md_ret_files=(
        'hatari_libretro.so'
        'readme.txt'
        'gpl.txt'
    )
}

function configure_lr-hatari() {
    mkRomDir "atarist"
    ensureSystemretroconfig "atarist"

    # move any old configs to new location
    moveConfigDir "$home/.hatari" "$md_conf_root/atarist"

    addEmulator 1 "$md_id" "atarist" "$md_inst/hatari_libretro.so"
    addSystem "atarist"

    # add LD_LIBRARY_PATH='$md_inst' to start of launch command
    iniConfig " = " '"' "$configdir/atarist/emulators.cfg"
    iniGet "$md_id"
    iniSet "$md_id" "LD_LIBRARY_PATH='$md_inst' $ini_value"
}
