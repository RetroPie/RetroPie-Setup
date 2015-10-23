#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="xroar"
rp_module_desc="Dragon / CoCo emulator XRoar"
rp_module_menus="2+"

function depends_xroar() {
    getDepends libsdl1.2-dev libraspberrypi-dev
    # ilclient is part of libraspberrypi-doc, but not included on all distros
    if hasPackage rbp-bootloader-osmc; then getDepends rbp-userland-src-osmc; else getDepends libraspberrypi-doc; fi
}

function sources_xroar() {
    gitPullOrClone "$md_build" http://www.6809.org.uk/git/xroar.git rasppi
    # fix up missing includes/libraries
    sed -i "s|-I/opt/vc/include/interface/vcos/pthreads|-I/opt/vc/include/interface/vcos/pthreads -I/opt/vc/include/interface/vmcs_host/linux|g" configure
    sed -i "s/-lopenmaxil/-lopenmaxil -lpthread -lm/g" configure
}

function build_xroar() {
    cd /opt/vc/src/hello_pi/libs/ilclient
    make clean
    make
    cd "$md_build"
    ./configure --enable-rasppi --prefix="$md_inst"
    make clean
    make
    md_ret_require="$md_build/xroar"
}

function install_xroar() {
    make install
}

function configure_xroar() {
    mkRomDir "dragon32"
    mkRomDir "coco"

    mkdir -p "$md_inst/share/xroar"
    ln -snf "$biosdir" "$md_inst/share/xroar/roms"

    addSystem 1 "$md_id-dragon32" "dragon32" "$md_inst/bin/xroar -machine dragon32 -run %ROM%"
    addSystem 1 "$md_id-coco" "coco" "$md_inst/bin/xroar -machine coco -run %ROM%"

    __INFMSGS+=("For emulator $md_id you need to copy system/basic roms such as d32.rom (Dragon 32) and bas13.rom (CoCo) to '$biosdir'.")
}
