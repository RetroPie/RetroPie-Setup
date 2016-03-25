#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="giana"
rp_module_desc="Giana's Return"
rp_module_menus="4+"
rp_module_flags="nobin !x86 !mali"

function install_giana() {
    wget http://www.retroguru.com/gianas-return/gianas-return-v.latest-raspberrypi.zip -O "$md_inst/giana.zip"
    unzip -n "$md_inst/giana.zip" -d "$md_inst"
    rm "$md_inst/giana.zip"
}

function configure_giana() {
    addPort "$md_id" "giana" "Giana's Return" "pushd $md_inst; $md_inst/giana_rpi; popd"

    chmod +x "$md_inst/giana_rpi"
}
