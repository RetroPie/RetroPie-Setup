#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="stella"
rp_module_desc="Atari2600 emulator STELLA"
rp_module_help="ROM Extensions: .a26 .bin .rom .zip .gz\n\nCopy your Atari 2600 roms to $romdir/atari2600"
rp_module_licence="GPL2 https://raw.githubusercontent.com/stella-emu/stella/master/License.txt"
rp_module_repo="git https://github.com/stella-emu/stella.git :_get_version_stella"
rp_module_section="opt"
rp_module_flags=""

function _get_version_stella() {
    if [[ "$__gcc_version" -lt 11 ]]; then
        echo "6.7"
    else
        # latest version needs C++-20 support
        echo "7.0"
    fi
}

function depends_stella() {
    getDepends libsdl2-dev libpng-dev zlib1g-dev
}

function sources_stella() {
    gitPullOrClone
}

function build_stella() {
    ./configure --prefix="$md_inst"
    make clean
    make
    md_ret_require="$md_build/stella"
}

function install_stella() {
    make install
}

function configure_stella() {
    mkRomDir "atari2600"

    moveConfigDir "$home/.config/stella" "$md_conf_root/atari2600/stella"

    addEmulator 1 "$md_id" "atari2600" "$md_inst/bin/stella -maxres 320x240 -fullscreen 1 -tia.fsfill 1 %ROM%"
    addSystem "atari2600"
}
