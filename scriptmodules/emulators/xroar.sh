#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="xroar"
rp_module_desc="Dragon / CoCo emulator XRoar"
rp_module_section="opt"
rp_module_flags="!mali"

function depends_xroar() {
    getDepends libsdl1.2-dev automake
}

function sources_xroar() {
    gitPullOrClone "$md_build" http://www.6809.org.uk/git/xroar.git 0.33.2
}

function build_xroar() {
    local params=(--without-gtk2 --without-gtkgl)
    if ! isPlatform "x11"; then
        params+=(--without-pulse)
    fi
    ./autogen.sh
    ./configure --prefix="$md_inst" "${params[@]}"
    make clean
    make
    md_ret_require="$md_build/src/xroar"
}

function install_xroar() {
    make install
}

function configure_xroar() {
    mkRomDir "dragon32"
    mkRomDir "coco"

    mkdir -p "$md_inst/share/xroar"
    ln -snf "$biosdir" "$md_inst/share/xroar/roms"

    local params=(-fs)
    ! isPlatform "x11" && params+=(-vo sdl --ccr simple)
    addSystem 1 "$md_id-dragon32" "dragon32" "$md_inst/bin/xroar ${params[*]} -machine dragon32 -run %ROM%"
    addSystem 1 "$md_id-cocous" "coco" "$md_inst/bin/xroar ${params[*]} -machine cocous -run %ROM%"
    addSystem 0 "$md_id-coco" "coco" "$md_inst/bin/xroar ${params[*]} -machine coco -run %ROM%"

    __INFMSGS+=("For emulator $md_id you need to copy system/basic roms such as d32.rom (Dragon 32) and bas13.rom (CoCo) to '$biosdir'.")
}
