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
rp_module_help="ROM Extensions: .st .stx .img .rom .raw .ipf .ctr .zip\n\nCopy your Atari ST games to $romdir/atarist"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/hatari/master/gpl.txt"
rp_module_repo="git https://github.com/libretro/hatari.git hitari2014-mercurial"
rp_module_section="exp"

function depends_lr-hatari() {
    getDepends zlib1g-dev
}

function sources_lr-hatari() {
    gitPullOrClone
    # TARGET_NAME should be overriden by user input
    sed -i "s/TARGET_NAME :=/TARGET_NAME ?=/" "$md_build/Makefile.libretro"
    _sources_libcapsimage_hatari
}

function build_lr-hatari() {
    _build_libcapsimage_hatari

    cd "$md_build"
    make -f Makefile.libretro clean
    make -f Makefile.libretro capsimg=1 capssrc="$md_build/capsimg_source_linux_macosx" capslib="$md_build/lib" capslibname=":libcapsimage.so.5.1" TARGET_NAME="hatari" LDFLAGS="-Wl,-rpath='$md_inst'" 
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
    defaultRAConfig "atarist"

    # move any old configs to new location
    moveConfigDir "$home/.hatari" "$md_conf_root/atarist"

    addEmulator 1 "$md_id" "atarist" "$md_inst/hatari_libretro.so"
    addSystem "atarist"
}
