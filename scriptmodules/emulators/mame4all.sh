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
rp_module_help="ROM Extension: .zip\n\nCopy your MAME4all-Pi roms to either $romdir/mame-mame4all or\n$romdir/arcade"
rp_module_licence="NONCOM https://raw.githubusercontent.com/RetroPie/mame4all-pi/master/readme.txt"
rp_module_section="main"
rp_module_flags="!x11 !mali !kms"

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

    if [[ "$md_mode" == "install" ]]; then
        mkdir -p "$md_conf_root/$system/"{cfg,hi,inp,memcard,nvram,snap,sta}

        # move old config
        moveConfigFile "$md_inst/mame.cfg" "$md_conf_root/$system/mame.cfg"

        local config="$(mktemp)"
        cp "mame.cfg.template" "$config"

        iniConfig "=" "" "$config"
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

        copyDefaultConfig "$config" "$md_conf_root/$system/mame.cfg"
        rm "$config"

        chown -R $user:$user "$md_conf_root/$system"
    fi

    addEmulator 0 "$md_id" "arcade" "$md_inst/mame %BASENAME%"
    addEmulator 1 "$md_id" "$system" "$md_inst/mame %BASENAME%"
    addSystem "arcade"
    addSystem "$system"
}
