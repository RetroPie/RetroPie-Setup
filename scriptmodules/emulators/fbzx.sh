#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="fbzx"
rp_module_desc="ZXSpectrum emulator FBZX"
rp_module_menus="2+"
rp_module_flags="dispmanx"

function depends_fbzx() {
    getDepends libasound2-dev libsdl1.2-dev
}

function sources_fbzx() {
    wget -O- -q $__archive_url/fbzx-2.10.0.tar.bz2 | tar -xvj --strip-components=1 
}

function build_fbzx() {
    make clean
    make
    md_ret_require="$md_build/fbzx"
}

function install_fbzx() {
    md_ret_files=(
        'AMSTRAD'
        'CAPABILITIES'
        'COPYING'
        'FAQ'
        'fbzx'
        'fbzx.desktop'
        'fbzx.svg'
        'INSTALL'
        'keymap.bmp'
        'PORTING'
        'README'
        'README.TZX'
        'spectrum-roms'
        'TODO'
        'VERSIONS'
    )
}

function configure_fbzx() {
    mkRomDir "zxspectrum"

    delSystem "$md_id" "zxspectrum-fbzx"
    addSystem 0 "$md_id" "zxspectrum" "$md_inst/fbzx %ROM%"
}
