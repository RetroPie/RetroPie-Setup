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
rp_module_help="ROM Extensions: .cas .wav .bas .asc .dmk .jvc .os9 .dsk .vdk .rom .ccc .sna\n\nCopy your Dragon roms to $romdir/dragon32\n\nCopy your CoCo games to $romdir/coco\n\nCopy the required BIOS files d32.rom (Dragon 32), bas13.rom (CoCo), coco3.rom/coco3p.rom (CoCo3) to $biosdir"
rp_module_licence="GPL3 http://www.6809.org.uk/xroar/"
rp_module_repo="git http://www.6809.org.uk/git/xroar.git 1.0.9"
rp_module_section="opt"
rp_module_flags=""

function depends_xroar() {
    local depends=(libsdl2-dev automake libasound2-dev texinfo zlib1g-dev)
    isPlatform "x11" && depends+=(libpulse-dev)
    getDepends "${depends[@]}"
}

function sources_xroar() {
    gitPullOrClone "$md_build" "$md_repo_url" "$md_repo_branch" "" 0

}

function build_xroar() {
    local params=(--without-gtk2 --without-gtkgl --without-oss)
    if ! isPlatform "x11"; then
        params+=(--without-pulse --disable-kbd-translate --without-x)
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

    local params=()
    ! isPlatform "x11" && params+=(-vo sdl -ccr simple)
    ! isPlatform "videocore" && params+=(-fs)
    addEmulator 1 "$md_id-dragon32" "dragon32" "$md_inst/bin/xroar ${params[*]} -machine dragon32 -run %ROM%"
    addEmulator 1 "$md_id-cocous" "coco" "$md_inst/bin/xroar ${params[*]} -machine cocous -run %ROM%"
    addEmulator 0 "$md_id-coco" "coco" "$md_inst/bin/xroar ${params[*]} -machine coco -run %ROM%"
    addEmulator 0 "$md_id-coco3us" "coco" "$md_inst/bin/xroar ${params[*]} -machine coco3 -run %ROM%"
    addEmulator 0 "$md_id-coco3" "coco" "$md_inst/bin/xroar ${params[*]} -machine coco3p -run %ROM%"

    addSystem "dragon32"
    addSystem "coco"
}
