#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="jzintv"
rp_module_desc="Intellivision emulator"
rp_module_help="ROM Extensions: .int .bin\n\nCopy your Intellivision roms to $romdir/intellivision\n\nCopy the required BIOS files exec.bin and grom.bin to $biosdir"
rp_module_licence="GPL2 http://spatula-city.org/%7Eim14u2c/intv/"
rp_module_section="opt"
rp_module_flags="dispmanx !mali !kms"

function depends_jzintv() {
    getDepends libsdl1.2-dev
}

function sources_jzintv() {
    downloadAndExtract "$__archive_url/jzintv-20181225.zip" "$md_build"
    cd jzintv/src
}

function build_jzintv() {
    mkdir -p jzintv/bin
    cd jzintv/src
    make clean
    make CC="gcc" CXX="g++" WARNXX="" OPT_FLAGS="$CFLAGS"
    md_ret_require="$md_build/jzintv/bin/jzintv"
}

function install_jzintv() {
    md_ret_files=(
        'jzintv/bin'
        'jzintv/src/COPYING.txt'
        'jzintv/src/COPYRIGHT.txt'
    )
}

function configure_jzintv() {
    mkRomDir "intellivision"

    if ! isPlatform "x11"; then
        setDispmanx "$md_id" 1
    fi

    addEmulator 1 "$md_id" "intellivision" "$md_inst/bin/jzintv -p $biosdir -q %ROM%"
    addSystem "intellivision"
}
