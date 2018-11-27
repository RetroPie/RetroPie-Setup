#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="yabause"
rp_module_desc="Sega Saturn Emulator"
rp_module_help="ROM Extensions: .iso .bin .zip\n\nCopy your Sega Saturn roms to $romdir/saturn\n\nCopy the required BIOS file saturn_bios_us.bin and saturn_bios_jp.bin to $biosdir"
rp_module_licence="https://github.com/devmiyax/yabause/blob/minimum_linux/yabause/COPYING"
rp_module_section="opt"
rp_module_flags="!armv6"

function depends_yabause() {
    local depends=(cmake libgles2-mesa-dev libsdl2-dev libboost-filesystem-dev libboost-system-dev libboost-locale-dev libboost-date-time-dev)
    getDepends "${depends[@]}"
}

function sources_yabause() {
    git clone --recursive https://github.com/devmiyax/yabause.git -b minimum_linux   "$md_build" 
}

function build_yabause() {
    mkdir build 
	  cd build
	  export CFLAGS="-O2 -mcpu=cortex-a15 -mtune=cortex-a15.cortex-a7 -mfpu=neon-vfpv4 -mfloat-abi=hard -ftree-vectorize -funsafe-math-optimizations"
	  cmake ../yabause -DYAB_PORTS=xu4 -DYAB_WANT_DYNAREC_DEVMIYAX=ON -DYAB_WANT_ARM7=ON
    make    
    md_ret_require="$md_build/build/src/xu4/yabasanshiro"
}

function install_yabause() {
    md_ret_files=(
        'build/src/xu4/yabasanshiro'
    )
}

function install_bin_yabause() {
    downloadAndExtract "http://github.com/Retro-Arena/xu4-bins/raw/master/yabause.tar.gz" "$md_inst" 1
}

function configure_yabause() {
    rm $configdir/saturn/emulators.cfg
    mkRomDir "saturn"
    addEmulator 0 "${md_id}-1x" "saturn" "$md_inst/yabasanshiro -a -r 3 -b /home/pigaming/RetroPie/BIOS/saturn_bios.bin -i %ROM%"
    addEmulator 0 "${md_id}-1x-nf" "saturn" "$md_inst/yabasanshiro -a -nf -r 3 -b /home/pigaming/RetroPie/BIOS/saturn_bios.bin -i %ROM%"
    addEmulator 0 "${md_id}-2x" "saturn" "$md_inst/yabasanshiro -a -r 2 -b /home/pigaming/RetroPie/BIOS/saturn_bios.bin -i %ROM%"
    addEmulator 0 "${md_id}-2x-nf" "saturn" "$md_inst/yabasanshiro -a -nf -r 3 -b /home/pigaming/RetroPie/BIOS/saturn_bios.bin -i %ROM%"
    #addEmulator 0 "${md_id}-native" "saturn" "$md_inst/yabasanshiro -a -i %ROM%"
    addSystem "saturn"
}
