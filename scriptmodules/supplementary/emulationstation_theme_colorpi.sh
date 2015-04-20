#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
#

rp_module_id="esthemecolorpi"
rp_module_desc="EmulationStation Theme Color Pi"
rp_module_menus="2+"
rp_module_flags="nobin"

function install_esthemecolorpi() {
    # download themes archive
    wget -O colorpi.zip "http://downloads.petrockblock.com/retropiearchives/colorpi.zip"

    mkdir -p "/etc/emulationstation/themes"

    # remove old simple theme files
    rmDirExists "/etc/emulationstation/themes/colorpi"

    # unzip archive to tmp folder
    unzip colorpi.zip -d /etc/emulationstation/themes/

    # delete zi parchive
    rm colorpi.zip

    chmod -R go+xr /etc/emulationstation/themes/
}
