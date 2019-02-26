#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="quasi88"
rp_module_desc="NEC PC-8801 emulator"
rp_module_help="ROM Extensions: .d88 .88d .cmt .t88\n\nCopy your pc88 games to to $romdir/pc88\n\nCopy bios files FONT.ROM, N88.ROM, N88KNJ1.ROM, N88KNJ2.ROM, and N88SUB.ROM to $biosdir/pc88"
rp_module_section="exp"
rp_module_flags="dispmanx !mali !kms"

function depends_quasi88() {
    getDepends libsdl1.2-dev
}

function sources_quasi88() {
    downloadAndExtract "$__archive_url/quasi88-0.6.4.tgz" "$md_build" --strip-components 1
    applyPatch "$md_data/01_fixes.diff"
}

function build_quasi88() {
    make X11_VERSION= SDL_VERSION=1 clean
    make X11_VERSION= SDL_VERSION=1 ARCH=linux SOUND_SDL=1 USE_OLD_MAME_SOUND=1 USE_FMGEN=1 ROMDIR="$biosdir/pc88" DISKDIR="$romdir/pc88" TAPEDIR="$romdir/pc88"
    md_ret_require="$md_build/quasi88.sdl"
}

function install_quasi88() {
    make X11_VERSION= SDL_VERSION=1 BINDIR="$md_inst" install
}

function configure_quasi88() {
    mkRomDir "pc88"
    moveConfigDir "$home/.quasi88" "$md_conf_root/pc88"
    mkUserDir "$biosdir/pc88"

    addEmulator 1 "$md_id" "pc88" "$md_inst/quasi88.sdl -f6 IMAGE-NEXT1 -f7 IMAGE-NEXT2 -f8 NOWAI -f9 ROMAJI -f10 NUMLOCK -fullscreen %ROM%"
    addSystem "pc88"
}
