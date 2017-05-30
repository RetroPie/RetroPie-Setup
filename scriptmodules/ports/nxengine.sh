#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="nxengine"
rp_module_desc="Cave Story engine clone - NxEngine"
rp_module_help="The original Cave Story game files are automatically installed to $md_inst."
rp_module_section="opt"

function depends_nxengine() {
    getDepends libsdl-ttf2.0-0 libsdl1.2
}

function sources_nxengine() {
    if isPlatform "rpi"; then 
        wget -O- -q http://www.cavestory.org/downloads/pi-NXEngine-master.zip
        unzip -oj pi-NXEngine-master.zip -d "$md_inst"
        rm pi-NXEngine-master.zip
    fi
    
    if isPlatform "arm"; then 
        wget -O- -q http://nxengine.sourceforge.net/dl/nx-src-1003.tar.bz2 | tar -xvj --strip-components=1 -C "$md_inst"
        rm nx-src-1003.tar.bz2
    fi
    
    if isPlatform "x86"; then
        wget -O- -q http://nxengine.sourceforge.net/dl/nx-src-1006.tar.bz2 | tar -xvj --strip-components=1 -C "$md_inst"
        rm nx-src-1006.tar.bz2
    fi
}

function build_nxengine() {
    if isPlatform "rpi"; then
        cd "$md_inst"
        scons -j6
    else
        cd "$md_inst"
        make clean
        make
    fi
}
    
function install_bin_nxengine() {
    if isPlatform "rpi"; then
        wget -O- -q http://www.sheasilverman.com/rpi/raspbian/installer/cavestory.zip
        unzip -oj cavestory.zip -d "$md_inst"
        rm cavestory.zip
    fi
    
    if isPlatform "x86"; then
        wget -O- -q http://nxengine.sourceforge.net/dl/nx-lin32-1002.tar.gz | tar -xvz --strip-components=1 -C "$md_inst"
        rm nx-lin32-1002.tar.gz
    fi       
}

function configure_nxengine() {
    addPort "$md_id" "cavestory" "Cave Story" "$md_inst/nx"
}
