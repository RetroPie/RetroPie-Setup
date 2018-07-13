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
rp_module_help="ROM Extensions: .sna .szx .z80 .tap .tzx .gz .udi .mgt .img .trd .scl .dsk .zip\n\nCopy your ZX Spectrum to $romdir/zxspectrum"
rp_module_licence="GPL3 https://raw.githubusercontent.com/rastersoft/fbzx/master/COPYING"
rp_module_section="opt"
rp_module_flags="dispmanx !mali !kms"

function depends_fbzx() {
    getDepends "libasound2-dev libsdl1.2-dev"
}

function sources_fbzx() {
    local branch
    # use older version for non x86 systems (faster)
    ! isPlatform "x86" && branch="2.11.1"
    gitPullOrClone "$md_build" https://github.com/rastersoft/fbzx "$branch"
    ! isPlatform "x86" && sed -i 's|PREFIX2=$(PREFIX)/usr|PREFIX2=$(PREFIX)|' Makefile
}

function build_fbzx() {
    make clean
    make
    if ! isPlatform "x86"; then
        md_ret_require="$md_build/fbzx"
    else
        md_ret_require="$md_build/src/fbzx"
    fi
}

function install_fbzx() {
    if ! isPlatform "x86"; then
        mkdir "$md_inst/bin"
    fi
    make install PREFIX="$md_inst"
}

function configure_fbzx() {
    mkRomDir "zxspectrum"

    addEmulator 0 "$md_id" "zxspectrum" "pushd $md_inst/share; $md_inst/bin/fbzx %ROM%; popd"
    addSystem "zxspectrum"
}
