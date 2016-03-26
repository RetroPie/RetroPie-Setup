#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="mame4all"
rp_module_desc="MAME emulator MAME4All-Pi"
rp_module_menus="2+"
rp_module_flags="!x86 !mali"

function depends_mame4all() {
    getDepends libasound2-dev libsdl1.2-dev libraspberrypi-dev
}

function sources_mame4all() {
    gitPullOrClone "$md_build" https://github.com/RetroPie/mame4all-pi.git
}

function build_mame4all() {
    make clean
    # drz80 contains obsoleted arm assembler that gcc/as will not like for arm8 cpu targets
    if isPlatform "armv8"; then
        CFLAGS="-O2 -march=armv7-a -mfpu=neon-vfpv4 -mfloat-abi=hard" make
    else
        make
    fi
    md_ret_require="$md_build/mame"
}

function install_mame4all() {
    md_ret_files=(
        'cheat.dat'
        'clrmame.dat'
        'folders'
        'hiscore.dat'
        'mame'
        'mame.cfg.template'
        'readme.txt'
        'skins'
    )
}

function configure_mame4all() {
    local system="mame-mame4all"
    mkRomDir "arcade"
    mkRomDir "$system"
    mkRomDir "$system/artwork"
    mkRomDir "$system/samples"

    mkdir -p "$md_conf_root/$system/"{cfg,hi,inp,memcard,nvram,snap,sta}

    # move old config
    moveConfigFile "mame.cfg" "$md_conf_root/$system/mame.cfg"

    # if the user doesn't already have a config, we will copy the default.
    if [[ ! -f "$md_conf_root/$system/mame.cfg" ]]; then
        cp "mame.cfg.template" "$md_conf_root/$system/mame.cfg"
    fi

    iniConfig "=" "" "$md_conf_root/$system/mame.cfg"
    iniSet "cfg" "$md_conf_root/$system/cfg"
    iniSet "hi" "$md_conf_root/$system/hi"
    iniSet "inp" "$md_conf_root/$system/inp"
    iniSet "memcard" "$md_conf_root/$system/memcard"
    iniSet "nvram" "$md_conf_root/$system/nvram"
    iniSet "snap" "$md_conf_root/$system/snap"
    iniSet "sta" "$md_conf_root/$system/sta"

    iniSet "artwork" "$romdir/$system/artwork"
    iniSet "samplepath" "$romdir/$system/samples;$romdir/arcade/samples"
    iniSet "rompath" "$romdir/$system;$romdir/arcade"

    iniSet "samplerate" "44100"

    chown -R $user:$user "$md_conf_root/$system"

    addSystem 0 "$md_id" "arcade" "$md_inst/mame %BASENAME%"
    addSystem 1 "$md_id" "$system arcade mame" "$md_inst/mame %BASENAME%"
}
