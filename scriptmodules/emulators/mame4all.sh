#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
#

rp_module_id="mame4all"
rp_module_desc="MAME emulator MAME4All-Pi"
rp_module_menus="2+"

function depends_mame4all() {
    getDepends libasound2-dev libsdl1.2-dev
}

function sources_mame4all() {
    gitPullOrClone "$md_build" https://github.com/joolswills/mame4all-pi.git
}

function build_mame4all() {
    make clean
    make
    md_ret_require="$md_build/mame"
}

function install_mame4all() {
    md_ret_files=(
        'cheat.dat'
        'clrmame.dat'
        'folders'
        'hiscore.dat'
        'mame'
        'readme.txt'
        'skins'
    )
    # install mame.cfg under another name as we will copy it
    cp -v "$md_build/mame.cfg" "$md_inst/mame.cfg.sample"
}

function configure_mame4all() {
    local system="mame-mame4all"
    mkRomDir "$system"
    mkRomDir "$system/artwork"
    mkRomDir "$system/samples"

    mkdir -p "$configdir/$system/"{cfg,hi,inp,memcard,nvram,snap,sta}

    # move old config
    if [[ -f "mame.cfg" && ! -h "mame.cfg" ]]; then
        mv "mame.cfg" "$configdir/$system/mame.cfg"
    fi

    # if the user doesn't already have a config, we will copy the default.
    if [[ ! -f "$configdir/$system/mame.cfg" ]]; then
        cp "mame.cfg.sample" "$configdir/$system/mame.cfg"
    fi

    ln -sf "$configdir/$system/mame.cfg"

    iniConfig "=" "" "$configdir/$system/mame.cfg"
    iniSet "cfg" "$configdir/$system/cfg"
    iniSet "hi" "$configdir/$system/hi"
    iniSet "inp" "$configdir/$system/inp"
    iniSet "memcard" "$configdir/$system/memcard"
    iniSet "nvram" "$configdir/$system/nvram"
    iniSet "snap" "$configdir/$system/snap"
    iniSet "sta" "$configdir/$system/sta"

    iniSet "artwork" "$romdir/$system/artwork"
    iniSet "samplepath" "$romdir/$system/samples"
    iniSet "rompath" "$romdir/$system"

    iniSet "samplerate" "44100"

    chown -R $user:$user "$configdir/$system"

    addSystem 1 "$md_id" "$system arcade mame" "$md_inst/mame %BASENAME%"
}
