#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-easyrpg"
rp_module_desc="RPG Maker 2000/2003 engine - EasyRPG Player interpreter port for libretro."
rp_module_help="ROM Extension: .ldb\n\nYou need to unzip your RPG Maker games into subdirectories in $romdir/ports/easyrpg/games\n\nRTP file:\nExtract the RTP files from their respective .exe installers and then copy RTP 2000 files in $biosdir/rtp/2000 and RTP 2003 files in $biosdir/rtp/2003."
rp_module_licence="GPL3 https://raw.githubusercontent.com/libretro/easyrpg-libretro/master/COPYING"
rp_module_section="exp"
rp_module_flags=""

function depends_lr-easyrpg() {
    depends_easyrpg-player
}

function sources_lr-easyrpg() {
    gitPullOrClone "$md_build" https://github.com/libretro/easyrpg-libretro.git
    gitPullOrClone "liblcf" https://github.com/EasyRPG/liblcf.git
}

function build_lr-easyrpg() {
    cd "liblcf"
    autoreconf -i
    ./configure --prefix=/usr
    make -j`nproc`
    sudo make install
    cd ..

    cd "builds/libretro"
    make -f Makefile.libretro clean
    make -f Makefile.libretro -j`nproc`
    md_ret_require="$md_build/builds/libretro/easyrpg_libretro.so"
}

function install_lr-easyrpg() {
    md_ret_files=(
        'builds/libretro/easyrpg_libretro.so'
    )
}

function remove_lr-easyrpg() {
    remove_easyrpg-player
}

function configure_lr-easyrpg() {
    setConfigRoot "ports"

    mkRomDir "ports/easyrpg/games"

    addPort "$md_id" "easyrpg" "EasyRPG Player" "$md_inst/easyrpg_libretro.so" "$romdir/ports/easyrpg/games/"

    ensureSystemretroconfig "ports/easyrpg" 

    mkUserDir "$biosdir/rtp/2000"
    mkUserDir "$biosdir/rtp/2003"    
}
