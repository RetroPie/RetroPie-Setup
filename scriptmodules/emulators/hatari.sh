#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
#

rp_module_id="hatari"
rp_module_desc="Atari emulator Hatari"
rp_module_menus="2+"
rp_module_flags="dispmanx"

function depends_hatari() {
    getDepends libsdl1.2-dev zlib1g-dev libpng12-dev cmake libreadline-dev portaudio19-dev
    apt-get remove -y hatari
}

function sources_hatari() {
    wget -q -O- "http://downloads.petrockblock.com/retropiearchives/hatari-1.8.0.tar.bz2" | tar -xvj --strip-components=1
}

function build_hatari() {
    ./configure --prefix="$md_inst"
    make clean
    make
    md_ret_require="$md_build/src/hatari"
}

function install_hatari() {
    make install
}

function configure_hatari() {
    mkRomDir "atarist"

    # move any old configs to new location
    if [[ -d "$home/.hatari" && ! -h "$home/.hatari" ]]; then
        mv -v "$home/.hatari/"* "$configdir/atarist/"
        rmdir "$home/.hatari"
    fi

    ln -snf "$configdir/atarist" "$home/.hatari"

    setDispmanx "$md_id" 0

    # add sdl mode for when borders are on
    ensureFBMode 416 288

    delSystem "$md_id" "atariststefalcon"
    delSystem "$md_id" "atarist"

    addSystem 1 "$md_id-fast" "atarist" "$md_inst/bin/hatari --zoom 1 --compatible 0 --timer-d 1 -w --borders 0 %ROM%"
    addSystem 0 "$md_id-fast-borders" "atarist" "$md_inst/bin/hatari --zoom 1 --compatible 0 --timer-d 1 -w --borders 1 %ROM%"
    addSystem 0 "$md_id-compatible" "atarist" "$md_inst/bin/hatari --zoom 1 --compatible 1 --timer-d 0 -w --borders 0 %ROM%"
    addSystem 0 "$md_id-compatible-borders" "atarist" "$md_inst/bin/hatari --zoom 1 --compatible 1 --timer-d 0 -w --borders 1 %ROM%"
}
