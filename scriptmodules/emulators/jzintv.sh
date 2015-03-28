#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
#

rp_module_id="jzintv"
rp_module_desc="Intellivision emulator"
rp_module_menus="2+"
rp_module_flags="dispmanx"

function depends_jzintv() {
    getDepends libsdl1.2-dev
}

function sources_jzintv() {
    wget http://downloads.petrockblock.com/retropiearchives/jzintv-20141028.zip -O jzintv.zip
    unzip jzintv.zip
    rm jzintv.zip
    cd jzintv/src
    # don't build event_diag.rom/emu_ver.rom/joy_diag.rom/jlp_test.bin due to missing example/library files from zip
    sed -i '/^PROGS/,$d' {event,joy,jlp,util}/subMakefile
}

function build_jzintv() {
    mkdir -p jzintv/bin
    cd jzintv/src
    make clean
    make OPT_FLAGS="$CFLAGS"
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

    setDispmanx "$md_id" 1

    addSystem 1 "$md_id" "intellivision" "$md_inst/bin/jzintv -p $biosdir -q %ROM%"

    __INFMSGS+=("You need to copy Intellivision BIOS files (exec.bin & grom.bin) to the folder $biosdir.")
}
