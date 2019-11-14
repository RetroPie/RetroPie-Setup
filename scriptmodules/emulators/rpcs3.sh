#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="rpcs3"
rp_module_desc="PS3 emulator RPCS3"
rp_module_help="ROM Extensions: .ps3\n\nCopy your PS3 roms to $romdir/ps3"
rp_module_licence="GPL2 https://github.com/RPCS3/rpcs3/blob/master/LICENSE"
rp_module_section="exp"
rp_module_flags="!arm"

function install_bin_rpcs3() {
    wget --content-disposition https://rpcs3.net/latest-appimage
    rpcs3_bin=`ls rpcs3*AppImage`  
    mv $rpcs3_bin $md_inst/$rpcs3_bin
    chmod +x $md_inst/$rpcs3_bin
    mkdir $romdir/ps3
    touch $romdir/ps3/launch.ps3
}

function configure_rpcs3() {
    mkRomDir "ps3"
    moveConfigDir "$home/.config/rpcs3" "$md_conf_root/ps3"

    addEmulator 0 "$md_id-nogui" "ps3" "$md_inst/$rpcs3_bin %ROM% --nogui"
    addEmulator 1 "$md_id" "ps3" "$md_inst/$rpcs3_bin"

    addSystem "ps3"
}
