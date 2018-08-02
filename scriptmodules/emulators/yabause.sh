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
rp_module_desc="Sega Saturn emu - Yabause "
rp_module_help="ROM Extensions: .iso .bin .zip\n\nCopy your Sega Saturn roms to $romdir/saturn\n\nCopy the required BIOS file saturn_bios.bin to $biosdir"
rp_module_licence="https://github.com/devmiyax/yabause/blob/minimum_linux/yabause/COPYING"
rp_module_section="exp"
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
	cmake ../yabause -DYAB_PORTS=xu4
 make
    
    md_ret_require="$md_build/build/src/xu4/yabasanshiro"
}

function install_yabause() {
    md_ret_files=(
        'build/src/xu4/yabasanshiro'
        
    )
}

function configure_yabause() {
    mkRomDir "saturn"
    

    addEmulator 0 "${md_id}-internal" "saturn" "$md_inst/yabasanshiro -a -i %ROM%"
	 addEmulator 0 "${md_id}-US" "saturn" "$md_inst/yabasanshiro -a -b /home/pigaming/RetroPie/BIOS/saturn_bios.bin -i %ROM%"
	 addEmulator 0 "${md_id}-JP" "saturn" "$md_inst/yabasanshiro -a -b /home/pigaming/RetroPie/BIOS/sega_101.bin -i %ROM%"
	 
    addSystem "saturn"
}
